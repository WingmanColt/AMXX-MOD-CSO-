#include <cs_player_models_api>
#include <cs_weap_models_api>
#include <cs_weap_restrict_api>
#include <cs_maxspeed_api>
#include <WeaponLevels>
#include <fakemeta_util>
#include <engine>

// Bits
#define Get_BitVar(%1,%2)		(%1 & (1 << (%2 & 31)))
#define Set_BitVar(%1,%2)		(%1 |= (1 << (%2 & 31)));
#define UnSet_BitVar(%1,%2)		(%1 &= ~(1 << (%2 & 31)));

#define P_Model "models/ZB5/Primary/p_primary_19032017.mdl" 
#define W_Model "models/ZB5/Primary/w_primary_19032017.mdl"

#define P_Model2 "models/ZB5/Pistols/p_secondary_19032017.mdl"
#define W_Model2 "models/ZB5/Pistols/w_secondary_19032017.mdl"

#define MAX_MONEY 50000
#define MAX_LEVEL 61
#define MAX_EXP 100

#define FADE_IN			0x0000		// Just here so we don't pass 0 into the function
#define FADE_OUT			0x0001		// Fade out (not in)
#define FADE_MODULATE		0x0002		// Modulate (don't blend)
#define FADE_STAYOUT		0x0004		// ignores the duration, stays faded out until new ScreenFade message received

enum PlayerTeams
{
TEAM_ALL = 0,
TEAM_ZOMBIE,
TEAM_HUMAN,
TEAM_START
}
enum 
{
NORMAL,	
ORIGIN,
HOST
}
enum 
{
FEMALE,
HEALTH,
MAXHEALTH,
GRAVITY,
SPEED,
RESET_GRAVITY,
RESET_SPEED,	
KNOCKBACK,
EVO_POINTS,
EVO_LV,
ZCLASS
}
enum
{
SYNCHUD_NOTICE = 0,
SYNCHUD_HUMAN_SKILL,
SYNCHUD_HUMAN_HUD,
SYNCHUD_ZOMBIE_HUD,
SYNCHUD_ZOMBIE_SKILL,
SYNCHUD_HUMAN_QUESTS
}

enum 
{
MODE_NORMAL = 1,
MODE_AMBUSH,
MODE_SWARM
}

enum 
{
WPN_PRIMARY = 1,
WPN_SECONDARY,
WPN_MELEE,
WPN_GRENADE
}

enum
{
WPN_PISTOLS,	
WPN_SHOTGUNS,
WPN_SUBS,
WPN_RIFLES,
WPN_SNIPERS,
WPN_MACHINES,
WPN_DESTROYERS,
WPN_KNIVES,
WPN_SETS
}
enum 
{
QUEST_HEADSHOT,
QUEST_MELEE,
QUEST_SUPPLYBOX,
QUEST_MORALE,
QUEST_INFECT,
QUEST_SURVIVE,
QUEST_MASTER
}
enum 
{
SKILL_E,
SKILL_Q
}
enum 
{	
SKILL_LEVEL,		
SKILL_PLEVEL,	
SKILL_CTIME,
SKILL_RTIME,
SKILL_CAN,
SKILL_DO,
SKILL_CTIME_2,
SKILL_RTIME_2,
SKILL_CAN_2,
SKILL_DO_2
}
// Menus
native zb5_cbox_menu(id)
native zb5_menu_items(id)
native zb5_menu_quest(id)
native zb5_menu_camera(id)
native zb5_zombie_menu(id)
native zb5_zclass_menu(id)
native zp_vote_started()
native zb5_class_menu(id)
native zb5_weapons_menu(id)
native zb5_main_menu(id)

native zb5_register_weapon(const Name[], const Desc[], weapon_type, unlock_cost, vip)
native zb5_register_class(const Name[], const Desc[], unlock_cost)
native zb5_remove_class(id)

// CORE
native zp_core_is_zombie(id)
native zp_core_is_hero(id)
native zp_set_user_hero(id, hero)
native zp_core_is_admin(id)
native zp_core_is_vip(id)
native zp_core_is_female(id)
native zp_core_is_first_zombie(id)
native zp_core_is_last_human(id)
native zp_core_is_last_zombie(id)
native zp_core_zombie_name(id)
native zp_core_get_players_count(Alive, Team)
native zp_core_infect(id, attacker = 0)
native zp_core_cure(id, attacker = 0)
native zp_core_force_hero(id)
native zp_core_force_heroine(id)
native zp_core_round_started()
native zp_core_round()
native zp_GameStart()
native zp_GameAvailable()
native zp_GameEnd()
native zp_core_respawn_as_zombie(id, zombie = true)
native zb5_set_user_unstuck(id)

// PRECACHE
native PrecacheModel(const szFile[])
native PrecacheSound(const szFile[])
native PrecacheGeneric(const szFile[])

// LEVEL SYSTEM
native zb5_get_level_hud(id)
native zb5_get_user_level(id)
native zb5_get_user_exp(id)
native zb5_set_user_level(id, amount)
native zb5_set_user_exp(id, amount, mode)
native zb5_last_weapon(id)
native zb5_item_exp(id)

// REGISTER SYSTEM
native reg_is_user_logged(id)
native reg_is_user_guest(id)
native reg_open_menu(id)
forward reg_user_register(id)
forward reg_user_logged(id)

// QUEST SYSTEM
native zb5_get_user_quest(id, quest)
native zb5_set_user_quest(id, quest, amount)

// EVOLUTION
native zb5_human_evolution(id)
native zb5_set_evolution(id)
native zb5_force_evolved(id, mode)
native zb5_get_maxlevel(id)
native zb5_update_level()
native zb5_set_evo_level(id, level, maxlevel)

// HUMANS
native zb5_had_vip(id)
native zb5_had_admin(id)
native zb5_had_class(id)
native zb5_skill_human(id, info)
forward zb5_humanskill(id, SkillButton);
forward zb5_humanskill_reset(id);

// ZOMBIE
native zb5_register_zclass(const Name[], const Desc[], unlock_cost, female, knock, health, sskill_1, sskill_2)

native zb5_skill_zombie(id, info)
native zb5_get_zombie_info(id, INFO)
native zb5_set_zombie_info(id, INFO, amount = 0, Float:amount2 = 0.0)
native zb5_remove_zclass(id)
native zb5_had_zclass(id)
native zb5_get_regular(id)
native zb5_zombie_PermDeath(id)
forward zb5_zclass_selected_post(id, classid);
forward zb5_zclass_remove_post(id);
forward zb5_zombieskill(id, SkillButton);
forward zb5_zombieskill_reset(id, SkillButton);

// ITEMS
native zb5_had_DamageBooster(id)
native zb5_had_DoubleGrenade(id)
native zb5_had_ZombieRespawn(id)
native zb5_had_StrongLife(id)

native zb5_give_DamageBooster(id)
native zb5_give_NightVision(id)
native zb5_set_user_nvg(id, Give, On, Sound, IgnoredHad)
native zb5_get_user_nvg(id)
native zb5_cbox(id)
native zb5_cbox_time(id)
native zb5_buy_item_exp(id)
native zb5_get_buyexp(id)
native zb5_get_restock(id)
native zb5_give_Sheild(id)
native zb5_restock_ammo(id)
native zb5_get_upgrade(id)

// SPRITES
native zb5_make_burn(id, attacker, Float:Time, Float:Scale, const Model[])
native zb5_make_shell(id, mode, Float:upScale, Float:fwScale, Float:rgScale , Float:rgKoord1 , Float:rgKoord2, time)
native zb5_make_icon_sprite(id, sprite, scale, brightness)
native zb5_make_icon(id)
native zb5_show_sprite(id, const model[], Float:RemoveTime, Float:Scale, Float:RenderAmount)
native zp_show_dhud(id, R, G, B, Float:X, Float:Y, Float:TimeLive, const Text[], id2);
native zp_get_synchud_id(hudtype);
native zb5_AddTofull_Icon(id, Float:Glow, Float:Scale, Float:Time, const Model[], Frames)
native zb5_AddTofull_eIcon(ent, RenderAmt, Float:Scale, Float:Origin2, const sprite[])
native zb5_valid_eIcon(ent)
native zb5_AddTofull_pIcon(id, RenderAmt, Float:Scale, Float:Origin2, const sprite[])
native zb5_valid_pIcon(id)
native zb5_make_SIcon(id, status, const icon[], red, green, blue)

// OPTIONS
native zb5_give_cbox(id, amount)
native zb5_set_hspeed(id, Float:Speed)
native zb5_reset_hspeed(id)

// WEAPON ATTRIBUTES
native set_weapon_knockback(attacker, victim, Float:jump)
native set_weapon_kick(attacker, victim, Float:jump)
native set_weapons_unlimited_clip(id, set)
native set_weapons_headshot(id, set)
native set_weapons_recoil(id, Float:recoil)
native reset_weapons_recoil(id)
native create_fake_attack(id, const name[])
native zb5_weapons_primary()
native zb5_weapons_secondary()

native get_weapon_knife(id, Weapon)
native get_weapon_grenade_he(id, Weapon)
native get_weapon_grenade_flash(id, Weapon)
native get_weapon_grenade_smoke(id, Weapon)
native get_weapon_pistol(id, Weapon)
native get_weapon_shotgun(id, Weapon)
native get_weapon_subgun(id, Weapon)
native get_weapon_rifle(id, Weapon)
native get_weapon_scope(id, Weapon)
native get_weapon_machine(id, Weapon)
native get_weapon_sniper(id, Weapon)

// OTHERS
native get_weapon_chainsaw(id)
native get_weapon_flameguns(id, weapon)

// HAD
native zb5_had_dmp7a1(id)
native zb5_had_cv47(id)
native zb5_had_ddeagle(id)
native had_weapon_plasma(id)
native zb5_had_walter(id)

// REMOVE NATIVES
native remove_all_machines(id, set, set2)
native remove_weapon_chainsaw(id, set)

// FORWARDS
forward zp_fw_core_infect_post(id, attacker)
forward zp_fw_core_cure_post(id, attacker)
forward zp_fw_core_spawn_post(id)
forward zp_fw_core_dead_post(victim, attacker, headshot)

forward zp_fw_game_start()
forward zp_fw_game_end()
forward zp_fw_round_new()

forward zp_fw_zombie_evolution(id)
forward zp_fw_restock_ammo(id)
forward zp_fw_human_invisible(id)
forward zp_fw_level_post(id)

forward zb5_weapon_selected_post(id, weaponid);
forward zb5_weapon_remove_post(id)
forward zb5_class_selected_post(id, classid);
forward zb5_class_remove_post(id);

forward RuningTime()
forward RuningTime_Player(id)

stock zp_colored_print(const id, const input[], any:...) 
{
if(!reg_is_user_logged(id))
return 

static count = 1, players[32]
static msg[191], is
vformat(msg, 190, input, 3)

replace_all(msg, 190, "!g", "^4");
replace_all(msg, 190, "!y", "^1");
replace_all(msg, 190, "!t", "^3");

if (id) players[0] = id; else get_players(players, count, "ch")
{
for (is = 0; is < count; is++)
{
if (is_user_connected(players[is]))
{
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[is])
write_byte(players[is]);
write_string(msg);
message_end();
}
}
}
}
stock Make_Sprite(id, sprite, scale, frame, x, y, z)
{	
static Float:Origin[3], TE_FLAG
get_position(id, float(x), float(y), float(z), Origin)

TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
TE_FLAG |= TE_EXPLFLAG_NOSOUND
TE_FLAG |= TE_EXPLFLAG_NOPARTICLES

engfunc(EngFunc_MessageBegin, MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, Origin, id)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, Origin[0])
engfunc(EngFunc_WriteCoord, Origin[1])
engfunc(EngFunc_WriteCoord, Origin[2])
write_short(sprite)
write_byte(scale)
write_byte(frame)
write_byte(TE_FLAG)
message_end()
}

stock Make_ScreenFade(id, Float:fDuration, red, green, blue, alpha, type)
{	
static MSG; MSG = get_user_msgid("ScreenFade")
message_begin(MSG_ONE_UNRELIABLE, MSG, _, id)	
write_short(floatround(4096.0 * fDuration, floatround_round));
write_short(floatround(4096.0 * fDuration, floatround_round));
write_short(type);
write_byte(red);
write_byte(green);
write_byte(blue);
write_byte(alpha);
message_end();
}
stock update_specialammo(id, Ammo, On)
{	
static AmmoSprites[33]
format(AmmoSprites, sizeof(AmmoSprites), "number_%d", Ammo)

static MSG; MSG = get_user_msgid("StatusIcon")
message_begin(MSG_ONE_UNRELIABLE, MSG, {0,0,0}, id)
write_byte(On)
write_string(AmmoSprites)
write_byte(42) // red
write_byte(212) // green
write_byte(255) // blue
message_end()
}
stock Make_PunchAngle(id, Float:x, Float:y)
{	
static Float:punchAngle[3];
punchAngle[0] = x
punchAngle[1] = y	
punchAngle[2] = 0.0;
set_pev(id, pev_punchangle, punchAngle);	
}
stock Make_ScreenShake(id, x, y, z)
{
static MSG; MSG = get_user_msgid("ScreenShake")
message_begin(MSG_ONE_UNRELIABLE, MSG, {0,0,0}, id)
write_short((1<<12) * x) // Amplitude
write_short((1<<12) * y) // Duration
write_short((1<<12) * z) // Frequency 
message_end()	
}
stock set_fov(id, num = 95)
{
static MSG; MSG = get_user_msgid("SetFOV")
message_begin(MSG_ONE_UNRELIABLE, MSG, {0,0,0}, id)
write_byte(num)
message_end()
}
stock sendmsg_BarTime(id, wait_time)
{
static MSG; MSG = get_user_msgid("BarTime")	
message_begin(MSG_ONE_UNRELIABLE, MSG, _, id)
write_short(wait_time)
message_end()
}
stock Make_Dlight(id, radius, r, g, b, life, rate)
{
static origin[3];
pev(id, pev_origin, origin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_DLIGHT) // TE id
write_coord(origin[0])
write_coord(origin[1])
write_coord(origin[2])
write_byte(radius) // radius
write_byte(r) // r
write_byte(g) // g
write_byte(b) // b
write_byte(life) // life
write_byte(rate) // decay rate
message_end()	
}
stock Make_Elight(id, radius, r, g, b, life, rate)
{
static fOrigin[3]
pev(id, pev_origin, fOrigin)

message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_ELIGHT)
write_short(id)
write_coord(fOrigin[0])
write_coord(fOrigin[1])
write_coord(fOrigin[2])
write_coord(radius)
write_byte(r)
write_byte(g)
write_byte(b)
write_byte(life)
write_coord(rate)
message_end()
}

stock PlaySound(id, const sound[])
{
if(equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(id, "mp3 play ^"sound/%s^"", sound)
else client_cmd(id, "spk ^"%s^"", sound)
}
stock EmitSound(id, chan, const file_sound[])
{
emit_sound(id, chan, file_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}
stock GetEntityCount()
{
static iEntCount; iEntCount = entity_count()
static iEntMax; iEntMax = global_get(glb_maxEntities)

if(iEntCount > iEntMax)
{
log_to_file("EntityLimit.log", "Entity ( %d ) limit ( %d max ) reached !", iEntCount, iEntMax)  
return 0;
}

return 0;
} 
stock fm_cs_get_weapon_ent_owner(ent)
{
if (!is_valid_ent(ent))
return -1

return get_pdata_cbase(ent, 41, 4)
}
stock set_entity_anim(ent, anim)
{
set_pev(ent, pev_animtime, get_gametime())
set_pev(ent, pev_framerate, 1.0)
set_pev(ent, pev_sequence, anim)
}
const WEAPONS_BITSUM = PRIMARY_WEAPONS_BIT_SUM | SECONDARY_WEAPONS_BIT_SUM

stock has_user_any_weapon(id)
{
return pev(id, pev_weapons) & WEAPONS_BITSUM
}  

stock ham_strip_weapon(id,weapon[])
{
if(!equal(weapon,"weapon_",7)) 
return 0

new wId = get_weaponid(weapon)
if(!wId) return 0

new wEnt
while((wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname",weapon)) && pev(wEnt,pev_owner) != id) {}
if(!wEnt) return 0

if(get_user_weapon(id) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon,wEnt)

if(!ExecuteHamB(Ham_RemovePlayerItem,id,wEnt)) return 0
ExecuteHamB(Ham_Item_Kill,wEnt);

set_pev(id,pev_weapons,pev(id,pev_weapons) & ~(1<<wId))

return 1
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
