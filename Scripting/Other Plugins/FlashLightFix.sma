#include <amxmodx> 
#include <fakemeta> 
public plugin_init() 
{      
register_forward(FM_AddToFullPack, "fw_full_pack", 1) 
} 
public fw_full_pack(es, e, ent, host, hostflags, player, pSet)
{
static bitEffects
if(player && host != ent && get_orig_retval() && (bitEffects = get_es(es, ES_Effects)) & EF_DIMLIGHT)
{
set_es(es, ES_Effects, bitEffects & ~EF_DIMLIGHT)
}
}  
