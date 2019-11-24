#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <cs_player_models_api>
#include <cs_maxspeed_api>
#include <cs_weap_models_api>
#include <zp50_gamemodes>
#include <ZP_Shop>

#define VIP ADMIN_LEVEL_B
#define TASK_SHOWHUD 100
#define ID_SHOWHUD (taskid - TASK_SHOWHUD)
new g_MsgSync2, g_MsgSync3, chache_g_jumps
new g_had_vip[33],jumpnum[33], bool:dojump[33], g_jumps
new const Models[][] = {"ZP_Human01", "ZP_Human02", "ZP_VIP02", "ZP_Human04", "ZP_Human05", "ZP_Human08", "ZP_Human09"}

public plugin_init() 
{	
g_jumps = register_cvar("zp_vip_jumps", "1")
chache_g_jumps = get_pcvar_num(g_jumps)	
register_clcmd("say /vips", "print_adminlist")
g_MsgSync2 = CreateHudSyncObj(1)
g_MsgSync3 = CreateHudSyncObj(2)
}
public client_putinserver(id)
{
set_task(0.5, "ShowHud", id+TASK_SHOWHUD, _, _, "b")	
}
public plugin_natives()
{	
register_native("zp_had_vip", "native_vip", 1)
}
public native_vip(id)return g_had_vip[id];
public client_disconnected(id)
{
if(task_exists(id+TASK_SHOWHUD))	
remove_task(id+TASK_SHOWHUD)
}
public zp_fw_core_cure_post(id)
{			
if(!zp_class_survivor_get(id) && !zp_class_sniper_get(id))
{					
set_user_health(id, 250)
set_user_gravity(id, 0.9)	
cs_set_player_model(id, Models[random_num(0, sizeof Models - 1)])
if(get_user_flags(id) & VIP)
{
zp_boost_energy(id)
set_user_armor(id, 35)	
cs_set_player_model(id, "ZP_Crysis01")
set_user_gravity(id, 0.9)
cs_reset_player_maxspeed(id)	
cs_set_player_maxspeed_auto(id, 1.1)
strip_user_weapons(id) 
give_item(id, "weapon_knife")
message_begin(MSG_BROADCAST, get_user_msgid("ScoreAttrib"))
write_byte(id) // id
write_byte(1<<2) // attrib
message_end()	
g_had_vip[id] = true
}
strip_user_weapons(id) 
give_item(id, "weapon_knife")
}
}
public client_PreThink(id)
{
if(!is_user_alive(id) || !g_jumps || (!(get_user_flags(id) & VIP))) 
return PLUGIN_CONTINUE

static nbut, obut, fflags
nbut= get_user_button(id)
obut = get_user_oldbutton(id)
fflags = get_entity_flags(id)

if((nbut & IN_JUMP) && !(fflags & FL_ONGROUND) && !(obut & IN_JUMP))
{
if(jumpnum[id] < chache_g_jumps && !zp_core_is_zombie(id))
{
dojump[id] = true
jumpnum[id]++
return PLUGIN_CONTINUE
}
}
if((nbut & IN_JUMP) && (fflags & FL_ONGROUND))
{
jumpnum[id] = 0
return PLUGIN_CONTINUE
}

return PLUGIN_CONTINUE
}
public client_PostThink(id)
{
if(!is_user_alive(id) || !get_pcvar_num(g_jumps) || (!(get_user_flags(id) & VIP))) return PLUGIN_CONTINUE

if(dojump[id] == true)
{
static Float:velocity[3]	
entity_get_vector(id,EV_VEC_velocity,velocity)
velocity[2] = random_float(245.0,260.0)
entity_set_vector(id,EV_VEC_velocity,velocity)
dojump[id] = false
return PLUGIN_CONTINUE
}
return PLUGIN_CONTINUE
}	
public ShowHud(taskid)
{	
new id = ID_SHOWHUD
if (zp_core_is_zombie(id)) 
{
ClearSyncHud(id, g_MsgSync2)		
set_hudmessage(30, 50, 0, 0.02, 0.9, 0, 1.0, 1.0, 1.0, 1.0, -1)		
ShowSyncHudMsg(id, g_MsgSync3, "Health: %d || Class: Zombie || Ammo Packs: %d", pev(id, pev_health), zp_ammopacks_get(id))	
}else{
ClearSyncHud(id, g_MsgSync2)	
set_hudmessage(20, 20, 85, 0.02, 0.9, 0, 1.0, 1.0, 1.0, 1.0, -1)		
ShowSyncHudMsg(id, g_MsgSync3, "Health: %d || Class: Human || Ammo Packs: %d", pev(id, pev_health), zp_ammopacks_get(id))	
}
if (!is_user_alive(id)) 
{
ClearSyncHud(id, g_MsgSync3)		
set_hudmessage(25, 50, 0, 0.02, 0.15, 0, 1.0, 1.0, 1.0, 1.0, -1)		
ShowSyncHudMsg(id, g_MsgSync2, "Visit Our Site: CMS-BG.eu^n[Premium Admin/VIP: 2.40/4.80 - Skype: support.cso2]^n^nPublished:^n[For more info contact visit our site]")	
}
}
public print_adminlist(user) 
{
new adminnames[33][32], message[256]
new id, count, x, len
for(id = 1 ; id <= get_maxplayers() ; id++)
if(is_user_connected(id))
if(get_user_flags(id) & VIP)
get_user_name(id, adminnames[count++], 31)

len = format(message, 255, "Connected VIPS: ", id)
if(count > 0) {
for(x = 0 ; x < count ; x++) {
len += format(message[len], 255-len, "%s%s ", adminnames[x], x < (count-1) ? ", ":"")
if(len > 96 ) {
print_col_chat(user, "!g%s", message)
len = format(message, 255, "")
}
}
print_col_chat(user, "!g%s", message)
}
else {
len += format(message[len], 255-len, "No one", id)
print_col_chat(user, "!g%s", message)
}
}
stock print_col_chat(const id, const input[], any:...)    
{    
new count = 1, players[32];    
static msg[191];    
vformat(msg, 190, input, 3);    
replace_all(msg, 190, "!g", "^4"); // Green Color    
replace_all(msg, 190, "!y", "^1"); // Default Color ()    
replace_all(msg, 190, "!t", "^3"); // Team Color    
if (id) players[0] = id; else get_players(players, count, "ch");    
{    
for ( new i = 0; i < count; i++ )    
{    
if ( is_user_connected(players[i]) )    
{    
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText") , _, players[i]);    
write_byte(players[i]);    
write_string(msg);    
message_end();    
}    
}    
}    
}    
