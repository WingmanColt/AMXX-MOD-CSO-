#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

new HamHook: forwardIDRain,
HamHook: forwardIDSound;

public plugin_init(){
DisableHamForward( forwardIDRain );
DisableHamForward( forwardIDSound );
}

public plugin_precache(){
engfunc( EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_snow") );

forwardIDRain	=	RegisterHam( Ham_Spawn , "env_rain" , "fwSpawnedRain" , 1 );
forwardIDSound	=	RegisterHam( Ham_Spawn , "ambient_generic" , "fwSpawnedSound" , 1 );
}

public fwSpawnedRain( iEnt ){

if( !pev_valid( iEnt ) ){
return HAM_IGNORED;
}

engfunc( EngFunc_RemoveEntity,  iEnt );

return HAM_IGNORED;
}

public fwSpawnedSound( iEnt ){

if( !pev_valid( iEnt ) ){
return HAM_IGNORED;
}

new szMessage[ 256 ];

pev( iEnt , pev_message , szMessage , charsmax( szMessage ) );

if( !equal( szMessage , "ambience/rain.wav" ) ){
return HAM_IGNORED;
}

engfunc( EngFunc_RemoveEntity,  iEnt );

return HAM_IGNORED;
}

public client_connect( id ){
client_cmd( id , "cl_weather 1" );
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
