#include <amxmodx>
#include <ZombieMod5>

#define PLAYER_LINUX_XTRA_OFF 5
#define OFFSET_LINUX_WEAPONS  4
#define OFFSET_CLIPAMMO 51

#define m_pActiveItem 373
#define fm_cs_set_weapon_ammo(%1,%2) set_pdata_int(%1, OFFSET_CLIPAMMO, %2, OFFSET_LINUX_WEAPONS)

const NO_CLIP_WPN = ((1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))
new const MAX_WEAPON_CLIP[] = { -1, 13, -1, 10, 1, 7, -1, 30, 30, 1, 30, 20, 25, 30, 35, 25, 12, 20,10, 30, 100, 8, 30, 30, 20, 2, 7, 30, 30, -1, 50 }

new Float:cl_pushangle[33][3], bool:g_enabled[33], bool:g_enabled2[33]
new bool:g_headshot[33], Float:g_recoil[33], g_attack[33], g_smokepuff_id

public plugin_init() 
{
register_event("CurWeapon" , "Event_CurWeapon" , "be" , "1=1" )

static weapon_name[24]
for (new i = 1; i <= 30; i++) 
{
if (!(NO_CLIP_WPN & 1 << i) && get_weaponname(i, weapon_name, 23)) 
{
RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "_FW_Weapon_PrimaryAttack_Pre")
RegisterHam(Ham_Weapon_PrimaryAttack, weapon_name, "_FW_Weapon_PrimaryAttack_Post", 1)
}
}
RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack")
RegisterHam(Ham_TraceAttack, "worldspawn", "TrackeAttack_Post")
RegisterHam(Ham_TraceAttack, "player", "fw_trace")

register_forward(FM_TraceLine, "fw_TraceLine")
register_forward(FM_TraceHull, "fw_TraceHull")	
}
public plugin_precache()
{
g_smokepuff_id = engfunc(EngFunc_PrecacheModel, "sprites/wall_puff1.spr")
}

public plugin_natives()
{
register_native("set_weapons_recoil", "set_weapons_recoil2", 1)	
register_native("reset_weapons_recoil", "reset_weapons_recoil2", 1)	
register_native("set_weapons_headshot", "set_weapons_headshot2", 1)	
register_native("set_weapons_unlimited_clip", "set_weapons_unlimited_clip2", 1)
register_native("create_fake_attack", "Create_FakeAttack", 1)	
}

public client_putinserver(id)Reset_All(id)
public client_disconnected(id)Reset_All(id)
public zp_fw_core_cure_post(id)Reset_All(id)
public zp_fw_core_spawn_post(id)Reset_All(id)
public zp_fw_core_infect_post(id)
{
if(zp_core_is_zombie(id))	
Reset_All(id)
}

public Reset_All(id)
{
g_recoil[id] = 0.0
g_enabled[id] = false
g_enabled2[id] = false	
g_headshot[id] = false		
}
public set_weapons_unlimited_clip2(id, set)
{
g_enabled2[id] = (set == 0 ? false : true)
}
public set_weapons_headshot2(id, set)
{
g_headshot[id] = (set == 0 ? false : true)
}
public set_weapons_recoil2(id, Float:recoil)
{
g_recoil[id] = recoil
g_enabled[id] = true	
}
public reset_weapons_recoil2(id, Float:recoil)
{
g_recoil[id] = 0.0
g_enabled[id] = false	
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
cs_set_weapon_ammo(get_pdata_cbase(id, m_pActiveItem) , MAX_WEAPON_CLIP[iWeapon])

if (Clip < 2) // refill when clip is nearly empty
{
static wname[32], weapon_ent
get_weaponname(iWeapon, wname, sizeof wname - 1)
weapon_ent = fm_find_ent_by_owner(-1, wname, id)

fm_set_weapon_ammo(weapon_ent, MAX_WEAPON_CLIP[iWeapon])
}
}
}
public _FW_Weapon_PrimaryAttack_Pre(entity) 
{
if(!is_valid_ent(entity))
return HAM_IGNORED;

static id; id = pev(entity, pev_owner)

if(!is_user_alive(id))
return HAM_IGNORED;

if (!g_enabled[id]) 
return HAM_IGNORED;

pev(id, pev_punchangle, cl_pushangle[id])
return HAM_IGNORED;
}

public _FW_Weapon_PrimaryAttack_Post(entity) 
{
if(!is_valid_ent(entity))
return HAM_IGNORED;

static id; id = pev(entity, pev_owner)

if(!is_user_alive(id))
return HAM_IGNORED;

if (!g_enabled[id]) 
return HAM_IGNORED;

static Float:push[3]

pev(id, pev_punchangle, push)
xs_vec_sub(push, cl_pushangle[id], push)
xs_vec_mul_scalar(push, g_recoil[id], push)
xs_vec_add(push, cl_pushangle[id], push)
set_pev(id, pev_punchangle, push)

return HAM_IGNORED;
}
public fw_trace(victim, attacker, Float:damage, Float:direction[3], Ptr, damage_type)
{
if (!is_user_alive(attacker) || !is_user_alive(victim))
return HAM_IGNORED;

if (!zp_core_is_zombie(victim))
return HAM_IGNORED

if (g_headshot[attacker])
set_tr2(Ptr, TR_iHitgroup, HIT_HEAD)

return HAM_IGNORED
}
public TrackeAttack_Post(Victim, Attacker, Float:Damage, Float:Direction[3], Ptr, DamageBits)
{
if(!is_user_alive(Attacker))
return HAM_IGNORED

if(get_user_weapon(Attacker) == CSW_KNIFE)
return HAM_IGNORED

if(g_attack[Attacker])
return HAM_IGNORED

static Float:flEnd[3], Float:vecPlane[3]

get_tr2(Ptr, TR_vecEndPos, flEnd)
get_tr2(Ptr, TR_vecPlaneNormal, vecPlane)	

if(!is_user_alive(Victim))
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_STREAK_SPLASH)
write_coord_f(flEnd[0])
write_coord_f(flEnd[1])
write_coord_f(flEnd[2])
write_coord_f(vecPlane[0] * random_float(25.0,30.0))
write_coord_f(vecPlane[1] * random_float(25.0,30.0))
write_coord_f(vecPlane[2] * random_float(25.0,30.0))
write_byte(5)
write_short(12)
write_short(3)
write_short(75)	
message_end()	

fake_smoke(Attacker, Ptr)
} 

return HAM_HANDLED
}

public fake_smoke(id, trace_result)
{
static Float:vecSrc[3], Float:vecEnd[3], TE_FLAG

get_weapon_attachment(id, vecSrc)
global_get(glb_v_forward, vecEnd)

xs_vec_mul_scalar(vecEnd, 8192.0, vecEnd)
xs_vec_add(vecSrc, vecEnd, vecEnd)

get_tr2(trace_result, TR_vecEndPos, vecSrc)
get_tr2(trace_result, TR_vecPlaneNormal, vecEnd)

xs_vec_mul_scalar(vecEnd, 2.5, vecEnd)
xs_vec_add(vecSrc, vecEnd, vecEnd)

TE_FLAG |= TE_EXPLFLAG_NODLIGHTS
TE_FLAG |= TE_EXPLFLAG_NOSOUND
TE_FLAG |= TE_EXPLFLAG_NOPARTICLES

engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0)
write_byte(TE_EXPLOSION)
engfunc(EngFunc_WriteCoord, vecEnd[0])
engfunc(EngFunc_WriteCoord, vecEnd[1])
engfunc(EngFunc_WriteCoord, vecEnd[2] - 10.0)
write_short(g_smokepuff_id)
write_byte(2)
write_byte(50)
write_byte(TE_FLAG)
message_end()
}

public fw_TraceAttack(Ent, Attacker, Float:Damage, Float:Dir[3], ptr, DamageType)
{
if(!is_user_alive(Attacker))
return HAM_IGNORED
if(!g_attack[Attacker])
return HAM_IGNORED

return HAM_SUPERCEDE
}
public Create_FakeAttack(id, WEAPON_ANIMEXT)
{
static Ent; Ent = find_ent_by_owner(-1, "weapon_knife", id)
if(!is_valid_ent(Ent)) return

g_attack[id] = true
//ExecuteHamB(Ham_Weapon_PrimaryAttack, Ent)
ExecuteHamB(Ham_Weapon_SecondaryAttack, Ent)

// Set Real Attack Anim
static iAnimDesired,  szAnimation[64]

formatex(szAnimation, charsmax(szAnimation), (pev(id, pev_flags) & FL_DUCKING) ? "crouch_shoot_%s" : "ref_shoot_%s", WEAPON_ANIMEXT)
if((iAnimDesired = lookup_sequence(id, szAnimation)) == -1)
iAnimDesired = 0

set_pev(id, pev_sequence, iAnimDesired)
g_attack[id] = false
}
public fw_TraceLine(Float:vector_start[3], Float:vector_end[3], ignored_monster, id, handle)
{
if(!is_user_alive(id))
return FMRES_IGNORED

if(!g_attack[id])
return FMRES_IGNORED

static Float:vecStart[3], Float:vecEnd[3], Float:v_angle[3], Float:v_forward[3], Float:view_ofs[3], Float:fOrigin[3]

pev(id, pev_origin, fOrigin)
pev(id, pev_view_ofs, view_ofs)
xs_vec_add(fOrigin, view_ofs, vecStart)
pev(id, pev_v_angle, v_angle)

engfunc(EngFunc_MakeVectors, v_angle)
get_global_vector(GL_v_forward, v_forward)

xs_vec_mul_scalar(v_forward, 0.0, v_forward)
xs_vec_add(vecStart, v_forward, vecEnd)

engfunc(EngFunc_TraceLine, vecStart, vecEnd, ignored_monster, id, handle)

return FMRES_SUPERCEDE
}

public fw_TraceHull(Float:vector_start[3], Float:vector_end[3], ignored_monster, hull, id, handle)
{
if(!is_user_alive(id))
return FMRES_IGNORED

if(!g_attack[id])
return FMRES_IGNORED

static Float:vecStart[3], Float:vecEnd[3], Float:v_angle[3], Float:v_forward[3], Float:view_ofs[3], Float:fOrigin[3]

pev(id, pev_origin, fOrigin)
pev(id, pev_view_ofs, view_ofs)
xs_vec_add(fOrigin, view_ofs, vecStart)
pev(id, pev_v_angle, v_angle)

engfunc(EngFunc_MakeVectors, v_angle)
get_global_vector(GL_v_forward, v_forward)

xs_vec_mul_scalar(v_forward,  0.0, v_forward)
xs_vec_add(vecStart, v_forward, vecEnd)

engfunc(EngFunc_TraceHull, vecStart, vecEnd, ignored_monster, hull, id, handle)

return FMRES_SUPERCEDE
}

stock fm_set_weapon_ammo(entity, amount)
{
set_pdata_int(entity, OFFSET_CLIPAMMO, amount, OFFSET_LINUX_WEAPONS);
}
