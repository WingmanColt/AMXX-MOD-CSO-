#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <fvault>
#include <zp50_core>

new const g_vault_human_level[] = "LevelSystemHuman";
new const g_vault_human_exp[] = "ExpSystemHuman";
new const g_vault_ammo[] = "AmmoSystem";

new g_level[33], g_exp[33], Float:g_fHavedmg[33]
new Float:g_fHaveDamage[33], szName[32], g_name[33][100]

public plugin_init()
{
RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
}
public client_authorized(id)
{
if(!is_user_hltv(id) && !is_user_bot(id))
{
LoadData_Human(id)
LoadDataAmmo(id)
}
}
public client_disconnect(id)
{
if(!is_user_hltv(id) && !is_user_bot(id))
{	
if(g_exp[id] > 0) 
{ 
SaveDataHuman(id)
g_exp[id] = 0; 
} 
if(g_level[id] > 0) 
{ 
SaveDataHuman(id)
g_level[id] = 0; 
} 	
SaveDataAmmo(id)
}
}

public zp_fw_core_infect(id, attacker)
{	
if(!is_user_alive(attacker))
return;

if(zp_core_is_zombie(attacker))
{
if(g_level[attacker] == 41)
return;

g_exp[attacker] += 1	
colorchat(attacker, "^4[Attention]^3 +1 Zombie Exprience");
LevelUP(attacker)
SaveDataHuman(attacker)
}
}
public fw_TakeDamage_Post(victim, inflictor, attacker, Float:damage, damage_type)
{
if(!is_user_alive(victim) || !is_user_alive(attacker))
return HAM_IGNORED
if(zp_core_is_zombie(attacker) || !zp_core_is_zombie(victim))
return HAM_IGNORED
if(g_level[attacker] == 41)
return HAM_IGNORED
g_fHaveDamage[attacker] += damage;
g_fHavedmg[attacker] += damage;

if(zp_class_sniper_get(attacker))
{
if(g_fHaveDamage[attacker] >= 700.0)
{	
g_fHaveDamage[attacker] -= 700.0
g_exp[attacker] += 1
colorchat(attacker, "^4[Attention]^3 +1 Exprience");	
LevelUP(attacker)	
SaveDataHuman(attacker)
}
}
if(zp_class_survivor_get(attacker))
{
if(g_fHaveDamage[attacker] >= 5500.0)
{	
g_fHaveDamage[attacker] -= 5500.0
g_exp[attacker] += 5
colorchat(attacker, "^4[Attention]^3 +5 Exprience");	
LevelUP(attacker)	
SaveDataHuman(attacker)
}
}
if(!zp_class_sniper_get(attacker) && !zp_class_survivor_get(attacker))
{
if(g_fHaveDamage[attacker] >= 4000.0)
{	
g_fHaveDamage[attacker] -= 4000.0
g_exp[attacker] += 5
colorchat(attacker, "^4[Attention]^3 +5 Exprience");	
LevelUP(attacker)	
SaveDataHuman(attacker)
}
}
else if(g_fHavedmg[attacker] >= 10000.0)
{
g_fHavedmg[attacker] -= 10000.0;
colorchat(attacker, "^4[Promotion]^3 You have 10.000%% Damage! +50 armor.");	
PlaySound(attacker, "ZB5/10000dmg.wav")
set_user_armor(attacker, clamp(get_user_armor(attacker) + 50, 1, 500))
fade(attacker,243,207,149)
}
return HAM_HANDLED
}
public LevelUP(id)
{
if(g_level[id] == 41)
return 
while(g_exp[id] >= 100) 
{
g_level[id] += 1
g_exp[id] = 0
fade(id,149,240,149)
PlaySound(id, "ZPChile/systemlvup.wav")
get_user_name(id, szName, 31)
colorchat(0, "^4[Attention]^3 ***** Congratulations. [%s] promoted to %d level. *****", szName, g_level[id]);	
SaveDataHuman(id)
}
}
LoadData_Human(id)
{	
new authid[35]; 
get_user_authid(id, authid, sizeof(authid) - 1); 

new data2[16]; 
if(fvault_get_data(g_vault_human_exp, authid, data2, sizeof(data2) - 1)) 
g_exp[id] = str_to_num(data2); 
else  
g_exp[id] = 0; 

new data[16]; 
if(fvault_get_data(g_vault_human_level, authid, data, sizeof(data) - 1)) 
g_level[id] = str_to_num(data); 
else 
g_level[id] = 0; 
}
SaveDataHuman(id)
{	
new authid[35]; 
get_user_authid(id, authid, sizeof(authid) - 1); 
new data2[16]; 
num_to_str(g_level[id], data2, sizeof(data2) - 1); 
fvault_set_data(g_vault_human_exp, authid, data2); 
new data[16]; 
num_to_str(g_exp[id], data, sizeof(data) - 1); 
fvault_set_data(g_vault_human_exp, authid, data); 
}
LoadDataAmmo(id)
{	
new data1[30]; fvault_get_data(g_vault_ammo, g_name[id], data1, charsmax(data1))
new have = str_to_num(data1)
if(have > 0)
{
zp_ammopacks_set(id, have)
new string1[30]
formatex(string1, charsmax(string1), "0")
fvault_set_data(g_vault_ammo, g_name[id], string1)
}
}
SaveDataAmmo(id)
{	
new aps = zp_ammopacks_get(id)
if(aps == 0)
{
return PLUGIN_HANDLED;
}	
new aps_have[30]
fvault_get_data(g_vault_ammo, g_name[id], aps_have, 29)
new result = aps + str_to_num(aps_have)
new aps2[30]
formatex(aps2, charsmax(aps2), "%i", result)
fvault_set_data(g_vault_ammo, g_name[id], aps2)
return PLUGIN_CONTINUE
}
public plugin_natives()
{
register_native("zpc_get_user_level", "native_level", 1)
register_native("zpc_get_user_exp", "native_exp", 1)
}
public native_level(id)return g_level[id]
public native_exp(id)return g_exp[id]
public native_level2(id, amount)g_level[id] = amount

stock fade(id,r,g,b)
{	
message_begin(MSG_ONE_UNRELIABLE,get_user_msgid ("ScreenFade"), _, id)
write_short(1<<10) 
write_short(1<<10)
write_short(1<<10)
write_byte(r)
write_byte(g)
write_byte(b) 
write_byte(50) 
message_end()	
}
stock PlaySound(id, const sound[])
{
if (equal(sound[strlen(sound)-4], ".mp3"))
client_cmd(id, "mp3 play ^"sound/%s^"", sound)
else
client_cmd(id, "spk ^"%s^"", sound)
}
stock colorchat(const id, const input[], any:...) 
{ 
new count = 1, players[32]; 
static msg[191]; 
vformat(msg, 190, input, 3); 
replace_all(msg, 190, "!g", "^4"); // Green Color 
replace_all(msg, 190, "!y", "^1"); // Default Color (?©°  ??«??©) 
replace_all(msg, 190, "!t", "^3"); // Team Color 
if (id) players[0] = id; else get_players(players, count, "ch"); 
{ 
for (new i = 0; i < count; i++) 
{ 	
if (is_user_connected(players[i])) 
{ 
message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]); 
write_byte(players[i]); 
write_string(msg); 
message_end(); 
} 
} 
} 
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
