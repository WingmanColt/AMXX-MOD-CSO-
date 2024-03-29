#include <amxmodx>
#include <zp50_core>

new const sound2[][] =
{
"ZPChile/weapons/uzi-1.wav",		
"ZPChile/weapons/m16a1-1.wav",	
"ZPChile/weapons/usas-1.wav",	
"ZPChile/weapons/m60-1.wav",	
"ZPChile/weapons/m60craft_clipin1.wav",	
"ZPChile/weapons/m60craft_clipin2.wav",	
"ZPChile/weapons/m60craft_clipin3.wav",	
"ZPChile/weapons/m60craft_clipout.wav",	
"ZPChile/weapons/balrog11_charge.wav",
"ZPChile/fire_explo.wav",
"ZPChile/fire1.wav",
"ZPChile/fire2.wav",
"ZPChile/fire3.wav",
"ZPChile/fire4.wav",
"ZPChile/warning.wav",
"ZPChile/infected01.wav",
"ZPChile/win_humans.wav",
"ZPChile/win_zombies.wav",
"ZPChile/evacuate_area.wav",
"ZPChile/Spitter/pain1.wav",
"ZPChile/Spitter/pain2.wav",
"ZPChile/Spitter/pain3.wav",
"ZPChile/Spitter/spitter_acid_loop_02.wav",
"ZPChile/Spitter/spitter_spit_02.wav",
"ZPChile/Spitter/spitter_death_02.wav",
"ZPChile/Jockey/pain1.wav",
"ZPChile/Jockey/pain2.wav",
"ZPChile/Jockey/pain3.wav",
"ZPChile/Jockey/death1.wav",
"ZPChile/Jockey/death2.wav",
"ZPChile/Jockey/jockey_attackloop01.wav",
"ZPChile/Jockey/jockey_loudattack01.wav",
"ZPChile/Tank/tank_death_01.wav",
"ZPChile/Tank/tank_pain_01.wav",
"ZPChile/Tank/tank_pain_02.wav",
"ZPChile/Tank/tank_pain_03.wav",
"ZPChile/Boomer/boomer_pain1.wav",
"ZPChile/Boomer/boomer_pain2.wav",
"ZPChile/Boomer/boomer_pain3.wav",
"ZPChile/Boomer/vomit_1.wav",
"ZPChile/Boomer/explo_boomber.wav",
"ZPChile/Smoker/pain1.wav",
"ZPChile/Smoker/pain2.wav",
"ZPChile/Smoker/pain3.wav",
"ZPChile/Smoker/death1.wav",
"ZPChile/Smoker/smoker_drag.wav",
"ZPChile/Charger/charger_pain_1.wav",
"ZPChile/Charger/charger_pain_2.wav",
"ZPChile/Charger/charger_die_1.wav",
"ZPChile/Charger/charger_smash.wav",
"ZPChile/Charger/charger_speed.wav",
"ZPChile/Charger/charger_speed2.wav",
"ZPChile/Tank/tank_lunch.wav",
"ZPChile/Hunter/Jump01.wav",
"ZPChile/Siren/siren_scream.wav",
"ZPChile/Oxidation/gas_form.wav",
"ZPChile/Zombie/pain1.wav",
"ZPChile/Zombie/pain2.wav",
"ZPChile/Zombie/pain3.wav",
"ZPChile/Zombie/infect1.wav",
"ZPChile/Zombie/infect2.wav",
"ZPChile/Zombie/idle1.wav",
"ZPChile/Zombie/idle2.wav",
"ZPChile/Zombie/death01.wav",
"ZPChile/Zombie/death02.wav",
"ZPChile/Assassin/pain1.wav",
"ZPChile/Assassin/pain2.wav",
"ZPChile/Assassin/pain3.wav",
"ZPChile/Assassin/death1.wav",
"ZPChile/Nemesis/pain1.wav", 
"ZPChile/Nemesis/pain2.wav",
"ZPChile/Nemesis/death1.wav",
"ZPChile/ZPC_Assassin_Round.wav",
"ZPChile/ZPC_Multi_Round.wav",
"ZPChile/Shout/Shout01.wav",
"ZPChile/Shout/Shout05.wav",
"ZPChile/frost_exp.wav",
"ZPChile/flare_on.wav",
"ZPChile/pipe_beep.wav",
"ZPChile/bazooka_stone_explode.wav",
"ZPChile/player/choke01.wav",
"ZPChile/player/choke02.wav", 
"ZPChile/player/choke03.wav",
"ZPChile/player/cough01.wav",
"ZPChile/player/cough02.wav", 
"ZPChile/player/cough03.wav",
"ZPChile/player/gooedbyspitter01.wav",
"ZPChile/player/grabbedbysmoker01.wav",
"ZPChile/player/grabbedbysmoker02.wav", 
"ZPChile/player/grabbedbysmoker03.wav",
"ZPChile/player/grabbedbyjockey01.wav",
"ZPChile/player/grabbedbycharger08.wav",
"weapons/rocketfire1.wav",
"weapons/mine_deploy.wav",
"weapons/mine_charge.wav",
"weapons/mine_activate.wav",
"debris/beamstart14.wav",
"items/gunpickup2.wav"
}
new const models[][] =
{	
"models/player/ZPC_Player01/ZPC_Player01.mdl",
"models/player/ZPC_Player01/ZPC_Player01t.mdl",
"models/player/ZPC_Player02/ZPC_Player02.mdl",
"models/player/ZPC_Player02/ZPC_Player02T.mdl",
"models/player/ZPC_Human01/ZPC_Human01.mdl",
"models/player/ZPC_Human02/ZPC_Human02.mdl",
"models/player/ZPC_Human03/ZPC_Human03.mdl",
"models/player/ZPC_Human04/ZPC_Human04.mdl",
"models/player/ZPC_Human05/ZPC_Human05.mdl",
"models/player/ZPC_Human06/ZPC_Human06.mdl",
"models/player/ZPC_Human07/ZPC_Human07.mdl",
"models/player/ZPC_Human08/ZPC_Human08.mdl",
"models/player/ZPC_Assassin/ZPC_Assassin.mdl",
"models/player/ZPC_Nemesis/ZPC_Nemesis.mdl",
"models/player/ZPC_Hunter/ZPC_Hunter.mdl",
"models/player/ZPC_ZTerror/ZPC_ZTerror.mdl",
"models/player/ZPC_Resident/ZPC_Resident.mdl",
"models/player/ZPC_Spitter/ZPC_Spitter.mdl",
"models/player/ZPC_Climb/ZPC_Climb.mdl",
"models/player/ZPC_Jockey/ZPC_Jockey.mdl",
"models/player/ZPC_Tank/ZPC_Tank.mdl",
"models/player/ZPC_Siren/ZPC_Siren.mdl",
"models/player/ZPC_Charger/ZPC_Charger.mdl",
"models/player/ZPC_Oxidation/ZPC_Oxidation.mdl",
"models/player/ZPC_Boomer/ZPC_Boomer.mdl",
"models/player/ZPC_Boomer/ZPC_BoomerT.mdl",
"models/player/ZPC_Smoker/ZPC_Smoker.mdl",
"models/player/ZPC_Smoker/ZPC_SmokerT.mdl",
"models/ZPChile/Claws/v_knife_assassin.mdl",
"models/ZPChile/Claws/v_knife_nemesis.mdl",
"models/ZPChile/Claws/v_knife_hunter.mdl",
"models/ZPChile/Claws/v_knife_jockey.mdl",
"models/ZPChile/Claws/v_knife_terror.mdl",
"models/ZPChile/Claws/v_knife_boomer.mdl",
"models/ZPChile/Claws/v_knife_spitter.mdl",
"models/ZPChile/Claws/v_knife_smoker.mdl",
"models/ZPChile/Claws/v_knife_climb.mdl",
"models/ZPChile/Claws/v_knife_charger.mdl",
"models/ZPChile/Claws/v_knife_tank.mdl",
"models/ZPChile/Claws/v_knife_oxidation.mdl",
"models/ZPChile/Grenades/v_explosive.mdl",
"models/ZPChile/Grenades/v_frost.mdl",
"models/ZPChile/Grenades/v_flare.mdl",
"models/ZPChile/Grenades/v_pipe.mdl",
"models/ZPChile/Grenades/p_pipe.mdl",
"models/ZPChile/Grenades/w_pipe.mdl",
"models/ZPChile/Grenades/w_secondary.mdl",
"models/ZPChile/Primary/v_uzi.mdl",
"models/ZPChile/Primary/v_usas.mdl",
"models/ZPChile/Primary/v_m16a1.mdl",
"models/ZPChile/Primary/v_m60.mdl",
"models/ZPChile/Primary/p_m60.mdl",
"models/ZPChile/Primary/w_m60.mdl",
"models/ZPChile/Claws/doing_spit.mdl",
"models/ZPChile/Claws/ground_spit.mdl",
"models/ZPChile/Items/cube.mdl",
"models/ZPChile/Items/cube_small.mdl",
"models/ZPChile/Items/radar_by_morte.mdl",
"models/pallet_with_bags.mdl",
"models/v_tripmine.mdl",
"models/rpgrocket.mdl",
"models/w_flare.mdl",
"models/w_flaret.mdl",
"models/v_rpg.mdl",
"models/p_rpg.mdl",
"models/w_rpg.mdl"
}
new const sprites[][] =
{
"sprites/ZPChile/hud/640hud7.spr",
"sprites/ZPChile/hud/640hud105.spr",
"sprites/ZPChile/hud/640hud79.spr",
"sprites/weapon_m60craft_Chile.txt",
"sprites/weapon_m16a1_Chile.txt",
"sound/ZPChile/Ambience/Assassin.mp3",
"sound/ZPChile/Ambience/Swarm.mp3"
}
public plugin_precache()
{
if(!can_precache())
return;		
new i	
for(i = 0; i < sizeof(models); i++)
PrecacheModel(models[i])
for(i = 0; i < sizeof(sound2); i++)
PrecacheSound(sound2[i])
for(i = 0; i < sizeof(sprites); i++)
PrecacheGeneric(sprites[i])
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
