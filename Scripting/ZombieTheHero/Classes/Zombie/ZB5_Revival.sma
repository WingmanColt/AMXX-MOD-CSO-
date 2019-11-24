#include <amxmodx>
#include <ZombieMod5>

#define BURN_CLASSNAME "metatronic_burn"

new const ZombieSound[][] =
{
"ZB5/zombi_revival_hurt.wav",
"ZB5/zombi_revival_death.wav",

"ZB5/Zombie/revival_skill1.wav",
"ZB5/Zombie/zombi_heal_revival.wav"
}
new const ZombieModel[][] =
{	
"models/player/ZB5_Revival/ZB5_Revival.mdl",
"models/ZB5/Claws/v_ZB5_Revival.mdl"
}

enum _:Options
{
CLASS,
SPRITE,
DO_SKILL,
DO_SKILL2,
RESET_TIME
}

static Temp_String[64]
new g_IsZombie, g_IsAlive, g_IsConnected
new g_had[33][Options], g_class, g_skill_hud

public plugin_init()
{
Register_SafetyFunc()
	
register_think(BURN_CLASSNAME, "fw_Burn_Think")		
register_touch(BURN_CLASSNAME, "*", "fw_Burn_Touch")
	
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
register_forward(FM_EmitSound, "fw_EmitSound")	

g_skill_hud = zp_get_synchud_id(SYNCHUD_ZOMBIE_SKILL)
g_class = zb5_register_zclass("Metatronic", "\y(Immortality)", 0, 1, 1, 7000,0,0)
}

public plugin_precache()
{
new i	
for(i = 0; i < sizeof(ZombieSound); i++)
PrecacheSound(ZombieSound[i])	

for(i = 0; i < sizeof(ZombieModel); i++)
PrecacheModel(ZombieModel[i])		
}

public zp_fw_round_new()remove_entity_name(BURN_CLASSNAME)
public zb5_zclass_selected_post(id, class)
{
if(class == g_class)
Get_Class(id)
}

public Get_Class(id)
{	
zb5_remove_zclass(id)
Reset_All(id, 1)

g_had[id][CLASS] = true	

cs_set_player_model(id, "ZB5_Revival")

cs_set_player_view_model(id, CSW_KNIFE, "models/ZB5/Claws/v_ZB5_Revival.mdl")
cs_set_player_weap_model(id, CSW_KNIFE, "")
set_weapon_anim(id, 3)
}

public Reset_All(id, full)
{
if(pev_valid(g_had[id][SPRITE])) remove_entity(g_had[id][SPRITE])	
g_had[id][SPRITE] = -1
	
g_had[id][DO_SKILL] = false
g_had[id][DO_SKILL2] = false

g_had[id][RESET_TIME] = 0

if(full)	
g_had[id][CLASS] = false
}
////// HUD //////
public RuningTime_Player(id)
{		
if(!is_alive(id))
return 
if(!is_zombie(id))
return
if(!g_had[id][CLASS])
return

HUD_SKILL(id)
}
public HUD_SKILL(id)
{	
//// SKILLS /////
if(g_had[id][RESET_TIME] > 0) 
{
g_had[id][RESET_TIME]--
if(!g_had[id][RESET_TIME]) 
Reset_Skill(id)	
}
////////////////////////

if(!g_had[id][DO_SKILL2])		
formatex(Temp_String, sizeof(Temp_String), "^n[AUTOMATIC] - Immortality (Ready)")
else 
formatex(Temp_String, sizeof(Temp_String), "^n[AUTOMATIC] - Immortality^n        (Time: %i)", g_had[id][RESET_TIME])

set_hudmessage(190, 190, 190, -1.0, 0.10, 0, 1.0, 1.0)
ShowSyncHudMsg(id,g_skill_hud, "%s", Temp_String)
}
// SKILL 1
public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
if(!is_alive(victim))
return HAM_IGNORED 
if(!is_zombie(victim))
return HAM_IGNORED
if(!g_had[victim][CLASS])
return HAM_IGNORED

static health; health = get_user_health(victim)
if((health <= 500) && !g_had[victim][DO_SKILL])	
{
g_had[victim][DO_SKILL]	= true	
g_had[victim][DO_SKILL2] = true	

switch(zb5_get_zombie_info(victim, EVO_LV))
{
case HOST:g_had[victim][RESET_TIME] = 6
case ORIGIN:g_had[victim][RESET_TIME] = 9
case NORMAL:g_had[victim][RESET_TIME] = 4
}

fm_set_rendering(victim)
fm_set_rendering(victim, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 200)

if(!zb5_get_user_nvg(victim))
Make_ScreenFade(victim, 1.0, 0, 0, random_num(100,250), 100, FADE_IN)

EmitSound(victim, CHAN_VOICE, ZombieSound[2])

fm_set_user_godmode(victim, 1)
create_fake_attack(victim, "knife")
set_weapon_anim(victim, 2)

set_weapons_timeidle(victim, CSW_KNIFE, 1.0)
set_player_nextattack(victim, 1.0)

fm_set_user_health(victim, health + 2000)
set_fov(victim, 110)
Make_FireBurn(victim)
}
return HAM_HANDLED
}
public Reset_Skill(id)
{
if(!zb5_get_user_nvg(id))
Make_ScreenFade(id, 1.0, 100, 0, 0, 90, FADE_OUT)	

fm_set_user_godmode(id, 0)	
fm_set_rendering(id)	

set_fov(id)
EmitSound(id, CHAN_VOICE, ZombieSound[3])
g_had[id][DO_SKILL2] = false
}
public Make_FireBurn(id)
{		
g_had[id][SPRITE] = create_entity("env_sprite")
static iEnt; iEnt = g_had[id][SPRITE]
if(!is_valid_ent(iEnt))return

static Float:MyOrigin[3]
entity_get_vector(id, EV_VEC_origin, MyOrigin)

entity_set_string(iEnt, EV_SZ_classname, BURN_CLASSNAME)
entity_set_model(iEnt, "sprites/ZB5/holybomb_burn.spr")

// set info for ent
entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_NOCLIP)
entity_set_int(iEnt, EV_INT_solid, SOLID_NOT)

entity_set_int(iEnt, EV_INT_rendermode, kRenderTransAdd)
entity_set_float(iEnt, EV_FL_renderamt, 250.0)
entity_set_float(iEnt, EV_FL_scale, 5.0)

entity_set_int(iEnt,EV_INT_iuser1, id)
entity_set_edict(iEnt,EV_ENT_aiment, id)

entity_set_vector(iEnt, EV_VEC_origin, MyOrigin)
entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1)
}
public fw_Burn_Think(iEnt)
{
if(!is_valid_ent(iEnt)) 
return

static Float:fFrame; fFrame = entity_get_float(iEnt, EV_FL_frame) 
static Float:originF[3]; entity_get_vector(iEnt, EV_VEC_origin, originF) 

// effect exp
fFrame += 1.0
if(fFrame > 14.0) fFrame = 0.0

entity_set_float(iEnt, EV_FL_frame, fFrame)
entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1)

static owner; owner = entity_get_int(iEnt, EV_INT_iuser1) 
if (!is_alive(owner) || !is_zombie(owner) || !g_had[owner][CLASS])
{
remove_entity(iEnt)
return;
}
}
public fw_Burn_Touch(iEnt, id)
{
if (!is_valid_ent(iEnt)) 
return;

static owner; owner = entity_get_int(iEnt, EV_INT_iuser1) 
static health; health = get_user_health(id)

if(!is_alive(id) || is_zombie(id))
return

if(health > 5)
ExecuteHam(Ham_TakeDamage, id, iEnt, owner, 1.0, DMG_BURN)
else user_kill(id)
}
public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch) 
{ 
if (sample[0] == 'h' && sample[1] == 'o' && sample[2] == 's' && sample[3] == 't' && sample[4] == 'a' && sample[5] == 'g' && sample[6] == 'e') 
return FMRES_SUPERCEDE; 

if(!is_alive(id))
return FMRES_IGNORED; 
if(!is_zombie(id))
return FMRES_IGNORED; 
if(!g_had[id][CLASS])
return FMRES_IGNORED; 

if(sample[7] == 'b' && sample[8] == 'h' && sample[9] == 'i' && sample[10] == 't') 
{
emit_sound(id, channel, ZombieSound[0], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
if(sample[7] == 'd' && ((sample[8] == 'i' && sample[9] == 'e') || (sample[8] == 'e' && sample[9] == 'a'))) 
{
emit_sound(id, channel, ZombieSound[1], volume, attn, flags, pitch) 
return FMRES_SUPERCEDE 
}
return FMRES_IGNORED 
} 

/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)
public zb5_zclass_remove_post(id)Reset_All(id, 1)

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Reset_All(id, 1)
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)
}

Safety_Disconnected(id)
{
Reset_All(id, 1)
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsZombie, id)
UnSet_BitVar(g_IsAlive, id)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)

if(zp_core_is_zombie(id))
{
Reset_All(id, 0)
Set_BitVar(g_IsZombie, id)

if(g_had[id][CLASS])	
Get_Class(id)
}else Reset_All(id, 1)
}
public zp_fw_core_cure_post(id)
{
UnSet_BitVar(g_IsZombie, id)
}

public fw_Safety_Killed_Post(id)
{
Reset_All(id, 0)

UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Reset_All(id, 0)

Set_BitVar(g_IsZombie, id)

if(g_had[id][CLASS])	
Get_Class(id)
}
is_alive(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsAlive, id))
return 0

return 1
}
is_zombie(id)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0
if(!Get_BitVar(g_IsZombie, id))
return 0

return 1
}

/* ===============================
--------- END OF SAFETY  ---------
=================================*/
