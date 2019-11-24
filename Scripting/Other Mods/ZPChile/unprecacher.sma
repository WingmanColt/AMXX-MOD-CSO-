#include <amxmodx> 
#include <cstrike> 
#include <fakemeta> 
#include <hamsandwich> 

// Entries Limit !
public plugin_init()
{
RegisterHam(Ham_CS_Restart, "armoury_entity", "FwdSetCount", 1);
}
public FwdSetCount(Ent)
{
set_pdata_int(Ent, 35, 99999, 4);
}  

new const g_Sounds[][] = 
{ 
"weapons/c4_beep1.wav", 
"weapons/c4_beep2.wav", 
"weapons/c4_beep3.wav", 
"weapons/c4_beep4.wav", 
"weapons/c4_beep5.wav", 
"weapons/c4_plant.wav", 
"weapons/c4_disarm.wav", 
"weapons/c4_disarmed.wav", 
"ambience/Guit1.wav",
"ambience/Opera.wav",
"ambience/Opera.wav",
"weapons/sg_explode.wav",
"radio/blow.wav",
"radio/bombdef.wav",
"radio/bombpl.wav",
"radio/circleback.wav",
"radio/clear.wav",
"radio/com_followcom.wav",
"radio/com_getinpos.wav",
"radio/com_go.wav",
"radio/com_reportin.wav",
"radio/ct_affirm.wav",
"radio/ct_backup.wav",
"radio/ct_coverme.wav",
"radio/ct_enemys.wav",
"radio/ct_fireinhole.wav",
"radio/ct_imhit.wav",
"radio/ct_inpos.wav",
"radio/ct_point.wav",
"radio/ct_reportingin.wav",
"radio/ctwin.wav",
"radio/elim.wav",
"radio/enemydown.wav",
"radio/fallback.wav",
"radio/fireassis.wav",
"radio/flankthem.wav",
"radio/followme.wav",
"radio/getout.wav",
"radio/hitassist.wav",
"radio/hosdown.wav",
"radio/letsgo.wav",
"radio/locknload.wav",
"radio/matedown.wav",
"radio/meetme.wav",
"radio/moveout.wav",
"radio/negative.wav",
"radio/position.wav",
"radio/regroup.wav",
"radio/rescued.wav",
"radio/roger.wav",
"radio/rounddraw.wav",
"radio/sticktog.wav",
"radio/stormfront.wav",
"radio/takepoint.wav",
"radio/takepoint.wav",
"radio/terwin.wav",
"radio/vip.wav",
"hostage/hos1.wav",
"hostage/hos2.wav",
"hostage/hos3.wav",
"hostage/hos4.wav",
"hostage/hos5.wav",
"hostage/hos1.wav",
"player/breathe1.wav",
"player/breathe2.wav",
"player/pl_die1.wav",
"player/pl_dirt1.wav",
"player/pl_dirt2.wav",
"player/pl_dirt3.wav",
"player/pl_dirt4.wav",
"player/pl_duct1.wav",
"player/pl_duct2.wav",
"player/pl_duct3.wav",
"player/pl_duct4.wav",
"player/pl_fallpain1.wav",
"player/pl_fallpain2.wav",
"player/pl_fallpain3.wav",
"player/pl_grate1.wav",
"player/pl_grate2.wav",
"player/pl_grate3.wav",
"player/pl_grate4.wav",
"player/pl_jump1.wav",
"player/pl_jump2.wav",
"player/pl_ladder1.wav",
"player/pl_ladder2.wav",
"player/pl_ladder3.wav",
"player/pl_ladder4.wav",
"player/pl_metal1.wav",
"player/pl_metal2.wav",
"player/pl_metal3.wav",
"player/pl_metal4.wav",
"player/pl_pain2.wav",
"player/pl_pain4.wav",
"player/pl_pain5.wav",
"player/pl_pain6.wav",
"player/pl_pain7.wav",
"player/pl_shell1.wav",
"player/pl_shot1.wav",
"player/pl_slosh1.wav",
"player/pl_slosh2.wav",
"player/pl_slosh3.wav",
"player/pl_slosh4.wav",
"player/pl_snow1.wav",
"player/pl_snow2.wav",
"player/pl_snow3.wav",
"player/pl_snow4.wav",
"player/pl_snow5.wav",
"player/pl_snow6.wav",
"player/pl_step1.wav",
"player/pl_step2.wav",
"player/pl_step3.wav",
"player/pl_step4.wav",
"player/pl_tile1.wav",
"player/pl_tile2.wav",
"player/pl_tile3.wav",
"player/pl_tile4.wav",
"player/pl_tile5.wav",
"player/sprayer.wav"
} 
new const g_Models[][] = 
{ 
"models/player/militia/militia.mdl",
"models/player/spetsnaz/spetsnaz.mdl",
"models/v_c4.mdl",
"models/p_c4.mdl",
"models/w_c4.mdl",
"models/shield/p_shield_deagle.mdl",
"models/shield/p_shield_fiveseven.mdl",
"models/shield/p_shield_flashbang.mdl",
"models/shield/p_shield_glock18.mdl",
"models/shield/p_shield_hegrenade.mdl",
"models/shield/p_shield_p228.mdl",
"models/shield/p_shield_smokegrenade.mdl",
"models/shield/p_shield_usp.mdl",
"models/shield/v_shield_deagle.mdl",
"models/shield/v_shield_fiveseven.mdl",
"models/shield/v_shield_flashbang.mdl",
"models/shield/v_shield_glock18.mdl",
"models/shield/v_shield_hegrenade.mdl",
"models/shield/v_shield_p228.mdl",
"models/shield/v_shield_smokegrenade.mdl",
"models/shield/v_shield_usp.mdl",
"models/shield/v_shield_knife.mdl",
"models/v_shield.mdl",
"models/p_shield.mdl",
"models/w_shield.mdl",
"models/v_shield_r.mdl",
"models/p_shield_r.mdl",
"models/w_shield_r.mdl",
"models/w_backpack.mdl",
"models/hostage01.mdl",
"models/hostage02.mdl",
"models/hostage03.mdl",
"models/hostage04.mdl",
"models/hostage05.mdl",
"models/hostage06.mdl",
"models/hostage07.mdl",
"models/hostage08.mdl",
"models/player/vip/vip.mdl",
"sprites/c4.spr",
"sprites/ic4.spr",
"sprites/ihostage.spr",
"sprites/iplayerc4.spr",
"sprites/iplayervip.spr",
"sprites/ibackpack.spr"
}
new const g_Generic[][] = 
{ 
"sprites\weapon_c4.txt",
"gfx\vgui\ak47.tga",
"gfx\vgui\aug.tga",
"gfx\vgui\awp.tga",
"gfx\vgui\defuser.tga",
"gfx\vgui\deserteagle.tga",
"gfx\vgui\elites.tga",
"gfx\vgui\famas.tga",
"gfx\vgui\fiveseven.tga",
"gfx\vgui\flashbang.tga",
"gfx\vgui\g3sg1.tga",
"gfx\vgui\galil.tga",
"gfx\vgui\gign.tga",
"gfx\vgui\glock18.tga",
"gfx\vgui\hegrenade.tga",
"gfx\vgui\kevlar.tga",
"gfx\vgui\kevlar_helmet.tga",
"gfx\vgui\leet.tga",
"gfx\vgui\m249.tga",
"gfx\vgui\m3.tga",
"gfx\vgui\m4a1.tga",
"gfx\vgui\mac10.tga",
"gfx\vgui\mp5.tga",
"gfx\vgui\nightvision.tga",
"gfx\vgui\not_available.tga",
"gfx\vgui\p228.tga",
"gfx\vgui\p90.tga",
"gfx\vgui\sas.tga",
"gfx\vgui\scout.tga",
"gfx\vgui\sg550.tga",
"gfx\vgui\sg552.tga",
"gfx\vgui\shield.tga",
"gfx\vgui\smokegrenade.tga",
"gfx\vgui\tmp.tga",
"gfx\vgui\ump45.tga",
"gfx\vgui\urban.tga",
"gfx\vgui\usp45.tga",
"gfx\vgui\vip.tga",
"gfx\vgui\xm1014.tga"
}
public plugin_precache() 
{ 
register_forward(FM_PrecacheModel, "PrecacheModel") 
register_forward(FM_PrecacheGeneric, "PrecacheGeneric") 
register_forward(FM_PrecacheSound, "PrecacheSound") 
} 
public PrecacheModel(const szModel[]) 
{ 
for(new i = 0; i < sizeof(g_Models); i++) 
{ 
if(containi(szModel, g_Models[i]) != -1 ) 
{ 
forward_return(FMV_CELL, 0) 
return FMRES_SUPERCEDE 
} 
} 
return FMRES_IGNORED 
} 

public PrecacheSound(const szSound[]) 
{ 
for(new i = 0; i < sizeof(g_Sounds); i++) 
{ 
if(containi(szSound, g_Sounds[i]) != -1 ) 
{ 
forward_return(FMV_CELL, 0) 
return FMRES_SUPERCEDE 
} 
} 
return FMRES_IGNORED 
}
public PrecacheGeneric(const szGeneric[]) 
{ 
for(new i = 0; i < sizeof(g_Generic); i++) 
{ 
if(containi(szGeneric, g_Generic[i]) != -1 ) 
{ 
forward_return(FMV_CELL, 0) 
return FMRES_SUPERCEDE 
} 
} 
return FMRES_IGNORED 
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
