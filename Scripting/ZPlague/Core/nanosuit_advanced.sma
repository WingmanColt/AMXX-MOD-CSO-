#include <amxmodx>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#include <zp50_core>

#define REFIRE_PISTOLS	0.85
#define REFIRE_KNIFE 0.75
#define REFIRE_M3 0.70
#define REFIRE_SNIPERS 0.60
#define RELOAD_RATIO 0.78
#define SH_CARTRAGE_RATIO 2
#define SH_AMMO_MSG_AMMOID 5

// Delay of energy recharge after ability usage (time in 0.1 seconds)
#define DELAY_STR_JUMP 5
#define DELAY_STR_STAB 5
#define DELAY_STR_SHOT 2
#define DELAY_STR_G_THROW 3
#define DELAY_ARM_DAMAGE 5
#define DELAY_SPD_RUN 4
#define DELAY_SPD_FAST_ATTACK 10
#define DELAY_SPD_FAST_RELOAD 4
#define DELAY_SPD_SH_RELOAD 2
#define DELAY_CLK_DELAY	3
#define DELAY_CLK_FORCED 5
#define ENERGY_CROUCH 1.2
#define CRITICAL_EXTRA_ADD 10.0
#define CRIT_SPEED 1.0
#define MAX_SPEED 1.6

#define OFFSET_WEAPON_OWNER 41
#define OFFSET_WEAPON_ID 43
#define OFFSET_WEAPON_NEXT_PRIMARY_ATTACK 46
#define OFFSET_WEAPON_NEXT_SEC_ATTACK 47
#define OFFSET_WEAPON_IDLE_TIME	48
#define OFFSET_WEAPON_PRIMARY_AMMO_TYPE	49
#define OFFSET_WEAPON_CLIP 51
#define OFFSET_WEAPON_IN_RELOAD	54
#define OFFSET_PLAYER_NEXT_ATTACK 83
#define OFFSET_PLAYER_PAIN_SHOCK 108
#define OFFSET_PLAYER_ITEM_ACTIVE 373
#define OFFSET_PLAYER_AMMO_SLOT0 376
#define EXTRA_OFFSET_PLAYER_LINUX 5
#define EXTRA_OFFSET_WEAPON_LINUX 4

#define SPEED_WATER_MUL_CONSTANT 0.7266666
#define SPEED_CROUCH_MUL_CONSTANT 0.3333333
#define DMG_CS_KNIFE_BULLETS (1 << 12 | 1 << 0)
#define NANO_FLAG_INWATER (1<<1)
#define NANO_FLAG_CROUCHED (1<<0)

#define TASK_ENERGY 11
#define TASK_WARNED 22

#define is_user_player(%1) (1 <= %1 <= glb_maxplayers)
#define Ham_Player_ResetMaxSpeed Ham_Item_PreFrame
new const UNREGISTERED_WEAPONS_BITSUM  = ((1<<2) | (1<<CSW_HEGRENADE) | (1<<CSW_FLASHBANG) | (1<<CSW_SMOKEGRENADE) | (1<<CSW_C4))
new const NO_RELOAD_WEAPONS_BITSUM =((1<<CSW_M3) | (1<<CSW_XM1014) | (1<<CSW_KNIFE))
new const ON_LAND_CONST	=( FL_ONGROUND | FL_ONTRAIN | FL_PARTIALGROUND | FL_INWATER | FL_SWIM )
new const ON_WATER_CONST=( FL_INWATER | FL_SWIM )
new const Float:vec_hit_multi[] ={1.0, 4.0, 1.0, 1.25, 1.0, 1.0, 0.75, 0.75, 0.0}

stock const Float:wpn_reload_delay[CSW_P90+1] ={0.00, 2.70, 0.00, 2.00, 0.00, 0.55, 0.00, 3.15, 3.30, 0.00, 4.50, 2.70, 3.50, 3.35, 2.45, 3.30, 2.70, 2.20, 2.50, 2.63, 4.70, 0.55, 3.05, 2.12, 3.50, 0.00, 2.20, 3.00, 2.45, 0.00, 3.40}
stock const wpn_reload_anim[CSW_P90+1] = {-1,  5, -1, 3, -1, 6, -1, 1, 1, -1, 14, 4, 2, 3, 1, 1, 13, 7, 4, 1, 3, 6, 11, 1, 3, -1, 4, 1, 1, -1, 1}
stock const wpn_max_clip[CSW_P90+1] = {-1,  13, -1, 10,  1, 7, 1, 30, 30,  1, 30, 20, 25, 30, 35, 25, 12, 20, 10, 30, 100, 8 , 30, 30, 20,  2, 7, 30, 30, -1, 50}
stock const Float:wpn_act_speed[CSW_P90+1] = {0.0, 250.0, 0.0, 260.0, 250.0, 240.0, 250.0, 250.0, 240.0, 250.0, 250.0, 250.0, 250.0, 210.0, 240.0, 240.0, 250.0, 250.0, 210.0, 250.0, 220.0, 230.0, 230.0, 250.0, 210.0, 250.0, 250.0, 235.0, 221.0, 250.0, 245.0 }

enum NanoModes
{
NANO_STREN = 0,
NANO_ARMOR = 1,
NANO_SPEED = 2,
NANO_CLOAK = 3,	
NANO_STABILITY = 4,
NANO_ARMOR2 = 5
}
new const NanoScreenColor[NanoModes][] =
{
{200, 0,   0},
{30,  50,  230},
{150, 150, 0},
{150, 150, 150},
{5, 200, 5},	
{30,  50,  230}
}
enum NanoSpdMode
{
SPEED_MAXIMUM,
SPEED_CRITICAL,
SPEED_NORMAL
}
enum NanoSpeed
{
SPD_STILL = 0,
SPD_VSLOW,
SPD_SLOW,
SPD_NORMAL,
SPD_FAST
}

enum NanoSpeedScreen
{
SPD_SCR_STILL = 0,
SPD_SCR_VSLOW,
SPD_SCR_SLOW,
SPD_SCR_NORMAL,
SPD_SCR_FAST
}
enum KnifeState
{
KNIFE_NOT = 0,
KNIFE_FIRST_ATTACK,
KNIFE_SECOND_ATTACK
}

new glb_maxplayers, cl_is_thrown[33] = {0, ...}
new cl_nn_weapon[33], bool:cl_nn_online[33], Float:cl_nn_defense[33]
new Float:cl_nn_damage_time[33], cl_nn_has[33], Float:g_nn_energy[33]
new NanoSpdMode:cl_nn_sp_status[33], cl_nn_invisible[33]
new NanoSpeedScreen:cl_nn_scr_speed[33], cl_nn_energy2[33], g_nn_health[33]
new NanoSpeed:cl_nn_speed[33], Float:cl_nn_energy[33], Float:cl_nn_controlling[33]
new bool:cl_added_velocity[33] = {false, ...}
new NanoModes:cl_nn_mode[33] = {NANO_ARMOR, ...}
new bool:cl_nn_critical[33], cl_nn_block_recharge[33]
new KnifeState:cl_nn_st_knife[33] = {KNIFE_NOT, ...}
new Float:cl_nn_punch[33][3], cl_nn_shotgun_ammo[33]
new bool:cl_nn_actual_shot[33] = {false, ...}
new bool:cl_nn_st_jump[32 + 1] = {false, ...}
new nd_menu[33], nd_hud_sync, nd_hud_sync2, nd_msg_ammox, g_screen, nd_ent_monitor

public plugin_init()
{
register_logevent("event_startround", 2, "1=Round_Start")		
register_event("CurWeapon", "event_active_weapon", "be","1=1")	
register_event("DeathMsg", "event_death", "ae")	

nd_ent_monitor = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if (nd_ent_monitor)
{
set_pev(nd_ent_monitor, pev_classname, "screen_status")
set_pev(nd_ent_monitor, pev_nextthink, get_gametime() + 0.1)
register_forward(FM_Think, "fw_screenthink")
}

new weapon_name[24]
for (new i=CSW_P228;i<=CSW_P90;i++)
{
if (!(UNREGISTERED_WEAPONS_BITSUM & 1<<i) && get_weaponname(i, weapon_name, charsmax(weapon_name)))
{
RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_primary_attack")
RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "fw_primary_attack_post",1)
if (!(NO_RELOAD_WEAPONS_BITSUM & (1<<i)))
{
RegisterHam(Ham_Weapon_Reload, weapon_name, "fw_reload_post", 1)
}
else
{
if (i != CSW_KNIFE)
{
RegisterHam(Ham_Item_Deploy, weapon_name, "fw_shotgun_deploy", 1)
RegisterHam(Ham_Weapon_Reload, weapon_name, "fw_special_reload_post", 1)
}
}
}
}
RegisterHam(Ham_Spawn,"player","fw_spawn",1)
RegisterHam(Ham_Player_ResetMaxSpeed,"player","fw_resetmaxspeed",1)
RegisterHam(Ham_TraceAttack, "player", "fw_traceattack")
RegisterHam(Ham_TakeDamage, "player", "fw_takedamage")
RegisterHam(Ham_TakeDamage, "player", "fw_takedamage_post", 1)

register_forward(FM_PlayerPreThink, "fw_prethink")
register_forward(FM_PlayerPostThink, "fw_postthink")	
register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_CmdStart, "fw_CmdStart")

nd_hud_sync = CreateHudSyncObj(1)
nd_hud_sync2 = CreateHudSyncObj(2)
nd_msg_ammox = get_user_msgid("AmmoX")
g_screen = get_user_msgid("ScreenFade")
glb_maxplayers = global_get(glb_maxClients)
register_message(get_user_msgid("TextMsg"), "MessageTextMsg");

register_clcmd("say /nanosuit", "nanosuit_menu_show")
register_clcmd("say nanosuit", "nanosuit_menu_show")
register_clcmd("nanosuit", "nanosuit_menu_show")
register_clcmd("bindmenu", "Bind_Menu")
register_clcmd("say bindmenu", "Bind_Menu")
register_clcmd("get_stren", "nanosuit_str_mode")
register_clcmd("get_armor", "nanosuit_arm_mode")
register_clcmd("get_speed", "nanosuit_spd_mode")
register_clcmd("get_cloak", "nanosuit_clo_mode")
register_clcmd("get_energy", "set_con_energy")
register_clcmd("take_energy", "take_con_energy")
server_cmd("sv_maxspeed 99999.0")
}
public plugin_natives()
{
register_native("zp_boost_energy", "nanosuit_booster", 1)
register_native("zp_nanosuit_effect", "native_set_user_nanosuit", 1)
register_native("zp_bindmenu", "Bind_Menu", 1)
register_native("zp_nano_cloakmode", "Cloak", 1)
}
public nanosuit_booster(id)
{
if(cl_nn_energy2[id])
return	

cl_nn_energy2[id] = true	
g_nn_energy[id] += 100.0
g_nn_health[id] = 350
fm_set_user_health(id, 350)	
}
public client_connect(id)
{
client_cmd(id,"cl_sidespeed 400")
client_cmd(id,"cl_forwardspeed 400")
client_cmd(id,"cl_backspeed 400")
client_cmd(id, "bind alt nanosuit")
client_cmd(id, "bind ] get_energy")
client_cmd(id, "bind [ take_energy")
}
public client_putinserver(id)
{	
cl_nn_controlling[id] = 50.0
g_nn_energy[id] = 100.0
g_nn_health[id] = 250
cl_nn_actual_shot[id] = false
cl_nn_mode[id] = NANO_ARMOR2
nanosuit_reset(id)
}
public client_disconnected(id)
{
cl_nn_has[id] = false	
cl_nn_mode[id] = NANO_ARMOR
cl_added_velocity[id] = false
fm_set_rendering(id)
nanosuit_reset(id)
nano_reset(id)
}
public event_startround()
{
new players[32], count, id
get_players(players,count,"ad")

for (new i=0;i<count;i++)
{
id = players[i]

if(!is_user_connected(id))
return

if(!is_user_alive(id))
return

native_set_user_nanosuit(id, 1)
}
}

public zp_fw_core_infect_post(id, attacker)
{		
if(zp_core_is_zombie(id))
{				
native_set_user_nanosuit(id, 0)
}
else if(zp_class_nemesis_get(id) && zp_class_assassin_get(id))
{				
native_set_user_nanosuit(id, 0)
}
}
public zp_fw_core_cure_post(id)
{
if(zp_class_survivor_get(id) && zp_class_sniper_get(id))
{		
native_set_user_nanosuit(id, 0)
}
else if(!zp_class_survivor_get(id) && !zp_class_sniper_get(id))
{		
if (!cl_nn_energy2[id])
g_nn_health[id] = 250
else
g_nn_health[id] = 350	
fm_set_user_health(id, g_nn_health[id])	
native_set_user_nanosuit(id, 1)
}
}
public fw_spawn(id)
{
if(!is_user_alive(id))
return;

if(zp_core_is_zombie(id))
native_set_user_nanosuit(id, 0)
else
{	
native_set_user_nanosuit(id, 1)
cl_nn_energy[id] = 100.0
}
}
public Cloak(id)
{
return cl_nn_mode[id] == NANO_CLOAK;
}
public native_set_user_nanosuit(id, mode)
{
switch(mode)
{
case 0:
{
if(!zp_class_nemesis_get(id) && !zp_class_assassin_get(id))
fm_set_rendering(id)	
cl_nn_has[id] = false
nano_reset(id)
}	
case 1:
{
fm_set_rendering(id)	
cl_nn_has[id] = true
//cl_nn_mode[id] = NANO_ARMOR2
nanosuit_reset(id)
set_task(0.1,"set_energy",id+TASK_ENERGY, _, _,"b")
ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
}
}
}
public MessageTextMsg()
{
new szArg2[32];
get_msg_arg_string(2, szArg2, 31);
if (!equal(szArg2, "#Game_unknown_command"))
return PLUGIN_CONTINUE;

return PLUGIN_HANDLED;
}
public fw_CmdStart(id, uc_handle, seed)
{
if(!is_user_alive(id) || zp_core_is_zombie(id))	
return;

static CurButton; CurButton = get_uc(uc_handle, UC_Buttons)

if(CurButton & IN_USE && !nd_menu[id])
{
CurButton &= ~IN_USE
set_uc(uc_handle, UC_Buttons, CurButton)
	
nanosuit_menu_show(id)
}
}

public nanosuit_menu_create(id)
{
if(!is_user_alive(id) || zp_core_is_zombie(id))	
return PLUGIN_HANDLED

static text[200]
format(text,199,"\ySkyNET System \d|\rNano \ySuit\d|")
nd_menu[id] = menu_create(text, "nanosuit_menu_choose")

format(text,199,"MAXIMUM STRENGHT \d(High Damage)")
menu_additem(nd_menu[id], text)
format(text,199,"Maximum Armor \d(Protection)")
menu_additem(nd_menu[id], text)
format(text,199,"Maximum Speed \d(Quickness)")
menu_additem(nd_menu[id], text)
format(text,199,"Cloak Engaged \d(Invisiblity)")
menu_additem(nd_menu[id], text)
format(text,199,"Maximum Stability \d(Recovery)")

menu_additem(nd_menu[id], text)
menu_setprop(nd_menu[id], MPROP_EXIT, MEXIT_ALL)   

return PLUGIN_HANDLED  
}

public nanosuit_menu_show(id)
{
if(!is_user_alive(id))	
return PLUGIN_HANDLED

if(!cl_nn_has[id])
{
client_print(id, print_center,"You don't have Nanosuit!")
return PLUGIN_HANDLED
}

client_cmd(id,"spk ZPlague/NanoSuit/nanosuit_menu.wav")
nanosuit_menu_create(id)
menu_display(id, nd_menu[id])

return PLUGIN_HANDLED  
}


public nanosuit_menu_choose(id, menu, item)
{	
if(!is_user_alive(id) || zp_core_is_zombie(id))	
return PLUGIN_HANDLED

if (item != -3 && cl_nn_mode[id] != NanoModes:item)
{
if (cl_nn_mode[id] == NANO_SPEED)
{
if (cl_nn_energy[id] > 10)
cl_nn_sp_status[id] = SPEED_MAXIMUM
if (10 >= cl_nn_energy[id] > 0)
cl_nn_sp_status[id] = SPEED_CRITICAL
if (0 >= cl_nn_energy[id])
cl_nn_sp_status[id] = SPEED_NORMAL

switch (cl_nn_sp_status[id])
{
case SPEED_MAXIMUM: fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) / MAX_SPEED) // Maxim Speed
case SPEED_CRITICAL: fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) / CRIT_SPEED) // SP Critic
}
}

if (NanoModes:item == NANO_SPEED)
{
if (cl_nn_energy[id] > 10)//Critical Energy
cl_nn_sp_status[id] = SPEED_MAXIMUM
if (10 >= cl_nn_energy[id] > 0)//Critical Energy
cl_nn_sp_status[id] = SPEED_CRITICAL
if (0 >= cl_nn_energy[id])
cl_nn_sp_status[id] = SPEED_NORMAL

switch (cl_nn_sp_status[id])
{
case SPEED_MAXIMUM: fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * MAX_SPEED) // Maxim Speed
case SPEED_CRITICAL: fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * CRIT_SPEED) // SP Critic
}
}

set_nano_mode(id,NanoModes:item)
}

if(is_user_connected(id))
{
menu_destroy(menu)
return PLUGIN_HANDLED 
}

nd_menu[id] = false
return PLUGIN_HANDLED
}

/* ===================================================
[Events]
==================================================== */
public event_active_weapon(id)
{
if(!is_user_alive(id))
return;		
new weapon; weapon = read_data(2)

if (weapon != CSW_KNIFE)
cl_nn_st_knife[id] = KNIFE_NOT

if (weapon != CSW_HEGRENADE && weapon != CSW_FLASHBANG && weapon != CSW_SMOKEGRENADE && zp_core_is_zombie(id))
{
native_set_user_nanosuit(id, 0)
}
cl_nn_weapon[id] = weapon
}
public event_death()
{
static victim; victim = read_data(2)
if(cl_nn_has[victim])
{
cl_nn_mode[victim] = NANO_ARMOR2	
cl_nn_has[victim] = false
nano_reset(victim)
}
return;
}

/* ===================================================
[Fakemeta forwards (fake!)]
==================================================== */
public fw_postthink(id)
{
if(!is_user_alive(id) || zp_core_is_zombie(id))
return FMRES_IGNORED
	
if (cl_nn_st_jump[id])
{
static Float:vecforce[3]
pev(id,pev_velocity,vecforce)
vecforce[2] = 550.0
set_pev(id,pev_velocity,vecforce)
set_nano_energy(id, cl_nn_energy[id] - 25, DELAY_STR_JUMP)
cl_nn_st_jump[id] = false
}
return FMRES_IGNORED
}

public fw_prethink(id)
{		
if(!is_user_alive(id) || zp_core_is_zombie(id))
return FMRES_IGNORED

new Float:origin[3], Float:vel[3], bool:onground, flags
flags = pev(id, pev_flags)
onground = (flags & ON_LAND_CONST)  ? true : false
pev(id,pev_origin,origin)
pev(id,pev_velocity,vel)

if (cl_is_thrown[id] && onground)
{
cl_added_velocity[id] = false
cl_is_thrown[id] = 0
ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
}
	
if (cl_nn_has[id])
{
nanosuit_functions(id)
new rgb2[3]
switch (cl_nn_mode[id])
{
case NANO_STREN: rgb2 = {255, 5, 5}
case NANO_ARMOR: rgb2 = {12, 12, 170}
case NANO_SPEED: rgb2 = {150, 150, 0}
case NANO_STABILITY: rgb2 = {10, 170, 10}
default: fm_set_rendering(id)
}	
fm_set_rendering(id, kRenderFxGlowShell, rgb2[0], rgb2[1], rgb2[2],kRenderNormal, 0)	
if(cl_nn_mode[id] == NANO_CLOAK)
{	
ScreenFade(id, 2.0, 200, 200, 200)
fm_set_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, cl_nn_invisible[id])	
}
if (cl_nn_energy[id] < 20)
{
new fOrigin[3], rgb[3]
switch (cl_nn_mode[id])
{
case NANO_STREN: rgb = {255, 0, 0}
case NANO_ARMOR: rgb = {0, 0, 255}
case NANO_SPEED: rgb = {255, 255, 0}
case NANO_CLOAK: rgb = {255, 255, 255}
case NANO_STABILITY: rgb = {25, 255, 25}
default: rgb2 = {0, 0, 0}
}

pev(id, pev_origin, fOrigin)
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_ELIGHT)
write_short(id)
write_coord(fOrigin[0])
write_coord(fOrigin[1])
write_coord(fOrigin[2])
write_coord(10)
write_byte(rgb[0])
write_byte(rgb[1])
write_byte(rgb[2])
write_byte(2)
write_coord(0)
message_end()
}
}

new Float:speed
speed  = vector_length(vel)
new Float:mspeed
mspeed = fm_get_user_maxspeed(id)

if (NANO_FLAG_INWATER && flags & ON_WATER_CONST)
mspeed *= SPEED_WATER_MUL_CONSTANT

if (NANO_FLAG_CROUCHED && flags & FL_DUCKING)
mspeed *= SPEED_CROUCH_MUL_CONSTANT

// Remember the speed
if (speed == 0.0)cl_nn_speed[id] = SPD_STILL
if (speed > 0.0)	cl_nn_speed[id] = SPD_VSLOW
if (speed > 0.4 * mspeed)cl_nn_speed[id] = SPD_SLOW
if (speed > 0.6 * mspeed)cl_nn_speed[id] = SPD_NORMAL
if (speed > 0.9 * mspeed)cl_nn_speed[id] = SPD_FAST
if (speed < 0.6 * mspeed && cl_nn_has[id] && cl_nn_mode[id] == NANO_SPEED)	
set_pev(id,pev_flTimeStepSound,100)
if (speed == 0.0)cl_nn_scr_speed[id] = SPD_SCR_STILL
if (speed > 0.0)	cl_nn_scr_speed[id] = SPD_SCR_VSLOW
if (speed > 100.0)cl_nn_scr_speed[id] = SPD_SCR_SLOW
if (speed > 200.0)cl_nn_scr_speed[id] = SPD_SCR_NORMAL
if (speed > 265.0)cl_nn_scr_speed[id] = SPD_SCR_FAST
return FMRES_IGNORED
}
public fw_resetmaxspeed(id)
{				
if(!is_user_alive(id) || zp_core_is_zombie(id))
return
		
if (cl_is_thrown[id] != 0)
fm_set_user_maxspeed(id, CRIT_SPEED)

if (cl_nn_has[id])
{
switch (cl_nn_mode[id])
{
case NANO_ARMOR:fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * CRIT_SPEED)
case NANO_ARMOR2:fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * CRIT_SPEED)
case NANO_STREN:fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * CRIT_SPEED)
case NANO_CLOAK:fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * CRIT_SPEED)
case NANO_STABILITY:fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * CRIT_SPEED)
case NANO_SPEED:
{
if (cl_nn_energy[id] > 10)
cl_nn_sp_status[id] = SPEED_MAXIMUM
if (10 >= cl_nn_energy[id] > 0)
cl_nn_sp_status[id] = SPEED_CRITICAL
if (0 >= cl_nn_energy[id])
cl_nn_sp_status[id] = SPEED_NORMAL

switch (cl_nn_sp_status[id])
{
case SPEED_MAXIMUM: fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * MAX_SPEED)
case SPEED_CRITICAL: fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * CRIT_SPEED)
}
}
default: fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * CRIT_SPEED)
}
}
}
public nanosuit_ah_charge(id)
{
id -= TASK_WARNED

if (!(cl_nn_has[id]))
{
remove_task(id + TASK_WARNED)
return PLUGIN_CONTINUE
}

if (!is_user_alive(id))
{
return PLUGIN_CONTINUE
}
if(cl_nn_mode[id] != NANO_STABILITY)	
return PLUGIN_CONTINUE
static Float:health, HP
pev(id,pev_health,health)
if(cl_nn_energy2[id])
{
HP=350
}else{
HP=250	
}
if (floatround(health,floatround_floor) < HP)
{
new fOrigin[3]	
pev(id, pev_origin, fOrigin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_ELIGHT)
write_short(id)
write_coord(fOrigin[0])
write_coord(fOrigin[1])
write_coord(fOrigin[2])
write_coord(10)
write_byte(25)
write_byte(255)
write_byte(25)
write_byte(2)
write_coord(0)
message_end()

fm_set_user_health(id, min(g_nn_health[id], get_user_health(id) + 5))
}
return PLUGIN_CONTINUE
}

/* ===================================================
[Screen think of all players]
==================================================== */
public fw_screenthink(ent)
{
if (!pev_valid(ent))
return FMRES_IGNORED

if (ent != nd_ent_monitor)
return FMRES_IGNORED

new players[32], count, id
new Float:energy
energy = 100.0	
get_players(players, count, "ac")

for (new i=0;i<count;i++)
{
id = players[i]	
if (cl_nn_has[id])
{	
static hud[200]
formatex(hud, 199, "",id)
switch (cl_nn_mode[id])
{
case NANO_STABILITY:
{
formatex(hud, 199, "%s Recovery",hud)
if(cl_nn_energy2[id])
formatex(hud, 199, "%s^nBoosted Health / %d%%", hud, get_user_health(id))	
else formatex(hud, 199, "%s^nYou have no boost!", hud)	
}
case NANO_STREN: 
{
formatex(hud, 199, "%s High Damage",hud)
formatex(hud, 199, "%s^nController / (%d%%)", hud,  floatround(cl_nn_controlling[id] / energy * 100))
}
case NANO_ARMOR: formatex(hud, 199, "%s Defense",hud)
case NANO_SPEED: 
{	
formatex(hud, 199, "%s Quickness",hud)

switch (cl_nn_scr_speed[id])
{
case SPD_SCR_STILL:formatex(hud, 199, "%s ^nSpeed Status:Standing", hud)
case SPD_SCR_VSLOW:formatex(hud, 199, "%s ^nSpeed Status:Very Slow", hud)
case SPD_SCR_SLOW:formatex(hud, 199, "%s ^nSpeed Status:Slow", hud)
case SPD_SCR_NORMAL:formatex(hud, 199, "%s ^nSpeed Status: Normal", hud)
case SPD_SCR_FAST:formatex(hud, 199, "%s ^nSpeed Status: Fast", hud)
}
}
case NANO_CLOAK: formatex(hud, 199, "%s Invisiblity",hud)
case NANO_ARMOR2: formatex(hud, 199, "%s Defense",hud)
}
formatex(hud, 199, "%s^nEnergy / (%d%%)", hud, floatround(cl_nn_energy[id] / energy * 100))
formatex(hud, 199, "%s^n^nGameMod by iNexus The Creator ^nVisit: www.CMS-BG.eu", hud)
set_hudmessage(NanoScreenColor[cl_nn_mode[id]][0], NanoScreenColor[cl_nn_mode[id]][1], NanoScreenColor[cl_nn_mode[id]][2], -1.00, 0.80, 0, 0.0, 0.2, 0.0, 0.0)
ShowSyncHudMsg(id, nd_hud_sync, "%s", hud)


new playerCnt, players[32], id_spectator
get_players(players, playerCnt, "bch")

for (new ii = 0; ii < playerCnt; ++ii)
{
id_spectator = players[ii]

if (pev(id_spectator, pev_iuser2) == id)
ShowSyncHudMsg(id_spectator, nd_hud_sync, "%s", hud)
}
}
}
set_pev(ent, pev_nextthink, get_gametime() + 0.1)
return FMRES_IGNORED
}


/* ===================================================
[Energy manipulation task]
==================================================== */
public set_energy(id)
{
id -= TASK_ENERGY

if(!is_user_alive(id) || zp_core_is_zombie(id))
return PLUGIN_CONTINUE

if (!cl_nn_has[id])
{
remove_task(id + TASK_ENERGY)
return PLUGIN_CONTINUE
}

new NanoModes:active = cl_nn_mode[id]
static Float:energy; energy = cl_nn_energy[id]

// Decrease when player is running in speed mode
if (active == NANO_SPEED && pev(id,pev_flags) & ON_LAND_CONST)
{
static Float:multi

switch (cl_nn_sp_status[id])
{
case SPEED_NORMAL:
{
switch (cl_nn_speed[id])
{
case SPD_STILL: multi = 0.0
case SPD_VSLOW: multi = 0.0
case SPD_SLOW: multi = 0.0
case SPD_NORMAL: multi = 1.0
case SPD_FAST: multi = 1.0
}

energy -= (0.1) * multi
}
case SPEED_CRITICAL:
{
switch (cl_nn_speed[id])
{
case SPD_STILL:multi = 0.0
case SPD_VSLOW:multi = 0.0
case SPD_SLOW:multi = 0.0
case SPD_NORMAL:multi = 0.0
case SPD_FAST:multi = 0.4
}
energy -= (0.2) * multi
}
case SPEED_MAXIMUM:
{
switch (cl_nn_speed[id])
{
case SPD_STILL:multi = 0.0
case SPD_VSLOW:multi = 0.0
case SPD_SLOW:multi = 0.0
case SPD_NORMAL:multi = 0.0
case SPD_FAST:multi = 1.0
}
if(!cl_nn_energy2[id])
energy -= 2.0 * multi
else
energy -= 3.0 * multi
}
}
if (multi != 0.0)
cl_nn_block_recharge[id] = DELAY_SPD_RUN + 1
}

// Decrease in cloak mode
if (active == NANO_CLOAK)
{		
static Float:multi = 1.0

switch (cl_nn_speed[id])
{
case SPD_STILL: multi = 0.4
case SPD_VSLOW: multi = 0.6
case SPD_SLOW: multi = 0.8
case SPD_NORMAL: multi = 1.0
case SPD_FAST: multi = 1.1
}

energy -= 0.60 * multi
} 
if (energy < 10 && !cl_nn_critical[id])
{
cl_nn_critical[id] = true
cl_nn_online[id] = true
client_print(id, print_center, "-= Energy Critical =-");
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_energy.wav")	
client_cmd(id, "speak ZPlague/NanoSuit/nanosuit_critical.wav")	
}
if (active != NANO_CLOAK)
{
if (cl_nn_energy[id] < 10)
{
if (get_gametime() >= cl_nn_damage_time[id])
{
if (get_user_health(id) > 5)
{
fm_set_user_health(id, min(g_nn_health[id], get_user_health(id) - 5))
}
if (cl_nn_mode[id] == NANO_STREN)ScreenFade(id, 0.5, 250, 10, 10)
else if (cl_nn_mode[id] == NANO_SPEED)ScreenFade(id, 0.5, 250, 250, 10)
cl_nn_damage_time[id] = get_gametime() + 1.5
}
}
}
if (energy >= g_nn_energy[id] && cl_nn_online[id])
{	
client_cmd(id, "speak ZPlague/NanoSuit/nanosuit_allsystems.wav")
client_print(id, print_center, "-= All Systems Online =-")
cl_nn_online[id] = false
}	
if (energy <= 0.0)
{
if (active == NANO_CLOAK)
{
cl_nn_block_recharge[id] = DELAY_CLK_DELAY
set_nano_mode(id,NANO_STABILITY)
energy = 0.0
}
}
// Increase but not when in cloak mode
if (energy < g_nn_energy[id] && cl_nn_mode[id] != NANO_CLOAK && cl_nn_block_recharge[id] == 0)
{
static Float:energy2
if (active == NANO_SPEED)
energy2 = 2.3 // Regenerate
else
energy2 = 2.0 // Regenerate
if (pev(id,pev_button) & IN_DUCK && cl_nn_speed[id] == SPD_STILL)
energy2 *= ENERGY_CROUCH
energy2 += energy
energy = floatmin(g_nn_energy[id], energy2)
if (energy > 10.0 + CRITICAL_EXTRA_ADD)
cl_nn_critical[id] = false
}
if (cl_nn_block_recharge[id] > 0)
cl_nn_block_recharge[id] -= 1
cl_nn_energy[id] = energy
return PLUGIN_CONTINUE
}
/* ===================================================
[Ham forwards chapter (yummy)]
==================================================== */
public fw_primary_attack(ent)
{
if(!pev_valid(ent)) 
return HAM_IGNORED	
static id; id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, EXTRA_OFFSET_WEAPON_LINUX)
pev(id,pev_punchangle,cl_nn_punch[id])
static ammo,clip
get_user_ammo(id, cl_nn_weapon[id], ammo, clip)

if (cs_get_weapon_id(ent) == CSW_M3 || cs_get_weapon_id(ent) == CSW_XM1014)
cl_nn_shotgun_ammo[id] = ammo
else
cl_nn_shotgun_ammo[id] = -1

if (ammo != 0)
cl_nn_actual_shot[id] = true

return HAM_IGNORED
}

public fw_primary_attack_post(ent)
{
if(!pev_valid(ent)) 
return HAM_IGNORED	
static id; id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, EXTRA_OFFSET_WEAPON_LINUX)

if (cl_nn_mode[id] == NANO_CLOAK)
{
cl_nn_block_recharge[id] = DELAY_CLK_DELAY
set_nano_mode(id,NANO_ARMOR2)
cl_nn_energy[id] = 0.0
}

if (cl_nn_actual_shot[id] && cl_nn_has[id] && cl_nn_weapon[id] != CSW_KNIFE && cl_nn_mode[id] == NANO_STREN)
{
new Float:push[3]
pev(id,pev_punchangle,push)
xs_vec_sub(push,cl_nn_punch[id],push)
if(cl_nn_energy[id] > 10)
{
if(cl_nn_controlling[id] <= 10 && cl_nn_energy[id] >= 0.1)
{
xs_vec_div_scalar(push,2.0,push)
set_nano_energy(id,cl_nn_energy[id] - 0.1, DELAY_STR_SHOT)
}
else if(cl_nn_controlling[id] <= 20 && cl_nn_energy[id] >= 0.5)
{
xs_vec_div_scalar(push,1.7,push)
set_nano_energy(id,cl_nn_energy[id] - 0.5, DELAY_STR_SHOT)
}
else if(cl_nn_controlling[id] <= 30 && cl_nn_energy[id] >= 1.0)
{
xs_vec_div_scalar(push,1.5,push)
set_nano_energy(id,cl_nn_energy[id] - 1.0, DELAY_STR_SHOT)
}
else if(cl_nn_controlling[id] <= 40 && cl_nn_energy[id] >= 1.3)
{
xs_vec_div_scalar(push,1.4,push)
set_nano_energy(id,cl_nn_energy[id] - 1.3, DELAY_STR_SHOT)
}
else if(cl_nn_controlling[id] <= 50 && cl_nn_energy[id] >= 1.5)
{
xs_vec_div_scalar(push,1.3,push)
set_nano_energy(id,cl_nn_energy[id] - 1.5, DELAY_STR_SHOT)
}
else if(cl_nn_controlling[id] <= 60 && cl_nn_energy[id] >= 1.8)
{
xs_vec_div_scalar(push,1.0,push)
set_nano_energy(id,cl_nn_energy[id] - 1.8, DELAY_STR_SHOT)
}
else if(cl_nn_controlling[id] <= 70 && cl_nn_energy[id] >= 2.0)
{
xs_vec_div_scalar(push,0.9,push)
set_nano_energy(id,cl_nn_energy[id] - 2.0, DELAY_STR_SHOT)
}
else if(cl_nn_controlling[id] <= 80 && cl_nn_energy[id] >= 2.8)
{
xs_vec_div_scalar(push,0.5,push)
set_nano_energy(id,cl_nn_energy[id] - 2.8, DELAY_STR_SHOT)
}
else if(cl_nn_controlling[id] <= 85 && cl_nn_energy[id] >= 3.0)
{
xs_vec_div_scalar(push,0.4,push)
set_nano_energy(id,cl_nn_energy[id] - 3.0, DELAY_STR_SHOT)
}
else if(cl_nn_controlling[id] <= 90 && cl_nn_energy[id] >= 3.0)
{
xs_vec_div_scalar(push,0.3,push)
set_nano_energy(id,cl_nn_energy[id] - 3.0, DELAY_STR_SHOT)
}
else if(cl_nn_controlling[id] >= 95 && cl_nn_energy[id] >= 4.5)
{
xs_vec_div_scalar(push,0.2,push)
set_nano_energy(id,cl_nn_energy[id] - 4.5, DELAY_STR_SHOT)
}
}else{
if(cl_nn_energy[id] > 0)
{
xs_vec_div_scalar(push,0.6,push)
set_nano_energy(id,cl_nn_energy[id] - 0.3, DELAY_STR_SHOT)
}
xs_vec_add(push,cl_nn_punch[id],push)
set_pev(id,pev_punchangle,push)
}
}
if (cl_nn_actual_shot[id] && cl_nn_has[id] && cl_nn_mode[id] == NANO_SPEED && cl_nn_energy[id] >= 10)
{
static Float:multi
multi = 1.0
switch (cl_nn_weapon[id])
{
case CSW_DEAGLE,CSW_ELITE,CSW_FIVESEVEN,CSW_P228,CSW_USP,CSW_GLOCK18:
{
multi = REFIRE_PISTOLS
}
case CSW_M3:
{
multi = REFIRE_M3
}
case CSW_KNIFE:
{
multi = REFIRE_KNIFE
static Float:M_Delay
M_Delay = get_pdata_float(ent, OFFSET_WEAPON_NEXT_SEC_ATTACK, EXTRA_OFFSET_WEAPON_LINUX) * multi
set_pdata_float(ent, OFFSET_WEAPON_NEXT_SEC_ATTACK, M_Delay,  EXTRA_OFFSET_WEAPON_LINUX)
}
case CSW_SCOUT,CSW_AWP:
{
multi = REFIRE_SNIPERS
}
}

if (multi != 1.0)
set_nano_energy(id, cl_nn_energy[id] - 10,DELAY_SPD_FAST_ATTACK)

new Float:Delay

Delay = get_pdata_float( ent, OFFSET_WEAPON_NEXT_PRIMARY_ATTACK,  EXTRA_OFFSET_WEAPON_LINUX) * multi
set_pdata_float( ent, OFFSET_WEAPON_NEXT_PRIMARY_ATTACK, Delay,  EXTRA_OFFSET_WEAPON_LINUX)
}

cl_nn_actual_shot[id] = false
return HAM_IGNORED
}
public fw_traceattack(victim, attacker, Float:damage, Float:direction[3], tr, damagebits)
{	
static Float:origin[3], hitzone
hitzone = get_tr2(tr,TR_iHitgroup)
damage *= vec_hit_multi[hitzone]
pev(attacker,pev_origin,origin)

if (is_user_player(attacker))
{
if(!zp_class_assassin_get(victim) && !zp_class_nemesis_get(victim))
{		
if(!zp_core_is_zombie(attacker) && zp_core_is_zombie(victim))
{
ScreenFade(victim, 0.1, 200, 0, 0)
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), _, victim)
write_short((1<<13)*2)           
write_short((1<<12)*2) 
write_short((1<<13)*10) 
message_end()
}
}	
if (cl_nn_has[attacker] && cl_nn_mode[attacker] == NANO_STREN)
{
if(cl_nn_controlling[attacker] <= 5)damage *= 1.10
else if(cl_nn_controlling[attacker] <= 10)damage *= 1.15
else if(cl_nn_controlling[attacker] <= 15)damage *= 1.20
else if(cl_nn_controlling[attacker] <= 20)damage *= 1.25
else if(cl_nn_controlling[attacker] <= 25)damage *= 1.30
else if(cl_nn_controlling[attacker] <= 30)damage *= 1.35
else if(cl_nn_controlling[attacker] <= 35)damage *= 1.40
else if(cl_nn_controlling[attacker] <= 40)damage *= 1.45
else if(cl_nn_controlling[attacker] <= 45)damage *= 1.50
else if(cl_nn_controlling[attacker] <= 50)damage *= 1.55
else if(cl_nn_controlling[attacker] <= 55)damage *= 1.60
else if(cl_nn_controlling[attacker] <= 60)damage *= 1.65
else if(cl_nn_controlling[attacker] <= 65)damage *= 1.70
else if(cl_nn_controlling[attacker] <= 70)damage *= 1.75
else if(cl_nn_controlling[attacker] <= 75)damage *= 1.80
else if(cl_nn_controlling[attacker] <= 80)damage *= 1.85
else if(cl_nn_controlling[attacker] <= 85)damage *= 1.90
else if(cl_nn_controlling[attacker] <= 90)damage *= 1.95
else if(cl_nn_controlling[attacker] <= 90)damage *= 2.00
else if(cl_nn_controlling[attacker] <= 95)damage *= 2.10
else if(cl_nn_controlling[attacker] <= 100)damage *= 2.20
}
if(zp_core_is_zombie(attacker) && !zp_core_is_zombie(victim))
{
if(!zp_class_sniper_get(victim) && !zp_class_survivor_get(victim))
{	
if (cl_nn_has[victim] && cl_nn_mode[victim] == NANO_ARMOR || cl_nn_mode[victim] == NANO_ARMOR2)
{
ScreenFade(victim, 0.1, 0, 0, 200)
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), _, victim)
write_short((2<<13)*2)           
write_short((1<<12)*2) 
write_short((2<<13)*10) 
message_end()
}
}
}
}
if (hitzone != 8 && damage != 0.0)
damage /= vec_hit_multi[hitzone]
SetHamParamTraceResult(5,tr)
SetHamParamFloat(3,damage)
return HAM_HANDLED
}
public fw_shotgun_deploy(ent)
{
if(!pev_valid(ent)) 
return;
static id; id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, EXTRA_OFFSET_WEAPON_LINUX)
cl_nn_shotgun_ammo[id] = cs_get_weapon_ammo(ent)
}
public fw_special_reload_post(ent)
{
if(!pev_valid(ent)) 
return HAM_IGNORED	
static id; id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, EXTRA_OFFSET_WEAPON_LINUX)
new wpn_id = cs_get_weapon_id(ent)
new maxammo = wpn_max_clip[wpn_id]
new curammo = cs_get_weapon_ammo(ent)

if (cl_nn_shotgun_ammo[id] == -1)
{
cl_nn_shotgun_ammo[id] = curammo
return HAM_IGNORED
}
else
{
if (!(cl_nn_has[id] && cl_nn_mode[id] == NANO_SPEED && cl_nn_energy[id] >= 10))
{
cl_nn_shotgun_ammo[id] = curammo
return HAM_IGNORED
}

if (curammo < cl_nn_shotgun_ammo[id])
cl_nn_shotgun_ammo[id] = curammo

if (curammo - cl_nn_shotgun_ammo[id] == SH_CARTRAGE_RATIO && cs_get_user_bpammo(id, wpn_id) && curammo + 1 <= maxammo)
{
cs_set_weapon_ammo(ent, curammo + 1)
cs_set_user_bpammo(id, wpn_id, cs_get_user_bpammo(id, wpn_id) - 1)
cl_nn_shotgun_ammo[id] = curammo + 1
set_nano_energy(id, cl_nn_energy[id] - 10, DELAY_SPD_SH_RELOAD)
emessage_begin(MSG_ONE, nd_msg_ammox, {0,0,0}, id)
ewrite_byte(SH_AMMO_MSG_AMMOID)
ewrite_byte(curammo + 1)
emessage_end()
}
}
return HAM_IGNORED
}

public fw_reload_post(ent)
{
if(!pev_valid(ent)) 
return HAM_IGNORED	
if(get_pdata_int(ent, OFFSET_WEAPON_IN_RELOAD, EXTRA_OFFSET_WEAPON_LINUX))
{
static id; id = get_pdata_cbase(ent, OFFSET_WEAPON_OWNER, EXTRA_OFFSET_WEAPON_LINUX)

cl_nn_shotgun_ammo[id] = -1

if (cl_nn_has[id] && cl_nn_mode[id] == NANO_SPEED && cl_nn_energy[id] >= 20)
{
new Float:delay = wpn_reload_delay[get_pdata_int(ent, OFFSET_WEAPON_ID, EXTRA_OFFSET_WEAPON_LINUX)] * RELOAD_RATIO
set_pdata_float(id, OFFSET_PLAYER_NEXT_ATTACK, delay, EXTRA_OFFSET_PLAYER_LINUX)
set_pdata_float(ent, OFFSET_WEAPON_IDLE_TIME, delay + 0.5, EXTRA_OFFSET_WEAPON_LINUX)
set_nano_energy(id,cl_nn_energy[id] - 20,DELAY_SPD_FAST_RELOAD)
}
}

return HAM_IGNORED
}
public fw_takedamage(victim, inflictor, attacker, Float:damage, damagebits)
{
if (!is_user_player(attacker) && !zp_core_is_zombie(victim))
{
if (cl_nn_has[victim] && cl_nn_mode[victim] == NANO_ARMOR && cl_nn_mode[victim] == NANO_ARMOR2)
{
if(cl_nn_defense[victim] <= 20)damage *= 0.75
else if(cl_nn_defense[victim] <= 40)damage *= 0.60
else if(cl_nn_defense[victim] <= 60)damage *= 0.50
else if(cl_nn_defense[victim] <= 80)damage *= 0.45
else if(cl_nn_defense[victim] <= 100)damage *= 0.40

if (damage < cl_nn_energy[victim])
{
set_nano_energy(victim, cl_nn_energy[victim] - damage, DELAY_ARM_DAMAGE)
set_pev(victim,pev_dmg_inflictor,inflictor)
damage = 0.0
}
else
{
damage -= cl_nn_energy[victim]
set_nano_energy(victim, 0.0, DELAY_ARM_DAMAGE)
}
}
}
SetHamParamFloat(4,damage)
return HAM_HANDLED
}
public fw_takedamage_post(victim, inflictor, attacker, Float:damage, damagebits)
{
if (!is_user_player(attacker) && !zp_core_is_zombie(victim))
{	
if (cl_nn_has[victim] && cl_nn_mode[victim] == NANO_ARMOR)
{
new Float: painshock = get_pdata_float(victim, OFFSET_PLAYER_PAIN_SHOCK, EXTRA_OFFSET_PLAYER_LINUX)

if (painshock == 0.0)
return HAM_IGNORED

painshock = (0.0 - ((0.0 - painshock) * 1.0))

set_pdata_float(victim, OFFSET_PLAYER_PAIN_SHOCK, painshock, EXTRA_OFFSET_PLAYER_LINUX)
}
}
return HAM_IGNORED
}
/* ===================================================
[Nanosuit prethink functions]
==================================================== */
public nanosuit_functions(id)
{		
if(!is_user_alive(id))
return; 
if (cl_nn_mode[id] == NANO_SPEED)
{
if (cl_nn_energy[id] > 10)
{
if (cl_nn_sp_status[id] == SPEED_NORMAL)
{
fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * MAX_SPEED)
}
if (cl_nn_sp_status[id] == SPEED_CRITICAL)
{
fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * MAX_SPEED / CRIT_SPEED)
}

cl_nn_sp_status[id] = SPEED_MAXIMUM
}
if (10 >= cl_nn_energy[id] > 0)
{
if (cl_nn_sp_status[id] == SPEED_NORMAL)
{
fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * CRIT_SPEED)
}
if (cl_nn_sp_status[id] == SPEED_MAXIMUM)
{
fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) * CRIT_SPEED/MAX_SPEED)
}

cl_nn_sp_status[id] = SPEED_CRITICAL
}
if (0 >= cl_nn_energy[id])
{
if (cl_nn_sp_status[id] == SPEED_MAXIMUM)
{
fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) / MAX_SPEED)
}
if (cl_nn_sp_status[id] == SPEED_CRITICAL)
{
fm_set_user_maxspeed(id,fm_get_user_maxspeed(id) / CRIT_SPEED)
}
cl_nn_sp_status[id] = SPEED_NORMAL
}
return
}
if (cl_nn_mode[id] == NANO_STREN)
set_pev(id, pev_fuser2, 0.0)
return
}
/* ===================================================
[Functions that come in handy]
==================================================== */
set_nano_mode(id, NanoModes:mode, bool:announce = true)
{
if(!is_user_alive(id) || zp_core_is_zombie(id))	
return;  
if(zp_class_survivor_get(id) || zp_class_sniper_get(id))
return;

if (cl_nn_mode[id] == mode)
return

cl_nn_mode[id] = mode
if (announce)
{
switch (mode)
{	
case NANO_ARMOR:
{
ScreenFade(id, 0.2, 0, 0, 200)	
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_armor_switch.wav")
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_armor.wav")
client_print(id, print_center, "Armor Mode (Defense)")
ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
remove_task(id+TASK_WARNED)
}
case NANO_STREN:
{
ScreenFade(id, 0.2, 200, 10, 10)	
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_strength_switch.wav")
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_strength.wav")
client_print(id, print_center, "Strenght Mode (Damage)")
ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
ClearSyncHud(id, nd_hud_sync2)		
set_hudmessage(100, 25, 25, -1.0, 0.15, 0, 0.0, 1.0, 1.0, 1.0, -1)
ShowSyncHudMsg(id, nd_hud_sync2, "You can use controller buttons [ AND ]")
remove_task(id+TASK_WARNED)
}
case NANO_SPEED:
{	
ScreenFade(id, 0.2, 150, 150, 0)	
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_speed_switch.wav")
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_speed.wav")
client_print(id, print_center, "Speed Mode (Quickness)")
ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
remove_task(id+TASK_WARNED)
}
case NANO_STABILITY:
{	
ScreenFade(id, 0.2, 10, 150, 10)	
client_cmd(id, "spk ZPlague/NanoSuit/stability.wav")
client_print(id, print_center, "Stability Mode (Recovery)")
set_task(1.0,"nanosuit_ah_charge",id + TASK_WARNED, _, _,"b")
ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
}
case NANO_CLOAK:
{	
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_cloak_switch.wav")
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_cloak.wav")
client_print(id, print_center, "Cloak Mode (Invisible)")
ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
remove_task(id+TASK_WARNED)
}
case NANO_ARMOR2:
{	
fm_set_rendering(id)	
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_armor_switch.wav")
ExecuteHamB(Ham_Player_ResetMaxSpeed, id)
remove_task(id+TASK_WARNED)
}
}
}
}

set_nano_energy(id, Float:ammount, delay = 0)
{
cl_nn_energy[id] = ammount
if (delay > cl_nn_block_recharge[id])
cl_nn_block_recharge[id] = delay
if (ammount == 0.0 && cl_nn_mode[id] == NANO_CLOAK)
{
set_nano_mode(id,NANO_STABILITY)
}

return 1
}

nanosuit_reset(id)
{
if (task_exists(id + TASK_WARNED))
remove_task(id + TASK_WARNED)

if (task_exists(id + TASK_ENERGY))
remove_task(id + TASK_ENERGY)	

set_task(0.1, "set_energy",id+TASK_ENERGY, _, _,"b")

cl_nn_energy[id] = g_nn_energy[id]

switch(random_num(1,5))
{
case 1:
{
cl_nn_defense[id] = 20.0
cl_nn_invisible[id] = 5
}
case 2:
{
cl_nn_defense[id] = 40.0
cl_nn_invisible[id] = 0
}
case 3:
{
cl_nn_defense[id] = 60.0	
cl_nn_invisible[id] = 5
}
case 4:
{
cl_nn_defense[id] = 80.0	
cl_nn_invisible[id] = 0	
}
case 5:
{
cl_nn_defense[id] = 100.0
cl_nn_invisible[id] = 0
}
}
}

public nano_reset(id)
{
if (task_exists(id + TASK_ENERGY))
remove_task(id + TASK_ENERGY)	
if (task_exists(id + TASK_WARNED))
remove_task(id + TASK_WARNED)	
}
/* ===================================================
[Controller functions]
==================================================== */
public set_con_energy(id)
{
if(!is_user_alive(id))
return PLUGIN_HANDLED

if(!cl_nn_has[id])
{
client_print(id, print_center,"You don't have Nanosuit!")
return PLUGIN_HANDLED
}

if (cl_nn_mode[id] != NANO_STREN)
return PLUGIN_HANDLED

set_controlling(id)
return PLUGIN_HANDLED
}
public take_con_energy(id)
{
if(!is_user_alive(id))
return PLUGIN_HANDLED

if(!cl_nn_has[id])
{
client_print(id, print_center,"You don't have Nanosuit!")
return PLUGIN_HANDLED
}

if (cl_nn_mode[id] != NANO_STREN)
return PLUGIN_HANDLED

take_controlling(id)
return PLUGIN_HANDLED
}
public set_controlling(id)
{
if (!cl_nn_has[id] && cl_nn_mode[id] != NANO_STREN)
return PLUGIN_CONTINUE

new Float:energy = cl_nn_controlling[id]
if (energy < 100.0)
{
static Float:energy2
energy2 = 5.0
energy2 += energy
energy = floatmin(100.0, energy2)
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_controller.wav")	
}
cl_nn_controlling[id] = energy
return PLUGIN_CONTINUE
}
public take_controlling(id)
{
if (!cl_nn_has[id] && cl_nn_mode[id] != NANO_STREN)
return PLUGIN_CONTINUE

new Float:energy = cl_nn_controlling[id]
if (energy >= 5.0)
{
energy -= 5.0 
client_cmd(id, "spk ZPlague/NanoSuit/nanosuit_controller.wav")	
}
cl_nn_controlling[id] = energy
return PLUGIN_CONTINUE
}
/* ===================================================
[Bind Menu]
==================================================== */
public Bind_Menu(id)
{
if(!is_user_alive(id))
return;
if(!cl_nn_has[id])
{
client_print(id, print_center,"You don't have Nanosuit!")
return;
}

static menu;
menu = menu_create("\y[NS2] Bind Menu", "Bind_Menu1") 

menu_additem(menu, "Bind \yZ,X,C,V (Modes)", "1", 0);
menu_additem(menu, "Bind \yScroll UP, ScrollDown \r(Controller)", "2", 0);
menu_additem(menu, "Bind \y[ \wand \y] \r(Controller)", "3", 0);
menu_additem(menu, "Bind All Needed \rButtons", "4", 0);
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
} 
public Bind_Menu1(id, menu, item)   
{
if (!is_user_connected(id))
return PLUGIN_HANDLED;
if (item == MENU_EXIT)   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback) 
new key = str_to_num(data)   
switch(key)   
{  
case 1:
{
client_cmd(id, "bind z get_stren")	
client_cmd(id, "bind x get_armor")
client_cmd(id, "bind c get_speed")
client_cmd(id, "bind v get_cloak")
}
case 2:
{
client_cmd(id, "bind mwheelup get_con_energy")
client_cmd(id, "bind mwheeldown take_con_energy")
} 
case 3:
{
client_cmd(id, "bind ] get_energy")
client_cmd(id, "bind [ take_energy")
client_cmd(id, "bind mwheelup invprev")
client_cmd(id, "bind mwheeldown invnext")
} 
case 4:
{
client_cmd(id, "bind alt nanosuit")
client_cmd(id, "bind z get_stren")	
client_cmd(id, "bind x get_armor")
client_cmd(id, "bind c get_speed")
client_cmd(id, "bind v get_cloak")
client_cmd(id, "bind mwheelup get_con_energy")
client_cmd(id, "bind mwheeldown take_con_energy")
client_cmd(id, "bind ] get_energy")
client_cmd(id, "bind [ take_energy")
}     
}   
client_print(id,print_center, "Successfuly Binded Buttons!" )	
menu_destroy(menu)   
return PLUGIN_HANDLED   
}  

public nanosuit_str_mode(id)
{
if(!is_user_alive(id))
return PLUGIN_HANDLED

if(!cl_nn_has[id])
{
client_print(id, print_center,"You don't have Nanosuit!")
return PLUGIN_HANDLED
}
nanosuit_menu_choose(id,0,_:NANO_STREN)
ExecuteHamB(Ham_Player_ResetMaxSpeed,id)
return PLUGIN_HANDLED
}

public nanosuit_arm_mode(id)
{
if(!is_user_alive(id))
return PLUGIN_HANDLED

if(!cl_nn_has[id])
{
client_print(id, print_center,"You don't have Nanosuit!")
return PLUGIN_HANDLED
}

nanosuit_menu_choose(id,0,_:NANO_ARMOR)
ExecuteHamB(Ham_Player_ResetMaxSpeed,id)
return PLUGIN_HANDLED
}

public nanosuit_spd_mode(id)
{
if(!is_user_alive(id))
return PLUGIN_HANDLED

if(!cl_nn_has[id])
{
client_print(id, print_center,"You don't have Nanosuit!")
return PLUGIN_HANDLED
}

nanosuit_menu_choose(id,0,_:NANO_SPEED)
ExecuteHamB(Ham_Player_ResetMaxSpeed,id)
return PLUGIN_HANDLED
}

public nanosuit_clo_mode(id)
{
if(!is_user_alive(id))
return PLUGIN_HANDLED

if(!cl_nn_has[id])
{
client_print(id, print_center,"You don't have Nanosuit!")
return PLUGIN_HANDLED
}

nanosuit_menu_choose(id,0,_:NANO_CLOAK)
ExecuteHamB(Ham_Player_ResetMaxSpeed,id)
return PLUGIN_HANDLED
}
/* ===================================================
[Message stocks]
==================================================== */
stock ScreenFade(id, Float:fDuration, red, green, blue)
{	
message_begin(MSG_ONE, g_screen, _, id)
write_short(floatround(4096.0 * fDuration, floatround_round));
write_short(floatround(4096.0 * fDuration, floatround_round));
write_short(4096);
write_byte(red);
write_byte(green);
write_byte(blue);
write_byte(100);
message_end();

static SpecIuser2	
for(new i=1;i<=get_maxplayers();i++)
{
if(is_user_connected(i) && !is_user_alive(i))
{
SpecIuser2 = pev(i , pev_iuser2)

if(SpecIuser2 == id)
{
message_begin(MSG_ONE, g_screen, _, id)
write_short(floatround(4096.0 * fDuration, floatround_round));
write_short(floatround(4096.0 * fDuration, floatround_round));
write_short(4096);
write_byte(red);
write_byte(green);
write_byte(blue);
write_byte(100);
message_end();
}
}
}
}
