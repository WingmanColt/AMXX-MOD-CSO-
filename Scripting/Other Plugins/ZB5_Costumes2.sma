#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <ZombieMod5>

const OFFSET_CSMENUCODE = 205
const KEYSMENU = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0
new const CostumeModels[3][] ={"models/ZB5/Costumes/head.mdl", "models/ZB5/Costumes/back.mdl", "models/ZB5/Costumes/pelvis.mdl"}
new const gHeadNames[Head][] = { "Nothing","Cat","Provoke","Devil","Angel","Indian","Afro","CurlHair","Bazzi","Dao","Horn","Bomb" }

enum Head
{ 
Nothing,	
Cat,
Provoke,
Devil,
Angel,
Indian,
Afro,
CurlHair,
Bazzi,
Dao,
Horn,
Bomb
}
new const gFaceNames[Face][9] = { "Nothing", "Angel","Cat","Devil","Gold","Pumpkin","Snow" }
enum Face
{ 
Nothing,	
Angel,
Cat,
Devil,
Gold,
Pumpkin,
Snow
}
new const gHeadNames[Head][9] = { "Nothing", "Angel","Cat","Devil","Gold","Pumpkin","Snow" }
enum Back
{ 
Nothing,	
Angel2,
Clock2,
Devil2,
Gold2,
Snow2 
}
new const gBackNames[Back][8] = { "Nothing","Angel","Clock","Devil","Gold","Snow" }

enum Pelvis
{ 
Nothing,	
Cat3, 
Devil3, 
Squrel3 
}
new const gPelvisNames[Pelvis][8] = { "Nothing","Cat", "Devil", "Squrel" }

new g_Head[33][Head], g_Face[33][Face], g_Back[33][Back], g_Pelvis[33][Pelvis]
new Head:gName[33], Back:gName2[33], Pelvis:gName3[33], Face:gName4[33], bool:g_HadCostume[33]
new g_CostumeModelBack[33],g_CostumeModelHead[33],g_CostumeModelPelvis[33],g_CostumeModelFace[33]

public plugin_precache()
{	
for(new i = 0; i < 3; i++)
precache_model(CostumeModels[i])
}
public plugin_natives()
{
register_native("zb5_costumes_menu", "choose_costume", 1)
}
public client_putinserver(id)reset_all_models(id)
public client_disconnect(id)reset_all_models(id)
public zp_fw_core_infect_post(id)
{	
if(!zp_core_is_zombie(id))
return;

g_HadCostume[id] = false	
reset_costume(id, 1)	
reset_costume(id, 2)	
reset_costume(id, 3)
}
public zp_fw_core_dead_post(id, victim)
{	
if(!is_user_connected(victim))
return;

g_HadCostume[victim] = false	
reset_costume(victim, 1)	
reset_costume(victim, 2)	
reset_costume(victim, 3)
}
public zp_fw_core_spawn_post(id)
{
if(!is_user_connected(id) || !is_user_alive(id))
return;

if(zp_core_is_zombie(id))
{
reset_costume(id, 1)
reset_costume(id, 2)
reset_costume(id, 3)
g_HadCostume[id] = false
}else{
reset_costume(id, 1)
reset_costume(id, 2)
reset_costume(id, 3)	
g_HadCostume[id] = true
set_task(2.0, "load_costumes", id)
}
return;
}
public load_costumes(id)
{
Give_Head(id)
Give_Back(id)  
Give_Pelvis(id)	
}

///// MAIN /////
public choose_costume(id)  
{   
if(!is_user_alive(id) || zp_core_is_zombie(id))
return PLUGIN_HANDLED     

new buffer[512]	
new menu2 = menu_create("\r[Zombie: The Hero] \yCostume Menu", "choose2_costume")   
formatex(buffer, charsmax(buffer), "Costume Head [ \r%s \w]",  gHeadNames[gName[id]])
menu_additem(menu2, buffer, "1")
formatex(buffer, charsmax(buffer), "Costume Back [ \r%s \w]",  gBackNames[gName2[id]])
menu_additem(menu2, buffer, "2")
formatex(buffer, charsmax(buffer), "Costume Pelvis [ \r%s \w]",  gPelvisNames[gName3[id]])
menu_additem(menu2, buffer, "3")
formatex(buffer, charsmax(buffer), "\rRecieve \yCostumes")
menu_additem(menu2, buffer, "4")
menu_setprop(menu2, MPROP_EXIT, MEXIT_ALL)   

menu_display(id, menu2, 0)  
return PLUGIN_HANDLED   
} 

public choose2_costume(id, menu2, item)   
{   	
if (!is_user_connected(id))
return PLUGIN_HANDLED;
	
if (item == MENU_EXIT || zp_core_is_zombie(id))   
{   
menu_destroy(menu2)   
return PLUGIN_HANDLED   
}    
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu2, item, access, data,15, iName, 64, callback)   
new key = str_to_num(data)   
switch(key)   
{  	 
case 1:   
{   	
reset_costume(id, 1)	
reset_head(id)
costume_head(id) 
return PLUGIN_HANDLED   
}   
case 2:   
{   	
reset_costume(id, 2)	
reset_back(id)
costume_back(id) 
return PLUGIN_HANDLED   
}  
case 3:   
{   	
reset_costume(id, 3)	
reset_pelvis(id)	
costume_pelvis(id)
return PLUGIN_HANDLED   
} 
case 4:   
{   
reset_costume(id, 1)	
reset_costume(id, 2)	
reset_costume(id, 3)	
Give_Head(id)
Give_Back(id)  
Give_Pelvis(id)
return PLUGIN_HANDLED   
} 			
}   
menu_destroy(menu2)   
return PLUGIN_HANDLED   
} 
///// HEAD COSTUME /////
public costume_head(id)   
{   	
if(!is_user_alive(id) || zp_core_is_zombie(id))
return PLUGIN_HANDLED   

new buffer[512]
new menu = menu_create("\r[Zombie: The Hero] \yHead Costume", "costume2_head")  
formatex(buffer, charsmax(buffer), "Angel Head")
menu_additem(menu, buffer, "1")
formatex(buffer, charsmax(buffer), "Cat Ears")
menu_additem(menu, buffer, "2")
formatex(buffer, charsmax(buffer), "Devil Horns")
menu_additem(menu, buffer, "3")
formatex(buffer, charsmax(buffer), "Gold Mask");
menu_additem(menu, buffer, "4")
formatex(buffer, charsmax(buffer), "Pumpkin Head");
menu_additem(menu, buffer, "5")
formatex(buffer, charsmax(buffer), "Snowman Head");
menu_additem(menu, buffer, "6")

menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
return PLUGIN_HANDLED   
}   
public costume2_head(id, menu, item)   
{   
if (!is_user_connected(id))
return PLUGIN_HANDLED;
	
if (item == MENU_EXIT || zp_core_is_zombie(id))   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback);
new key = str_to_num(data)   
switch(key)   
{   
case 0:   
{   
reset_costume(id, 1)	
return PLUGIN_HANDLED   
}   	
case 1:   
{ 
g_Head[id][Angel] = 1
gName[id] = Angel
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 2:   
{ 	  
g_Head[id][Cat] = 1
gName[id] = Cat	
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 3:   
{ 	  
g_Head[id][Devil] = 1
gName[id] = Devil	
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 4:   
{ 	  
g_Head[id][Gold] = 1
gName[id] = Gold
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 5:   
{ 		  
g_Head[id][Pumpkin] = 1
gName[id] = Pumpkin	
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 6:   
{ 	  
g_Head[id][Snow] = 1
gName[id] = Snow
choose_costume(id) 
return PLUGIN_HANDLED   
}
}
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
///// BACK COSTUME /////
public costume_back(id)   
{   	
if(!is_user_alive(id) || zp_core_is_zombie(id))
return PLUGIN_HANDLED  

new buffer[512]
new menu = menu_create("\r[Zombie: The Hero] \yBack Costume", "costume2_back")  
formatex(buffer, charsmax(buffer), "Angel Wings")
menu_additem(menu, buffer, "1")
formatex(buffer, charsmax(buffer), "Clock Back");
menu_additem(menu, buffer, "2")
formatex(buffer, charsmax(buffer), "Devil Wings")
menu_additem(menu, buffer, "3")
formatex(buffer, charsmax(buffer), "Gold Back");
menu_additem(menu, buffer, "4")
formatex(buffer, charsmax(buffer), "Snow Back")
menu_additem(menu, buffer, "5")
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
return PLUGIN_HANDLED   
}   
public costume2_back(id, menu, item)   
{ 
if (!is_user_connected(id))
return PLUGIN_HANDLED;
	  
if (item == MENU_EXIT || zp_core_is_zombie(id))   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback);
new key = str_to_num(data)   
switch(key)   
{ 
case 0:   
{   
reset_costume(id, 2)	
return PLUGIN_HANDLED   
}   	  
case 1:   
{ 
g_Back[id][Angel2] = 1
gName2[id] = Angel2	
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 2:   
{ 
g_Back[id][Clock2] = 1
gName2[id] = Clock2
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 3:   
{ 
g_Back[id][Devil2] = 1
gName2[id] = Devil2	
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 4:   
{ 
g_Back[id][Gold2] = 1
gName2[id] = Gold2
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 5:   
{ 
g_Back[id][Snow2] = 1
gName2[id] = Snow2
choose_costume(id) 
return PLUGIN_HANDLED   
}
}
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
///// PELVIS COSTUME /////
public costume_pelvis(id)   
{   	
if(!is_user_alive(id) || zp_core_is_zombie(id))
return PLUGIN_HANDLED   

new buffer[512]
new menu = menu_create("\r[Zombie: The Hero] \yPelvis Costume", "costume2_pelvis")  
formatex(buffer, charsmax(buffer), "Cat Pelvis")
menu_additem(menu, buffer, "1")
formatex(buffer, charsmax(buffer), "Devil Tail");
menu_additem(menu, buffer, "2")
formatex(buffer, charsmax(buffer), "Pig Pelvis")
menu_additem(menu, buffer, "3")
menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)   
menu_display(id, menu, 0) 
return PLUGIN_HANDLED   
}   
public costume2_pelvis(id, menu, item)   
{   
if (!is_user_connected(id))
return PLUGIN_HANDLED;
	
if (item == MENU_EXIT || zp_core_is_zombie(id))   
{   
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
new data[15], iName[64]    
new access, callback   
menu_item_getinfo(menu, item, access, data,15, iName, 64, callback);
new key = str_to_num(data)   
switch(key)   
{   
case 0:   
{   
reset_costume(id, 3)	
return PLUGIN_HANDLED   
}   	
case 1:   
{ 				
g_Pelvis[id][Cat3] = 1
gName3[id] = Cat3
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 2:   
{
g_Pelvis[id][Devil3] = 1
gName3[id] = Devil3
choose_costume(id) 
return PLUGIN_HANDLED   
}
case 3:   
{ 	
g_Pelvis[id][Squrel3] = 1
gName3[id] = Squrel3
choose_costume(id) 
return PLUGIN_HANDLED   
}
}
menu_destroy(menu)   
return PLUGIN_HANDLED   
}   
public Give_Head(id)
{	
if(!is_user_alive(id) || zp_core_is_zombie(id))
return;
if(!g_HadCostume[id])
return		
switch(gName[id])
{
case Angel:make_costume(id, 1, 1, 0)
case Cat:make_costume(id, 1, 2, 1)
case Devil:make_costume(id, 1, 3, 2)
case Gold:make_costume(id, 1, 4, 3)
case Pumpkin:make_costume(id, 1, 5, 4)
case Snow:make_costume(id, 1, 6, 5)
}
}
public Give_Back(id)
{	
if(!is_user_alive(id) || zp_core_is_zombie(id))
return;
if(!g_HadCostume[id])
return
switch(gName2[id])
{
case Angel2:make_costume(id, 2, 1, 0)
case Clock2:make_costume(id, 2, 2, 1)
case Devil2:make_costume(id, 2, 3, 2)
case Gold2:make_costume(id, 2, 4, 3)
case Snow2:make_costume(id, 2, 5, 4)
}
}
public Give_Pelvis(id)
{
if(!is_user_alive(id) || zp_core_is_zombie(id))
return;
if(!g_HadCostume[id])
return
		
switch(gName3[id])
{
case Cat3:make_costume(id, 3, 1, 0)
case Devil3:make_costume(id, 3, 2, 1)
case Squrel3:make_costume(id, 3, 3, 2)
}
}
public make_costume(id, part, body, anim)
{
if(!is_user_alive(id))
return;
switch(part)
{
case 1:
{
g_CostumeModelHead[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target")) 
if(g_CostumeModelHead[id] && !zp_core_is_zombie(id))
{
set_pev(g_CostumeModelHead[id], pev_movetype, MOVETYPE_FOLLOW)
set_pev(g_CostumeModelHead[id], pev_aiment, id)
set_pev(g_CostumeModelHead[id], pev_rendermode, kRenderNormal)
engfunc(EngFunc_SetModel, g_CostumeModelHead[id], CostumeModels[0])
set_pev(g_CostumeModelHead[id], pev_body, body - 1)
set_pev(g_CostumeModelHead[id], pev_sequence, anim)
}
}	
case 2:
{
g_CostumeModelBack[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))	
if(g_CostumeModelBack[id] && !zp_core_is_zombie(id))
{
set_pev(g_CostumeModelBack[id], pev_movetype, MOVETYPE_FOLLOW)
set_pev(g_CostumeModelBack[id], pev_aiment, id)
set_pev(g_CostumeModelBack[id], pev_rendermode, kRenderNormal)
engfunc(EngFunc_SetModel, g_CostumeModelBack[id], CostumeModels[1])
set_pev(g_CostumeModelBack[id], pev_body, body - 1)
set_pev(g_CostumeModelBack[id], pev_sequence, anim)
}
}
case 3:
{
g_CostumeModelPelvis[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))	
if(g_CostumeModelPelvis[id] && !zp_core_is_zombie(id))
{
set_pev(g_CostumeModelPelvis[id], pev_movetype, MOVETYPE_FOLLOW)
set_pev(g_CostumeModelPelvis[id], pev_aiment, id)
set_pev(g_CostumeModelPelvis[id], pev_rendermode, kRenderNormal)
engfunc(EngFunc_SetModel, g_CostumeModelPelvis[id], CostumeModels[2])
set_pev(g_CostumeModelPelvis[id], pev_body, body - 1)
set_pev(g_CostumeModelPelvis[id], pev_sequence, anim)
}
}
}
}
public reset_costume(id, number)
{
switch(number)
{
case 1:
{
fm_set_entity_visibility(g_CostumeModelHead[id], 0)
g_CostumeModelHead[id] = 0
}	
case 2:
{
fm_set_entity_visibility(g_CostumeModelBack[id], 0)
g_CostumeModelBack[id] = 0
}
case 3:
{
fm_set_entity_visibility(g_CostumeModelPelvis[id], 0)
g_CostumeModelPelvis[id] = 0
}
}
}
public reset_all_models(id)
{
g_CostumeModelHead[id] = 0	
g_CostumeModelBack[id] = 0
g_CostumeModelPelvis[id] = 0
reset_head(id)
reset_back(id)
reset_pelvis(id)
}
public reset_head(id)
{
g_Head[id][Angel] = 0
g_Head[id][Cat] = 0
g_Head[id][Devil] = 0
g_Head[id][Gold] = 0
g_Head[id][Pumpkin] = 0
g_Head[id][Snow] = 0
g_CostumeModelHead[id] = 0
}
public reset_back(id)
{
g_Back[id][Angel2] = 0
g_Back[id][Clock2] = 0
g_Back[id][Devil2] = 0
g_Back[id][Gold2] = 0
g_Back[id][Snow2] = 0
g_CostumeModelBack[id] = 0
}
public reset_pelvis(id)
{
g_Pelvis[id][Cat3] = 0
g_Pelvis[id][Devil3] = 0
g_Pelvis[id][Squrel3] = 0
g_CostumeModelPelvis[id] = 0
}
stock fm_set_entity_visibility(index, visible = 1) {
set_pev(index, pev_effects, visible == 1 ? pev(index, pev_effects) & ~EF_NODRAW : pev(index, pev_effects) | EF_NODRAW);

return 1;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
