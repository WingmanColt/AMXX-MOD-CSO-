#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <ZBS_Weapons>

#define MAX_CLIENTS 32
#define SOUND_BUY "items/9mmclip1.wav"

new g_iCurrentAmmoMax[ MAX_CLIENTS +1 ];
new g_iCurrentAmmoCost[ MAX_CLIENTS +1 ];
new g_iCurrentAmmoValue[ MAX_CLIENTS +1 ];

new g_iForward_DummyResult;
new g_iForward_BuyAmmoPrimary;
new g_iForward_BuyAmmoSecondary;

new const MAXBPAMMO[ ] =
{
-1, 52, -1, 90, 1, 32, 1, 100, 90, 1,
120, 100, 100, 90, 90, 90, 100, 120,
30, 120, 200, 32, 90, 120, 90, 2,
35, 90, 90, -1, 100
};

new const OFFSET_AMMO[ ] =
{
0, 385, 0, 378, 0, 381, 0, 382,
380, 0, 386, 383, 382, 380, 380, 380,
382, 386, 377, 386, 379, 381, 380, 386,
378, 0, 384, 380, 378, 0, 383
};

new const BUYAMMO[ ] =
{
-1, 13, -1, 30, -1, 8, -1, 12,
30, -1, 30, 50, 12, 30, 30, 30,
12, 30, 10, 30, 30, 8, 30, 30,
30, -1, 7, 30, 30, -1, 50
};

new const AMMOTYPE[ ][ ] =
{
"", "357sig", "", "762nato", "", "buckshot", "", "45acp",
"556nato", "", "9mm", "57mm", "45acp", "556nato", "556nato", "556nato",
"45acp", "9mm", "338magnum", "9mm", "556natobox", "buckshot", "556nato", "9mm",
"762nato", "", "50ae", "556nato", "762nato", "", "57mm"
};

new const AMMOCOST[ ] =
{
0, // N--
50, // p228
0, // N--
80, // scout
0, // N--
65, // xm1014
0, // N--
25, // mac10
60, // aug
0, // N--
30, // elite
50, // fiveseven
25, // ump45
60, // sg550
60, // galil
60, // famas
25, // usp
30, // glock18
125, // awp
30, // mp5navy
60, // m249
65, // m3
60, // m4a1
30, // tmp
80, // g3sg1
0, // N--
40, // deagle
60, // sg552
80, // ak47
0, // N--
50 // p90
};

public plugin_natives( )
{
register_native("SetAmmoValue", "native_set_ammo_value", 1);
register_native("SetAmmoCost", "native_set_ammo_cost", 1);
register_native("SetAmmoMax", "native_set_ammo_max", 1);
}

public plugin_init()
{
register_clcmd("buyammo1", "Command_BuyAmmoPrimary");
register_clcmd("buyammo2", "Command_BuyAmmoSecondary");
g_iForward_BuyAmmoPrimary = CreateMultiForward( "buy_primary_ammo", ET_CONTINUE, FP_CELL );
g_iForward_BuyAmmoSecondary = CreateMultiForward( "buy_secondary_ammo", ET_CONTINUE, FP_CELL );
}

public Command_BuyAmmoPrimary( iPlayer )
{
if ( !is_user_alive( iPlayer ) )
return PLUGIN_HANDLED;

static szWeapons[ 32 ], iNum, i, iCurrentAmmo, iWeapon, bRefilled;
iNum = 0;

bRefilled = false;
get_user_weapons( iPlayer, szWeapons, iNum );

for ( i = 0; i < iNum; i++ )
{
iWeapon = szWeapons[ i ];

if ( ( 1<<iWeapon ) & 1509749160 )
{
g_iCurrentAmmoValue[ iPlayer ] = BUYAMMO[ iWeapon ];
g_iCurrentAmmoCost[ iPlayer ] = AMMOCOST[ iWeapon ];
g_iCurrentAmmoMax[ iPlayer ] = MAXBPAMMO[ iWeapon ];

ExecuteForward( g_iForward_BuyAmmoPrimary, g_iForward_DummyResult, iPlayer );

if (cs_get_user_money( iPlayer ) < g_iCurrentAmmoCost[ iPlayer ] )
{
if ( get_pdata_int( iPlayer, OFFSET_AMMO[ iWeapon ], 5 ) < g_iCurrentAmmoMax[ iPlayer ] )
{
UTIL_TextMsg( iPlayer, "#Not_Enough_Money" );
UTIL_BlinkAcct( iPlayer, 5 );
}

return PLUGIN_HANDLED;
}

iCurrentAmmo = get_pdata_int( iPlayer, OFFSET_AMMO[ iWeapon ], 5 );

ExecuteHamB( Ham_GiveAmmo, iPlayer, g_iCurrentAmmoValue[ iPlayer ], AMMOTYPE[ iWeapon ], g_iCurrentAmmoMax[ iPlayer ] );

if ( get_pdata_int( iPlayer, OFFSET_AMMO[ iWeapon ], 5 ) - iCurrentAmmo > 0 ) 
bRefilled = true;

break;
}
}

if ( !bRefilled ) 
{
for ( i = 0; i < iNum; i++ )
{
iWeapon = szWeapons[ i ];

if ( ( 1<<iWeapon ) & 1509749160 )
UTIL_TextMsg( iPlayer, "#Cannot_Carry_Anymore" );
}

return PLUGIN_HANDLED;
}

cs_set_user_money( iPlayer, cs_get_user_money( iPlayer ) - g_iCurrentAmmoCost[ iPlayer ] );
emit_sound( iPlayer, CHAN_ITEM, SOUND_BUY, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );

return PLUGIN_HANDLED;
}

public Command_BuyAmmoSecondary( iPlayer )
{
if ( !is_user_alive( iPlayer ) )
return PLUGIN_HANDLED;
if(!zbs_had_m79(iPlayer))
{
static szWeapons[ 32 ], iNum, i, iCurrentAmmo, iWeapon, bRefilled;
iNum = 0;

bRefilled = false;
get_user_weapons( iPlayer, szWeapons, iNum );

for ( i = 0; i < iNum; i++ )
{
iWeapon = szWeapons[ i ]

if((1<<iWeapon ) & 67308546 )
{
g_iCurrentAmmoValue[ iPlayer ] = BUYAMMO[ iWeapon ];
g_iCurrentAmmoCost[ iPlayer ] = AMMOCOST[ iWeapon ];
g_iCurrentAmmoMax[ iPlayer ] = MAXBPAMMO[ iWeapon ];

ExecuteForward( g_iForward_BuyAmmoSecondary, g_iForward_DummyResult, iPlayer );

if (cs_get_user_money( iPlayer ) < g_iCurrentAmmoCost[ iPlayer ] )
{
if ( get_pdata_int( iPlayer, OFFSET_AMMO[ iWeapon ], 5 ) < g_iCurrentAmmoMax[ iPlayer ] )
{
UTIL_TextMsg( iPlayer, "#Not_Enough_Money" );
UTIL_BlinkAcct( iPlayer, 5 );
}

return PLUGIN_HANDLED;
}
iCurrentAmmo = get_pdata_int( iPlayer, OFFSET_AMMO[ iWeapon ], 5 );
ExecuteHamB( Ham_GiveAmmo, iPlayer, g_iCurrentAmmoValue[ iPlayer ], AMMOTYPE[ iWeapon ], g_iCurrentAmmoMax[ iPlayer ] );
if ( get_pdata_int( iPlayer, OFFSET_AMMO[ iWeapon ], 5 ) - iCurrentAmmo > 0 )
bRefilled = true;

break;
}
}

if ( !bRefilled ) 
{
for ( i = 0; i < iNum; i++ )
{
iWeapon = szWeapons[ i ];

if ( ( 1<<iWeapon ) & 67308546 )
UTIL_TextMsg( iPlayer, "#Cannot_Carry_Anymore" );
}

return PLUGIN_HANDLED;
}
}
cs_set_user_money( iPlayer, cs_get_user_money( iPlayer ) - g_iCurrentAmmoCost[ iPlayer ] );
emit_sound( iPlayer, CHAN_ITEM, SOUND_BUY, VOL_NORM, ATTN_NORM, 0, PITCH_NORM );
return PLUGIN_HANDLED;
}

public native_set_ammo_value( iPlayer, iValue )
g_iCurrentAmmoValue[ iPlayer ] = iValue;

public native_set_ammo_cost( iPlayer, iValue )
g_iCurrentAmmoCost[ iPlayer ] = iValue;

public native_set_ammo_max( iPlayer, iValue )
g_iCurrentAmmoMax[ iPlayer ] = iValue;

UTIL_TextMsg( iPlayer, szMessage[] )
{
message_begin( MSG_ONE, 77, _,  iPlayer );
write_byte( 4 );
write_string( szMessage );
message_end( );
}

UTIL_BlinkAcct( iPlayer, BlinkAmt )
{
message_begin( MSG_ONE_UNRELIABLE, 104, _, iPlayer );
write_byte( BlinkAmt );
message_end( );
}
