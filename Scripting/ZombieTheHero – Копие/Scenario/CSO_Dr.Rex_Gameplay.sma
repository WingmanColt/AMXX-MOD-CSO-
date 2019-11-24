#include <amxmodx>

#define MAP "zs_nightmare2"

#define TIME_VOTE 5
#define TASK_VOTE 572014

new g_Menu, g_Vote
new Voting

public plugin_init()
{
g_Menu = menu_create("Fight Dr.Rex?", "MenuHandle_Fight")

menu_additem(g_Menu, "Yes, Let's fight him", "yes")
menu_additem(g_Menu, "No, Continue to play zombie", "no")
}

public GM_Time() Check_RoundTime()

public Check_RoundTime()
{
if(Voting) return

static Time; Time = get_timeleft()
static Minute; Minute = Time / 60

if(Minute < TIME_VOTE)
{
Voting = 1
g_Vote = 0

Start_Voting()
set_task(30.0, "End_Vote", TASK_VOTE)

client_print(0, print_chat, "[Dr.Rex] Vote is Started!")
}
}

public Start_Voting()
{
for(new i = 0; i < get_maxplayers(); i++)
{
if(!is_user_connected(i))
continue

menu_display(i, g_Menu, 0)
}
}

public MenuHandle_Fight(id, menu, item) 
{
if(!is_user_connected(id))
return PLUGIN_HANDLED
if(item == MENU_EXIT)
return PLUGIN_HANDLED

new szData[6], szName[64], Name[64]
new item_access, item_callback;

menu_item_getinfo(menu, item, item_access, szData,charsmax( szData ), szName,charsmax( szName ), item_callback );
get_user_name(id, Name, sizeof(Name))

if(equal(szData, "yes"))
{
g_Vote++
client_print(0, print_chat, "[Dr.Rex] %s has voted 'Yes'", Name)
} else if(equal(szData, "no")) {
g_Vote--
client_print(0, print_chat, "[Dr.Rex] %s has voted 'No'", Name)
}

return PLUGIN_HANDLED
}

public End_Vote()
{
for(new i = 0; i < get_maxplayers(); i++)
{
if(!is_user_connected(i))
continue

menu_cancel(i)
}

menu_destroy(g_Menu)

if(g_Vote <= 0) // No
{
client_print(0, print_chat, "[Dr.Rex] Vote Result: No")
} else { // Yes
set_task(5.0, "ChangeTime", TASK_VOTE)
client_print(0, print_chat, "[Dr.Rex] Vote Result: Yes")
}
}

public ChangeTime()
{
server_cmd("amx_map %s", MAP)
}
