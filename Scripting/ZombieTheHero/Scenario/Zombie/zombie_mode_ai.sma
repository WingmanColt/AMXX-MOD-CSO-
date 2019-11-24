#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
//#include <round_terminator>
#include <fun>

#define ZB_CLASSNAME "npc_zombie"
#define AMMOBOX_CLASSNAME "ammo_box"

#define TASK_ATTACK 323423
#define TASK_APPEAR 534534
#define TASK_CREATE 534332
#define TASK_HUD 967697
#define TASK_AMMO 5234234
#define TASK_SHOWAMMO 5345345
#define TASK_LIGHT 5343452
#define TASK_ROUND_SOUND 3234234

#define LIGHT "c"
#define SKYNAME "DrkG"

enum
{
	ANIM_IDLE = 0,
	ANIM_WALK = 1,
	ANIM_ATTACK = 2,
	ANIM_DIE = 3
}

new pev_victim = pev_enemy
new m_iBlood[2]

// spawns & way points
new const SPAWNS_FILE[] = "%s/zm_ai/sp_%s.cfg"
new const BOXS_FILE[] = "%s/zm_ai/box_%s.cfg"
const MAX_SPAWNS = 128
new Float:g_spawns[MAX_SPAWNS][3], g_total_spawns, Float:g_spawns_boss[MAX_SPAWNS][3], g_total_spawns_boss
new Float:npc_size_width = 16.0, Float:npc_size_height = 75.0
new Float:g_boxs[MAX_SPAWNS][3], g_total_boxs

#define MAX_DAY 12
new g_day
new const g_zombie_count[MAX_DAY + 1] = {
	20,
	30,
	40,
	50,
	60,
	70,
	80,
	90,
	100,
	110,
	120,
	200,
	300
}

new const g_remove_entities[][] = 
{ 
	"func_bomb_target",    
	"info_bomb_target", 
	"hostage_entity",      
	"monster_scientist", 
	"func_hostage_rescue", 
	"info_hostage_rescue",
	"info_vip_start",      
	"func_vip_safetyzone", 
	"func_escapezone" 
	//"func_buyzone"
}

new const Float:g_health_multi[MAX_DAY] = {
	1.0,
	1.2,
	1.4,
	1.6,
	1.8,
	2.0,
	2.2,
	2.4,
	2.6,
	2.8,
	3.0
}

new bool:g_reg
new g_day_zombie, g_current_zombie, g_current_zombie2
new sync_hud1//, sync_hud2
new g_fail, in_reloading_ammobox[33]
new is_boss_round, ammobox_id, fwd_zombie_create, g_fwSpawn

#define MAX_NPC 1000
new g_zombie[MAX_NPC], g_class[MAX_NPC], g_total_class, g_think[MAX_NPC]
new Array:g_class_health, Array:g_class_speed, Array:g_class_model, Array:g_class_modelindex
new current_target[MAX_NPC]

new const ammobox_spr[] = "sprites/zombie_mode_ai/ammo_box.spr"
new const ammobox_model[] = "models/zombie_mode_ai/ammo_box.mdl"
new const ammobox_reload_sound[] = "zombie_mode_ai/FullAmmo.wav"
new const sound_start[][] = {
	"zombie_mode_ai/AI_STAGE_START.WAV"
}

new const sound_end[][] = {
	"zombie_mode_ai/AI_STAGE_END.WAV"
}

new const sound_die[][] = {
	"zombie_mode_ai/NPC_DOWN1.WAV",
	"zombie_mode_ai/NPC_DOWN2.WAV",
	"zombie_mode_ai/2NANODEATH.WAV",
	"zombie_mode_ai/3NANODEATH.WAV"
}

new const sound_attack[][] = {
	"zombie_mode_ai/nano_attack_2.wav",
	"weapons/knife_hit4.wav",
	"zombie_mode_ai/zombi_attack_1.wav",
	"weapons/knife_hit2.wav"
}

new const sound_pain[][] = {
	"zombie_mode_ai/zombie_pain1.wav",
	"zombie_mode_ai/zombie_pain2.wav",
	"zombie_mode_ai/zombie_pain3.wav",
	"zombie_mode_ai/zombie_pain4.wav",
	"zombie_mode_ai/zombie_pain5.wav"
}
new const round_sound[][] = {
	"zombie_mode_ai/Daft_Punk-Recognizer.mp3"
}

public plugin_init()
{
	register_plugin("Zombie Mode AI", "1.0", "Dias")
	
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	register_logevent("event_roundstart", 2, "1=Round_Start")
	register_event("SendAudio", "round_end", "a", "2&%!MRAD_terwin")
	register_event("SendAudio", "round_end", "a", "2&%!MRAD_ctwin")  
	register_event("SendAudio", "round_end", "a", "2&%!MRAD_rounddraw")  	
	
	register_logevent("event_round_end", 2, "1=Round_End")
	register_event("TextMsg","event_round_end","a","2=#Game_Commencing","2=#Game_will_restart_in")
	
	register_message(get_user_msgid("TextMsg"), "hook_textmsg")	
	register_think(ZB_CLASSNAME, "fw_zb_think")
	register_forward(FM_CmdStart, "fw_cmdstart")
	unregister_forward(FM_Spawn, g_fwSpawn)
	RegisterHam(Ham_Spawn, "player", "fw_spawn", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_takedamage")
	
	sync_hud1 = CreateHudSyncObj(5)
	//sync_hud2 = CreateHudSyncObj(6)
	
	g_day = 0
	g_day_zombie = g_zombie_count[g_day]
	g_current_zombie = g_day_zombie	
	g_current_zombie2 = g_day_zombie
	
	fwd_zombie_create = CreateMultiForward("zmai_zombie_create", ET_IGNORE, FP_CELL)
	
	set_cvar_string("sv_skyname", SKYNAME)
		
	set_cvar_num("sv_skycolor_r", 0)
	set_cvar_num("sv_skycolor_g", 0)
	set_cvar_num("sv_skycolor_b", 0)	
	
	set_task(2.0, "set_light", TASK_LIGHT, _, _, "b")
}

public plugin_precache()
{
	g_class_health = ArrayCreate(1, 1)
	g_class_speed = ArrayCreate(1, 1)
	g_class_model = ArrayCreate(64, 1)
	g_class_modelindex = ArrayCreate(1, 1)
	
	engfunc(EngFunc_PrecacheModel, ammobox_model)
	precache_sound(ammobox_reload_sound)
	
	m_iBlood[0] = precache_model("sprites/blood.spr")
	m_iBlood[1] = precache_model("sprites/bloodspray.spr")
	ammobox_id = precache_model(ammobox_spr)
	
	static i, string[100]
	
	for (i = 0; i < ArraySize(g_class_model); i++)
	{
		ArrayGetString(g_class_model, i, string, charsmax(string))
		engfunc(EngFunc_PrecacheModel, string)
	}
	for(i = 0; i < sizeof(sound_start); i++)
		engfunc(EngFunc_PrecacheSound, sound_start[i])
	for(i = 0; i < sizeof(sound_end); i++)
		engfunc(EngFunc_PrecacheSound, sound_end[i])	
	for(i = 0; i < sizeof(sound_die); i++)
		engfunc(EngFunc_PrecacheSound, sound_die[i])	
	for(i = 0; i < sizeof(sound_attack); i++)
		engfunc(EngFunc_PrecacheSound, sound_attack[i])	
	for(i = 0; i < sizeof(sound_pain); i++)
		engfunc(EngFunc_PrecacheSound, sound_pain[i])
	for(i = 0; i < sizeof(round_sound); i++)
		engfunc(EngFunc_PrecacheSound, round_sound[i])
		
	load_spawn_points()
	load_ammobox_spawns()
	
	// Prevent some entities from spawning
	g_fwSpawn = register_forward(FM_Spawn, "fw_Spawn")	
}

public plugin_natives()
{
	register_native("zmai_register_class", "native_register_class", 1)
	register_native("zmai_is_zombie", "native_is_zombie", 1)
	register_native("zmai_is_valid_zombie", "native_is_valid_zombie", 1)
	register_native("zmai_get_class", "native_get_class", 1)
	register_native("zmai_set_think", "native_set_think", 1)
	register_native("zmai_set_zombie_count", "native_set_zb_count", 1)
	register_native("zmai_get_zombie_count", "native_get_zb_count", 1)
	register_native("zmai_get_current_target", "native_get_target", 1)
}

public fw_Spawn(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED;
	
	// Get classname
	new classname[32]
	pev(entity, pev_classname, classname, charsmax(classname))
	
	// Check whether it needs to be removed
	for (new i = 0; i < sizeof(g_remove_entities); i++)
	{
		if (equal(classname, g_remove_entities[i]))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public client_putinserver(id)
{
	set_task(0.2, "show_hud", id+TASK_HUD, _, _, "b")
}

public show_hud(id)
{
	id -= TASK_HUD
	
	if(is_user_connected(id))
	{
		set_hudmessage(255, 255, 255, -1.0, 0.0, 0, 2.0, 2.0)
		ShowSyncHudMsg(id, sync_hud1, "Round: %i - Zombies Left: %i", g_day, g_current_zombie, g_day_zombie)
	} else {
		remove_task(TASK_HUD)
	}
}

public set_light()
{
	set_lights(LIGHT)
}

public event_newround(id)
{
	//set_lights("f")
	balance_teams()
	
	remove_entity_name(ZB_CLASSNAME)
	remove_entity_name("temp_zb")

	if(task_exists(TASK_ATTACK)) remove_task(TASK_ATTACK)
	if(task_exists(TASK_APPEAR)) remove_task(TASK_APPEAR)
	if(task_exists(TASK_CREATE)) remove_task(TASK_CREATE)
	if(task_exists(TASK_SHOWAMMO)) remove_task(TASK_SHOWAMMO)
	
	remove_entity_name(AMMOBOX_CLASSNAME)
	set_task(0.1, "create_ammobox")
	
	if(g_fail == 0)
	{
		if(g_day >= MAX_DAY)
		{
			g_day = 0
		} else {
			g_day++
			
			//if(g_day == MAX_DAY)
				//is_boss_round = 1
		}		
	}
	
	g_day_zombie = g_zombie_count[g_day]
	g_current_zombie = g_day_zombie
	g_current_zombie2 = g_day_zombie
	
	set_task(3.0, "zombie_appear", TASK_APPEAR)
}

public fw_spawn(id)
{
	if(is_user_connected(id))
	{
		set_task(0.1, "set_ammo", id)
	}
}

public set_ammo(id)
{
	cs_set_user_bpammo(id, get_user_weapon(id), 200)
	cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM)
}

public event_round_end(id)
{
	if(task_exists(TASK_ATTACK)) remove_task(TASK_ATTACK)
	if(task_exists(TASK_APPEAR)) remove_task(TASK_APPEAR)
	if(task_exists(TASK_CREATE)) remove_task(TASK_CREATE)		
	if(task_exists(TASK_ROUND_SOUND)) remove_task(TASK_ROUND_SOUND)
	
	if(get_player_alive() >= 1)
	{
		for(new i = 0; i < g_zombie_count[g_day]; i++)
		{
			new ent = find_ent_by_class(-1, ZB_CLASSNAME)
			
			if(is_valid_ent(ent))
				kill_zombie(ent)
		}		
		
		g_fail = 0
	} else {
		for(new i = 0; i < g_zombie_count[g_day]; i++)
		{
			new ent = find_ent_by_class(-1, ZB_CLASSNAME)
			
			if(is_valid_ent(ent))
				native_set_think(ent, 0)
		}				
		
		g_fail = 1
	}
}

public create_ammobox()
{
	new Float:Origin[3]
	collect_spawn_box(Origin)
	
	new ent = create_entity("info_target")
	
	Origin[2] -= 35.0
	entity_set_origin(ent, Origin)
	
	entity_set_string(ent, EV_SZ_classname, AMMOBOX_CLASSNAME)
	entity_set_model(ent, ammobox_model)
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX)

	new Float:maxs[3] = {30.0, 30.0, 30.0}
	new Float:mins[3] = {-30.0, -30.0, -30.0}
	entity_set_size(ent, mins, maxs)
	
	set_task(0.25, "task_show_ammo_spr", TASK_SHOWAMMO, _, _, "b")
	
	drop_to_floor(ent)
}

public task_show_ammo_spr()
{
	static ent, Float:Origin[3]
	
	ent = find_ent_by_class(-1, AMMOBOX_CLASSNAME)
	pev(ent, pev_origin, Origin)
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, Origin[0])
	engfunc(EngFunc_WriteCoord, Origin[1])
	engfunc(EngFunc_WriteCoord, Origin[2] + 45.0)
	write_short(ammobox_id)
	write_byte(2)
	write_byte(186)
	message_end() 
}

public zombie_appear()
{
	if(!is_boss_round)
	{
		PlaySound(sound_start[random_num(0, charsmax(sound_start))])
		client_print(0, print_center, "Round %i", g_day)
		
		set_task(random_float(0.1, 2.5), "make_zombie", TASK_CREATE, _, _, "b")	
	} else {
		client_print(0, print_center, "Last Round !!!", g_day)
	}

	set_task(10.0, "start_round_sound", TASK_ROUND_SOUND)
}

public start_round_sound()
{
	PlaySound(round_sound[random_num(0, charsmax(round_sound))])
}

public make_zombie()
{
	if(g_current_zombie2 > 0)
	{
		if(get_zombie_alive() < 7)
		{
			g_current_zombie2--
			create_zombie()
		}
	} else {
		remove_task(TASK_CREATE)
	}
}

public event_roundstart(id)
{
	//set_task(1.0, "create_zombie", _, _, _, "b")
}

public create_zombie()
{	
	new ent = create_entity("info_target")
	new Float:Origin[3], Float:health, model[64]
	collect_spawn(Origin)
	
	g_class[ent] = random(g_total_class)
	health = ArrayGetCell(g_class_health, g_class[ent])
	
	health *= g_health_multi[g_day]
	
	ArrayGetString(g_class_model, g_class[ent], model, sizeof(model))
	
	dllfunc(DLLFunc_Spawn, ent)
	entity_set_origin(ent, Origin)
	
	entity_set_float(ent, EV_FL_takedamage, 1.0)
	entity_set_float(ent, EV_FL_health, health)
	
	entity_set_string(ent, EV_SZ_classname, ZB_CLASSNAME)
	entity_set_model(ent, model)
	entity_set_int(ent, EV_INT_solid, SOLID_SLIDEBOX)
	
	static modelindex
	modelindex = ArrayGetCell(g_class_modelindex, g_class[ent])
	set_pev(ent, pev_modelindex, modelindex)
	
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_STEP)
	
	set_pev(ent, pev_victim, 0)
	
	new Float:VEC_HULL_MIN[3] = { -16.0, -16.0, -40.0 }
	new Float:VEC_HULL_MAX[3] = { 16.0, 16.0, 72.0}
	entity_set_size(ent, VEC_HULL_MIN, VEC_HULL_MAX)
	
	play_anim(ent, ANIM_IDLE, 1.0)
	
	set_task(1.0, "start_attack", ent)
	//drop_to_floor(ent)
	
	if(!g_reg)
	{
		RegisterHamFromEntity(Ham_TakeDamage, ent, "fw_zb_takedmg")
		RegisterHamFromEntity(Ham_Killed, ent, "fw_zb_killed")
		g_reg = true
	}
	
	g_think[ent] = 1	
	g_zombie[ent] = 1

	static g_fwDummyResult
	ExecuteForward(fwd_zombie_create, g_fwDummyResult, ent)	
	
	return 1
}

public start_attack(ent)
{
	if(is_valid_ent(ent))
		entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.01)
}

public fw_takedamage(victim, inflictor, attacker, Float:damage, damagebits)
{
	if((get_user_team(victim) == 1) || (get_user_team(victim) == 2))
		return HAM_SUPERCEDE
		
	return HAM_HANDLED
}

public fw_zb_takedmg(victim, inflictor, attacker, Float:damage, damagebits)
{
	emit_sound(victim, CHAN_BODY, sound_pain[random_num(0, charsmax(sound_pain))], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	static Float:Origin[3]
	pev(victim, pev_origin, Origin)
	
	create_blood(Origin)	
}

public fw_zb_killed(ent2, attacker)
{
	g_current_zombie--
	emit_sound(ent2, CHAN_BODY, sound_die[random_num(0, charsmax(sound_die))], 1.0, ATTN_NORM, 0, PITCH_NORM)	
	
	static ent
	ent = create_entity("info_target")
	static Float:Origin[3], Float:Angles[3], Model[64]
	
	pev(ent2, pev_origin, Origin)
	pev(ent2, pev_angles, Angles)
	ArrayGetString(g_class_model, g_class[ent2], Model, sizeof(Model))
	
	entity_set_origin(ent, Origin)
	entity_set_vector(ent, EV_VEC_angles, Angles)
	
	entity_set_string(ent, EV_SZ_classname, "temp_zb")
	entity_set_model(ent, Model)
	
	drop_to_floor(ent)
	
	play_anim(ent, ANIM_DIE, 1.0)
	
	set_task(3.0, "remove_temp_zb", ent)
	
	if(g_current_zombie == 0)
	{
		TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Ct)
	}
	
	if(0 < attacker < 32)
	{
		if(cs_get_user_money(attacker) < 16000)
		{
			cs_set_user_money(attacker, cs_get_user_money(attacker) + 200)
		}
		
		client_print(attacker, print_center, "KILL !!!")
	}
}

public fw_cmdstart(id, uc_handle, seed)
{
	static Button
	Button = get_uc(uc_handle, UC_Buttons)
	
	if(Button & IN_USE)
	{
		static Ent, Float:Range
		Ent = find_ent_by_class(-1, AMMOBOX_CLASSNAME)
		
		if(!is_valid_ent(Ent))
			return FMRES_IGNORED
			
		static Weapon
		Weapon = get_user_weapon(id)
		
		if(Weapon == CSW_KNIFE || Weapon == CSW_C4 || Weapon == CSW_FLASHBANG || 
		Weapon == CSW_HEGRENADE || Weapon == CSW_SMOKEGRENADE)
			return FMRES_IGNORED
		
		
		Range = entity_range(Ent, id)
		if(Range <= 70.0)
		{
			if(cs_get_user_bpammo(id, get_user_weapon(id)) < 200)
			{
				if(!in_reloading_ammobox[id])
				{
					in_reloading_ammobox[id] = 1
					
					message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("BarTime"), _, id)
					write_short(1)
					message_end()
					
					set_task(1.0, "reload_ammo", id+TASK_AMMO)
					
					emit_sound(id, CHAN_BODY, ammobox_reload_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
				}					
			}		
		} else {
			if(in_reloading_ammobox[id])
			{
				in_reloading_ammobox[id] = 0
				
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("BarTime"), _, id)
				write_short(0)
				message_end()
				
				if(task_exists(id+TASK_AMMO)) remove_task(id+TASK_AMMO)				
			}			
		}
	} else {
		if(pev(id, pev_oldbuttons) & IN_USE)
		{
			if(in_reloading_ammobox[id])
			{
				in_reloading_ammobox[id] = 0
				
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("BarTime"), _, id)
				write_short(0)
				message_end()
				
				if(task_exists(id+TASK_AMMO)) remove_task(id+TASK_AMMO)				
			}				
		}
	}
	
	return FMRES_HANDLED
}

public reload_ammo(id)
{
	id -= TASK_AMMO
	
	client_print(id, print_center, "Reloaded - 100%% AMMO !!!")
	in_reloading_ammobox[id] = 0
	
	cs_set_user_bpammo(id, get_user_weapon(id), 200)
}

public kill_zombie(ent2)
{
	emit_sound(ent2, CHAN_BODY, sound_die[random_num(0, charsmax(sound_die))], 1.0, ATTN_NORM, 0, PITCH_NORM)		
	
	static ent
	ent = create_entity("info_target")
	static Float:Origin[3], Float:Angles[3], Model[64]
	
	ArrayGetString(g_class_model, g_class[ent2], Model, sizeof(Model))
	
	pev(ent2, pev_origin, Origin)
	pev(ent2, pev_angles, Angles)
	
	entity_set_origin(ent, Origin)
	entity_set_vector(ent, EV_VEC_angles, Angles)
	
	entity_set_string(ent, EV_SZ_classname, "temp_zb")
	entity_set_model(ent, Model)
	
	//drop_to_floor(ent)
	
	play_anim(ent, ANIM_DIE, 1.0)
	
	set_task(3.0, "remove_temp_zb", ent)
}

public remove_temp_zb(ent)
{
	remove_entity(ent)
}

public fw_zb_think(ent)
{
	if(!is_valid_ent(ent))
		return FMRES_IGNORED
	
	if(g_think[ent])
	{
		static victim
		static Float:Origin[3], Float:VicOrigin[3], Float:distance
		
		victim = FindClosesEnemy(ent)
		pev(ent, pev_origin, Origin)
		pev(victim, pev_origin, VicOrigin)
		
		distance = get_distance_f(Origin, VicOrigin)
		
		if(is_user_alive(victim))
		{
			if(distance <= 60.0)
			{
				if(!is_valid_ent(ent))
					return FMRES_IGNORED	
			
				new Float:Ent_Origin[3], Float:Vic_Origin[3]
				
				pev(ent, pev_origin, Ent_Origin)
				pev(victim, pev_origin, Vic_Origin)			
			
				npc_turntotarget(ent, Ent_Origin, victim, Vic_Origin)
				
				zombie_attack(ent, victim)
				entity_set_float(ent, EV_FL_nextthink, get_gametime() + 2.5)
			} else {
				
				if(get_anim(ent) != ANIM_WALK)
					play_anim(ent, ANIM_WALK, 1.0)
					
				new Float:Ent_Origin[3], Float:Vic_Origin[3]
				
				pev(ent, pev_origin, Ent_Origin)
				pev(victim, pev_origin, Vic_Origin)
				
				npc_turntotarget(ent, Ent_Origin, victim, Vic_Origin)
				hook_ent(ent, victim)
				
				entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.5)
			}
			
			current_target[ent] = victim
		} else {
			//hook_ent(ent, ent)
			
			if(get_anim(ent) != ANIM_IDLE)
				play_anim(ent, ANIM_IDLE, 1.0)
			
			entity_set_float(ent, EV_FL_nextthink, get_gametime() + 1.0)
		}
	} else {
		if(get_anim(ent) != ANIM_IDLE)
			play_anim(ent, ANIM_IDLE, 1.0)
			
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + 1.0)		
	}
	
	return FMRES_HANDLED
}

public zombie_attack(ent, victim)
{
	play_anim(ent, ANIM_ATTACK, 1.0) 
	
	emit_sound(victim, CHAN_BODY, sound_attack[random_num(0, charsmax(sound_attack))], 1.0, ATTN_NORM, 0, PITCH_NORM)
	ExecuteHam(Ham_TakeDamage, victim, 0, victim, random_float(15.0, 30.0), DMG_BULLET) 
	
	remove_task(ent+TASK_ATTACK)
	set_task(1.5, "stop_attack", ent+TASK_ATTACK)
}

public stop_attack(ent)
{
	ent -= TASK_ATTACK
	
	play_anim(ent, ANIM_IDLE, 1.0)
	remove_task(ent+TASK_ATTACK)
}

public npc_turntotarget(ent, Float:Ent_Origin[3], target, Float:Vic_Origin[3]) 
{
	if(target) 
	{
		new Float:newAngle[3]
		entity_get_vector(ent, EV_VEC_angles, newAngle)
		new Float:x = Vic_Origin[0] - Ent_Origin[0]
		new Float:z = Vic_Origin[1] - Ent_Origin[1]

		new Float:radians = floatatan(z/x, radian)
		newAngle[1] = radians * (180 / 3.14)
		if (Vic_Origin[0] < Ent_Origin[0])
			newAngle[1] -= 180.0
        
		entity_set_vector(ent, EV_VEC_angles, newAngle)
	}
}

public hook_ent(ent, victim)
{
	static Float:fl_Velocity[3]
	static Float:VicOrigin[3], Float:EntOrigin[3]
	static Float:Speed

	pev(ent, pev_origin, EntOrigin)
	pev(victim, pev_origin, VicOrigin)
	Speed = ArrayGetCell(g_class_speed, g_class[ent])
	
	static Float:distance_f
	distance_f = get_distance_f(EntOrigin, VicOrigin)

	if (distance_f > 60.0)
	{
		new Float:fl_Time = distance_f / Speed

		fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
		fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
		fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time
	} else
	{
		fl_Velocity[0] = 0.0
		fl_Velocity[1] = 0.0
		fl_Velocity[2] = 0.0
	}

	entity_set_vector(ent, EV_VEC_velocity, fl_Velocity)
}

public round_end()
{
	client_cmd(0, "stopsound")
	PlaySound(sound_end[random_num(0, charsmax(sound_end))])
	
	return PLUGIN_HANDLED
}

public hook_textmsg()
{
	new szMsg[22]
	get_msg_arg_string(2, szMsg, sizeof szMsg)	
		
	if(get_player_alive() >= 1)
	{
		if(equal(szMsg, "#Terrorists_Win"))
			set_msg_arg_string(2, "Round Clear !!!")
		else if(equal(szMsg, "#CTs_Win"))
			set_msg_arg_string(2 , "Round Clear !!!")
		else if(equal(szMsg, "#Round_Draw"))
			set_msg_arg_string(2 , "Round Clear !!!")	
		
		g_fail = 0
	} else {
		if(equal(szMsg, "#Terrorists_Win"))
			set_msg_arg_string(2, "Mission Failed !!!")
		else if(equal(szMsg, "#CTs_Win"))
			set_msg_arg_string(2 , "Mission Failed !!!")
		else if(equal(szMsg, "#Round_Draw"))
			set_msg_arg_string(2 , "Mission Failed !!!")		
		
		g_fail = 1
	}	
}  

// Transfer Player Team
public balance_teams()
{
	static iPlayersnum
	iPlayersnum = get_playersnum()

	if (iPlayersnum < 1) return;

	static iTerrors, iMaxTerrors, id
	iMaxTerrors = iPlayersnum/2
	iTerrors = 0

	for (id = 1; id <= get_maxplayers(); id++)
	{
		if (!is_user_connected(id))
			continue;
		
		if (cs_get_user_team(id) == CS_TEAM_SPECTATOR || cs_get_user_team(id) == CS_TEAM_UNASSIGNED)
			continue;
		
		cs_set_user_team(id, CS_TEAM_CT)
	}
	
	while (iTerrors < iMaxTerrors)
	{
		if (++id > get_maxplayers()) id = 1
		
		if (!is_user_connected(id))
			continue;
		
		if (cs_get_user_team(id) != CS_TEAM_CT)
			continue;
		
		if (random_num(0, 1))
		{
			cs_set_user_team(id, CS_TEAM_T)
			iTerrors++
		}
	}
}

stock bool:IsValidTarget(iTarget)
{
	if (!iTarget || !(1<= iTarget <= get_maxplayers()) || !is_user_connected(iTarget) || !is_user_alive(iTarget))
		return false
	return true
}

public FindClosesEnemy(entid)
{
	new Float:Dist
	new Float:maxdistance=4000.0
	new indexid=0	
	for(new i=1;i<=get_maxplayers();i++){
		if(is_user_alive(i) && is_valid_ent(i) && can_see_fm(entid, i))
		{
			Dist = entity_range(entid, i)
			if(Dist <= maxdistance)
			{
				maxdistance=Dist
				indexid=i
				
				return indexid
			}
		}	
	}	
	return 0
}

public bool:can_see_fm(entindex1, entindex2)
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

		engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the had of seen player
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
				engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the body of seen player
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
					engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the legs of seen player
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

stock get_anim(id)
{
	if(is_valid_ent(id))
	{	
		return pev(id, pev_sequence)
	}
	
	return PLUGIN_HANDLED
}

stock play_anim(index, sequence, Float:framerate = 1.0)
{
	if(is_valid_ent(index))
	{
		entity_set_float(index, EV_FL_animtime, get_gametime())
		entity_set_float(index, EV_FL_framerate,  framerate)
		entity_set_float(index, EV_FL_frame, 0.0)
		entity_set_int(index, EV_INT_sequence, sequence)
	}
}  

public create_blood(const Float:origin[3])
{
	// Show some blood :)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(m_iBlood[1])
	write_short(m_iBlood[0])
	write_byte(75)
	write_byte(5)
	message_end()
}

stock collect_spawn_box(Float:origin[3])
{
	for (new i=1; i<=g_total_boxs*3; i++)
	{
		origin = g_boxs[random(g_total_boxs)]
		if (check_spawn_box(origin)) return 1;
	}

	return 0;
}
stock check_spawn_box(Float:origin[3])
{
	new Float:originE[3], Float:origin1[3], Float:origin2[3]
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "ammobox")) != 0)
	{
		pev(ent, pev_origin, originE)
		
		// xoy
		origin1 = origin
		origin2 = originE
		origin1[2] = origin2[2] = 0.0
		if (vector_distance(origin1, origin2)<=2*npc_size_width) return 0;
	}
	return 1;
}

stock collect_spawn(Float:origin[3])
{
	for (new i=1; i<=g_total_spawns*3; i++)
	{
		origin = g_spawns[random(g_total_spawns)]
		if (check_spawn(origin)) return 1;
	}

	return 0;
}

stock check_spawn(Float:origin[3])
{
	new Float:originE[3], Float:origin1[3], Float:origin2[3]
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", ZB_CLASSNAME)) != 0)
	{
		pev(ent, pev_origin, originE)
		
		// xoy
		origin1 = origin
		origin2 = originE
		origin1[2] = origin2[2] = 0.0
		if (vector_distance(origin1, origin2)<=2*npc_size_width)
		{
			// oz
			origin1 = origin
			origin2 = originE
			origin1[0] = origin2[0] = origin1[1] = origin2[1] = 0.0
			if (vector_distance(origin1, origin2)<=npc_size_height) return 0;
		}
	}
	return 1;
}

stock str_count(const str[], searchchar)
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if(str[i] == searchchar)
			count++
	}
	
	return count;
}

// load spawn points
load_spawn_points()
{
	// Check for spawns points of the current map
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), SPAWNS_FILE, cfgdir, mapname)
	
	// Load spawns points
	if (file_exists(filepath))
	{
		new file = fopen(filepath,"rt"), row[4][6], boss
		
		while (file && !feof(file))
		{
			fgets(file, linedata, charsmax(linedata))
			
			// invalid spawn
			if(!linedata[0] || str_count(linedata,' ') < 2) continue;
			
			// get spawn point data
			parse(linedata,row[0],5,row[1],5,row[2],5,row[3],5)
			
			// origin
			boss = str_to_num(row[0])
			if (boss && g_total_spawns_boss<MAX_SPAWNS)
			{
				g_spawns_boss[g_total_spawns_boss][0] = floatstr(row[1])
				g_spawns_boss[g_total_spawns_boss][1] = floatstr(row[2])
				g_spawns_boss[g_total_spawns_boss][2] = floatstr(row[3])
				g_total_spawns_boss++
			}
			else if (g_total_spawns<MAX_SPAWNS)
			{
				g_spawns[g_total_spawns][0] = floatstr(row[1])
				g_spawns[g_total_spawns][1] = floatstr(row[2])
				g_spawns[g_total_spawns][2] = floatstr(row[3])
				g_total_spawns++
			}
		}
		if (file) fclose(file)
	}
}

// load spawn points
load_ammobox_spawns()
{
	// Check for spawns points of the current map
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), BOXS_FILE, cfgdir, mapname)
	
	// Load spawns points
	if (file_exists(filepath))
	{
		new file = fopen(filepath,"rt"), row[4][6]
		
		while (file && !feof(file))
		{
			fgets(file, linedata, charsmax(linedata))
			
			// invalid spawn
			if(!linedata[0] || str_count(linedata,' ') < 2) continue;
			
			// get spawn point data
			parse(linedata,row[0],5,row[1],5,row[2],5)
			
			// origin
			g_boxs[g_total_boxs][0] = floatstr(row[0])
			g_boxs[g_total_boxs][1] = floatstr(row[1])
			g_boxs[g_total_boxs][2] = floatstr(row[2])

			g_total_boxs++
			if (g_total_boxs>=MAX_SPAWNS) break;
		}
		if (file) fclose(file)
	}
}

public get_player_alive()
{
	static iAlive, id
	iAlive = 0
	
	for (id = 1; id <= get_maxplayers(); id++)
	{
		if (is_user_alive(id))
			iAlive++
	}
	
	return iAlive;
}

public get_zombie_alive()
{
	static iAlive, i
	iAlive = 0
	
	static classname[32]
	
	for (i = 1; i <= entity_count(); i++)
	{
		if(is_valid_ent(i))
		{
			pev(i, pev_classname, classname, sizeof(classname))
			if(equal(classname, ZB_CLASSNAME))
				iAlive++
		}
	}
	
	return iAlive;
}

// Plays a sound on clients
public PlaySound(const sound[])
{
	client_cmd(0, "spk ^"%s^"", sound)
}

public native_register_class(const Float:Health, const Float:Speed, const Model[], const modelindex)
{
	param_convert(3)
	
	ArrayPushCell(g_class_health, Health)
	ArrayPushCell(g_class_speed, Speed)
	ArrayPushString(g_class_model, Model)
	ArrayPushCell(g_class_modelindex, modelindex)
	
	g_total_class++

	return g_total_class - 1
}

public native_is_zombie(id)
{
	return g_zombie[id]
}

public native_get_class(id)
{
	return g_class[id]
}

public native_set_think(id, think)
{
	g_think[id] = think
}

public native_set_zb_count(count)
{
	g_current_zombie = count
	
	if(g_current_zombie == 0)
	{
		TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Ct)
	}	
}

public native_get_zb_count()
{
	return g_current_zombie
}

public native_is_valid_zombie(ent)
{
	return is_valid_ent(ent)
}

public native_get_target(ent)
{
	return current_target[ent]
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
