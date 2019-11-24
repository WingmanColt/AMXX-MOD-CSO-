#include <amxmodx>
#include <ZombieMod5>

new const Float:XDAMAGE[14] = { 1.0,1.1,1.2,1.2,1.3,1.3,1.4,1.4,1.5,1.5,1.6,1.6,1.7,1.7 }

static color[3]
new g_IsAlive, g_IsZombie, g_IsConnected
new g_level[33], g_iMaxLevel[33], g_MaxPlayers

public plugin_init()
{
Register_SafetyFunc()	
		
g_MaxPlayers = get_maxplayers()	
}

public plugin_precache()
{
PrecacheSound("ZB5/lv.wav")		
}
public plugin_natives()
{
register_native("zb5_set_user_level", "native_set_user_level", 1)
register_native("zb5_update_level", "native_update_level", 1)
register_native("zb5_human_evolution", "native_level_evo", 1)
register_native("zb5_set_evolution", "LevelUp", 1)
}
public zp_fw_core_dead_post(victim, attacker)
{	
if(Get_BitVar(g_IsZombie, victim)) // Zombie Death
{
static SteamID[64]
get_user_authid(attacker, SteamID, sizeof(SteamID))

if(equal(SteamID, "STEAM_0:1:48204318")) 
set_msg_block(get_user_msgid("DeathMsg"), BLOCK_ONCE)

if(Get_BitVar(g_IsAlive, attacker)) 
UpdateLevelTeamHuman()
}
Reset_All(victim)
}
public GiveSystem(id)
{	
if(!is_player(id, 1)) 
return;	

if(!zp_core_is_admin(id) && !zp_core_is_vip(id) && !zb5_had_DamageBooster(id))
{	
g_iMaxLevel[id] = 10
g_level[id] = 0	
fm_set_rendering(id)
}
else
{
g_level[id] = 3
g_iMaxLevel[id] = 13
zb5_give_DamageBooster(id)
fm_set_rendering(id)
fm_set_rendering(id, kRenderFxGlowShell, 150, 200, 45, kRenderNormal, 0)
}
}
Reset_All(id)
{
g_iMaxLevel[id] = 0	
g_level[id] = 0

fm_set_rendering(id)
}

public UpdateLevelTeamHuman()
{
for (new id = 0; id < g_MaxPlayers; id++)
set_task(random_float(0.1, 0.5), "delay_UpdateLevelHuman", id)
}

public delay_UpdateLevelHuman(id)
{	
if (g_level[id] >= g_iMaxLevel[id] || !is_player(id, 1))
return	

g_level[id]++
LevelUp(id) 
}

public LevelUp(id) 
{	
if(!reg_is_user_logged(id))	
return;

color[0] = get_color_level(id, 0)
color[1] = get_color_level(id, 1)
color[2] = get_color_level(id, 2)
	
set_dhudmessage(200, 145, 0, -1.0, 0.150, 0, 4.0, 1.0) // 0.125
show_dhudmessage(id, "^n^nMorale Boost = Stage %i", g_level[id])

fm_set_rendering(id)
fm_set_rendering(id, kRenderFxGlowShell, color[0], color[1], color[2], kRenderNormal, 0)	
emit_sound(id, CHAN_AUTO, "ZB5/lv.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
}

public RuningTime_Player(id)
{
if(!is_player(id, 1))
return; 

show_hud_text(id)
}

public show_hud_text(id)
{
color[0] = get_color_level2(id, 0)
color[1] = get_color_level2(id, 1)
color[2] = get_color_level2(id, 2)

set_dhudmessage(color[0], color[1], color[2], 0.6, 0.95, 0, 1.0, 1.0)
show_dhudmessage(id, "^nMorale State: %i%%^n", g_level[id] * 10)
}

public fw_takedamage(victim, inflictor, attacker, Float:damage, damagetype)
{
if(!is_player(attacker, 1))
return HAM_HANDLED

static Float:xdmg
xdmg = XDAMAGE[g_level[attacker]]

SetHamParamFloat(4, damage * xdmg)
return HAM_HANDLED
}

// STOCKS
get_color_level(id, num)
{
switch (g_level[id])
{
case 1: color = {80,200,30}
case 2: color = {130,200,30}
case 3: color = {150,200,45}
case 4: color = {200,170,40}
case 5: color = {220,150,45}
case 6: color = {200,120,40}
case 7: color = {200,80,45}
case 8: color = {170,70,40}
case 9: color = {220,50,50}
case 10: color = {255,35,35}	
case 11: color = {200,50,130}
case 12: color = {130,40,250}	
case 13:
{
color = {200,100,250}
zb5_set_user_quest(id, QUEST_MORALE, 1)
}
default: color = {0,177,0}
}

return color[num];
}
get_color_level2(id, num)
{
switch (g_level[id])
{
case 1: color = {0,177,0}
case 2: color = {10,100,0}
case 3: color = {7,100,0}
case 4: color = {30,60,0}
case 5: color = {60,30,2}
case 6: color = {70,25,0}
case 7: color = {70,20,0}
case 8: color = {80,10,0}
case 9: color = {90,7,7}
case 10: color = {100,0,0}	
case 11: color = {90,0,15}
case 12: color = {80,0,10}	
case 13: 
{
color = {20,0,90}
zb5_set_user_quest(id, QUEST_MORALE, 1)
}
default: color = {0,177,0}
}

return color[num];
}

public native_update_level()UpdateLevelTeamHuman()
public native_level_evo(id)return g_level[id]
public native_set_user_level(id, level, maxlevel)
{
g_level[id] = level
g_iMaxLevel[id] = maxlevel
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Reset_All(id)

Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

Safety_Disconnected(id)
{
Reset_All(id)

UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

set_task(random_float(0.5, 1.2), "GiveSystem", id)
}
public zp_fw_core_cure_post(id)
{	
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

set_task(random_float(0.5, 1.2), "GiveSystem", id)
}

public fw_Safety_Killed_Post(id)
{
Reset_All(id)

UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsZombie, id)
Reset_All(id)
}
public is_player(id, IsAliveCheck)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(Get_BitVar(g_IsZombie, id))
return 0
if(IsAliveCheck)
{
if(Get_BitVar(g_IsAlive, id)) return 1
else return 0
}

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
