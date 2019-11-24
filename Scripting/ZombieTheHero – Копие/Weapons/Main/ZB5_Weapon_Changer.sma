#include <amxmodx>
#include <fakemeta>
#include <cstrike>

new g_orig_event1, g_orig_event2, g_orig_event3
public plugin_init() 
{
register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)	
register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
}
public plugin_precache()
{	
register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)
}
public fw_PrecacheEvent_Post(type, const name[])
{
if(equal("events/m4a1.sc", name))
g_orig_event1 = get_orig_retval()	
if(equal("events/ak47.sc", name))
g_orig_event2 = get_orig_retval()	
if(equal("events/deagle.sc", name))
g_orig_event3 = get_orig_retval()
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
if(!is_user_connected(id))
return FMRES_IGNORED
	
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
return FMRES_HANDLED
}
public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
if(!is_user_connected(invoker))
return FMRES_IGNORED	

if(get_user_weapon(invoker) == CSW_M4A1)
{
if(eventid != g_orig_event1)
return FMRES_IGNORED

static Ent; Ent = fm_get_user_weapon_entity(invoker, CSW_M4A1)
if(!pev_valid(Ent))
return FMRES_IGNORED

if(!cs_get_weapon_silen(Ent))emit_sound(invoker, CHAN_WEAPON, "weapons/m4a1_unsil-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
if(cs_get_weapon_silen(Ent))emit_sound(invoker, CHAN_WEAPON, "weapons/m4a1-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker, cs_get_weapon_silen(Ent) ? random_num(1,3) : random_num(8,10))	
}
else if(get_user_weapon(invoker) == CSW_AK47)
{
if(eventid != g_orig_event2)
return FMRES_IGNORED

emit_sound(invoker, CHAN_WEAPON, "weapons/ak47-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(3,5))
} 
else if(get_user_weapon(invoker) == CSW_DEAGLE)
{
if(eventid != g_orig_event3)
return FMRES_IGNORED

emit_sound(invoker, CHAN_WEAPON, "weapons/deagle-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(1,2))	
} 
engfunc(EngFunc_PlaybackEvent, flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
return FMRES_SUPERCEDE
}
stock set_weapon_anim(id, anim)
{
set_pev(id, pev_weaponanim, anim)

message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, id)
write_byte(anim)
write_byte(pev(id,pev_body))
message_end()
}
stock fm_get_user_weapon_entity(id, wid = 0) {
new weap = wid, clip, ammo;
if (!weap && !(weap = get_user_weapon(id, clip, ammo)))
return 0;

new class[32];
get_weaponname(weap, class, sizeof class - 1);

return fm_find_ent_by_owner(-1, class, id);
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
