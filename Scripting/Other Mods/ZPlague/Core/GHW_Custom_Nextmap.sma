#include <amxmodx>
#include <amxmisc>
new configfile[200],maps[9][32]
new menu[1024], keys,extended, saytext
new bool:voting,votes[10],mp_timelimit
public plugin_init()
{
get_configsdir(configfile,199)
format(configfile,199,"%s/custom_nextmaps.ini",configfile)

if(file_exists(configfile))
{
register_menucmd(register_menuid("CustomNextMap"),(1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9),"VoteCount")
set_task(5.0,"Check_Endround",1337,"",0,"b")
mp_timelimit = get_cvar_pointer("mp_timelimit")
}
saytext =  get_user_msgid("SayText")
}
public Check_Endround()
{
new timeleft = get_timeleft()
if (timeleft < 1 || timeleft > 129)
{
return ;
}

remove_task(1337)

format(menu,1023,"\y[\rZombie\y:Nanosuit2] \wMap Chooser\w^n")
new Fsize = file_size(configfile,1)
new read[32], trash, string[8]
new numbers[17]

for(new i=1;i<9;i++)
{
numbers[i]=0
numbers[17-i]=0
for(new i2=0;i2<Fsize;i2++)
{
read_file(configfile,i2,read,31,trash)
format(string,7,"[%d]",i)
if(equali(read,string)) numbers[i]=i2+1

format(string,7,"[/%d]",i)
if(equali(read,string)) numbers[17-i]=i2-1
}
}

new tries
keys = (1<<9)
for(new i=1;i<9;i++)
{
format(maps[i],31,"")
if(numbers[i] && numbers[17-i] && numbers[17-i]-numbers[i]>=0)
{
tries=0
while(tries<50)
{
read_file(configfile,random_num(numbers[i],numbers[17-i]),read,31,trash)
if(is_map_valid(read))
{
format(maps[i],31,"%s",read)
format(menu,1023,"%s^n%d. %s",menu,i,read)
switch(i)
{
case 1: keys |= (1<<0)
case 2: keys |= (1<<1)
case 3: keys |= (1<<2)
case 4: keys |= (1<<3)
case 5: keys |= (1<<4)
case 6: keys |= (1<<5)
case 7: keys |= (1<<6)
case 8: keys |= (1<<7)
}
break;
}
tries++
}
}
}

new mapname[32]
get_mapname(mapname,31)
if(extended < 3)
{
format(menu,1023,"%s^n^n9. Extend %s",menu,mapname)
keys |= (1<<8)
}
format(menu,1023,"%s^n0. I don't care",menu)
show_menu(0,keys,menu,-1,"CustomNextMap")
set_task(15.0,"VoteTally")
voting=true
return ;
}

public VoteCount(id,key)
{
if(voting)
{
new name[32]
get_user_name(id,name,31)
if(extended<3 && key==8)
{
colorchat(0, "^4[NS2] %s ^3voted for map extension.", name);
votes[9]++
}
else if(key==9)
{
colorchat(0, "^4[NS2] %s ^3didn't vote.", name);
}
else if(strlen(maps[key+1]))
{
colorchat(0, "^4[NS2] %s ^3voted for ^4%s.",name,maps[key+1]);
votes[key+1]++
}
else
{
show_menu(0,keys,menu,-1,"CustomNextMap")
}
}
}

public VoteTally()
{
voting=false
new winner[2]
for(new i=1;i<10;i++)
{
if(votes[i]>winner[1])
{
winner[0]=i
winner[1]=votes[i]
}
votes[i]=0
}
if(!winner[1])
{
colorchat(0, "^4[NS2] ^3No one voted. Random Map coming.");
}
else if(winner[0]==9)
{
colorchat(0, "^4[NS2] ^3Map extending won. Extending map for 15 minutes.");
set_pcvar_float(mp_timelimit,get_pcvar_float(mp_timelimit) + 15)
set_task(15.0,"Check_Endround",1337,"",0,"b")
extended++
}
else
{
colorchat(0, "^4[NS2] ^3Voting Over. Nextmap will be ^4%s",maps[winner[0]]);
set_task(0.1,"change_level",winner[0],"",0,"d")
}
}

public change_level(map)
{
server_cmd("changelevel %s",maps[map])
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
message_begin(MSG_ONE_UNRELIABLE, saytext, _, players[i]); 
write_byte(players[i]); 
write_string(msg); 
message_end(); 
} 
} 
} 
} 
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
