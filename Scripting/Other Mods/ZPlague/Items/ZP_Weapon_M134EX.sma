#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <cs_maxspeed_api>
#include <zp50_core>

enum (+= 100)
{
TASK_M134_READY = 2000,
TASK_M134_CANCLICK,
TASK_M134_RELOADING
}
enum ( <<=1 )
{
v_angle = 1,
punchangle,
angles
}

enum _:eDataShell
{
SHELL_1 , 
SHELL_2
}
const m_flNextPrimaryAttack = 46
const m_flNextSecondaryAttack = 47
const m_flTimeWeaponIdle = 48
#define ID_M134_READY (taskid - TASK_M134_READY)
#define ID_M134_CANCLICK (taskid - TASK_M134_CANCLICK)
#define ID_M134_RELOADING (taskid - TASK_M134_RELOADING)
#define CSW_M134 CSW_M249
#define weapon_m134 "weapon_m249"
#define VectorAdd(%1,%2,%3) ( %3[ 0 ] = %1[ 0 ] + %2[ 0 ], %3[ 1 ] = %1[ 1 ] + %2[ 1 ], %3[ 2 ] = %1[ 2 ] + %2[ 2 ] )
new g_had_m134[33], g_m_ready[33], g_m_canclick[33], g_reloading[33]
new g_attack[33], g_m_shoot[33], g_iShell[eDataShell], g_orig_event_m249
public plugin_init()
{
register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")
RegisterHam(Ham_Item_AddToPlayer, weapon_m134, "fw_item_addtoplayer", 1)
RegisterHam(Ham_Weapon_Reload, weapon_m134, "fw_Weapon_Reload")
RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")	
RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack")
register_forward(FM_CmdStart, "fw_CmdStart" )
register_forward(FM_PlayerPreThink, "fw_PreThink")
register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
register_forward(FM_SetModel, "fw_SetModel")
register_forward(FM_AddToFullPack, "fw_AddToFullPack_post", 1)
register_forward(FM_CheckVisibility, "fw_CheckVisibility")
}
public plugin_precache()
{			
g_iShell[SHELL_1] = engfunc(EngFunc_PrecacheModel, "models/ZPlague/Items/wnpoth.mdl") 
g_iShell[SHELL_2] = engfunc(EngFunc_PrecacheModel, "models/ZPlague/Items/shell.mdl") 	
register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)	
}
public fwPrecacheEvent_Post(type, const name[])
{
if (equal("events/m249.sc", name))
g_orig_event_m249 = get_orig_retval()
}
public Hook_M249(id)engclient_cmd(id, weapon_m134)
public plugin_natives()
{
register_native("give_weapon_m134ex", "Get_M134", 1)	
register_native("remove_weapon_m134ex", "Remove_M134EX", 1)
register_native("remove_weapon_m134ex_2", "Remove_M134EX_2", 1)
}
public Get_M134(id)
{	
if(!is_user_alive(id))
return	
drop_weapons(id, 1)
g_had_m134[id] = true
give_item(id, weapon_m134)
cs_set_user_bpammo(id, CSW_M134, 200)
}
public Remove_M134EX_2(id)g_had_m134[id] = false
public Remove_M134EX(id)
{
if(task_exists(TASK_M134_CANCLICK))remove_task(id+TASK_M134_CANCLICK)
if(task_exists(TASK_M134_RELOADING))remove_task(id+TASK_M134_RELOADING)
if(task_exists(TASK_M134_READY))remove_task(id+TASK_M134_READY)
cs_reset_player_maxspeed(id)	
cs_set_player_maxspeed_auto(id, 1.0)
g_reloading[id] = false
g_m_canclick[id] = 0
g_m_ready[id] = 0
g_m_shoot[id] = 0
g_attack[id] = 0
}
public Event_CurWeapon(id)
{
if(!is_user_alive(id) || zp_core_is_zombie(id))
return

if(get_user_weapon(id) == CSW_M134)
{
if(g_had_m134[id])
{
set_pev(id, pev_viewmodel2, "models/ZPlague/Weapons/v_m134ex.mdl")
set_pev(id, pev_weaponmodel2, "models/ZPlague/Weapons/p_m134ex.mdl")
}		
}
}
public fw_SetModel(entity, model[])
{
if(!pev_valid(entity))
return FMRES_IGNORED;

static szClassName[33]
pev(entity, pev_classname, szClassName, charsmax(szClassName))

if(!equal(szClassName, "weaponbox"))
return FMRES_IGNORED;

static iOwner
iOwner = pev(entity, pev_owner)

if(equal(model, "models/w_m249.mdl"))
{
static weapon
weapon = fm_get_user_weapon_entity(entity, CSW_M134)

if(!pev_valid(weapon))
return FMRES_IGNORED;

if(g_had_m134[iOwner])
{	
set_pev(weapon, pev_impulse, 189572)	
engfunc(EngFunc_SetModel, entity, "models/ZPlague/Weapons/w_m134ex.mdl")
Remove_M134EX(iOwner)
g_had_m134[iOwner] = false
return FMRES_SUPERCEDE
}
}
return FMRES_IGNORED;
}

public fw_item_addtoplayer(ent, id)
{
if(!pev_valid(ent))
return HAM_IGNORED

if(pev(ent, pev_impulse) == 189572)
{
g_had_m134[id] = true	
set_pev(ent, pev_impulse, 0)
return HAM_HANDLED
}
return HAM_HANDLED
}
public fw_PreThink(id)
{	
if(!is_user_alive(id))
return PLUGIN_CONTINUE
if(zp_core_is_zombie(id))
return PLUGIN_CONTINUE
if(!g_had_m134[id])
return PLUGIN_CONTINUE

if(get_user_weapon(id) != CSW_M134 || !g_had_m134[id])Remove_M134EX(id)
else if(get_user_weapon(id) == CSW_M134 || g_had_m134[id])
{
if(g_m_ready[id] || g_m_canclick[id])set_pev(id, pev_maxspeed, 100.0)
else if(g_attack[id] || g_m_shoot[id])set_pev(id, pev_maxspeed, 50.0)
else if(!g_m_ready[id] || !g_m_canclick[id] || !g_attack[id] || !g_m_shoot[id])set_pev(id, pev_maxspeed, 150.0)
}
return PLUGIN_CONTINUE
}
public fw_Weapon_Reload(ent)
{
if(!pev_valid(ent))
return HAM_IGNORED	
new id = pev(ent,pev_owner)
if(!is_user_alive(id))
return HAM_IGNORED
new szClip, szAmmo
new szWeapID = get_user_weapon(id, szClip, szAmmo)

if(szWeapID == CSW_M134 && g_had_m134[id])
{
g_attack[id] = 0
g_m_shoot[id] = 0
g_reloading[id] = true
if (task_exists(id+TASK_M134_RELOADING)) remove_task(id+TASK_M134_RELOADING)
set_task(4.8, "task_reloaded", id+TASK_M134_RELOADING)
}

return HAM_IGNORED
}
public task_reloaded(taskid)
{
if(!is_user_alive(ID_M134_RELOADING) || zp_core_is_zombie(ID_M134_RELOADING))  
{  
remove_task(taskid);  
return;  
}  
g_reloading[ID_M134_RELOADING] = false
}
public fw_CmdStart(id, uc_handle, seed)
{
if(!is_user_alive(id) || !is_user_connected(id))
return FMRES_IGNORED	
if(zp_core_is_zombie(id))
return FMRES_IGNORED	
new szClip, szAmmo
new szWeapID = get_user_weapon(id, szClip, szAmmo)
if(szWeapID == CSW_M134 && g_had_m134[id])
{
if(g_reloading[id])
return FMRES_IGNORED
use_m134_attack(id, szClip, uc_handle)		
}
return FMRES_HANDLED
}
use_m134_attack(id, szClip, uc_handle)
{
static buttons
buttons = get_uc(uc_handle, UC_Buttons)

if ((buttons & IN_ATTACK))
{
if (!g_m_canclick[id] && !g_m_ready[id] && !g_m_shoot[id] && szClip)
{
buttons &= ~IN_ATTACK
set_uc(uc_handle, UC_Buttons, buttons)

set_weapons_timeidle(id, CSW_M134, 1.0)
set_weapon_anim(id, 5)
g_m_ready[id] = 1
set_player_nextattack(id, 1.0)
if (task_exists(id+TASK_M134_READY)) remove_task(id+TASK_M134_READY)
set_task(1.0, "task_m134_create_shoot", id+TASK_M134_READY)

g_m_canclick[id] = 1
if (task_exists(id+TASK_M134_CANCLICK)) remove_task(id+TASK_M134_CANCLICK)
set_task(1.0, "task_m134_remove_canclick", id+TASK_M134_CANCLICK)
}
}
else if (szClip)
{	
if (g_m_ready[id] || g_m_shoot[id])
{
g_m_ready[id] = 0
g_m_shoot[id] = 0

if (task_exists(id+TASK_M134_READY)) remove_task(id+TASK_M134_READY)
set_weapons_timeidle(id,CSW_M134, 1.1)
set_weapon_anim(id, 6)
}

if ((buttons & IN_RELOAD)) set_player_nextattack(id, 0.0)
}
}
public task_m134_create_shoot(taskid)
{
if(!is_user_alive(ID_M134_READY) || zp_core_is_zombie(ID_M134_READY))  
{  
remove_task(taskid);  
return;  
}  
g_m_ready[ID_M134_READY] = 0
g_m_shoot[ID_M134_READY] = 1
}
public task_m134_remove_canclick(taskid)
{
if(!is_user_alive(ID_M134_CANCLICK) || zp_core_is_zombie(ID_M134_CANCLICK))  
{  
remove_task(taskid);  
return;  
}  
g_m_canclick[ID_M134_CANCLICK] = 0
}
public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
if(!is_user_alive(id) || !is_user_connected(id))
return FMRES_IGNORED	
if(zp_core_is_zombie(id))
return FMRES_IGNORED
if(get_user_weapon(id) != CSW_M134)
return  FMRES_IGNORED
if(!g_had_m134[id])
return  FMRES_IGNORED
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001) 

return FMRES_HANDLED
}
public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
if(!is_user_connected(invoker))
return FMRES_IGNORED	
if(zp_core_is_zombie(invoker))
return FMRES_IGNORED		
if(get_user_weapon(invoker) != CSW_M134)
return FMRES_IGNORED
if(eventid != g_orig_event_m249)
return FMRES_IGNORED
if(g_had_m134[invoker])
{
engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
emit_sound(invoker, CHAN_WEAPON, "ZPlague/weapons/m134-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
set_player_nextattack(invoker, 0.07)
set_weapon_anim(invoker, random_num(1,2))
make_bullet(invoker)
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, invoker)
write_short(2<<12) 
write_short(1<<10) 
write_short(2<<12) 
message_end()
EjectBrass(invoker, g_iShell[SHELL_1], -5.0, 15.0, -3.0, -10.0, -50.0);
EjectBrass(invoker, g_iShell[SHELL_2], -5.0, 15.0, 8.0, 10.0, 50.0);
set_task(2.0, "PostShake", invoker)
}
return FMRES_SUPERCEDE
}
public PostShake(id)
{
if(!is_user_alive(id))
return;
if(!g_m_shoot[id])
return	
new szClip	
get_user_weapon(id, szClip)	
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, id)
if(szClip <= 0)
{
write_short(0) 
write_short(0) 
write_short(0) 
}else{
write_short(3<<14) 
write_short(1<<10) 
write_short(3<<14)
}
message_end()		
}
public fw_TraceAttack(ent, attacker, Float:Damage, Float:fDir[3], ptr, iDamageType)
{
if(!is_user_alive(attacker) || !is_user_connected(attacker))
return HAM_IGNORED	
if(zp_core_is_zombie(attacker))
return HAM_IGNORED	
if(get_user_weapon(attacker) != CSW_M134)
return HAM_IGNORED
if (iDamageType & (1<<24))
return HAM_IGNORED;
if(g_had_m134[attacker])SetHamParamFloat(3, float(200) / random_float(1.2, 1.3))	
return HAM_HANDLED
}
// STOCKS
stock make_bullet(id)
{
new target, body
get_user_aiming(id, target, body)
if(!target)
{		
new iOrigin[3]
get_user_origin(id, iOrigin, 3)
message_begin(MSG_ALL, SVC_TEMPENTITY, iOrigin)
write_byte(9) //TE_SPARKS
write_coord(iOrigin[0]) // Position
write_coord(iOrigin[1])
write_coord(iOrigin[2])
message_end()
}
return HAM_HANDLED
}
stock fm_cs_get_weapon_ent_owner(ent)
{
return get_pdata_cbase(ent, 41, 4)
}
stock set_weapon_anim(id, anim)
{
set_pev(id, pev_weaponanim, anim)

message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
write_byte(anim)
write_byte(pev(id,pev_body))
message_end()
}
stock drop_weapons(id, dropwhat)
{
static weapons[32], num, i, weaponid
num = 0
get_user_weapons(id, weapons, num)
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)	
for (i = 0; i < num; i++)
{
weaponid = weapons[i]

if (dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM))
{
static wname[32]
get_weaponname(weaponid, wname, sizeof wname - 1)
engclient_cmd(id, "drop", wname)
}
}
}
stock fm_get_user_weapon_entity(id, wid = 0) {
new weap = wid, clip, ammo;
if (!weap && !(weap = get_user_weapon(id, clip, ammo)))
return 0;

new class[32];
get_weaponname(weap, class, sizeof class - 1);

return fm_find_ent_by_owner(-1, class, id);
}
stock set_player_nextattack(id, Float:nexttime)
{
if(!is_user_alive(id))
return

set_pdata_float(id, 83, nexttime, 5)
}
stock set_weapons_timeidle(id, WeaponId ,Float:TimeIdle)
{
if(!is_user_alive(id))
return

static entwpn; entwpn = fm_get_user_weapon_entity(id, WeaponId)
if(!pev_valid(entwpn)) 
return

set_pdata_float(entwpn, 46, TimeIdle, 4)
set_pdata_float(entwpn, 47, TimeIdle, 4)
set_pdata_float(entwpn, 48, TimeIdle + 0.5, 4)
}

stock EjectBrass(Player, iShellModelIndex, Float:upScale, Float:fwScale, Float:rgScale , Float:rgKoord1 , Float:rgKoord2)
{
if(!is_user_alive(Player))
return		
UTIL_MakeVectors(Player, v_angle + punchangle);

static Float:vVel[ 3 ], Float:vAngle[ 3 ], Float:vOrigin[ 3 ], Float:vViewOfs[ 3 ],
i, Float:vShellOrigin[ 3 ],  Float:vShellVelocity[ 3 ], Float:vRight[ 3 ], 
Float:vUp[ 3 ], Float:vForward[ 3 ];
pev( Player, pev_velocity, vVel );
pev( Player, pev_view_ofs, vViewOfs );
pev( Player, pev_angles, vAngle );
pev( Player, pev_origin, vOrigin );
global_get( glb_v_right, vRight );
global_get( glb_v_up, vUp );
global_get( glb_v_forward, vForward );

for( i = 0; i < 3; i++ )
{
vShellOrigin[ i ] = vOrigin[ i ] + vViewOfs[ i ] + vUp[i] * upScale + vForward[i] * fwScale + vRight[ i ] * rgScale;
vShellVelocity[ i ] = vVel[ i ] + vRight[ i ] * random_float(rgKoord1, rgKoord2) + vUp[i] * random_float( 50.0, 100.0 ) + vForward[ i ] * 25.0;
}

engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vShellOrigin, 0);
write_byte(TE_MODEL);
engfunc(EngFunc_WriteCoord, vShellOrigin[0]);
engfunc(EngFunc_WriteCoord, vShellOrigin[1]);
engfunc(EngFunc_WriteCoord, vShellOrigin[2]);	
engfunc(EngFunc_WriteCoord, vShellVelocity[0]);
engfunc(EngFunc_WriteCoord, vShellVelocity[1]);
engfunc(EngFunc_WriteCoord, vShellVelocity[2]);
engfunc(EngFunc_WriteAngle, vAngle[1]);
write_short(iShellModelIndex);
write_byte(1);
write_byte(3); // 2.5 seconds
message_end();
}
stock UTIL_MakeVectors(pPlayer, bitsAngleType)
{
if(!is_user_alive(pPlayer))
return		
static Float:vPunchAngle[ 3 ], Float:vAngle[ 3 ];

if( bitsAngleType & v_angle )    
pev( pPlayer, pev_v_angle, vAngle );
if( bitsAngleType & punchangle ) 
pev( pPlayer, pev_punchangle, vPunchAngle );

VectorAdd( vAngle, vPunchAngle, vAngle );
engfunc( EngFunc_MakeVectors, vAngle );
}
stock fm_find_ent_by_owner(index, const classname[], owner, jghgtype = 0) {
new strtype[11] = "classname", ent = index;
switch (jghgtype) {
case 1: strtype = "target";
case 2: strtype = "targetname";
}

while ((ent = engfunc(EngFunc_FindEntityByString, ent, strtype, classname)) && pev(ent, pev_owner) != owner) {}

return ent;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
