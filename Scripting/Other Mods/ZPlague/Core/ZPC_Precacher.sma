#include <amxmodx>
#include <fakemeta>
new const sound2[][] =
{
"ZPlague/count/1.wav", 
"ZPlague/count/2.wav", 
"ZPlague/count/3.wav", 
"ZPlague/count/4.wav", 
"ZPlague/count/5.wav", 
"ZPlague/count/6.wav", 
"ZPlague/count/7.wav", 
"ZPlague/count/8.wav", 
"ZPlague/count/9.wav", 
"ZPlague/count/10.wav", 
"ZPlague/count/wav.wav", 
"ZPlague/count/_period.wav", 	
"ZPlague/Round/survivor_round.wav",	
"ZPlague/Round/wav.wav", 
"ZPlague/Round/_period.wav", 
"ZPlague/Pain/zombie_pain1.wav",
"ZPlague/Pain/zombie_pain2.wav",
"ZPlague/Pain/zombie_pain3.wav",
"ZPlague/Pain/zombie_pain4.wav",
"ZPlague/Pain/zombie_pain5.wav",
"ZPlague/Pain/nemesis_pain1.wav",
"ZPlague/Pain/nemesis_pain2.wav",
"ZPlague/Pain/wav.wav", 
"ZPlague/Pain/_period.wav", 
"ZPlague/Die/nemesis_die1.wav",
"ZPlague/Die/nemesis_die2.wav",
"ZPlague/Die/zombie_die1.wav",
"ZPlague/Die/zombie_die2.wav",
"ZPlague/Die/zombie_die3.wav",
"ZPlague/Die/zombie_die4.wav",
"ZPlague/Die/wav.wav", 
"ZPlague/Die/_period.wav", 
"ZPlague/Idle/zombie_idle1.wav",
"ZPlague/Idle/zombie_idle2.wav",
"ZPlague/Idle/wav.wav", 
"ZPlague/Idle/_period.wav", 
"ZPlague/Infect/zombie_infect1.wav",
"ZPlague/Infect/zombie_infect2.wav",
"ZPlague/Infect/zombie_infect3.wav",
"ZPlague/Infect/zombie_infect4.wav",
"ZPlague/Infect/zombie_infect5.wav",
"ZPlague/Infect/zombie_infect6.wav",
"ZPlague/Infect/zombie_infect7.wav",
"ZPlague/Infect/wav.wav", 
"ZPlague/Infect/_period.wav", 
"ZPlague/Knife/hit01.wav",
"ZPlague/Knife/hit02.wav",
"ZPlague/Knife/hit03.wav",
"ZPlague/Knife/wav.wav", 
"ZPlague/Knife/_period.wav", 
"ZPlague/Weapons/m134-1.wav",
"ZPlague/Weapons/m134_pinpull.wav",
"ZPlague/Weapons/m134_clipon.wav",
"ZPlague/Weapons/m134_clipoff.wav",
"ZPlague/Weapons/m134_spinup.wav",
"ZPlague/Weapons/flamegun-1.wav",
"ZPlague/Weapons/flamegun_draw.wav",
"ZPlague/Weapons/flamegun_clipin1.wav",
"ZPlague/Weapons/flamegun_clipout1.wav",
"ZPlague/Weapons/flamegun_clipout2.wav",
"ZPlague/Weapons/wav.wav", 
"ZPlague/Weapons/_period.wav", 
"ZPlague/NanoSuit/emerge.wav",
"ZPlague/NanoSuit/nanosuit_armor.wav",
"ZPlague/NanoSuit/nanosuit_armor_switch.wav",
"ZPlague/NanoSuit/nanosuit_cloak.wav",
"ZPlague/NanoSuit/nanosuit_cloak_switch.wav",
"ZPlague/NanoSuit/nanosuit_critical.wav",
"ZPlague/NanoSuit/nanosuit_energy.wav",
"ZPlague/NanoSuit/nanosuit_menu.wav",
"ZPlague/NanoSuit/nanosuit_speed.wav",
"ZPlague/NanoSuit/nanosuit_speed_switch.wav",
"ZPlague/NanoSuit/nanosuit_strength.wav",
"ZPlague/NanoSuit/nanosuit_strength_jump.wav",
"ZPlague/NanoSuit/nanosuit_strength_switch.wav",
"ZPlague/NanoSuit/nanosuit_regain.wav",
"ZPlague/NanoSuit/nanosuit_controller.wav",
"ZPlague/NanoSuit/wav.wav", 
"ZPlague/NanoSuit/_period.wav",
"ZPlague/Female/f_dominating.wav", 
"ZPlague/Female/f_godlike.wav", 
"ZPlague/Female/f_ultrakill.wav",
"ZPlague/Female/f_killingspree.wav", 
"ZPlague/Female/f_megakill.wav", 
"ZPlague/Female/f_holyshit.wav",
"ZPlague/Female/f_ludacrisskill.wav",
"ZPlague/Female/f_rampage.wav",
"ZPlague/Female/f_unstoppable.wav",
"ZPlague/Female/f_monsterkill.wav",
"ZPlague/Female/f_headshot.wav",
"ZPlague/Female/f_humiliation.wav",
"ZPlague/Female/f_wickedsick.wav",
"ZPlague/Female/wav.wav", 
"ZPlague/Female/_period.wav",
"ZPlague/Ambience/ambience.wav",
"ZPlague/Zombie_Coming.wav",
"ZPlague/_exp1.wav",
"ZPlague/flareon.wav",
"ZPlague/_exp2.wav",
"ZPlague/conc_explode.wav",
"ZPlague/supplybox_pickup.wav",
"ZPlague/flame.wav",
"ZPlague/madness.wav",
"ZPlague/Antidote.wav",
"ZPlague/tutor_msg.wav",
"ZPlague/zombi_pressure.wav",
"ZPlague/zombi_pre_idle_1.wav",
"ZPlague/zombi_pre_idle_2.wav",
"ZPlague/bazooka_stone_explode.wav",
"ZPlague/Smoker_drag.wav",
"ZPlague/gy_irondoor.wav",
"ZPlague/gy_woodendoor.wav",
"ZPlague/wolf.wav",
"ZPlague/wav.wav", 
"ZPlague/_period.wav",
"debris/beamstart14.wav",
"items/gunpickup2.wav",
"common/bodydrop2.wav",
"weapons/rocketfire1.wav",
"weapons/ric_metal-1.wav",
"weapons/ric_metal-2.wav",
"weapons/mine_deploy.wav",
"weapons/mine_charge.wav",
"weapons/mine_activate.wav"
}
new const models[][] =
{
"models/player/ZP_Human01/ZP_Human01.mdl",
"models/player/ZP_Human02/ZP_Human02.mdl",
"models/player/ZP_Human04/ZP_Human04.mdl",
"models/player/ZP_Human05/ZP_Human05.mdl",
"models/player/ZP_Human06/ZP_Human06.mdl",
"models/player/ZP_Carlito/ZP_Carlito.mdl",
"models/player/ZP_VIP02/ZP_VIP02.mdl",
"models/player/ZP_Crysis01/ZP_Crysis01.mdl",
"models/player/ZP_Crysis01/ZP_Crysis01T.mdl",
"models/player/ZP_Nemesis/ZP_Nemesis.mdl",
"models/player/ZP_Clown/ZP_Clown.mdl",
"models/player/ZP_Jumper/ZP_Jumper.mdl",
"models/player/ZP_Speeder/ZP_Speeder.mdl",
"models/player/ZP_Classic/ZP_Classic.mdl",
"models/player/ZP_Light/ZP_Light.mdl",
"models/player/ZP_Swarm/ZP_Swarm.mdl",
"models/player/ZP_Fat/ZP_Fat.mdl",
"models/player/ZP_HeadCrab/ZP_HeadCrab.mdl",
"models/player/ZP_Blood/ZP_Blood.mdl",
"models/ZPlague/Claws/v_knife_assassin.mdl",
"models/ZPlague/Claws/v_knife_nemesis.mdl",
"models/ZPlague/Claws/v_knife_clown.mdl",
"models/ZPlague/Claws/v_knife_light.mdl",
"models/ZPlague/Claws/v_knife_swarm.mdl",
"models/ZPlague/Claws/v_knife_speeder.mdl",
"models/ZPlague/Claws/v_knife_fat.mdl",
"models/ZPlague/Claws/v_knife_sucker.mdl",
"models/ZPlague/Weapons/v_ak47.mdl",
"models/ZPlague/Weapons/v_m4a1.mdl",
"models/ZPlague/Weapons/v_sg552.mdl",
"models/ZPlague/Weapons/v_m3.mdl",
"models/ZPlague/Weapons/v_xm1014.mdl",
"models/ZPlague/Weapons/v_g3sg1.mdl",
"models/ZPlague/Weapons/v_sg550.mdl",
"models/ZPlague/Weapons/v_m249.mdl",
"models/ZPlague/Weapons/v_usp.mdl",
"models/ZPlague/Weapons/v_deagle.mdl",
"models/ZPlague/Weapons/v_elite.mdl",
"models/ZPlague/Weapons/v_awp.mdl",
"models/ZPlague/Weapons/v_knife.mdl",
"models/ZPlague/Weapons/v_m134ex.mdl",
"models/ZPlague/Weapons/p_m134ex.mdl",
"models/ZPlague/Weapons/w_m134ex.mdl",
"models/ZPlague/Weapons/v_salamander.mdl",
"models/ZPlague/Weapons/p_salamander.mdl",
"models/ZPlague/Weapons/w_salamander.mdl",
"models/ZPlague/Grenades/v_frost.mdl",
"models/ZPlague/Grenades/v_flare.mdl",
"models/ZPlague/Grenades/v_flareT.mdl",
"models/ZPlague/Grenades/v_light.mdl",
"models/ZPlague/Grenades/v_conc.mdl",
"models/ZPlague/Grenades/p_conc.mdl",
"models/ZPlague/Grenades/w_conc.mdl",
"models/ZPlague/Grenades/v_antidote.mdl",
"models/ZPlague/Grenades/p_antidote.mdl",
"models/ZPlague/Grenades/w_antidote.mdl",
"models/ZPlague/Grenades/v_zombiebomb.mdl",
"models/ZPlague/Grenades/p_zombiebomb.mdl",
"models/ZPlague/Grenades/w_zombiebomb.mdl",
"models/ZPlague/Items/Box.mdl",
"models/v_egon.mdl",
"models/p_egon.mdl",
"models/w_egon.mdl",
"models/rpgrocket.mdl",
"models/v_tripmine.mdl",
"sprites/ZPlague/fire.spr"
}
new const generic[][] =
{
"sound/ZPlague/Ambience/fear1_ambience.mp3",
"sound/ZPlague/Ambience/fear2_ambience.mp3",
"sound/ZPlague/Ambience/nemesis_ambience.mp3",
"sound/ZPlague/Ambience/assassin_ambience.mp3",
"sound/ZPlague/Ambience/survivor_ambience.mp3",
"sound/ZPlague/Ambience/carlito_ambience.mp3",
"sound/ZPlague/Ambience/clown_amb.mp3",
"sound/ZPlague/Round/assassin_round.mp3",
"sound/ZPlague/Round/nemesis_round.mp3",
"sound/ZPlague/Round/carlito_round.mp3",
"sound/ZPlague/Round/clown_round.mp3",
"sound/ZPlague/Round/biohazard_round.mp3",
"sound/ZPlague/Round/swarm_round.mp3",
"sound/ZPlague/Round/sniper_round.mp3"
}
public plugin_precache()
{
new i	
for(i = 0; i < sizeof(models); i++)
precache_model(models[i])
for(i = 0; i < sizeof(sound2); i++)
precache_sound(sound2[i])
for(i = 0; i < sizeof(generic); i++)
precache_generic(generic[i])
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
