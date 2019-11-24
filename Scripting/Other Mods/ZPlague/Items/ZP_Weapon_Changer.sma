#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <ZP_Shop>
new const sound[][] =
{
"ZPlague/Weapons/m4a1_unsil-1.wav",
"ZPlague/Weapons/m4a1-1.wav", 
"ZPlague/Weapons/m249-1.wav",
"ZPlague/Weapons/ak47-1.wav",
"ZPlague/Weapons/m3-1.wav",
"ZPlague/Weapons/xm1014-1.wav",
"ZPlague/Weapons/sg550-1.wav",
"ZPlague/Weapons/g3sg1-1.wav"
}
new g_orig_event, g_orig_event2, g_orig_event3, g_orig_event4, g_orig_event5, g_orig_event6, 
g_orig_event7, g_orig_event8, g_orig_event9, g_orig_event10, g_orig_event11
public plugin_init() 
{
register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)	
register_forward(FM_PlaybackEvent, "fw_PlaybackEvent")	
}
public plugin_precache()
{	
for(new i = 0; i < sizeof(sound); i++)
precache_sound(sound[i])
register_forward(FM_PrecacheEvent, "fw_PrecacheEvent_Post", 1)
}
public fw_PrecacheEvent_Post(type, const name[])
{
if(equal("events/m4a1.sc", name))
g_orig_event = get_orig_retval()	
if(equal("events/ak47.sc", name))
g_orig_event2 = get_orig_retval()	
if(equal("events/m249.sc", name))
g_orig_event3 = get_orig_retval()
if(equal("events/m3.sc", name))
g_orig_event4 = get_orig_retval()
if(equal("events/xm1014.sc", name))
g_orig_event5 = get_orig_retval()
if(equal("events/sg550.sc", name))
g_orig_event6 = get_orig_retval()	
if(equal("events/g3sg1.sc", name))
g_orig_event7 = get_orig_retval()	
if(equal("events/sg552.sc", name))
g_orig_event8 = get_orig_retval()
if(equal("events/usp.sc", name))
g_orig_event9 = get_orig_retval()
if(equal("events/deagle.sc", name))
g_orig_event10 = get_orig_retval()
if(equal("events/awp.sc", name))
g_orig_event11 = get_orig_retval()
}

public fw_UpdateClientData_Post(id, sendweapons, cd_handle)
{
if(!is_user_alive(id) || !is_user_connected(id))
return FMRES_IGNORED	
if(get_user_weapon(id) == CSW_M249)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
else if(get_user_weapon(id) == CSW_M4A1)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
else if(get_user_weapon(id) == CSW_AK47)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
else if(get_user_weapon(id) == CSW_M3)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
else if(get_user_weapon(id) == CSW_XM1014)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
else if(get_user_weapon(id) == CSW_SG550)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
else if(get_user_weapon(id) == CSW_G3SG1)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
else if(get_user_weapon(id) == CSW_SG552)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
else if(get_user_weapon(id) == CSW_AWP)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
else if(get_user_weapon(id) == CSW_USP)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
else if(get_user_weapon(id) == CSW_DEAGLE)
set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.001)
return FMRES_HANDLED
}
public fw_PlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
if(!is_user_alive(invoker) || !is_user_connected(invoker))
return FMRES_IGNORED	
if(!zp_weapon_flamegun(invoker))
{
if(get_user_weapon(invoker) == CSW_M249)
{
if(eventid != g_orig_event3)
return FMRES_IGNORED
emit_sound(invoker, CHAN_WEAPON, sound[2], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(1,2))	
make_bullet(invoker)
} 
}
if(get_user_weapon(invoker) == CSW_M4A1)
{
if(eventid != g_orig_event)
return FMRES_IGNORED
static Ent; Ent = fm_get_user_weapon_entity(invoker, CSW_M4A1)
if(!pev_valid(Ent))
return FMRES_IGNORED
if(!cs_get_weapon_silen(Ent))emit_sound(invoker, CHAN_WEAPON, sound[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
if(cs_get_weapon_silen(Ent))emit_sound(invoker, CHAN_WEAPON, sound[1], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker, cs_get_weapon_silen(Ent) ? random_num(1,3) : random_num(8,10))	
make_bullet(invoker)
}
else if(get_user_weapon(invoker) == CSW_AK47)
{
if(eventid != g_orig_event2)
return FMRES_IGNORED
emit_sound(invoker, CHAN_WEAPON, sound[3], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(3,5))
make_bullet(invoker)	
} 
else if(get_user_weapon(invoker) == CSW_M3)
{
if(eventid != g_orig_event4)
return FMRES_IGNORED
emit_sound(invoker, CHAN_WEAPON, sound[4], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(1,2))	
make_bullet(invoker)
} 
else if(get_user_weapon(invoker) == CSW_XM1014)
{
if(eventid != g_orig_event5)
return FMRES_IGNORED
emit_sound(invoker, CHAN_WEAPON, sound[5], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(1,2))
make_bullet(invoker)	
} 
else if(get_user_weapon(invoker) == CSW_SG550)
{
if(eventid != g_orig_event6)
return FMRES_IGNORED
emit_sound(invoker, CHAN_WEAPON, sound[6], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(1,2))
make_bullet(invoker)	
} 
else if(get_user_weapon(invoker) == CSW_G3SG1)
{
if(eventid != g_orig_event7)
return FMRES_IGNORED
emit_sound(invoker, CHAN_WEAPON, sound[7], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(1,2))
make_bullet(invoker)	
} 
else if(get_user_weapon(invoker) == CSW_SG552)
{
if(eventid != g_orig_event8)
return FMRES_IGNORED
emit_sound(invoker, CHAN_WEAPON, "weapons/sg552-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(3,4))
make_bullet(invoker)	
} 
else if(get_user_weapon(invoker) == CSW_AWP)
{
if(eventid != g_orig_event11)
return FMRES_IGNORED
emit_sound(invoker, CHAN_WEAPON, "weapons/awp1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(1,2))	
make_bullet(invoker)
} 
else if(get_user_weapon(invoker) == CSW_USP)
{
if(eventid != g_orig_event9)
return FMRES_IGNORED
static Ent; Ent = fm_get_user_weapon_entity(invoker, CSW_USP)
if(!cs_get_weapon_silen(Ent))emit_sound(invoker, CHAN_WEAPON, "weapons/usp_unsil-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)	
if(cs_get_weapon_silen(Ent))emit_sound(invoker, CHAN_WEAPON, "weapons/usp1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker, cs_get_weapon_silen(Ent) ? random_num(1,3) : random_num(9,11))	
make_bullet(invoker)	
} 
else if(get_user_weapon(invoker) == CSW_DEAGLE)
{
if(eventid != g_orig_event10)
return FMRES_IGNORED
emit_sound(invoker, CHAN_WEAPON, "weapons/deagle-1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM)		
set_weapon_anim(invoker,  random_num(1,2))	
make_bullet(invoker)
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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
