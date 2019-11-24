#include <amxmodx>
#include <cstrike>
#include <hamsandwich>

#define TEAM_SELECT_VGUI_MENU_ID 2
new g_pcvar_team
public plugin_init() 
{
register_message(get_user_msgid("ShowMenu"), "message_show_menu")
register_message(get_user_msgid("VGUIMenu"), "message_vgui_menu")
g_pcvar_team = register_cvar("team", "2")
}
public message_show_menu(msgid, dest, id) 
{
if (!should_autojoin(id))
return PLUGIN_CONTINUE

static team_select[] = "#Team_Select"
static menu_text_code[sizeof team_select]
get_msg_arg_string(4, menu_text_code, sizeof menu_text_code - 1)
if (!equal(menu_text_code, team_select))
return PLUGIN_CONTINUE

set_force_team_join_task(id, msgid)
menu_cancel(id)
return PLUGIN_HANDLED
}

public message_vgui_menu(msgid, dest, id) {
if (get_msg_arg_int(1) != TEAM_SELECT_VGUI_MENU_ID || !should_autojoin(id))
return PLUGIN_CONTINUE

set_force_team_join_task(id, msgid)
menu_cancel(id)
return PLUGIN_HANDLED
}

bool:should_autojoin(id) 
{
return (!get_user_team(id) && !task_exists(id))
}

set_force_team_join_task(id, menu_msgid) 
{
static param_menu_msgid[2]
param_menu_msgid[0] = menu_msgid
set_task(1.0, "task_force_team_join", id, param_menu_msgid, sizeof param_menu_msgid)
}

public task_force_team_join(menu_msgid[], id) 
{
if (get_user_team(id))
return
static team[2], class[2]
cs_set_user_team(id,CS_TEAM_CT)
get_pcvar_string(g_pcvar_team, team, sizeof team - 1)
get_pcvar_string(g_pcvar_team, class, sizeof class - 1)
force_team_join(id, menu_msgid[0], team, class)
respawn_player(id)
}

stock force_team_join(id, menu_msgid, /* const */ team[] = "5", /* const */ class[] = "0") 
{
static jointeam[] = "jointeam"
if (class[0] == '0') {
engclient_cmd(id, jointeam, team)
return
}

static msg_block, joinclass[] = "joinclass"
msg_block = get_msg_block(menu_msgid)
set_msg_block(menu_msgid, BLOCK_SET)
engclient_cmd(id, jointeam, team)
engclient_cmd(id, joinclass, class)
set_msg_block(menu_msgid, msg_block)
}
public fw_PlayerSpawn_Post(id)
remove_task(id)

public client_disconnect(id)
remove_task(id)

public respawn_player(id)
{
ExecuteHamB(Ham_CS_RoundRespawn, id)
}
