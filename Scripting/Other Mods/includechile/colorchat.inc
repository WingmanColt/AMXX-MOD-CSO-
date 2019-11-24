#if defined _colorchat_included
  #endinput
#endif
#define _colorchat_included

enum ChatColor
{
	CHATCOLOR_NORMAL = 1,
	CHATCOLOR_GREEN,
	CHATCOLOR_TEAM_COLOR,
	CHATCOLOR_GREY, 	
	CHATCOLOR_RED, 		
	CHATCOLOR_BLUE, 	
};

new g_TeamName[][] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

static g_msgSayText,g_msgTeamInfo;

colorChat(id, ChatColor:color, const msg[], {Float,Sql,Result,_}:...)
{
	new team, index, MSG_Type
	new bool:teamChanged = false
	static message[192]
	
	if(!g_msgSayText) g_msgSayText = get_user_msgid("SayText");
	if(!g_msgTeamInfo) g_msgTeamInfo = get_user_msgid("TeamInfo");
	
	switch(color)
	{
		case CHATCOLOR_NORMAL: // Normal
		{
			message[0] = 0x01;
		}
		case CHATCOLOR_GREEN: // Green
		{
			message[0] = 0x04;
		}
		default: // Grey, Red, Blue
		{
			message[0] = 0x03;
		}
	}
	
	vformat(message[1], 190, msg, 4);
	replace_all(message, 190, "$g", "^x04")
	replace_all(message, 190, "$n", "^x01")
	replace_all(message, 190, "$t", "^x03")
	message[191] = '^0';
	
	if(id == 0)
	{
		index = findAnyPlayer();
		MSG_Type = MSG_ALL;
	}
	else
	{
		index = id;
		MSG_Type = MSG_ONE;
	}
	if(index != 0)
	{
		team = get_user_team(index);	
		if(color == CHATCOLOR_RED && team != 1)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[1])
			teamChanged = true
		}
		else
		if(color == CHATCOLOR_BLUE && team != 2)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[2])
			teamChanged = true
		}
		else
		if(color == CHATCOLOR_GREY && team != 0)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[0])
			teamChanged = true
		}
		messageSayText(index, MSG_Type, message);
		if(teamChanged)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[team])
		}
	}
}

messageSayText(id, type, message[])
{
	message_begin(type, g_msgSayText, _, id)
	write_byte(id)		
	write_string(message)
	message_end()
}
	
messageTeamInfo(id, type, team[])
{
	message_begin(type, g_msgTeamInfo, _, id)
	write_byte(id)
	write_string(team)
	message_end()
}
	
findAnyPlayer()
{
	static players[32], inum, pid
	
	get_players(players, inum, "ch")
	
	for (new a = 0; a < inum; a++)
	{
		pid = players[a]
		if(is_user_connected(pid))
			return pid
	}
	
	return 0
}