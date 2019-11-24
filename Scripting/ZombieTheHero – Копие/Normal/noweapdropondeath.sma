#include <amxmodx>
#include <ZombieMod5>

#define WBOX "models/w_weaponbox.mdl"
new g_entid[33]
public plugin_init() 
{
register_forward(FM_SetModel, "forward_set_model")
}

public forward_set_model(entid, model[]) 
{
if (!is_valid_ent(entid) || !equal(model, WBOX, 9))
return FMRES_IGNORED

new id = entity_get_edict(entid, EV_ENT_owner)
if(!zp_core_is_human(id, 1))
return FMRES_IGNORED

if (equal(model, WBOX)) {
g_entid[id] = entid
return FMRES_IGNORED
}

if (entid != g_entid[id])
return FMRES_IGNORED

g_entid[id] = 0

static g_maxents; g_maxents = get_global_int(GL_maxEntities)
for (new i = 1; i <= g_maxents; ++i) 
{
if (is_valid_ent(i) && entid == entity_get_edict(i, EV_ENT_owner)) {
kill_entity(entid)
kill_entity(i)
}
}

return FMRES_IGNORED
}

stock kill_entity(id) 
entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags)|FL_KILLME)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
