#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_maxspeed_api>
#include <cs_player_models_api>
#include <cs_weap_restrict_api>
#include <cs_weap_models_api>
#include <zp50_core>

const OFFSET_LINUX = 5
const OFFSET_PAINSHOCK = 108
#define flag_get(%1,%2) (%1 & (1 << (%2 & 31)))
#define flag_get_boolean(%1,%2) (flag_get(%1,%2) ? true : false)
#define flag_set(%1,%2) %1 |= (1 << (%2 & 31))
#define flag_unset(%1,%2) %1 &= ~(1 << (%2 & 31))
#define TASK_TIME_REMOVE 8345843
#define TASK_TIME_WAIT 53495734
#define TASK_SOUND 12002
#define TASK_HUD 13312

new const Sound[2][] = {"ZPlague/zombi_pre_idle_1.wav","ZPlague/zombi_pre_idle_2.wav"}
new g_IsNemesis, g_can_skill1[33], g_skill1[33], 
g_hud_skill1, g_msgSetFOV, g_MaxPlayers
public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
RegisterHam(Ham_TakeDamage, "player", "Player_TakeDamage", 1)
register_forward(FM_ClientDisconnect, "fw_ClientDisconnect_Post", 1)
register_clcmd("drop", "cmd_drop")
g_hud_skill1 = CreateHudSyncObj()
g_msgSetFOV = get_user_msgid("SetFOV")
g_MaxPlayers = get_maxplayers()
}
public plugin_natives()
{
register_library("zp50_core")
register_native("zp_class_nemesis_get", "native_class_nemesis_get")
register_native("zp_class_nemesis_set", "native_class_nemesis_set")
register_native("zp_class_nemesis_get_count", "native_class_nemesis_get_count")
}
public show_skill_hud(id)
{
id -= TASK_HUD
if(is_user_alive(id) && flag_get(g_IsNemesis, id))
show_hud_fastrun(id)
}
public show_hud_fastrun(id)
{
static Color[3], Text[64]
if(g_can_skill1[id]){
Color[0] = 200; Color[1] = 200; Color[2] = 200	
formatex(Text, sizeof(Text),"[G] - PainShockFree (Ready)")	
}else{
Color[0] = 200; Color[1] = 0; Color[2] = 0	
formatex(Text, sizeof(Text),"[G] - PainShockFree (Wait)")	
}
set_hudmessage(Color[0], Color[1], Color[2], -1.0, 0.125, 0, 0.0, 1.0)
ShowSyncHudMsg(id, g_hud_skill1, Text)	
}
public client_disconnect(id)
{
if (flag_get(g_IsNemesis, id))
{
fm_set_rendering(id)
}
}

public fw_ClientDisconnect_Post(id)
{
flag_unset(g_IsNemesis, id)
}

// Ham Take Damage Forward
public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;

if (flag_get(g_IsNemesis, attacker) && !zp_core_is_zombie(victim))
{
if (inflictor == attacker)
{
if(zp_class_survivor_get(victim))
{
SetHamParamFloat(4, damage * 2.0)
}else{
ExecuteHamB(Ham_Killed, victim, attacker, 0)
}
return HAM_HANDLED;
}
}
return HAM_IGNORED;
}
public Player_TakeDamage(victim, inflictor, attacker)
{
if (victim == attacker || !is_user_alive(attacker))
return HAM_IGNORED;
	
if (flag_get(g_IsNemesis, victim))
{
if(g_skill1[victim])set_pdata_float(victim, OFFSET_PAINSHOCK, 5.0, OFFSET_LINUX)
}
return HAM_HANDLED;
}
public zp_fw_grenade_frost_pre(id)
{
// Prevent frost for Nemesis
if (flag_get(g_IsNemesis, id))
return PLUGIN_HANDLED;
return PLUGIN_CONTINUE;
}
public zp_fw_core_spawn_post(id)
{
if (flag_get(g_IsNemesis, id))
{
fm_set_rendering(id)
flag_unset(g_IsNemesis, id)
}
}

public zp_fw_core_cure(id, attacker)
{
if (flag_get(g_IsNemesis, id))
{
fm_set_rendering(id)
flag_unset(g_IsNemesis, id)
}
cs_reset_player_view_model(id, CSW_KNIFE)
cs_reset_player_weap_model(id, CSW_KNIFE)
cs_set_player_weap_restrict(id, false)
}

public zp_fw_core_infect_post(id, attacker)
{
if (!flag_get(g_IsNemesis, id))
return;

g_can_skill1[id] = 1
g_skill1[id] = 0
set_user_health(id, 100000)
set_user_gravity(id, 0.7)
cs_reset_player_maxspeed(id)
cs_set_player_maxspeed_auto(id, 1.40)
cs_set_player_model(id, "ZP_Nemesis")
cs_set_player_view_model(id, CSW_KNIFE, "models/ZPlague/Claws/v_knife_nemesis.mdl")
cs_set_player_weap_model(id, CSW_KNIFE, "")
fm_set_rendering(id, kRenderFxGlowShell, 200, 10, 10, kRenderNormal, 0)
set_task(1.0, "show_skill_hud", id+TASK_HUD, _, _, "b")	
}
public cmd_drop(id)
{
if(is_user_alive(id) && flag_get(g_IsNemesis, id))
skill1_handle(id)
}
public skill1_handle(id)
{	
if(g_can_skill1[id] && !g_skill1[id] && flag_get(g_IsNemesis, id))
{
g_can_skill1[id] = 0
g_skill1[id] = 1
cs_reset_player_maxspeed(id)
set_user_gravity(id, 0.5)
cs_reset_player_maxspeed(id)
cs_set_player_maxspeed_auto(id, 1.70)	
emit_sound(id, CHAN_STATIC, "ZPlague/zombi_pressure.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_fov(id, 105)
set_task(2.0, "Berserk_HeartBeat", id+TASK_SOUND)
set_task(5.0, "stop_skill1", id+TASK_TIME_REMOVE)
}
}
public stop_skill1(id)
{
id -= TASK_TIME_REMOVE

if(is_user_alive(id) && flag_get(g_IsNemesis, id))
{	
g_can_skill1[id] = 0
g_skill1[id] = 0
set_fov(id)
set_user_gravity(id, 0.7)
cs_reset_player_maxspeed(id)
cs_set_player_maxspeed_auto(id, 1.40)
set_task(20.0, "reset_skill1", id+TASK_TIME_WAIT)
}
}

public reset_skill1(id)
{
id -= TASK_TIME_WAIT

if(is_user_alive(id) && flag_get(g_IsNemesis, id))
{
remove_task(id+TASK_TIME_WAIT)
g_can_skill1[id] = 1
g_skill1[id] = 0
}	
}
public Berserk_HeartBeat(id)
{
id -= TASK_SOUND

if(is_user_alive(id) && flag_get(g_IsNemesis, id))
{
if(g_skill1[id])
{	
emit_sound(id, CHAN_STATIC, Sound[random_num(0,1)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
set_task(2.0, "Berserk_HeartBeat", id+TASK_SOUND)
}
}
}
public native_class_nemesis_get(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_connected(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return -1;
}

return flag_get_boolean(g_IsNemesis, id);
}

public native_class_nemesis_set(plugin_id, num_params)
{
new id = get_param(1)

if (!is_user_alive(id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Invalid Player (%d)", id)
return false;
}

if (flag_get(g_IsNemesis, id))
{
log_error(AMX_ERR_NATIVE, "[ZP] Player already a nemesis (%d)", id)
return false;
}

flag_set(g_IsNemesis, id)
zp_core_force_infect(id)
return true;
}

public native_class_nemesis_get_count(plugin_id, num_params)
{
return GetNemesisCount();
}
GetNemesisCount()
{
new iNemesis, id

for (id = 1; id <= g_MaxPlayers; id++)
{
if (is_user_alive(id) && flag_get(g_IsNemesis, id))
iNemesis++
}

return iNemesis;
}
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
new Float:RenderColor[3];
RenderColor[0] = float(r);
RenderColor[1] = float(g);
RenderColor[2] = float(b);

set_pev(entity, pev_renderfx, fx);
set_pev(entity, pev_rendercolor, RenderColor);
set_pev(entity, pev_rendermode, render);
set_pev(entity, pev_renderamt, float(amount));

return 1
}
stock set_fov(id, num = 95)
{
if(!is_user_connected(id))
return

message_begin(MSG_ONE_UNRELIABLE, g_msgSetFOV, {0,0,0}, id)
write_byte(num)
message_end()
}
