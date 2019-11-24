#include <amxmodx>
#include <fakemeta>

public plugin_init() 
{
register_event("CurWeapon","Changeweapon_Hook","be","1=1")
}

public Changeweapon_Hook(id)
{
if(!is_user_alive(id))
return;

static model[32]
pev(id,pev_viewmodel2,model,31)

if(equali(model, "models/v_m4a1.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_m4a1.mdl")
else if(equali(model, "models/v_ak47.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_ak47.mdl")
else if(equali(model, "models/v_sg552.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_sg552.mdl")
else if(equali(model, "models/v_m3.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_m3.mdl")
else if(equali(model, "models/v_xm1014.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_xm1014.mdl")
else if(equali(model, "models/v_m249.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_m249.mdl")
else if(equali(model, "models/v_g3sg1.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_g3sg1.mdl")
else if(equali(model, "models/v_sg550.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_sg550.mdl")
else if(equali(model, "models/v_usp.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_usp.mdl")
else if(equali(model, "models/v_deagle.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_deagle.mdl")
else if(equali(model, "models/v_elite.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_elite.mdl")
else if(equali(model, "models/v_knife.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_knife.mdl")
else if(equali(model, "models/v_awp.mdl"))
set_pev(id,pev_viewmodel2,"models/ZPlague/Weapons/v_awp.mdl")
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
