#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <zp50_core>

#define TE_BLOODSPRITE	115
new blood
public plugin_init()
{
register_event("Damage","Damage","3=DMG_BULLET")
RegisterHam(Ham_BloodColor,"player","Hook_BloodColor")
}
public plugin_precache()
{
blood = precache_model("sprites/blood.spr")
}
public Hook_BloodColor(id)
{
if (!zp_core_is_zombie(id))
return HAM_IGNORED;

SetHamReturnInteger(243)
return HAM_SUPERCEDE;
}
public Damage(id)
{
if(is_user_connected(id) && get_user_health(id)!=50)
{
new origin[3]
get_user_origin(id,origin)
new hitpoint, weapon
get_user_attacker(id,weapon,hitpoint)
switch(hitpoint)
{
case 1:get_user_origin(id,origin,1)
case 2:origin[2] += 25
case 3:origin[2] += 10
case 4:
{
origin[2] += 10
origin[0] += 5
origin[1] += 5
}
case 5:
{
origin[2] += 10
origin[0] -= 5
origin[1] -= 5
}
case 6:
{
origin[2] -= 10
origin[0] += 5
origin[1] += 5
}
case 7:
{
origin[2] -= 10
origin[0] -= 5
origin[1] -= 5
}
}
message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
write_byte(TE_BLOODSPRITE)
write_coord(origin[0])
write_coord(origin[1])
write_coord(origin[2])
write_short(blood)
write_short(blood)
write_byte(243)
write_byte(3)
message_end()
}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
