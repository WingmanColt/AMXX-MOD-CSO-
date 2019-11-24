#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

new g_spawned[33]
public plugin_init() 
{	
register_forward(FM_CmdStart, "fw_CmdStart")
}

public plugin_cfg()
{
if(zbs_is_scenario())
return
	
CheckBots()	
}
public Kick()server_cmd("sypb kick")
public client_putinserver(id)
{
if(is_user_bot(id))
return;
	
g_spawned[id] = false 	
}
public zp_fw_core_spawn_post(id)
{
if(is_user_bot(id))
return;
	
if(g_spawned[id])
return;

set_task(5.0, "Kick")		
g_spawned[id] = true
}
public client_disconnected(id)
{
if(is_user_bot(id))
return;

if(!g_spawned[id])
return;
		
server_cmd("sypb_add")
g_spawned[id] = false 
}
public CheckBots()
{
static Bots
Bots = (20 - zp_core_get_players_count(0, 3))
Bots = Bots - 10

server_cmd("sypb_quota %i", Bots)
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
