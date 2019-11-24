#include <amxmodx>
#include <fakemeta>
#include <zp50_class_zombie>

// Classic Zombie Attributes
new const zombieclass1_name[] = "Fat Zombie"
new const zombieclass1_info[] = "Health"
new const zombieclass1_models[][] = { "ZP_Fat" }
new const zombieclass1_clawmodels[][] = { "models/ZPlague/Claws/v_knife_fat.mdl"}
const zombieclass1_health = 4999
const Float:zombieclass1_speed = 1.00
const Float:zombieclass1_gravity = 0.9

new g_ZombieClassID

public plugin_precache()
{
new index
g_ZombieClassID = zp_class_zombie_register(zombieclass1_name, zombieclass1_info, zombieclass1_health, zombieclass1_speed, zombieclass1_gravity)
for (index = 0; index < sizeof zombieclass1_models; index++)
zp_class_zombie_register_model(g_ZombieClassID, zombieclass1_models[index])
for (index = 0; index < sizeof zombieclass1_clawmodels; index++)
zp_class_zombie_register_claw(g_ZombieClassID, zombieclass1_clawmodels[index])
}
public client_disconnect(id)fm_set_rendering(id)
public zp_fw_core_infect_post(id, attacker)
{	
if(!is_user_alive(id))
return; 	
if(zp_class_nemesis_get(id) || zp_class_clown_get(id) || zp_class_assassin_get(id))
return;	
if (zp_class_zombie_get_current(id) == g_ZombieClassID)
{
fm_set_rendering(id)	
fm_set_rendering(id, kRenderFxGlowShell, 10, 190, 10, kRenderNormal, 0)
}
}
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
new Float:RenderColor[3];
RenderColor[0] = float(r);
RenderColor[1] = float(g);
RenderColor[2] = float(b);

set_pev(entity, pev_renderfx, fx);
set_pev(entity, pev_rendercolor, RenderColor);
set_pev(entity, pev_rendermode, render);
set_pev(entity, pev_renderamt, float(amount));

return 1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
