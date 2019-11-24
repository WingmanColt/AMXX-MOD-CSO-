#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <cs_weap_models_api>
#include <zp50_colorchat>
#include <zp50_gamemodes>
#include <zp50_core>
#include <ZP_Shop>

enum (+= 100)
{
TASK_SCREENHUD = 0,
TASK_RETURNSUIT
}
#define ID_SCREENHUD (taskid - TASK_SCREENHUD)
#define ID_RETURNSUIT (taskid - TASK_RETURNSUIT)
const PEV_NADE_TYPE = pev_flTimeStepSound
const NADE_TYPE_EMI = 1231137
new g_had_emi[33], ntime[33], g_trailSpr, g_exploSpr
public plugin_init()
{
register_event("CurWeapon", "Event_CurWeapon", "be", "1=1")	
register_forward(FM_SetModel, "fw_SetModel")
RegisterHam(Ham_Think, "grenade", "fw_ThinkGrenade")
}

public plugin_precache()
{
g_trailSpr = engfunc(EngFunc_PrecacheModel, "sprites/laserbeam.spr")
g_exploSpr = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
}
public plugin_natives()
{
register_native("give_item_conc", "Get_EMI", 1)
}
public Get_EMI(id)
{	
if (user_has_weapon(id, CSW_SMOKEGRENADE))
return 
new money = zp_ammopacks_get(id) 		
if (money >= 13)
{		
zp_ammopacks_set(id, money - 13)		
give_item(id, "weapon_smokegrenade")
g_had_emi[id] = true
}else{
zp_colored_print(id, "^x01Not enough AmmoPacks!")
}
}
public Event_CurWeapon(id)
{
if(!is_user_alive(id) || !zp_core_is_zombie(id))
return

if(get_user_weapon(id) == CSW_SMOKEGRENADE)
{
if(g_had_emi[id])
{
set_pev(id, pev_viewmodel2, "models/ZPlague/Grenades/v_conc.mdl")
set_pev(id, pev_weaponmodel2, "models/ZPlague/Grenades/p_conc.mdl")
}		
}
}
public fw_SetModel(ent, const model[])
{
if (!pev_valid(ent))
return;

// We don't care
if (strlen(model) < 8)
return;

// Narrow down our matches a bit
if (model[7] != 'w' || model[8] != '_')
return;

// Get damage time of grenade
static Float:dmgtime
pev(ent, pev_dmgtime, dmgtime)

// Grenade not yet thrown
if (dmgtime == 0.0)
return;

static id; id = pev(ent, pev_owner)

if (!is_user_alive(id))
return;

if (!zp_core_is_zombie(id))
return;

if (model[9] == 's' && model[10] == 'm')
{
if(g_had_emi[id])
{
message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
write_byte(TE_BEAMFOLLOW) // TE id
write_short(ent) // entity
write_short(g_trailSpr) // sprite
write_byte(10) // life
write_byte(10) // width
write_byte(150) // r
write_byte(170) // g
write_byte(200) // b
write_byte(100) // brightness
message_end()
engfunc(EngFunc_SetModel, ent, "models/ZPlague/Grenades/w_conc.mdl")
set_pev(ent, PEV_NADE_TYPE, NADE_TYPE_EMI)
}
}
}
public fw_ThinkGrenade(entity)
{
if (!pev_valid(entity)) 
return HAM_IGNORED;

static Float:dmgtime
pev(entity, pev_dmgtime, dmgtime)

if (dmgtime > get_gametime())
return HAM_IGNORED;

switch (pev(entity, PEV_NADE_TYPE))
{
case NADE_TYPE_EMI: 
{
emi_bomb(entity) 
return HAM_SUPERCEDE;
}
}

return HAM_IGNORED;
}
emi_bomb(entity)  
{  
if(!pev_valid(entity))
return;

static Float:Origin[3]
pev(entity, pev_origin, Origin)  

engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, Origin, 0)
write_byte(TE_BEAMCYLINDER) // TE id
engfunc(EngFunc_WriteCoord, Origin[0]) // x
engfunc(EngFunc_WriteCoord, Origin[1]) // y
engfunc(EngFunc_WriteCoord, Origin[2]) // z
engfunc(EngFunc_WriteCoord, Origin[0]) // x axis
engfunc(EngFunc_WriteCoord, Origin[1]) // y axis
engfunc(EngFunc_WriteCoord, Origin[2]+555.0) // z axis
write_short(g_exploSpr) // sprite
write_byte(0) // startframe
write_byte(0) // framerate
write_byte(4) // life
write_byte(60) // width
write_byte(0) // noise
write_byte(150) // red
write_byte(170) // green
write_byte(200) // blue
write_byte(200) // brightness
write_byte(0) // speed
message_end()

emit_sound(entity, CHAN_WEAPON, "ZPlague/conc_explode.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
static Float:origin[3];  
pev(entity, pev_origin, origin);  

static victim, hp;  
victim = -1;  

while((victim = engfunc(EngFunc_FindEntityInSphere, victim, origin, 250.0)) != 0)  
{  
if(!is_user_alive(victim))  
continue;  

if(zp_core_is_zombie(victim))  
continue;  

if(!task_exists(victim+TASK_SCREENHUD))  
{  
hp = get_user_health(victim);  
hp -= 5;  

if (hp < 7)  
hp = 7;  

set_user_health(victim, hp - 5);  

message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, victim);   
write_short(3<<14/2);  
write_short(3<<14/2)  
write_short(3<<14);  
write_byte(255);  
write_byte(0);  
write_byte(0);  
write_byte(200);  
message_end();  
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, victim)
write_short(3<<14) 
write_short(2<<12) 
write_short(3<<14)
message_end()
zp_nanosuit_effect(victim, 0)

ntime[victim] = floatround(15.0, floatround_ceil);  

set_hudmessage(0, 128, 255, 0.37, 0.27, 0, 1.0, 1.0, 0.01);  
show_hudmessage(victim, "       !!!! CRITICAL ERROR !!!!^n             SYSTEM FAILED^n^n      ATTEMPTING REBOOT IN:%d^n^nREASON: Electro - Magnetic Impulse (EMI)", ntime[victim])  

set_task(1.0, "emi_screenhud", victim+TASK_SCREENHUD, _, _, "a", ntime[victim]);  
set_task(15.0, "emi_return", victim+TASK_RETURNSUIT);  
}  
}  

engfunc(EngFunc_RemoveEntity, entity);  
}  

public emi_screenhud(taskid)  
{  
if(ntime[ID_SCREENHUD] <= 0)  
{  
remove_task(taskid);  
return;  
}  

ntime[ID_SCREENHUD]--;  

set_user_health(ID_SCREENHUD, get_user_health(ID_SCREENHUD) - 5);  
new hp = get_user_health(ID_SCREENHUD);  
hp -= 5;  

if (hp < 7)  
hp = 7;  

set_user_health(ID_SCREENHUD, hp - 5);  

message_begin(MSG_ONE, get_user_msgid("ScreenFade"), _, ID_SCREENHUD);  
write_short(3<<14/2);  
write_short(3<<14/2)  
write_short(3<<14);  
write_byte(255);  
write_byte(0);  
write_byte(0);  
write_byte(200);  
message_end();  

message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenShake"), {0,0,0}, ID_SCREENHUD)
write_short(3<<14) 
write_short(2<<12) 
write_short(3<<14)
message_end()

set_hudmessage(0, 128, 255, 0.37, 0.27, 0, 1.0, 1.0, 0.01);  
show_hudmessage(ID_SCREENHUD, "       !!!! CRITICAL ERROR !!!!^n             SYSTEM FAILED^n^n      ATTEMPTING REBOOT IN:%d^n^nREASON: Electro - Magnetic Impulse (EMI)", ntime[ID_SCREENHUD])  
}  

public emi_return(taskid)  
{  
if(!is_user_alive(ID_RETURNSUIT) || zp_core_is_zombie(ID_RETURNSUIT))  
{  
remove_task(taskid);  
return;  
}  
zp_nanosuit_effect(ID_RETURNSUIT, 1)
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
