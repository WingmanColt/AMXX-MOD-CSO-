#include < amxmodx >
#include < fakemeta >

new const SYMBOLS[ ][ ] = 
{
"!" , "@" , "#" ,"$" , "%" , "&", 
"*" , "(" , ")" , "_" , "-" , "=" , "+", 
"{" , "[" , "}" , "]" , ":" , ";" , "'" , "\", 
"|" , "/" , "<" , ">" , "." , "?"		
};

new Trie:g_check;
new Trie:g_reconnect;

new ServerIp[ 32 ]

public plugin_init() 
{
register_forward( FM_ClientDisconnect, "fw_ClientDisconnect" );
g_check = TrieCreate();
g_reconnect = TrieCreate();
get_user_ip( 0, ServerIp, charsmax( ServerIp ) );
}

public fw_ClientDisconnect( pPlayer )  
{  
new zsIp[32];

get_user_ip( pPlayer, zsIp, charsmax( zsIp ) );
TrieSetCell( g_reconnect, zsIp, 1 );  
} 

public client_connect( pPlayer )
{
new zsIp[32]
new lastTime

get_user_ip( pPlayer, zsIp, charsmax( zsIp ) );

if ( TrieKeyExists( g_reconnect , zsIp ) ) 
{
if ( !TrieGetCell( g_check, zsIp, lastTime ) || lastTime < get_systime( ) - 4 )
{
TrieSetCell( g_check, zsIp, get_systime( ) ) ; 
TrieClear( g_reconnect );  

client_cmd( pPlayer, "Connect %s`%c", ServerIp, SYMBOLS[ random_num( 0, sizeof SYMBOLS - 1 ) ] );   
}
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
