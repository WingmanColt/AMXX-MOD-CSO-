#include <amxmodx> 
#include <fakemeta> 
public plugin_init() 
{      
register_forward(FM_AddToFullPack, "fw_full_pack", 1) 
} 
public fw_full_pack(es, e, ent, host, hostflags, player, pSet)
{
if(!pev_valid(ent))
return;	
static bitEffects
if(player && host != ent && get_orig_retval() && (bitEffects = get_es(es, ES_Effects)) & EF_DIMLIGHT)
{
set_es(es, ES_Effects, bitEffects & ~EF_DIMLIGHT)
}
}  
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
