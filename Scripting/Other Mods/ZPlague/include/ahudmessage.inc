#if defined _ahudmessage_included
#endinput
#endif

#define _ahudmessage_included

#include <amxmodx>

stock __ahud_color2;
stock __ahud_x2;
stock __ahud_y2;
stock __ahud_effect2;
stock __ahud_fxtime2;
stock __ahud_holdtime2;
stock __ahud_fadeintime2;
stock __ahud_fadeouttime2;
stock __ahud_reliable2;

stock set_ahudmessage( red = 200, green = 200, blue = 200, Float:x2 = -1.0, Float:y2 = 0.65, effects2 = 0, Float:fxtime2 = 5.0, Float:holdtime2 = 7.0, Float:fadeintime2 = 0.1, Float:fadeouttime2 = 1.5, bool:reliable2 = true )
{
#define clamp_byte(%1)       ( clamp( %1, 0, 200 ) )
#define pack_color(%1,%2,%3) ( %3 + ( %2 << 8 ) + ( %1 << 15 ) )

__ahud_color2       = pack_color( clamp_byte( red ), clamp_byte( green ), clamp_byte( blue ) );
__ahud_x2           = _:x2;
__ahud_y2           = _:y2;
__ahud_effect2      = effects2;
__ahud_fxtime2      = _:fxtime2;
__ahud_holdtime2    = _:holdtime2;
__ahud_fadeintime2  = _:fadeintime2;
__ahud_fadeouttime2 = _:fadeouttime2;
__ahud_reliable2    = _:reliable2;

return 1;
}

stock show_ahudmessage( index, const message[], any:... )
{
new buffer[ 128 ];
new numArguments = numargs();

if( numArguments == 2 )
{
send_ahudMessage( index, message );
}
else if( index || numArguments == 3 )
{
vformat( buffer, charsmax( buffer ), message, 3 );
send_ahudMessage( index, buffer );
}
else
{
new playersList[ 32 ], numPlayers;
get_players( playersList, numPlayers, "ch" );

if( !numPlayers )
{
return 0;
}

new Array:handleArrayML = ArrayCreate();

for( new i = 2, j; i < numArguments; i++ )
{
if( getarg( i ) == LANG_PLAYER )
{
while( ( buffer[ j ] = getarg( i + 1, j++ ) ) ) {}
j = 0;

if( GetLangTransKey( buffer ) != TransKey_Bad )
{
ArrayPushCell( handleArrayML, i++ );
}
}
}

new size = ArraySize( handleArrayML );

if( !size )
{
vformat( buffer, charsmax( buffer ), message, 3 );
send_ahudMessage( index, buffer );
}
else
{
for( new i = 0, j; i < numPlayers; i++ )
{
index = playersList[ i ];

for( j = 0; j < size; j++ )
{
setarg( ArrayGetCell( handleArrayML, j ), 0, index );
}

vformat( buffer, charsmax( buffer ), message, 3 );
send_ahudMessage( index, buffer );
}
}

ArrayDestroy( handleArrayML );
}

return 1;
}
stock send_ahudMessage( const index, const message[] )
{
message_begin( __ahud_reliable2 ? ( index ? MSG_ONE : MSG_ALL ) : ( index ? MSG_ONE_UNRELIABLE : MSG_BROADCAST ), SVC_DIRECTOR, _, index );
{
write_byte( strlen( message ) + 31 );
write_byte( DRC_CMD_MESSAGE );
write_byte( __ahud_effect2 );
write_long( __ahud_color2 );
write_long( __ahud_x2 );
write_long( __ahud_y2 );
write_long( __ahud_fadeintime2 );
write_long( __ahud_fadeouttime2 );
write_long( __ahud_holdtime2 );
write_long( __ahud_fxtime2 );
write_string( message );
}
message_end();
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
