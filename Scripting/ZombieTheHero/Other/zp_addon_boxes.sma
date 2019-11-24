/*========================================================*
                 ZP Addon Boxes crate
          iNexus, FOX, kapitana, WaLkZ, dias
*=======================================================*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <fakemeta_util>
#include <hamsandwich>
#include <zombieplague>

#define PLAYER_LINUX_XTRA_OFF 5
#define OFFSET_LINUX_WEAPONS  4
#define OFFSET_CLIPAMMO 51

#define m_pActiveItem 373
#define fm_cs_set_weapon_ammo(%1,%2) set_pdata_int(%1, OFFSET_CLIPAMMO, %2, OFFSET_LINUX_WEAPONS)

const NO_CLIP_WPN = ((1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))
new const MAX_WEAPON_CLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 }

#define BOX_CLASSNAME "box"
#define ITEMBOX_ANTIDOTE "item_antidote"
#define ITEMBOX_HEALTH "item_health"
#define ITEMBOX_HGIBS "item_hgibs"
#define ITEMBOX_ARMOR "item_armor"
#define ITEMBOX_AMMO "item_ammo"
#define TASK_BOX 128256

#define PRESENT_MODEL "models/items/box.mdl"
#define PRESENT_MODEL_ANTIDOTE "models/items/antidote.mdl"
#define PRESENT_MODEL_HEALTH_VIAL "models/items/health_vial.mdl"
#define PRESENT_MODEL_HEALTH_HGIBS "models/items/hgibs.mdl"
#define PRESENT_MODEL_ARMOR "models/items/armor.mdl"
#define PRESENT_MODEL_AMMO "models/items/ammo.mdl"
new const wood_break[] = "items_sound/wood_break.wav"
new const pickup[] = "items_sound/pickup.wav"

#define PREFIX "ZP"

const MAX_BOX_ENT = 100
new const box_spawn_file[] = "%s/zp_boxes/%s.cfg"

new box_count, box_ent[MAX_BOX_ENT], g_total_box_spawn,
Float:g_box_spawn[MAX_BOX_ENT][3], g_endround, bool:made_box, g_newround,
g_GibModelIndex[7], g_ham_killed, min_boxes, max_boxes, bool:g_enabled2[33]

public plugin_init()
{
	register_plugin( "[ZP] Addon Boxes PRIVATE", "1.0", "iNexus, FOX, kapitana, WaLkZ, dias" )
	register_event("CurWeapon" , "Event_CurWeapon" , "be" , "1=1" )
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	register_logevent("logevent_round_end", 2, "1=Round_End")
	register_forward(FM_Touch, "fw_box_touch")
	g_ham_killed = false
	min_boxes = register_cvar("zp_min_boxes", "2")
	max_boxes = register_cvar("zp_max_boxes", "12")
}

public plugin_precache()
{
	precache_sound(wood_break)
	precache_sound(pickup)
	precache_model(PRESENT_MODEL)
	precache_model(PRESENT_MODEL_ANTIDOTE)
	precache_model(PRESENT_MODEL_HEALTH_VIAL)
	precache_model(PRESENT_MODEL_HEALTH_HGIBS)
	precache_model(PRESENT_MODEL_AMMO)
	precache_model(PRESENT_MODEL_ARMOR)
	
	new i, ii = 0, buffer[100]
	 
	for(i = 0; i < sizeof(g_GibModelIndex); i++)
	{
		ii++
		
		formatex(buffer, charsmax(buffer), "models/items/gib/gib0%i.mdl", ii)
		
		g_GibModelIndex[i] = precache_model(buffer)
	}
	load_box_spawn()	
}

public plugin_cfg() set_task(0.5, "event_newround")
public zp_user_humanized_post(id)g_enabled2[id] = false
public zp_user_infected_post(id)g_enabled2[id] = false
public event_newround()
{
	made_box = false
	g_newround = 1
	g_endround = 0
	
	for(new i = 0; i<=get_maxplayers(); i++)
	g_enabled2[i] = false
	
	remove_entities()
	box_count = 0
	
	if(!made_box)
	{
		g_newround = 0
		made_box = true
			
		if(task_exists(TASK_BOX)) remove_task(TASK_BOX)
		if(g_total_box_spawn) valid_box()
	}
}

public logevent_round_end() g_endround = 1

public load_box_spawn()
{
	// Check for spawns points of the current map
	new cfgdir[32], mapname[32], filepath[100], linedata[64]
	get_configsdir(cfgdir, charsmax(cfgdir))
	get_mapname(mapname, charsmax(mapname))
	formatex(filepath, charsmax(filepath), box_spawn_file, cfgdir, mapname)
	
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
			g_box_spawn[g_total_box_spawn][0] = floatstr(row[0])
			g_box_spawn[g_total_box_spawn][1] = floatstr(row[1])
			g_box_spawn[g_total_box_spawn][2] = floatstr(row[2])
			
			g_total_box_spawn++
			if (g_total_box_spawn >= MAX_BOX_ENT) 
				break
		}

		if (file) fclose(file)
	}
}

public valid_box()
{
	if (box_count >= 1 || g_newround || g_endround) return
	if (get_total_box() >= 1) return

	make_box()
	if (task_exists(TASK_BOX)) remove_task(TASK_BOX)
	set_task(30.0, "make_box", TASK_BOX, _, _, "b")
}

public make_box()
{
	if (box_count >= random_num(get_pcvar_num(min_boxes),get_pcvar_num(max_boxes))
	|| get_total_box() >= get_pcvar_num(max_boxes) || g_newround || g_endround)
		remove_task(TASK_BOX)
	else
	{
		box_count++
		new Float:Mins[3] = {-2.0,-2.0,-0.0}
		new Float:Maxs[3] = {5.0,5.0,17.0}
		new BoxEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
		if(!pev_valid(BoxEnt)) return
		set_pev(BoxEnt, pev_classname, BOX_CLASSNAME)
		engfunc(EngFunc_SetModel, BoxEnt,PRESENT_MODEL)
		entity_set_int(BoxEnt, EV_INT_movetype, MOVETYPE_TOSS)
		entity_set_int(BoxEnt, EV_INT_solid, SOLID_BBOX)
		set_pev(BoxEnt, pev_takedamage, 1.0)
		set_pev(BoxEnt, pev_health, 1)
		entity_set_float(BoxEnt, EV_FL_gravity,1.0)
		engfunc(EngFunc_SetSize,BoxEnt,Mins,Maxs)
		
		// Bugfix
		if(!g_ham_killed)
		{
			RegisterHamFromEntity(Ham_Killed, BoxEnt, "present_killed", 1)
			g_ham_killed = true
		}
		
		static Float:angles[3]
		entity_get_vector(BoxEnt,EV_VEC_angles,angles)
		angles[1] -= random_num(-255, 255)
		entity_set_vector(BoxEnt,EV_VEC_angles,angles)
		
		static Float:Origin[3]
		collect_spawn_point(Origin)
		engfunc(EngFunc_SetOrigin, BoxEnt, Origin)
		box_ent[box_count] = BoxEnt
	}
}

public remove_entities()
{
	remove_ent_by_class(BOX_CLASSNAME)
	remove_ent_by_class(ITEMBOX_ANTIDOTE)
	remove_ent_by_class(ITEMBOX_HEALTH)
	remove_ent_by_class(ITEMBOX_HGIBS)
	remove_ent_by_class(ITEMBOX_AMMO)
	remove_ent_by_class(ITEMBOX_ARMOR)
	
	new box_ent_reset[MAX_BOX_ENT]
	box_ent = box_ent_reset
}

public fw_box_touch(ent, id)
{
	if(!pev_valid(ent) || !is_user_alive(id)
	|| zp_get_user_nemesis(id) || zp_get_user_survivor(id)) return
	
	static classname[32], Float:armor
	entity_get_string(ent,EV_SZ_classname,classname,31)
	pev(id, pev_armorvalue, armor)
	
	// Bugfix
	if (equal(classname, BOX_CLASSNAME))
		return

	if (equal(classname, ITEMBOX_ANTIDOTE))
	{
		if(zp_get_user_zombie(id) && !zp_get_user_last_zombie(id))
		{	
			client_print_color2(id, "!g[%s]!y You won an antidote!", PREFIX)
			zp_disinfect_user(id)
			remove_entity_item(ent)
		}
	}

	if (equal(classname, ITEMBOX_HEALTH))
	{
		if(!zp_get_user_zombie(id))
		{
			client_print_color2(id, "!g[%s]!y +50 health!", PREFIX)
			set_user_health(id,get_user_health(id) + 50)
			remove_entity_item(ent)
		}
	}

	if (equal(classname, ITEMBOX_HGIBS))
	{
		if(zp_get_user_zombie(id))
		{
			client_print_color2(id, "!g[%s]!y +1000 health!", PREFIX)
			set_user_health(id,get_user_health(id) + 1000)
			remove_entity_item(ent)
		}
	}

	if (equal(classname, ITEMBOX_ARMOR))
	{	
		if(!zp_get_user_zombie(id) && armor < 100)
		{
			client_print_color2(id, "!g[%s]!y +50 Armor!", PREFIX)
			set_pev(id, pev_armorvalue, floatmax(0.0, armor + 50))
			remove_entity_item(ent)
		}
	}

	if (equal(classname, ITEMBOX_AMMO))
	{
		if(!zp_get_user_zombie(id) && !g_enabled2[id])
		{
			client_print_color2(id, "!g[%s]!y Unlimited clip!", PREFIX)
			g_enabled2[id] = true
			remove_entity_item(ent)
		}
	}
}

public remove_entity_item(ent)
{
	emit_sound(ent,CHAN_AUTO,"items_sound/pickup.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
	if (pev_valid(ent)) remove_entity(ent)
}

collect_spawn_point(Float:origin[3]) // By Sontung0
{
	for (new i = 1; i <= g_total_box_spawn/* *3*/ ; i++)
	{
		origin = g_box_spawn[random(g_total_box_spawn)]
		if (check_spawn_box(origin)) return
	}
}

public get_total_box()
{
	new total
	for (new i = 1; i <= box_count; i++)
	{
		if (box_ent[i]) total += 1
	}
	return total
}

str_count(const str[], searchchar) // By Twilight Suzuka
{
	new count, i, len = strlen(str)
	
	for (i = 0; i <= len; i++)
	{
		if(str[i] == searchchar)
		count++
	}

	return count;
}

check_spawn_box(Float:origin[3]) // By Sontung0
{
	new Float:originE[3], Float:origin1[3], Float:origin2[3]
	new ent = -1
	while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", BOX_CLASSNAME)) != 0)
	{
		pev(ent, pev_origin, originE)
		
		// xoy
		origin1 = origin
		origin2 = originE
		origin1[2] = origin2[2] = 0.0
		if (vector_distance(origin1, origin2) <= 32.0) return 0;
	}
	return 1;
}

remove_ent_by_class(classname[])
{
	new nextitem  = find_ent_by_class(-1, classname)
	if(!pev_valid(nextitem))
		return
	while(nextitem)
	{
		remove_entity(nextitem)
		nextitem = find_ent_by_class(-1, classname)
	}
}

// NEW CODE
public present_killed(ent)
{
	if(!pev_valid(ent)) return

	static Float:originF[3]
	entity_get_vector(ent,EV_VEC_origin,originF)
	
	// New metod
	for(new i = 0; i < sizeof(g_GibModelIndex); i++)
	{
		// New message FOX
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_BREAKMODEL) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x axis
		engfunc(EngFunc_WriteCoord, originF[1]) // x axis
		engfunc(EngFunc_WriteCoord, originF[2]+20) // x axis
		write_coord(16) // size x
		write_coord(16) // size y
		write_coord(16) // size z
		write_coord(random_num(-20, 20)) // velocity x
		write_coord(random_num(-20, 20)) // velocity y
		write_coord(20) // velocity z
		write_byte(10) // random velocity
		write_short(g_GibModelIndex[i]) // model
		write_byte(1) // count
		write_byte(15 * 10) // life
		write_byte(0x4F);
		message_end()
	}
	
	emit_sound(ent,CHAN_AUTO,"items_sound/wood_break.wav",VOL_NORM,ATTN_NORM,0,PITCH_NORM)
	
	// Item Chance
	new num = random_num(0,5)
	if(num == 0) return
	
	new ItemEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))	
	entity_set_float(ItemEnt, EV_FL_scale, 1.0);
	set_pev(ItemEnt, pev_solid, 1)
	set_pev(ItemEnt, pev_movetype, 6)
	set_pev(ItemEnt, pev_nextthink, 1.0)
	entity_set_origin(ItemEnt,originF)
	
	static Float:angles[3]
	entity_get_vector(ItemEnt,EV_VEC_angles,angles)
	angles[1] -= random_num(-255, 255)
	entity_set_vector(ItemEnt,EV_VEC_angles,angles)
	
	switch(random_num(1,10))
	{
		case 1..2: // Antidote chance
		{
			entity_set_string(ItemEnt,EV_SZ_classname, ITEMBOX_ANTIDOTE)
			entity_set_model(ItemEnt,PRESENT_MODEL_ANTIDOTE)
		}
		case 3..5: // Health Vial chance
		{
			entity_set_string(ItemEnt,EV_SZ_classname, ITEMBOX_HEALTH)
			entity_set_model(ItemEnt,PRESENT_MODEL_HEALTH_VIAL)
		}
		case 6..8: // Health HGIBS chance
		{
			entity_set_string(ItemEnt,EV_SZ_classname, ITEMBOX_HGIBS)
			entity_set_model(ItemEnt,PRESENT_MODEL_HEALTH_HGIBS)
		}
		case 9..10: // Armor chence
		{
			entity_set_string(ItemEnt,EV_SZ_classname, ITEMBOX_ARMOR)
			entity_set_model(ItemEnt,PRESENT_MODEL_ARMOR)
		}
		case 11: // Unlimited Clip chence
		{
			entity_set_string(ItemEnt,EV_SZ_classname, ITEMBOX_AMMO)
			entity_set_model(ItemEnt,PRESENT_MODEL_AMMO)
		}
	}
}
public Event_CurWeapon(id) 
{
if(!is_user_alive(id))
return

if(!g_enabled2[id]) 
return

static iWeapon, Clip

iWeapon = read_data(2)
Clip = read_data(3)

if(!(NO_CLIP_WPN & (1<<iWeapon))) 
{
fm_cs_set_weapon_ammo(get_pdata_cbase(id, m_pActiveItem) , MAX_WEAPON_CLIP[iWeapon])

if (Clip < 2) // refill when clip is nearly empty
{
static wname[32], weapon_ent
get_weaponname(iWeapon, wname, sizeof wname - 1)
weapon_ent = fm_find_ent_by_owner(-1, wname, id)

fm_set_weapon_ammo(weapon_ent, MAX_WEAPON_CLIP[iWeapon])
}

}
}
stock fm_set_weapon_ammo(entity, amount)
{
set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}
stock client_print_color2(const id, const input[], any:...) 
{
new count = 1, players[32]
static msg[191]
vformat(msg, 190, input, 3)

replace_all(msg, 190, "!g", "^4")
replace_all(msg, 190, "!y", "^1")
replace_all(msg, 190, "!t", "^3")
replace_all(msg, 190, "!team2", "^0")

if (id)
players[0] = id;
else
get_players(players, count, "ch")

for (new i = 0; i < count; i++) {

if (is_user_connected(players[i])) {

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
write_byte(players[i]);
write_string(msg);
message_end();
}
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
