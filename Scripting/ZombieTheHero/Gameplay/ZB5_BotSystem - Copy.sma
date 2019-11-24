#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

new g_MaxPlayers, g_Kicked = true;

public plugin_init() 
{	
register_forward(FM_CmdStart, "fw_CmdStart")
g_MaxPlayers = get_maxplayers()
}

public plugin_cfg()
{
if(zbs_is_scenario())
return
	
CheckBots()	
}

public RuningTime()
{
if(zp_core_get_players_count(0, 3) == 0 && g_Kicked)
{
log_amx("FALSE !!!!!!!!!!")	
g_Kicked = false
return
}
if(GetPlayersCount() > 0 && !g_Kicked)
{
log_amx("TRUE !!!!!!!!!!")	
g_Kicked = true
return
}
CheckBots()
}
/*public Kick()server_cmd("sypb kick")
public client_connectex(id)
{
if(is_user_bot(id))
return;
	
set_task(10.0, "Kick")
}*/
public client_putinserver(id)
{
CheckBots()
}
public client_disconnected(id)
{
CheckBots()
}
public CheckBots()
{
static Bots
Bots = (22 - zp_core_get_players_count(0, 3))
Bots = Bots - 10

server_cmd("sypb_quota %i", Bots)

if(!g_Kicked)
{
server_cmd("sypb kickall")
log_amx("kicked !!!!!!!!!!")
g_Kicked = true
}
}
public fw_CmdStart(id, Handle)
{
static Buttons; Buttons = get_uc(Handle,UC_Buttons);
if(is_user_bot(id) && !zp_GameStart())
{
Buttons &= ~IN_ATTACK;
set_uc(Handle , UC_Buttons, Buttons);
return FMRES_SUPERCEDE;
}
return FMRES_IGNORED;
} 

GetPlayersCount()
{
static iAlive, id

for (id = 1; id <= g_MaxPlayers; id++)
{

if (is_user_connected(id) && !is_user_bot(id))
iAlive++
}

return iAlive;
}
