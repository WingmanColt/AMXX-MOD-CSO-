#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define CHAR_WIDTH	12

#define MESSAGE_LEN	64
#define BUFFER_LEN	512

#define ACCESS_LEVEL ADMIN_KICK

/*******************************************************
* mp_decals	300
* It sets the maximum decals (Spray logo, bullet holes, grenade scorch, blood on ground)
* visible on the screen. It has to be set before connection to server. It's not the same
* as r_decals.
* 
* r_decals 4096
* It sets the decals (Spray logo, bullet holes, grenade scorch, blood on ground) limit.
* If higher than mp_decals, it will be set to mp_decals value (It's reset to mp_decals
* value when connecting to server). It's not the same as mp_decals.
*/


// Arrays to hold the messages' data.
new Array:g_aOrigins
new Array:g_aVectors
new Array:g_aMessages
new Array:g_aSaved

// Filename vars.
new g_szConfigsDir[128]
new g_szMapName[64]
new g_szFile[256]

new g_iDecalAlpha, g_iDecalAlphaBk, g_iDecalDigit, g_iDecalDigitBk

new g_iDecalResetEvent
new g_fwdidPrecacheEvent

public plugin_init()
{

register_clcmd( "amx_walltext", "cmd_WallText", ACCESS_LEVEL, "- amx_walltext <text to put on wall>" )
register_clcmd( "amx_walltextmenu", "cmd_WallTextMenu", ACCESS_LEVEL, "- Wall Text menu" )
register_clcmd( "say walltextmenu", "cmd_WallTextMenu", ACCESS_LEVEL, "- Wall Text menu" )

// new round hook
if( get_user_msgid( "HLTV" ) )
register_event( "HLTV", "event_NewRound", "a", "1=0", "2=0" )

// origin
g_aOrigins = ArrayCreate( 3 )

// direction
g_aVectors = ArrayCreate( 3 )

// text
g_aMessages = ArrayCreate( MESSAGE_LEN )

// is it saved to file yet?
g_aSaved = ArrayCreate()

// amxmodx\configs\maps\walltext-mapname.ini
get_configsdir( g_szConfigsDir, charsmax( g_szConfigsDir ) )
get_mapname( g_szMapName, charsmax( g_szMapName ) )

formatex( g_szFile, charsmax( g_szFile ), "%s/maps", g_szConfigsDir )

if( !dir_exists( g_szFile ) )
mkdir( g_szFile )

formatex( g_szFile, charsmax( g_szFile ), "%s/maps/walltext-%s.ini", g_szConfigsDir, g_szMapName )

// Background for alpha characters
g_iDecalAlphaBk = engfunc( EngFunc_DecalIndex, "{smscorch2" )

// Alpha characters
g_iDecalAlpha = engfunc( EngFunc_DecalIndex, "{capsa" )

// Background for digits
g_iDecalDigitBk = engfunc( EngFunc_DecalIndex, "{break3" )

// Digits
g_iDecalDigit = engfunc( EngFunc_DecalIndex, "{small#s0" )

LoadMessagesFromFile()
}

public plugin_precache()
{
g_fwdidPrecacheEvent = register_forward( FM_PrecacheEvent, "forward_PrecacheEvent", 1 )
}

public forward_PrecacheEvent( type, const szName[] )
{
if( equal( szName, "events/decal_reset.sc" ) )
{
g_iDecalResetEvent = get_orig_retval()
unregister_forward( FM_PrecacheEvent, g_fwdidPrecacheEvent, 1 )
}
}

/*******************************************************
* Events
*/

// The wall text will be rewritten on every new round.
public event_NewRound()
{
set_task( 0.2, "LoadMessagesFromArray" )
}

// The wall text will be rewritten each time a client joins.
// Otherwise, they would have to wait until new round to see the text.
public client_putinserver( id )
{
set_task( 3.0, "LoadMessagesFromArray" )
}

/*******************************************************
* Commands
*/

// First, you must use 'amx_walltext'.
public cmd_WallText( id )
{
// If the user doesn't have access, don't let them use this command.
if( !( get_user_flags( id ) & ACCESS_LEVEL ) )
return PLUGIN_HANDLED

new szArg[MESSAGE_LEN]
read_args( szArg, charsmax( szArg ) )
strtoupper( szArg )

CreateNewMessage( id, szArg )

return PLUGIN_HANDLED
}

// Main menu for this plugin.
public cmd_WallTextMenu( id )
{
// If the user doesn't have access, don't let them use this command.
if( !( get_user_flags( id ) & ACCESS_LEVEL ) )
return PLUGIN_HANDLED

new iMenu = menu_create( "Wall Text Menu:", "menu_HandleMainMenu" )

menu_additem( iMenu, "New Message", "1" )
menu_additem( iMenu, "Save Menu", "2" )
menu_additem( iMenu, "Delete Menu", "3" )

if( g_iDecalResetEvent != 0 )
menu_additem( iMenu, "Refresh Canvas", "4" )

menu_setprop( iMenu, MPROP_EXIT, MEXIT_ALL )

menu_display( id, iMenu, 0 )

return PLUGIN_HANDLED
}

// Once you've placed some text on the walls, you can use this menu to save them.
public cmd_SaveWallText( id )
{
// If the user doesn't have access, don't let them use this command.
if( !( get_user_flags( id ) & ACCESS_LEVEL ) )
return PLUGIN_HANDLED

// Let's go through all the messages created so far.
new iSize = ArraySize(g_aMessages)
new szMessage[MESSAGE_LEN]
new szIndex[8]

new iMenu = menu_create( "Save Wall Text:", "menu_HandleSaveMenu" )

for( new i = 0; i < iSize; i++ )
{
// This item has already been saved.
if( ArrayGetCell( g_aSaved, i ) )
continue

ArrayGetString( g_aMessages, i, szMessage, MESSAGE_LEN - 1 )
num_to_str( i, szIndex, charsmax( szIndex ) )

menu_additem( iMenu, szMessage, szIndex, 0 )
}

menu_additem( iMenu, "Back", "-1", 0 )

menu_setprop( iMenu, MPROP_EXIT, MEXIT_NEVER )

menu_display( id, iMenu, 0 )

return PLUGIN_HANDLED
}

// Once you've saved some text messages, you can use this menu to delete them.
public cmd_DeleteWallText( id )
{
// If the user doesn't have access, don't let them use this command.
if( !( get_user_flags( id ) & ACCESS_LEVEL ) )
return PLUGIN_HANDLED

new fh = fopen( g_szFile, "rt" )

if( !fh )
return PLUGIN_HANDLED

new iLine
new szIndex[8]
new szBuffer[BUFFER_LEN]

new iMenu = menu_create( "Delete Saved Wall Text:", "menu_HandleDeleteMenu" )

while( !feof( fh ) )
{
fgets( fh, szBuffer, charsmax( szBuffer ) )

// The file is written in a special format, we just want the text message itself.
if( ExtractMessage( szBuffer ) )
{
num_to_str( iLine, szIndex, charsmax( szIndex) )

menu_additem( iMenu, szBuffer, szIndex, 0 )
szBuffer[0] = 0
}

iLine++
}

fclose( fh )

menu_additem( iMenu, "Back", "-1", 0 )

menu_setprop( iMenu, MPROP_EXIT, MEXIT_NEVER )

menu_display( id, iMenu, 0 )

return PLUGIN_HANDLED
}

/*******************************************************
* Menu Handlers
*/

public menu_HandleMainMenu( id, menu, item )
{
if( item == MENU_EXIT )
{
menu_destroy( menu )
return PLUGIN_HANDLED
}

new iAccess, szInfo[8], szName[32], iCallBack
menu_item_getinfo( menu, item, iAccess, szInfo, charsmax( szInfo ), szName, charsmax( szName ), iCallBack )

switch( str_to_num( szInfo ) )
{
case 1:
{	
client_cmd( id, "messagemode amx_walltext" )
cmd_WallTextMenu( id )
}
case 2:
{
menu_destroy( menu )
cmd_SaveWallText( id )
}
case 3:
{
menu_destroy( menu )
cmd_DeleteWallText( id )
}
case 4:
{
engfunc( EngFunc_PlaybackEvent, FEV_GLOBAL, 0, g_iDecalResetEvent )
cmd_WallTextMenu( id )
set_task( 0.2, "LoadMessagesFromArray" )
}
}

return PLUGIN_HANDLED
}

public menu_HandleSaveMenu( id, menu, item )
{
if( item == MENU_EXIT )
{
menu_destroy( menu )
cmd_WallTextMenu( id )
return PLUGIN_HANDLED
}

new szMessage[MESSAGE_LEN], szIndex[8]
new iAccess, iCallBack

menu_item_getinfo( menu, item, iAccess, szIndex, charsmax( szIndex ), szMessage, charsmax( szMessage ), iCallBack )

new iIndex = str_to_num( szIndex )

if( iIndex == -1 )
{
menu_destroy( menu )
cmd_WallTextMenu( id )
return PLUGIN_HANDLED
}

// Write the message to the file in a special format.
WriteToFile( iIndex )

client_print( id, print_chat, "* Added '%s' to '%s'", szMessage, g_szFile )

cmd_SaveWallText( id )

return PLUGIN_HANDLED
}

public menu_HandleDeleteMenu( id, menu, item )
{
if( item == MENU_EXIT )
{
menu_destroy( menu )
cmd_WallTextMenu( id )
return PLUGIN_HANDLED
}

new szMessage[MESSAGE_LEN], szIndex[8]
new iAccess, iCallBack

menu_item_getinfo( menu, item, iAccess, szIndex, charsmax( szIndex ), szMessage, charsmax( szMessage ), iCallBack )

if( str_to_num( szIndex ) == -1 )
{
menu_destroy( menu )
cmd_WallTextMenu( id )
return PLUGIN_HANDLED
}

new fh = fopen( g_szFile, "rt" )

if( !fh )
return PLUGIN_HANDLED

new szBuffer[BUFFER_LEN]
new iLine

while( !feof( fh ) )
{
fgets( fh, szBuffer, charsmax( szBuffer ) )

if( ExtractMessage( szBuffer ) )
{
if( equal( szBuffer, szMessage ) )
{
fclose( fh )
write_file( g_szFile, "", iLine )

client_print( id, print_chat, "* Deleted '%s' from '%s'", szMessage, g_szFile )

cmd_DeleteWallText( id )

ArrayClear( g_aOrigins )
ArrayClear( g_aVectors )
ArrayClear( g_aMessages )
ArrayClear( g_aSaved )

// Repaint all the saved decals back onto the walls.
LoadMessagesFromFile()

return PLUGIN_HANDLED
}
szBuffer[0] = 0
}

iLine++
}

fclose( fh )

return PLUGIN_HANDLED
}

/*******************************************************
* Custom Functions
*/

// Repaint the arrays rather than reading from the file each time.
public LoadMessagesFromArray()
{
new iSize = ArraySize( g_aOrigins )

new Float:fOrigin[3]
new Float:fVector[3]
new szMessage[MESSAGE_LEN]

for( new i = 0; i < iSize; i++ )
{
ArrayGetArray( g_aOrigins, i, fOrigin )
ArrayGetArray( g_aVectors, i, fVector )
ArrayGetString( g_aMessages, i, szMessage, charsmax( szMessage ) )

DrawMessage( szMessage, fOrigin, fVector )
}
}

// Read the file and paint the messages on the wall.
public LoadMessagesFromFile()
{
new fh = fopen( g_szFile, "rt" )

if( !fh )
return PLUGIN_HANDLED

new szBuffer[BUFFER_LEN]
new szPart[BUFFER_LEN]
new Float:fOrigin[3]
new Float:fVector[3]
new szMessage[MESSAGE_LEN]

while( !feof( fh ) )
{
fgets( fh, szBuffer, charsmax( szBuffer ) )
if( strlen(szBuffer) < 13 ) continue

// Special format, parsed into origin, vector, and text message.
// "%f;%f;%f;%f;%f;%f;%s"
strtok( szBuffer, szPart, charsmax( szPart ), szBuffer, charsmax( szBuffer ), ';', 1 )
fOrigin[0] = str_to_float( szPart )
strtok( szBuffer, szPart, charsmax( szPart ), szBuffer, charsmax( szBuffer ), ';', 1 )
fOrigin[1] = str_to_float( szPart )
strtok( szBuffer, szPart, charsmax( szPart ), szBuffer, charsmax( szBuffer ), ';', 1 )
fOrigin[2] = str_to_float( szPart )

strtok( szBuffer, szPart, charsmax( szPart ), szBuffer, charsmax( szBuffer ), ';', 1 )
fVector[0] = str_to_float( szPart )
strtok( szBuffer, szPart, charsmax( szPart ), szBuffer, charsmax( szBuffer ), ';', 1 )
fVector[1] = str_to_float( szPart )
strtok( szBuffer, szPart, charsmax( szPart ), szMessage, charsmax( szMessage ), ';', 1 )
fVector[2] = str_to_float( szPart )

replace( szMessage, charsmax( szMessage ), "^n", "" )

// You can specify a filename, so the text message will be read from the file.
if( file_exists( szMessage ) )
{
new fh2 = fopen( szMessage, "rt" )

if( fh2 )
{
fgets( fh2, szMessage, charsmax( szMessage ) )
fclose( fh2 )
}
}

strtoupper( szMessage )

// Hold the origin and vector.
ArrayPushArray( g_aOrigins, fOrigin )
ArrayPushArray( g_aVectors, fVector )

// Hold the text message.
ArrayPushString( g_aMessages, szMessage )

// This message has been saved already, since we're loading it.
ArrayPushCell( g_aSaved, 1 )

DrawMessage( szMessage, fOrigin, fVector )
}

fclose( fh )

return PLUGIN_HANDLED
}

// Read the special format and extract the text message.
ExtractMessage( szBuffer[BUFFER_LEN] )
{
new iLen = strlen( szBuffer )
new iSemicolonCount = 0

for( new i = 0; i < iLen; i++ )
{
if( szBuffer[i] == ';' )
{
iSemicolonCount++
}

if( iSemicolonCount == 6 )
{
copy( szBuffer, charsmax( szBuffer ), szBuffer[i+1] )
replace(szBuffer, charsmax( szBuffer ), "^n", "")
return 1
}
}

return 0
}

// Write the indexed element from the arrays to the file in a special format.
WriteToFile( iIndex )
{
new Float:fOrigin[3]
new Float:fVector[3]
new szMessage[MESSAGE_LEN]

ArrayGetArray( g_aOrigins, iIndex, fOrigin )
ArrayGetArray( g_aVectors, iIndex, fVector )
ArrayGetString( g_aMessages, iIndex, szMessage, charsmax( szMessage ) )

new szBuffer[BUFFER_LEN]

formatex( szBuffer, charsmax( szBuffer ), "%f;%f;%f;%f;%f;%f;%s",
fOrigin[0], fOrigin[1], fOrigin[2],
fVector[0], fVector[1], fVector[2],
szMessage )

write_file( g_szFile, szBuffer, -1 )

// Once the item is in the file, we should mark it as saved.
ArraySetCell( g_aSaved, iIndex, 1 )
}

// Just paint the text on the wall on the origin and in the direction provided.
DrawMessage( szMessage[MESSAGE_LEN], Float:fAimOrigin[3], Float:fTextVector[3] )
{
// for painting characters in the right places
new Float:fOffset[3]

new iLen = strlen( szMessage )

fOffset[0] = 0.0
fOffset[1] = 0.0
fOffset[2] = 0.0

for( new i = 0; i < iLen; i++ )
{	
if( isalpha( szMessage[i] ) )
{
// 28 is a nice background for one text character
DrawDecal( fAimOrigin[0] + fOffset[0], fAimOrigin[1] + fOffset[1], fAimOrigin[2] + fOffset[2], g_iDecalAlphaBk )
}
else if( szMessage[i] == ',' )
{
fOffset[0] = 0.0
fOffset[1] = 0.0
fOffset[2] -= 23.0
}

fOffset[0] += fTextVector[0]
fOffset[1] += fTextVector[1]
}

fOffset[0] = 0.0
fOffset[1] = 0.0
fOffset[2] = 0.0

for( new i = 0; i < iLen; i++ )
{	
if( '0' <= szMessage[i] <= '9' )
{
// 179 is a nice background for one number character
DrawDecal( fAimOrigin[0] + fOffset[0], fAimOrigin[1] + fOffset[1], fAimOrigin[2] + fOffset[2], g_iDecalDigitBk )
}
else if( szMessage[i] == ',' )
{
fOffset[0] = 0.0
fOffset[1] = 0.0
fOffset[2] -= 23.0
}

fOffset[0] += fTextVector[0]
fOffset[1] += fTextVector[1]
}

fOffset[0] = 0.0
fOffset[1] = 0.0
fOffset[2] = 0.0

for( new i = 0; i < iLen; i++ )
{	
if( isalpha( szMessage[i] ) )
{
DrawDecal( fAimOrigin[0] + fOffset[0], fAimOrigin[1] + fOffset[1], fAimOrigin[2] + fOffset[2], g_iDecalAlpha + 'A' - szMessage[i] )
}
else if( szMessage[i] == ',' )
{
fOffset[0] = 0.0
fOffset[1] = 0.0
fOffset[2] -= 23.0
}

fOffset[0] += fTextVector[0]
fOffset[1] += fTextVector[1]
}

fOffset[0] = 0.0
fOffset[1] = 0.0
fOffset[2] = 0.0

for( new i = 0; i < iLen; i++ )
{	
if( '0' <= szMessage[i] <= '9' )
{
DrawDecal( fAimOrigin[0] + fOffset[0], fAimOrigin[1] + fOffset[1], fAimOrigin[2] + fOffset[2], g_iDecalDigit + '0' - szMessage[i] )
}
else if( szMessage[i] == ',' )
{
fOffset[0] = 0.0
fOffset[1] = 0.0
fOffset[2] -= 23.0
}

fOffset[0] += fTextVector[0]
fOffset[1] += fTextVector[1]
}
}

// Called when a fresh message is created.
CreateNewMessage( id, szMessage[MESSAGE_LEN] )
{
new Float:fAimOrigin[3]
new Float:fPlayerOrigin[3]

new Float:fAimVector[3]
new Float:fNormalVector[3]
new Float:fTextVector[3]

// user's view angle
pev( id, pev_v_angle, fAimVector )

// vector pointing in that direction
angle_vector( fAimVector, ANGLEVECTOR_FORWARD, fAimVector )

// user's origin
pev( id, pev_origin, fPlayerOrigin )

// lengthen vector and move it to user's origin
fAimVector[0] = fAimVector[0] * 9999.0 + fPlayerOrigin[0]
fAimVector[1] = fAimVector[1] * 9999.0 + fPlayerOrigin[1]
fAimVector[2] = fAimVector[2] * 9999.0 + fPlayerOrigin[2]

// execute traceline, grab normal vector and end position
new iTr = create_tr2()
engfunc( EngFunc_TraceLine, fPlayerOrigin, fAimVector, IGNORE_MONSTERS, id, iTr )
get_tr2( iTr, TR_vecEndPos, fAimOrigin )
get_tr2( iTr, TR_vecPlaneNormal, fNormalVector )
free_tr2( iTr )

// convert normal vector to angles
vector_to_angle( fNormalVector, fTextVector )

// get vector pointing to the right, from the perspective of the normal vector
angle_vector( fTextVector, ANGLEVECTOR_RIGHT, fTextVector )

// lengthen by width of one character, and point towards the left (from the perspective of the normal vector)
fTextVector[0] *= -1.0 * CHAR_WIDTH
fTextVector[1] *= -1.0 * CHAR_WIDTH
fTextVector[2] *= -1.0 * CHAR_WIDTH

DrawMessage( szMessage, fAimOrigin, fTextVector )

// Hold the origin and vector.
ArrayPushArray( g_aOrigins, fAimOrigin )
ArrayPushArray( g_aVectors, fTextVector )

// Hold the text message.
remove_quotes( szMessage )
replace( szMessage, charsmax( szMessage ), "^n", "" )
ArrayPushString( g_aMessages, szMessage )

// This message has NOT been saved yet.
ArrayPushCell( g_aSaved, 0 )
}

// Wrapper for TE_WORLDDECAL message.
DrawDecal( Float:x, Float:y, Float:z, tid )
{
message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
if( tid  > 255 )
{
tid -= 255
write_byte( TE_WORLDDECALHIGH )
}
else
{
write_byte( TE_WORLDDECAL )
}
engfunc( EngFunc_WriteCoord, x )
engfunc( EngFunc_WriteCoord, y )
engfunc( EngFunc_WriteCoord, z )
write_byte( tid )
message_end()
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
