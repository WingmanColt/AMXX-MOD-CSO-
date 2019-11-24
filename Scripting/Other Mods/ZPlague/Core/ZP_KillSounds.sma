#include <amxmodx>
#include <amxmisc>

#define LEVELS 10
#define TASK_CLEAR_KILL    100

new kills[33] = {0,...};
new deaths[33] = {0,...};
new kill[33][24];

new levels[10] = {3, 4, 6, 8, 10, 12,14,15,16,18};

new sounds[10][] = 
{
"ZPlague/Female/f_dominating", 
"ZPlague/Female/f_godlike", 
"ZPlague/Female/f_ultrakill",
"ZPlague/Female/f_killingspree", 
"ZPlague/Female/f_megakill", 
"ZPlague/Female/f_holyshit",
"ZPlague/Female/f_ludacrisskill",
"ZPlague/Female/f_rampage",
"ZPlague/Female/f_unstoppable",
"ZPlague/Female/f_monsterkill"
};

new messages[10][] = 
{
"%s: Triple Kill !", 
"%s: Multi Kill !",
"%s: Ultra Kill !", 
"%s: Killing Spree !",
"%s: Mega Kill !",
"%s: Holy Shit !",
"%s: Ludicrous Kill !", 
"%s: Rampage !",
"%s: Unstoppable !", 
"%s: M o n s t e R  K i L L ! ! !"
};
is_mode_set(bits) 
{
new mode[9];
get_cvar_string("ut_killstreak_advanced", mode, 8);
return read_flags(mode) & bits;
}

public plugin_init() 
{
register_event("ResetHUD", "reset_hud", "b");
register_event("DeathMsg", "event_death", "a");
}
public event_death(id) 
{
new killer = read_data(1);
new victim = read_data(2);
new headshot = read_data(3);
new weapon[24], vicname[32], killname[32]
read_data(4,weapon,23)
get_user_name(victim,vicname,31)
get_user_name(killer,killname,31)

if(headshot == 1) 
{ 
set_hudmessage(0, random_num(50,100), random_num(50,100), -1.0, 0.30, 0, 6.0, 6.0)
show_hudmessage(0, "%s removed %s head !!", killname, vicname)
client_cmd(0,"spk ZPlague/Female/f_headshot.wav")
} 


if(weapon[0] == 'k')
{ 
set_hudmessage(0, random_num(50,100), random_num(50,100), -1.0, 0.30, 0, 6.0, 6.0)
show_hudmessage(0, "%s humiliation player %s", killname, vicname)
client_cmd(0,"spk ZPlague/Female/f_humiliation.wav")
} 

if(weapon[1] == 'r')
{
set_hudmessage(random_num(50,100), random_num(50,100), 0, -1.0, 0.30, 0, 6.0, 6.0)
show_hudmessage(0,"%s got a big explosion for %s",killname,vicname)
client_cmd(0,"spk ZPlague/Female/f_ludacrisskill.wav")
}

if(kill[killer][0] && equal(kill[killer],weapon))
{
set_hudmessage(random_num(50,50), random_num(50,50), 0, -1.0, 0.30, 0, 6.0, 6.0)
show_hudmessage(0,"Wow %s made a double kill", killname)
kill[killer][0] = 0;
client_cmd(0,"spk ZPlague/Female/f_unstoppable.wav")
}

else
{
kill[killer] = weapon;
set_task(0.1,"clear_kill",TASK_CLEAR_KILL+killer);
}



kills[killer] += 1;
kills[victim] = 0;
deaths[killer] = 0;
deaths[victim] += 1;

for (new i = 0; i < LEVELS; i++) 
{
if (kills[killer] == levels[i]) 
{
announce(killer, i);
return PLUGIN_CONTINUE;
}
}

return PLUGIN_CONTINUE;
}

announce(killer, level) 
{

new name[33]

get_user_name(killer, name, 32);
set_hudmessage(0,50,150, 0.05, 0.65, 2, 0.02, 6.0, 0.01, 0.1, 2);
show_hudmessage(0, messages[level], name);
client_cmd(0, "spk %s", sounds[level]);

return PLUGIN_CONTINUE;

}


public reset_hud(id) 
{
if (is_mode_set(16)) {
if (kills[id] > levels[0]) {
client_print(id, print_chat, 
"* You are on a killstreak with %d kills.", kills[id]);
} else if (deaths[id] > 1) {
client_print(id, print_chat, 
"* Take care, you are on a deathstreak with %d deaths in a row.", deaths[id]);
}
}
}
public client_connect(id) 
{
kills[id] = 0;
deaths[id] = 0;
}

public clear_kill(taskid)
{
new id = taskid-TASK_CLEAR_KILL;
kill[id][0] = 0;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
