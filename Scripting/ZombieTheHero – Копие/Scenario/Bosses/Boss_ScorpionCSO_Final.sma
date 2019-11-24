/* Boss CSO By Itachi Uchiha- 
My Canal Youtube https://www.youtube.com/channel/UCar-rq1Dvuvha9Id2ypP7tg
My Facebook Contact https://www.facebook.com/ItachiUchihapro
My Pag Facebook https://www.facebook.com/TutorialesItachi/
Wep Forro http://itachiuchiha-mods.esy.es/
Boss All https://daniel3536.jimdo.com/news-boss-for-cs-1-6-2017/
*/

#include <amxmodx>
#include <engine>
#include <fakemeta_util>
#include <ZombieMod5>
#include <ScenarioMod>


//Configs Boss
#define NAME_MAP "zs_behind2"
#define CLASS_NAME_BOSS "Boss_Scorpion_CSO"
#define HEALTH_BOSS 100000.0
#define HEALTH_BOSS_REGENERADOR 150.0
#define SPEED_SCORPION 300.0

//Damage Attack
#define DAMAGE_ATTACK 50.0
#define DAMAGE_ATTACK2 100.0
#define DAMAGE_FINAL 1000.0
#define DAMAGE_REMOLINO 1000

//Remove Task Anti Bug
#define HP_SPRITE 1
#define ATTACK_TASK 2
#define ATTACK_SPEED 3
#define ATTACK_REMOLINO 4
#define SALUD_GENERADOR 5
#define EMPUJAR_REMOLINO 6
#define START_MUSIC 7

//Map Origin Boss
#define Map1 725.732604
#define Map2 291.838897
#define Map3 120.031250

enum
{
ANIM_DUMMY = 0,
ZBS_APPEAR,
ZBS_IDLE1,
ZBS_WALK,
ZBS_RUN,
ZBS_ATTACK1,
ZBS_ATTACK2,
ZBS_ATTACK3,
ZBS_ATTACK_TENTACLE1,
ZBS_ATTACK_TENTACLE2,
ZBS_ATTACK_STORM1,
ZBS_ATTACK_STORM2,
ZBS_ATTACK_STORM_END,
ZBS_GUARD_START,
ZBS_GUARD_LOOP,
ZBS_GUARD_END,
ZBS_GUARD_BROCKEN,
ZBS_DASH_START,
ZBS_DASH_LOOP,
ZBS_DASH_END,
ZBS_DEATH
}


new const Boss_Model_CSO[] = "models/Scorpion_CSO/scorpion_boss.mdl"

new const Remolino_Boss[] = "models/Scorpion_CSO/ef_hurricane.mdl"
new const Remolino_Tierra[] = "models/Scorpion_CSO/ef_scorpion_hole.mdl"
new const Remolino_Tierra2[] = "models/Scorpion_CSO/ef_scorpion_hole2.mdl"
new const Model_Tentacle[] = "models/Scorpion_CSO/tentacle4.mdl"

new const Hp_Sprite_Boss[] = "sprites/Scorpion_CSO/hp.spr"
new const Scenarios_Start[] = "sound/Scorpion_CSO/scenario_start.mp3"

new const Sound_Boss_CSO[20][] = 
{
"Scorpion_CSO/zbs_appear.wav",
"Scorpion_CSO/zbs_attack1.wav",
"Scorpion_CSO/zbs_attack2.wav",
"Scorpion_CSO/zbs_attack3.wav",
"Scorpion_CSO/zbs_attack_tentacle1_1.wav",
"Scorpion_CSO/zbs_attack_tentacle1_2.wav",
"Scorpion_CSO/zbs_attack_tentacle2_1.wav",
"Scorpion_CSO/zbs_attack_storm1_1.wav",
"Scorpion_CSO/zbs_attack_storm1_2.wav",
"Scorpion_CSO/zbs_attack_storm2_1.wav",
"Scorpion_CSO/zbs_attack_storm_end.wav",
"Scorpion_CSO/zbs_dash_start.wav",
"Scorpion_CSO/death.wav",
"Scorpion_CSO/sandstorm.wav",
"Scorpion_CSO/windstorm.wav",
"Scorpion_CSO/Caminar_v1.wav",
"Scorpion_CSO/Caminar_v2.wav",
"Scorpion_CSO/zbs_guard_start.wav",
"Scorpion_CSO/zbs_guard_loop.wav",
"Scorpion_CSO/zbs_guard_start.wav"
}

new Boss_Model_Linux, Damage_Off, Start_Boss_CSO, Damage_Touch, y_hpbar, y_think, y_bleeding[2], mapname[31], Remolino_Posicion

new Float:Origin[3], Float:Skill_Time_Boss, Float:Skill_Time_Boss2, Float:HP_V2, HP_Death

public plugin_init()
{
get_mapname(mapname,31)
if(!equali(mapname, NAME_MAP)) return

register_event("HLTV", "event_newround", "a", "1=0", "2=0")
register_think(CLASS_NAME_BOSS, "cso_boss_think")
register_touch(CLASS_NAME_BOSS, "*", "cso_boss_touch")
register_touch("Damage_Storm", "*", "Remolino_Touch")
register_touch("Damage_Tentacle", "*", "Tentacle_Touch")

register_clcmd("say /origin", "npc_position")
register_clcmd("say /create", "create_cso_scorpion")
}
public plugin_cfg()						// Cvar's goes here
{
server_cmd("mp_freezetime 5.0")
}
public plugin_precache()
{
get_mapname(mapname,31)
if(!equali(mapname, NAME_MAP)) return

for(new i = 0; i < sizeof(Sound_Boss_CSO); i++)
precache_sound(Sound_Boss_CSO[i])
y_bleeding[0] = precache_model("sprites/blood.spr")
y_bleeding[1] = precache_model("sprites/bloodspray.spr")

Boss_Model_Linux = precache_model(Boss_Model_CSO)
precache_model(Remolino_Boss)
precache_model(Remolino_Tierra)
precache_model(Remolino_Tierra2)
precache_model(Model_Tentacle)
precache_model(Hp_Sprite_Boss)

precache_generic(Scenarios_Start)

new Neblina = create_entity("env_fog");
DispatchKeyValue(Neblina, "density", "0.0005")
DispatchKeyValue(Neblina, "rendercolor", "218 200 146")
}
public event_newround()
{	
if(pev_valid(y_think))
{
remove_task(y_think+ATTACK_TASK)
remove_task(y_think+ATTACK_SPEED)
remove_task(y_think+ATTACK_REMOLINO)
remove_task(y_think+SALUD_GENERADOR)
remove_task(y_think+HP_SPRITE)
remove_entity_name(CLASS_NAME_BOSS)
remove_entity_name("Damage_Storm")
remove_entity_name("Models_Remolino")
remove_entity_name("Damage_Tentacle")
}
client_cmd(0, "mp3 stop")
remove_task(EMPUJAR_REMOLINO)
remove_task(START_MUSIC)
if(pev_valid(y_hpbar)) remove_entity(y_hpbar)
}
public npc_position(id)
{
pev(id, pev_origin, Origin)

client_print(id, print_console, "Origin %f %f %f", Origin[0], Origin[1], Origin[2])
}
public zp_fw_game_start()
{
get_mapname(mapname,31)
if(!equali(mapname, NAME_MAP)) return

create_cso_scorpion()	
}
public create_cso_scorpion()
{
new ent = create_entity("info_target")
y_think = ent

Remolino_Posicion = 0
Damage_Touch = 0
HP_Death = 1

Origin[0] = Map1; Origin[1] = Map2; Origin[2] = Map3;

entity_set_origin(ent, Origin)
entity_set_float(ent, EV_FL_takedamage, 1.0)
entity_set_float(ent, EV_FL_health, HEALTH_BOSS + 1000.0)

emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[0], 1.0, ATTN_NORM, 0, PITCH_NORM)

entity_set_string(ent, EV_SZ_classname, CLASS_NAME_BOSS)
entity_set_model(ent, Boss_Model_CSO)
entity_set_int(ent, EV_INT_solid, SOLID_BBOX)
entity_set_int(ent, EV_INT_movetype, MOVETYPE_PUSHSTEP)

new Float:maxs[3] = {120.0, 120.0, 70.0}
new Float:mins[3] = {-200.0, -120.0, -35.0}
entity_set_size(ent, mins, maxs)
entity_set_int(ent, EV_INT_modelindex, Boss_Model_Linux)
anim(ent, ZBS_APPEAR)

set_pev(ent, pev_nextthink, get_gametime() + 12)

if(!Damage_Off)
{
Damage_Off = 1
RegisterHamFromEntity(Ham_TakeDamage, ent, "cso_boss_take_damage", 1)
}
y_hpbar = create_entity("env_sprite")
set_pev(y_hpbar, pev_scale, 0.6)
set_pev(y_hpbar, pev_owner, ent)
engfunc(EngFunc_SetModel, y_hpbar, Hp_Sprite_Boss)	
set_task(0.1, "cso_boss_ready", ent+HP_SPRITE, _, _, "b")

set_task(0.5, "Replay_Music", ent)
}
public Replay_Music()
{
client_cmd(0, "mp3 play %s", Scenarios_Start)
set_task(180.0, "Replay_Music", START_MUSIC)
}
public cso_boss_ready(ent)
{
ent -= HP_SPRITE
if(!pev_valid(ent))
{
remove_task(ent+HP_SPRITE)
return
}
static Float:Origin[3], Float:cso_boss_health
pev(ent, pev_origin, Origin)
Origin[2] += 450.0
engfunc(EngFunc_SetOrigin, y_hpbar, Origin)
pev(ent, pev_health, cso_boss_health)
if(HEALTH_BOSS < (cso_boss_health - 1000.0))
{
set_pev(y_hpbar, pev_frame, 100.0)
} else {
set_pev(y_hpbar, pev_frame, 0.0 + ((((cso_boss_health - 1000.0) - 1 ) * 100) / HEALTH_BOSS))
}		
}

//-------------------------------------SCORPION ATTACK-------------------------------------

public scorpion_attack(ent)
{
if(!pev_valid(ent) || Start_Boss_CSO)
return	
Start_Boss_CSO = 1
Remolino_Posicion = 0
set_pev(ent, pev_movetype, MOVETYPE_NONE)

new Attack_Modos = random_num(0,3)
switch(Attack_Modos) {
case 0: 
{
set_task(1.0, "Attack1_Scorpion", ent+ATTACK_TASK)
set_task(2.0, "simple_attack_reload", ent+ATTACK_TASK)
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
anim(ent, ZBS_ATTACK1)
}
case 1: 
{
set_task(1.6, "Attack1_Scorpion", ent+ATTACK_TASK)
set_task(2.5, "simple_attack_reload", ent+ATTACK_TASK)
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
anim(ent, ZBS_ATTACK2)
}
case 2: 
{
set_task(2.1, "Attack2_Scorpion", ent+ATTACK_TASK)
set_task(4.2, "simple_attack_reload", ent+ATTACK_TASK)
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
anim(ent, ZBS_ATTACK3)
}
case 3: 
{
Damage_Touch = 1
set_task(5.0, "Scorpion_Tentacle", ent+ATTACK_TASK)
set_task(9.0, "simple_attack_reload", ent+ATTACK_TASK)
set_task(1.0, "Attack_Sound1", ent+ATTACK_TASK)
anim(ent, ZBS_ATTACK_TENTACLE1)
}
}
}
public Attack_Sound1(ent)
{
ent -= ATTACK_TASK
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
set_task(2.0, "Attack_Sound2", ent+ATTACK_TASK)
}
public Attack_Sound2(ent)
{
ent -= ATTACK_TASK
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[5], 1.0, ATTN_NORM, 0, PITCH_NORM)
}
public Attack_Sound3(ent)
{
ent -= ATTACK_TASK
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[6], 1.0, ATTN_NORM, 0, PITCH_NORM)
}
public Attack1_Scorpion(ent)
{
ent -= ATTACK_TASK
if(!pev_valid(ent))
return

static Float:Origin[3]; get_position(ent, 250.0, 0.0, 0.0, Origin)
static Float:POrigin[3]

for(new i = 0; i < get_maxplayers(); i++)
{
if(!is_user_alive(i))
continue

pev(i, pev_origin, POrigin)
if(get_distance_f(Origin, POrigin) > 270.0)
continue

ExecuteHam(Ham_TakeDamage, i, 0, i, DAMAGE_ATTACK, DMG_SLASH)
ScreenFade(i, 10, {255, 0, 0}, 120)
shake_screen(i)
}
}
public Attack2_Scorpion(ent)
{
ent -= ATTACK_TASK
if(!pev_valid(ent))
return

for(new i = 0; i < get_maxplayers(); i++)
{
if(is_user_alive(i) && entity_range(ent, i) <= 400)
{
ExecuteHam(Ham_TakeDamage, i, 0, i, DAMAGE_ATTACK2, DMG_SLASH)
ScreenFade(i, 10, {255, 0, 0}, 120)
shake_screen(i)
}
}
}

//-------------------------------------SCORPION SPEED ATTACK-------------------------------------
public Velocidad_Enojado(ent)
{
if(!pev_valid(ent) || Start_Boss_CSO)
return
Start_Boss_CSO = 1
Damage_Touch = 1
Remolino_Posicion = 0
anim(ent, ZBS_DASH_START)
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[11], 1.0, ATTN_NORM, 0, PITCH_NORM)

set_task(1.0, "Velocidad_Enojado2", ent+ATTACK_SPEED)
}
public Velocidad_Enojado2(ent)
{
ent -= ATTACK_SPEED
anim(ent, ZBS_DASH_LOOP)
set_task(0.2, "Velocidad_Enojado3", ent+ATTACK_SPEED, _, _, "b")
set_task(1.0, "Velocidad_Enojado4", ent+ATTACK_SPEED)
}

public Velocidad_Enojado3(ent)
{
ent -= ATTACK_SPEED
if(!pev_valid(ent))
return
entity_set_int(ent, EV_INT_sequence, 18)
entity_set_float(ent, EV_FL_framerate, 1.0)
emit_sound(ent, CHAN_STREAM, Sound_Boss_CSO[16], 1.0, ATTN_NORM, 0, PITCH_NORM)
set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)
static Float:Origin[3]
get_position(ent, 3500.0, 0.0, 0.0, Origin)
control_ai2(ent, Origin, 1000.0)
for(new i = 0; i < get_maxplayers(); i++)
{
if(is_user_alive(i) && entity_range(ent, i) <= 200)
{
shake_screen(i)
ScreenFade(i, 10, {255, 0, 0}, 120)
ExecuteHam(Ham_TakeDamage, i, 0, i, DAMAGE_FINAL, DMG_SLASH)
}
}
}
public Velocidad_Enojado4(ent)
{
ent -= ATTACK_SPEED
if(!pev_valid(ent))
return

set_pev(ent, pev_movetype, MOVETYPE_NONE)
remove_task(ent+ATTACK_SPEED)

anim(ent, ZBS_DASH_END)
Damage_Touch = 0
set_task(2.0, "reload_scorpion", ent)
}
public reload_scorpion(ent)
{
Start_Boss_CSO = 0
}

//-------------------------------------SCORPION REMOLINO V1-------------------------------------

public Sound1_Remolino(ent)
{
ent -= ATTACK_REMOLINO
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[7], 1.0, ATTN_NORM, 0, PITCH_NORM)
}
public Sound2_Remolino(ent)
{
ent -= ATTACK_REMOLINO
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[8], 1.0, ATTN_NORM, 0, PITCH_NORM)
}
public Sound3_Remolino(ent)
{
ent -= ATTACK_REMOLINO
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[9], 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public Model_Tierra(ent) 
{
ent -= ATTACK_REMOLINO
Models_Tierra(ent, Remolino_Tierra, 0, 1)
}
public Model_Tierra2(ent) 
{	
ent -= ATTACK_REMOLINO
Models_Tierra(ent, Remolino_Tierra2, 0, 1)
}
public Model_Tierra3(ent) 
{	
ent -= ATTACK_REMOLINO
Models_Tierra(ent, Remolino_Tierra2, 0, 0)
}
public Posicion_Storm(ent)
{
if(Start_Boss_CSO)
return

Start_Boss_CSO = 1
Damage_Touch = 1
Remolino_Posicion = 1

set_task(3.0, "Scorpion_Storm", ent+ATTACK_REMOLINO)

}
public Scorpion_Storm(ent)
{
ent -= ATTACK_REMOLINO
if(!pev_valid(ent))

Remolino_Posicion = 0
anim(ent, ZBS_ATTACK_STORM1)

set_pev(ent, pev_movetype, MOVETYPE_NONE)

new Float:maxs[3] = {0.0, 0.0, 0.0}
new Float:mins[3] = {-0.0, -0.0, -35.0}
entity_set_size(ent, mins, maxs)

set_task(1.0, "Sound1_Remolino", ent+ATTACK_REMOLINO)
set_task(4.0, "Sound2_Remolino", ent+ATTACK_REMOLINO)

set_task(1.1, "Model_Tierra", ent+ATTACK_REMOLINO)
set_task(1.0, "Model_Tierra2", ent+ATTACK_REMOLINO)

set_task(7.0, "Start_Remolino", ent+ATTACK_REMOLINO)
set_task(8.0, "Devolver_Fuerza", ent+ATTACK_REMOLINO)
}
public Devolver_Fuerza(ent)
{
ent -= ATTACK_REMOLINO
if(!pev_valid(ent))
return
Damage_Touch = 0
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[10], 1.0, ATTN_NORM, 0, PITCH_NORM)

anim(ent, ZBS_ATTACK_STORM_END)
new Float:maxs[3] = {120.0, 120.0, 70.0}
new Float:mins[3] = {-200.0, -120.0, -35.0}
entity_set_size(ent, mins, maxs)

Models_Tierra(ent, Remolino_Tierra, 1, 0)
set_task(0.1, "Model_Tierra3", ent+ATTACK_REMOLINO)

set_task(6.0, "reload_scorpion", ent+ATTACK_REMOLINO)
set_task(6.1, "Remove_Task_Remolino", ent+ATTACK_REMOLINO)
}
public Start_Remolino(ent)
{
ent -= ATTACK_REMOLINO
if(!pev_valid(ent))
return

static Float:StartOrigin[3], Float:TargetOrigin[8][3]

get_position(ent, 5.0, 0.0, 140.0, StartOrigin)

new Remolino_Random = random_num(0,1)
switch(Remolino_Random) {
case 0: 
{
get_position(ent, 500.0, 500.0, 0.0, TargetOrigin[0])
get_position(ent, 500.0, -500.0, 0.0, TargetOrigin[1])
get_position(ent, -500.0, 500.0, 0.0, TargetOrigin[2])
get_position(ent, -500.0, -500.0, 0.0, TargetOrigin[3])
get_position(ent, 500.0, 0.0, 0.0, TargetOrigin[4])
get_position(ent, -500.0, 0.0, 0.0, TargetOrigin[5])
get_position(ent, 0.0, 500.0, 0.0, TargetOrigin[6])
get_position(ent, 0.0, -500.0, 0.0, TargetOrigin[7])
}
case 1: 
{
get_position(ent, 80.0, 80.0, 0.0, TargetOrigin[0])
get_position(ent, 80.0, -80.0, 0.0, TargetOrigin[1])
get_position(ent, -80.0, 80.0, 0.0, TargetOrigin[2])
get_position(ent, -80.0, -80.0, 0.0, TargetOrigin[3])
get_position(ent, 80.0, 0.0, 0.0, TargetOrigin[4])
get_position(ent, -80.0, 0.0, 0.0, TargetOrigin[5])
get_position(ent, 0.0, 80.0, 0.0, TargetOrigin[6])
get_position(ent, 0.0, -80.0, 0.0, TargetOrigin[7])
}
}

for(new i = 0; i < 8; i++)
Create_Remolino1(StartOrigin, TargetOrigin[i])
}
public Create_Remolino1(Float:StartOrigin[3], Float:TargetOrigin[3])
{
static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if(!pev_valid(Ent)) return

set_pev(Ent, pev_movetype, MOVETYPE_PUSHSTEP)
set_pev(Ent, pev_solid, SOLID_TRIGGER)

set_pev(Ent, pev_classname, "Damage_Storm")
engfunc(EngFunc_SetModel, Ent, Remolino_Boss)
set_pev(Ent, pev_origin, StartOrigin)

anim(Ent, 0)

new Float:maxs[3] = {50.0, 50.0, 100.0}
new Float:mins[3] = {-50.0, -50.0, -8.0}
entity_set_size(Ent, mins, maxs)

static Float:Velocity[3]
get_speed_vector(StartOrigin, TargetOrigin, 1400.0, Velocity)

set_pev(Ent, pev_velocity, Velocity)

set_task(1.0, "Remover_Remolino", Ent+ATTACK_REMOLINO)
}
public Remover_Remolino(Ent)
{
Ent -= ATTACK_REMOLINO
if(!pev_valid(Ent)) return
engfunc(EngFunc_RemoveEntity, Ent)
}
public Remove_Task_Remolino(Ent) remove_task(Ent+ATTACK_REMOLINO)

public Remolino_Touch(Ent, id)
{
if(!pev_valid(Ent))
return

new Classname[32]
if(pev_valid(id)) pev(id, pev_classname, Classname, sizeof(Classname))

if(equal(Classname, "Damage_Storm"))
return

if(is_user_alive(id))
{
ExecuteHamB(Ham_TakeDamage, id, 0, id, DAMAGE_REMOLINO, DMG_SLASH)
static Float:Jugador[3]
Jugador[2] = 1000.0
set_pev(id, pev_velocity, Jugador)
}
}
public Models_Tierra(ent, const Model[], Anim, Jalar_Humanos)
{
new Tierra = create_entity("info_target")

if( !pev_valid( Tierra ) )
{
return;
}

get_position(ent, 5.0, 0.0, 140.0, Origin)

entity_set_origin(Tierra, Origin)

entity_set_model(Tierra, Model)
entity_set_int(Tierra, EV_INT_solid, SOLID_BBOX)
entity_set_int(Tierra, EV_INT_movetype, MOVETYPE_TOSS)

set_pev(Tierra, pev_classname, "Models_Remolino")

anim(Tierra, Anim)

set_task(5.4, "Remover_Tierra", Tierra+ATTACK_REMOLINO)

for(new i = 0; i < get_maxplayers(); i++)
{
if(is_user_alive(i) && entity_range(ent, i) <= 1100.0)
{
static arg[2]
arg[0] = ent
arg[1] = i

if(Jalar_Humanos)
set_task(0.01, "Jalar_Scorpion", EMPUJAR_REMOLINO, arg, sizeof(arg), "b")
else
set_task(0.01, "Empujar_Scorpion", EMPUJAR_REMOLINO, arg, sizeof(arg), "b")
}
}

set_task(5.0, "Stop_Jalar", ent+2012)	
}
public Stop_Jalar(Jalar)
{
Jalar -= 2012

static ent
ent = find_ent_by_class(-1, "Models_Remolino")

if(pev_valid(ent))
remove_entity(ent)
remove_task(EMPUJAR_REMOLINO)
}
public Remover_Tierra(Tierra)
{
Tierra -= ATTACK_REMOLINO
if(!pev_valid(Tierra)) return
engfunc(EngFunc_RemoveEntity, Tierra)
}

//-------------------------------------SCORPION REMOLINO V2-------------------------------------





//-------------------------------------SCORPION TENTACLE-------------------------------------

public Scorpion_Tentacle(ent)
{
ent -= ATTACK_TASK
if(!pev_valid(ent))
return

set_task(1.0, "Start_Tentacle", ent+ATTACK_TASK)
}
public Start_Tentacle(ent)
{
ent -= ATTACK_TASK
if(!pev_valid(ent))
return

static Float:beam_origin[33][3]

get_position(ent, 400.0, 20.0, 0.0, beam_origin[0])
get_position(ent, 400.0, -20.0, 0.0, beam_origin[1])

get_position(ent, 450.0, 20.0, 0.0, beam_origin[3])
get_position(ent, 450.0, -20.0, 0.0, beam_origin[4])

get_position(ent, 500.0, 20.0, 0.0, beam_origin[5])
get_position(ent, 500.0, -20.0, 0.0, beam_origin[6])

get_position(ent, 550.0, 20.0, 0.0, beam_origin[7])
get_position(ent, 550.0, -20.0, 0.0, beam_origin[8])

get_position(ent, 600.0, 20.0, 0.0, beam_origin[9])
get_position(ent, 600.0, -20.0, 0.0, beam_origin[10])

get_position(ent, 650.0, 20.0, 0.0, beam_origin[11])
get_position(ent, 650.0, -20.0, 0.0, beam_origin[12])

get_position(ent, 700.0, 20.0, 0.0, beam_origin[13])
get_position(ent, 700.0, -20.0, 0.0, beam_origin[14])

get_position(ent, 750.0, 20.0, 0.0, beam_origin[15])
get_position(ent, 750.0, -20.0, 0.0, beam_origin[16])


//2
get_position(ent, 400.0, 80.0, 0.0, beam_origin[17])
get_position(ent, 400.0, -80.0, 0.0, beam_origin[18])

get_position(ent, 450.0, 80.0, 0.0, beam_origin[19])
get_position(ent, 450.0, -80.0, 0.0, beam_origin[20])

get_position(ent, 500.0, 80.0, 0.0, beam_origin[21])
get_position(ent, 500.0, -80.0, 0.0, beam_origin[22])

get_position(ent, 550.0, 80.0, 0.0, beam_origin[23])
get_position(ent, 550.0, -80.0, 0.0, beam_origin[24])

get_position(ent, 600.0, 80.0, 0.0, beam_origin[25])
get_position(ent, 600.0, -80.0, 0.0, beam_origin[26])

get_position(ent, 650.0, 80.0, 0.0, beam_origin[27])
get_position(ent, 650.0, -80.0, 0.0, beam_origin[28])

get_position(ent, 700.0, 80.0, 0.0, beam_origin[29])
get_position(ent, 700.0, -80.0, 0.0, beam_origin[30])

get_position(ent, 750.0, 80.0, 0.0, beam_origin[31])
get_position(ent, 750.0, -80.0, 0.0, beam_origin[32])

for(new i = 0; i < 33; i++)
Create_Tentacle1(beam_origin[i])
}

public Create_Tentacle1(Float:StartOrigin[3])
{
static Ent; Ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
if(!pev_valid(Ent)) return

set_pev(Ent, pev_movetype, MOVETYPE_STEP)
set_pev(Ent, pev_solid, SOLID_BBOX)

set_pev(Ent, pev_classname, "Damage_Tentacle")
engfunc(EngFunc_SetModel, Ent, Model_Tentacle)
set_pev(Ent, pev_origin, StartOrigin)

anim(Ent, 0)

new Float:maxs[3] = {1.0, 1.0, 1.0}
new Float:mins[3] = {-1.0, -1.0, -30.0}
entity_set_size(Ent, mins, maxs)

set_task(3.9, "Remover_Tentacle", Ent+ATTACK_TASK)
}
public Remover_Tentacle(Ent)
{
Ent -= ATTACK_TASK
if(!pev_valid(Ent)) return
anim(Ent, 2)
set_task(0.7, "Remover_Tentacle2", Ent+ATTACK_TASK)
}
public Remover_Tentacle2(Ent)
{
Ent -= ATTACK_TASK
if(pev_valid(Ent))
engfunc(EngFunc_RemoveEntity, Ent)
}
public Tentacle_Touch(Ent, id)
{
if(!pev_valid(Ent))
return

new Classname[32]
if(pev_valid(id)) pev(id, pev_classname, Classname, sizeof(Classname))

if(equal(Classname, "Damage_Tentacle"))
return

if(is_user_alive(id))
{
set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
set_pev(id, pev_maxspeed, 1.0)
}
}
//-------------------------------------SCORPION HP GENERADOR-----------------------------------
public Salud_Regenerador(ent)
{
ent -= SALUD_GENERADOR
if(!pev_valid(ent) && !HP_Death) return

if(pev(ent, pev_health) >= HEALTH_BOSS)
{
return
} else
set_pev(ent, pev_health, pev(ent, pev_health) + HEALTH_BOSS_REGENERADOR)

}

public Scorpion_Salud_V0(ent)
{
if(!pev_valid(ent) || Start_Boss_CSO)
return
Start_Boss_CSO = 1

set_task(1.0, "Scorpion_Salud_V1", ent+SALUD_GENERADOR)
}
public Scorpion_Salud_V1(ent)
{
ent -= SALUD_GENERADOR
if(!pev_valid(ent) && !HP_Death)
return
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[17], 1.0, ATTN_NORM, 0, PITCH_NORM)

anim(ent, ZBS_GUARD_START)
set_task(4.0, "Scorpion_Salud_V2", ent+SALUD_GENERADOR)
}
public Scorpion_Salud_V2(ent)
{
ent -= SALUD_GENERADOR
if(!pev_valid(ent) && !HP_Death)
return
set_pev(ent, pev_skin, 1)
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[18], 1.0, ATTN_NORM, 0, PITCH_NORM)

anim(ent, ZBS_GUARD_LOOP)
set_task(7.0, "Scorpion_Salud_V3", ent+SALUD_GENERADOR)

set_task(0.0, "Salud_Regenerador", ent+SALUD_GENERADOR)
set_task(0.4, "Salud_Regenerador", ent+SALUD_GENERADOR, _, _, "b")
}
public Scorpion_Salud_V3(ent)
{
ent -= SALUD_GENERADOR
if(!pev_valid(ent) && !HP_Death)
return
set_pev(ent, pev_skin, 0)
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[19], 1.0, ATTN_NORM, 0, PITCH_NORM)

remove_task(ent+SALUD_GENERADOR)
anim(ent, ZBS_GUARD_END)
set_task(2.0, "reload_scorpion", ent)
}

//-------------------------------------SCORPION END SKILLS-------------------------------------
public simple_attack_reload(ent)
{
ent -= ATTACK_TASK
remove_task(ent+ATTACK_TASK)
Start_Boss_CSO = 0
Damage_Touch = 0
}
public cso_boss_touch(ent, id)
{
if(!pev_valid(id))
return

if(is_user_alive(id) && Damage_Touch)
{
ExecuteHam(Ham_TakeDamage, id, 0, id, DAMAGE_FINAL, DMG_SLASH)
shake_screen(id)
ScreenFade(id, 10, {255, 0, 0}, 120)
}
}
public reload_run(ent)
{
Start_Boss_CSO = 0
anim(ent, ZBS_IDLE1)
}
public cso_boss_think(ent)
{
if(!pev_valid(ent))
return
if(pev(ent, pev_iuser3))
return
if(pev(ent, pev_health) - 1000.0 < 0.0)
{
cso_boss_death(ent)
set_pev(ent, pev_iuser3, 1)
return
}
if((pev(ent, pev_health) - 1000.0 <= HEALTH_BOSS / 2.0))
{
if(get_gametime() - 15.0 > HP_V2)
{
Scorpion_Salud_V0(ent)
HP_V2 = get_gametime()
}

}
if(Remolino_Posicion)
{
static Float:Target[3], Float:Origin[3]

pev(ent, pev_origin, Origin)
Target[0] = Map1
Target[1] = Map2
Target[2] = Map3

if(pev(ent, pev_movetype) == MOVETYPE_PUSHSTEP)
{
if(get_distance_f(Target, Origin) > 48.0)
{
Aim_To(ent, Target, 1.0, 1) 
control_ai2(ent, Target, SPEED_SCORPION)

entity_set_float(ent, EV_FL_framerate, 1.0)
entity_set_int(ent, EV_INT_sequence, ZBS_RUN)

set_pev(ent, pev_nextthink, get_gametime() + 0.0)

emit_sound(ent, CHAN_STREAM, Sound_Boss_CSO[15], 1.0, ATTN_NORM, 0, PITCH_NORM)
}
} else {
Remolino_Posicion = 0
}
}

if(!Start_Boss_CSO)
{
static victim, Float:Origin[3], Float:EnemyOrigin[3]
victim = enemy_distance(ent, 1)
pev(victim, pev_origin, EnemyOrigin)

if(is_user_alive(victim))
{
if(entity_range(victim, ent) <= 290)
{
Aim_To(ent, EnemyOrigin, 2.0, 0) 
scorpion_attack(ent)				
set_pev(ent, pev_nextthink, get_gametime() + 0.1)
} else {
if(pev(ent, pev_sequence) != ZBS_RUN)
anim(ent, ZBS_RUN)

if(get_gametime() - Skill_Time_Boss > Skill_Time_Boss2)
{
static Random_Scorpion
Random_Scorpion = random_num(0, 1)
switch(Random_Scorpion)
{
case 0: Velocidad_Enojado(ent)
case 1: Posicion_Storm(ent)//Scorpion_Storm(ent)
}
Skill_Time_Boss = random_float(22.0, 18.0)
Skill_Time_Boss2 = get_gametime()
}

emit_sound(ent, CHAN_STREAM, Sound_Boss_CSO[15], 1.0, ATTN_NORM, 0, PITCH_NORM)

set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)
get_position(ent, 300.0, 0.0, 0.0, Origin)
Aim_To(ent, EnemyOrigin, 1.0, 1) 
control_ai2(ent, Origin, SPEED_SCORPION)
set_pev(ent, pev_nextthink, get_gametime() + 0.0)

}
} else {
if(pev(ent, pev_sequence) != ZBS_IDLE1)
anim(ent, ZBS_IDLE1)
set_pev(ent, pev_nextthink, get_gametime() + 0.0)
}		
} else {
set_pev(ent, pev_nextthink, get_gametime() + 0.0)
}
return
}
public cso_boss_death(ent)
{	
HP_Death = 0
emit_sound(ent, CHAN_AUTO, Sound_Boss_CSO[12], 1.0, ATTN_NORM, 0, PITCH_NORM)
anim(ent, ZBS_DEATH)
set_pev(ent, pev_movetype, MOVETYPE_NONE)
set_pev(ent, pev_solid, SOLID_NOT)
set_pev(ent, pev_velocity, {0.0, 0.0, 0.0})
set_pev(ent, pev_deadflag, DEAD_DYING)

remove_task(ent+ATTACK_TASK)
remove_task(ent+ATTACK_SPEED)
remove_task(ent+ATTACK_REMOLINO)
remove_task(ent+SALUD_GENERADOR)
remove_task(ent+HP_SPRITE)
remove_task(EMPUJAR_REMOLINO)
remove_task(START_MUSIC)

client_cmd(0, "mp3 stop")

set_task(12.0, "delete_cso_boss", ent)
return HAM_SUPERCEDE	
}
public delete_cso_boss(ent)
{
if(pev_valid(ent))
remove_entity(ent)
if(pev_valid(y_hpbar))
remove_entity(y_hpbar)

zp_round_terminate(1)
}
public cso_boss_take_damage(victim, inflictor, attacker, Float:damage, damagebits)
{
static Float:Origin[3]
fm_get_aim_origin(attacker, Origin)
create_blood(Origin)	
}
stock ScreenFade(id, Timer, Colors[3], Alpha) {	
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, id);
write_short((1<<12) * Timer)
write_short(1<<12)
write_short(0)
write_byte(Colors[0])
write_byte(Colors[1])
write_byte(Colors[2])
write_byte(Alpha)
message_end()
}
stock shake_screen(id)
{
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"),{0,0,0}, id)
write_short(1<<14)
write_short(1<<13)
write_short(1<<13)
message_end()
}
stock anim(ent, sequence) {
set_pev(ent, pev_sequence, sequence)
set_pev(ent, pev_animtime, halflife_time())
set_pev(ent, pev_framerate, 1.0)
}

stock create_blood(const Float:origin[3])
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
write_byte(TE_BLOODSPRITE)
engfunc(EngFunc_WriteCoord, origin[0])
engfunc(EngFunc_WriteCoord, origin[1])
engfunc(EngFunc_WriteCoord, origin[2])
write_short(y_bleeding[1])
write_short(y_bleeding[0])
write_byte(218)
write_byte(7)
message_end()
}
public enemy_distance(ent, can_see)
{
new Float:maxdistance = 4980.0
new indexid = 0	
new Float:current_dis = maxdistance

for(new i = 1 ;i <= get_maxplayers(); i++)
{
if(can_see)
{
if(is_user_alive(i) && attacking1(ent, i) && entity_range(ent, i) < current_dis)
{
current_dis = entity_range(ent, i)
indexid = i
}
} else {
if(is_user_alive(i) && entity_range(ent, i) < current_dis)
{
current_dis = entity_range(ent, i)
indexid = i
}			
}
}	

return indexid
}


public bool:attacking1(entindex1, entindex2)
{
if (!entindex1 || !entindex2)
return false
if (pev_valid(entindex1) && pev_valid(entindex1))
{
new flags = pev(entindex1, pev_flags)
if (flags & EF_NODRAW || flags & FL_NOTARGET)
{
return false
}
new Float:lookerOrig[3]
new Float:targetBaseOrig[3]
new Float:targetOrig[3]
new Float:temp[3]
pev(entindex1, pev_origin, lookerOrig)
pev(entindex1, pev_view_ofs, temp)
lookerOrig[0] += temp[0]
lookerOrig[1] += temp[1]
lookerOrig[2] += temp[2]
pev(entindex2, pev_origin, targetBaseOrig)
pev(entindex2, pev_view_ofs, temp)
targetOrig[0] = targetBaseOrig [0] + temp[0]
targetOrig[1] = targetBaseOrig [1] + temp[1]
targetOrig[2] = targetBaseOrig [2] + temp[2]
engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0)
if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
{
return false
} 
else 
{
new Float:flFraction
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
else
{
targetOrig[0] = targetBaseOrig [0]
targetOrig[1] = targetBaseOrig [1]
targetOrig[2] = targetBaseOrig [2]
engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0)
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
else
{
targetOrig[0] = targetBaseOrig [0]
targetOrig[1] = targetBaseOrig [1]
targetOrig[2] = targetBaseOrig [2] - 17.0
engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0)
get_tr2(0, TraceResult:TR_flFraction, flFraction)
if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
{
return true
}
}
}
}
}
return false
}
public Aim_To(iEnt, Float:vTargetOrigin[3], Float:flSpeed, Style)
{
if(!pev_valid(iEnt))	
return

if(!Style)
{
static Float:Vec[3], Float:Angles[3]
pev(iEnt, pev_origin, Vec)

Vec[0] = vTargetOrigin[0] - Vec[0]
Vec[1] = vTargetOrigin[1] - Vec[1]
Vec[2] = vTargetOrigin[2] - Vec[2]
engfunc(EngFunc_VecToAngles, Vec, Angles)
Angles[0] = Angles[2] = 0.0 

set_pev(iEnt, pev_v_angle, Angles)
set_pev(iEnt, pev_angles, Angles)
} else {
new Float:f1, Float:f2, Float:fAngles, Float:vOrigin[3], Float:vAim[3], Float:vAngles[3];
pev(iEnt, pev_origin, vOrigin);
xs_vec_sub(vTargetOrigin, vOrigin, vOrigin);
xs_vec_normalize(vOrigin, vAim);
vector_to_angle(vAim, vAim);

if (vAim[1] > 180.0) vAim[1] -= 360.0;
if (vAim[1] < -180.0) vAim[1] += 360.0;

fAngles = vAim[1];
pev(iEnt, pev_angles, vAngles);

if (vAngles[1] > fAngles)
{
f1 = vAngles[1] - fAngles;
f2 = 360.0 - vAngles[1] + fAngles;
if (f1 < f2)
{
vAngles[1] -= flSpeed;
vAngles[1] = floatmax(vAngles[1], fAngles);
}
else
{
vAngles[1] += flSpeed;
if (vAngles[1] > 180.0) vAngles[1] -= 360.0;
}
}
else
{
f1 = fAngles - vAngles[1];
f2 = 360.0 - fAngles + vAngles[1];
if (f1 < f2)
{
vAngles[1] += flSpeed;
vAngles[1] = floatmin(vAngles[1], fAngles);
}
else
{
vAngles[1] -= flSpeed;
if (vAngles[1] < -180.0) vAngles[1] += 360.0;
}		
}

set_pev(iEnt, pev_v_angle, vAngles)
set_pev(iEnt, pev_angles, vAngles)
}
}
stock control_ai2(ent, Float:VicOrigin[3], Float:speed)
{
if(!pev_valid(ent))
return

static Float:fl_Velocity[3], Float:EntOrigin[3], Float:distance_f, Float:fl_Time

pev(ent, pev_origin, EntOrigin)

distance_f = get_distance_f(EntOrigin, VicOrigin)
fl_Time = distance_f / speed

fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time

set_pev(ent, pev_velocity, fl_Velocity)
}

public Jalar_Scorpion(arg[2])
{
static Float:Origin[3], Float:Speed
pev(arg[0], pev_origin, Origin)

Speed = (1000.0 / entity_range(arg[0], arg[1])) * 75.0

control_ai2(arg[1], Origin, Speed)
}
public Empujar_Scorpion(arg[2])
{
static Float:Origin[3], Float:Speed
pev(arg[0], pev_origin, Origin)

Speed = (1000.0 / entity_range(arg[0], arg[1])) * -90.0

control_ai2(arg[1], Origin, Speed)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
