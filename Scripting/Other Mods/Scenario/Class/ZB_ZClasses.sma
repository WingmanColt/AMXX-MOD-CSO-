#include <amxmodx>
#include <zombie_scenario>

new const zb_model[] = "models/player/zbs_origin/zbs_origin.mdl"
new const zb_model2[] = "models/player/zbs_host/zbs_host.mdl"
new const zb_model3[] = "models/player/zbs_speed_host/zbs_speed_host.mdl"
new const zb_model4[] = "models/player/zbs_heavy_origin/zbs_heavy_origin.mdl"
new const zb_model5[] = "models/player/zbs_zombi_boss/zbs_zombi_boss.mdl"
new const zb_model6[] = "models/player/zbs_heal_origin/zbs_heal_origin.mdl"
new const zb_model7[] = "models/player/zbs_pc_origin/zbs_pc_origin.mdl"
new const zb_model8[] = "models/player/zbs_pc_host/zbs_pc_host.mdl"
new const zb_model9[] = "models/player/zbs_deimos_origin/zbs_deimos_origin.mdl"

new g_zclass_tankorigin, g_zclass_tankhost,g_zclass_speedhost, g_zclass_heavyorigin,
g_zclass_heavyboss, g_zclass_healorigin, g_zclass_exsciorigin, g_zclass_exscihost
new zb_modelindex,zb_modelindex2,zb_modelindex3,zb_modelindex4,zb_modelindex5,
zb_modelindex6, zb_modelindex7, zb_modelindex8, zb_modelindex9, g_zclass_deimosorigin
public plugin_precache()
{
zb_modelindex = precache_model(zb_model)
zb_modelindex2 = precache_model(zb_model2)
zb_modelindex3 = precache_model(zb_model3)
zb_modelindex4 = precache_model(zb_model4)
zb_modelindex5 = precache_model(zb_model5)
zb_modelindex6 = precache_model(zb_model6)
zb_modelindex7 = precache_model(zb_model7)
zb_modelindex8 = precache_model(zb_model8)
zb_modelindex9 = precache_model(zb_model9)

g_zclass_tankorigin = zbs_register_class(180.0, 140.0, zb_model, zb_modelindex)
g_zclass_tankhost = zbs_register_class(150.0, 120.0, zb_model2, zb_modelindex2)
g_zclass_speedhost = zbs_register_class(200.0, 150.0, zb_model3, zb_modelindex3)
g_zclass_heavyorigin = zbs_register_class(350.0, 145.0, zb_model4, zb_modelindex4)
g_zclass_heavyboss = zbs_register_class(50000.0, 170.0, zb_model5, zb_modelindex5)
g_zclass_healorigin = zbs_register_class(300.0, 160.0, zb_model6, zb_modelindex6)
g_zclass_exsciorigin = zbs_register_class(230.0, 180.0, zb_model7, zb_modelindex7)
g_zclass_exscihost = zbs_register_class(180.0, 170.0, zb_model8, zb_modelindex8)
g_zclass_deimosorigin = zbs_register_class(7000.0, 185.0, zb_model9, zb_modelindex9)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang13322\\ f0\\ fs16 \n\\ par }
*/
