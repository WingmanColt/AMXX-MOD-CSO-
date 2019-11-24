#include <amxmodx>
#include <fakemeta>

#pragma semicolon 1

#define DISTANCE 120

new g_iTeam[33];
new bool:g_bSolid[33];
new bool:g_bHasSemiclip[33];
new Float:g_fOrigin[33][3];

new bool:g_bSemiclipEnabled;

new g_iForwardId[3];
new g_iMaxPlayers;
new g_iCvar[3];

public plugin_init( )
{

g_iCvar[0] = register_cvar( "semiclip_enabled", "1" );
g_iCvar[1] = register_cvar( "semiclip_teamclip", "0" );
g_iCvar[2] = register_cvar( "semiclip_transparancy", "0" );

register_forward( FM_ClientCommand, "fwdClientCommand" );

if( get_pcvar_num( g_iCvar[0] ) )
{
g_iForwardId[0] = register_forward( FM_PlayerPreThink, "fwdPlayerPreThink" );
g_iForwardId[1] = register_forward( FM_PlayerPostThink, "fwdPlayerPostThink" );

g_bSemiclipEnabled = true;
}
else
g_bSemiclipEnabled = false;

g_iMaxPlayers = get_maxplayers( );
}

public fwdPlayerPreThink( plr )
{
static id, last_think;

if( last_think > plr )
{
for( id = 1 ; id <= g_iMaxPlayers ; id++ )
{
if( is_user_alive( id ) )
{
if( get_pcvar_num( g_iCvar[1] ) )
g_iTeam[id] = get_user_team( id );

g_bSolid[id] = pev( id, pev_solid ) == SOLID_SLIDEBOX ? true : false;
pev( id, pev_origin, g_fOrigin[id] );
}
else
g_bSolid[id] = false;
}
}

last_think = plr;

if( g_bSolid[plr] )
{
for( id = 1 ; id <= g_iMaxPlayers ; id++ )
{
if( g_bSolid[id] && get_distance_f( g_fOrigin[plr], g_fOrigin[id] ) <= DISTANCE && id != plr )
{
if( get_pcvar_num( g_iCvar[1] ) && g_iTeam[plr] != g_iTeam[id] )
return FMRES_IGNORED;

set_pev( id, pev_solid, SOLID_NOT );
g_bHasSemiclip[id] = true;
}
}
}

return FMRES_IGNORED;
}

public fwdPlayerPostThink( plr )
{
static id;

for( id = 1 ; id <= g_iMaxPlayers ; id++ )
{
if( g_bHasSemiclip[id] )
{
set_pev( id, pev_solid, SOLID_SLIDEBOX );
g_bHasSemiclip[id] = false;
}
}
}

// is there a better way to detect changings of g_iCvar[0]?
public fwdClientCommand( plr )
{
// use the forwards just when needed, for good performance
if( !get_pcvar_num( g_iCvar[0] ) && g_bSemiclipEnabled )
{
unregister_forward( FM_PlayerPreThink, g_iForwardId[0] );
unregister_forward( FM_PlayerPostThink, g_iForwardId[1] );

g_bSemiclipEnabled = false;
}
else if( get_pcvar_num( g_iCvar[0] ) && !g_bSemiclipEnabled )
{
g_iForwardId[0] = register_forward( FM_PlayerPreThink, "fwdPlayerPreThink" );
g_iForwardId[1] = register_forward( FM_PlayerPostThink, "fwdPlayerPostThink" );

g_bSemiclipEnabled = true;
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
