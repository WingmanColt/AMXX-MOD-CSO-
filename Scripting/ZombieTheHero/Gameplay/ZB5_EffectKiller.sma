#include <amxmodx>
#include <engine>
#include <ZombieMod5>
#include <ScenarioMod>

#define MAX_NORMAL_KILL 4
#define TASK_RESET_TIME 534544

enum Items
{
MyKillCount,
MySpecialKill
}
enum
{
KILL_HEADSHOT = 1,
KILL_GRENADE,
KILL_MELEE
}

new const sound[][] =
{
"ZB5/kills/kill_1.wav",
"ZB5/kills/kill_2.wav",
"ZB5/kills/kill_3.wav",
"ZB5/kills/kill_4.wav",
"ZB5/kills/headshot.wav",
"ZB5/kills/grenade.wav",
"ZB5/kills/ohno.wav"	
}
new g_had[33][Items], ef_kills[7]

public plugin_precache()
{
for(new i = 0; i < sizeof(sound); i++)
PrecacheSound(sound[i])	
	
ef_kills[0] = PrecacheModel("sprites/ZB5/kills/headshot.spr")
ef_kills[1] = PrecacheModel("sprites/ZB5/kills/knife.spr")
ef_kills[2] = PrecacheModel("sprites/ZB5/kills/grenade.spr")
ef_kills[3] = PrecacheModel("sprites/ZB5/kills/kill_1.spr")
ef_kills[4] = PrecacheModel("sprites/ZB5/kills/kill_2.spr")
ef_kills[5] = PrecacheModel("sprites/ZB5/kills/kill_3.spr")
ef_kills[6] = PrecacheModel("sprites/ZB5/kills/kill_4.spr")
}
public zp_fw_core_spawn_post(id)
{
if(!is_user_connected(id))
return;

g_had[id][MyKillCount] = 0
}
public kill_check(Victim, Attacker, Headshot, Weapon)
{
if(!is_user_alive(Attacker))
return;

static AddKill
AddKill = 1

if(g_had[Attacker][MyKillCount] == 0)
{
if(!Headshot && Weapon != CSW_KNIFE && Weapon != CSW_HEGRENADE)
{
PlaySound(Attacker, "ZB5/kills/kill_1.wav")
zb5_set_user_exp(Attacker, 1, 0)
} else if(Headshot) {
PlaySound(Attacker, "ZB5/kills/headshot.wav")
Make_Sprite(Attacker, ef_kills[0], 1, 5, 30, 2, -15)
zb5_set_user_quest(Attacker, QUEST_HEADSHOT, 1)
} else if(Weapon == CSW_KNIFE && !Headshot) {
PlaySound(Attacker, "ZB5/kills/knife.wav")
Make_Sprite(Attacker, ef_kills[1], 1, 5, 30, 2, -15)
PlaySound(Victim, "ZB5/kills/ohno.wav")
zb5_set_user_quest(Attacker, QUEST_MELEE, 1)
} else if(Weapon == CSW_HEGRENADE) {
PlaySound(Attacker, "ZB5/kills/grenade.wav")
Make_Sprite(Attacker, ef_kills[2], 1, 5, 30, 2, -15)
zb5_set_user_exp(Attacker, 2, 0)
}

g_had[Attacker][MyKillCount]++
AddKill = 0
} 
switch(g_had[Attacker][MyKillCount])
{
case 2:
{
PlaySound(Attacker, "ZB5/kills/kill_2.wav")
zb5_set_user_exp(Attacker, 1, 0)
Make_Sprite(Attacker, ef_kills[4], 2, 4, 35, 2, -15)
}
case 3:
{		
PlaySound(Attacker, "ZB5/kills/kill_3.wav")
zb5_set_user_exp(Attacker, 1, 0)
Make_Sprite(Attacker, ef_kills[5], 2, 4, 35, 2, -15)
}
case 4:
{
PlaySound(Attacker, "ZB5/kills/kill_4.wav")
zb5_set_user_exp(Attacker, 1, 0)
Make_Sprite(Attacker, ef_kills[6], 2, 4, 35, 2, -15)	
}	
}
AddKill = 1


if(AddKill && g_had[Attacker][MyKillCount] <= MAX_NORMAL_KILL)
g_had[Attacker][MyKillCount]++
zb5_set_user_quest(Attacker, QUEST_MASTER, 1)

if(task_exists(Attacker+TASK_RESET_TIME)) remove_task(Attacker+TASK_RESET_TIME)
set_task(4.0, "reset_kill", Attacker+TASK_RESET_TIME)		
}

public zp_fw_core_dead_post(Victim, Attacker, Headshot)
{
static  Weapon, Weapon_Temp[32]

read_data(4, Weapon_Temp, charsmax(Weapon_Temp))
Weapon = get_cswpn_from_deathmsg(Weapon_Temp)

kill_check(Victim, Attacker, Headshot, Weapon)
}
public reset_kill(id)
{
id -= TASK_RESET_TIME

g_had[id][MyKillCount] = 0
}

stock get_cswpn_from_deathmsg(const sSprite[])
{
static sWpnName[32]
format(sWpnName, charsmax(sWpnName), "%s", sSprite)
if ( equal(sWpnName, "grenade") )
{
format(sWpnName, charsmax(sWpnName), "hegrenade")
}
format(sWpnName, charsmax(sWpnName), "weapon_%s", sWpnName)
return get_weaponid(sWpnName)
}
