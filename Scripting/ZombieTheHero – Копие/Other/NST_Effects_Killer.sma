///////////////////////////////////////////////////
//  AMXMOD[X]                                    //
//  Effects Killer                       	 //
//  by NST (Luckyboy_1987hp@yahoo.com)   	 //
//                                               //
// cvar:                                         //
//  nst_ek_time_kill < number >                  //
//  	< number > = 8,9,....                    //
//                                               //
//  nst_ek_sex < number >                        //
//  	< number > = 1 or 2                      //
//  	1 - Man                                  //
//  	2 - Woman                                //
//  nst_ek_type < number >                       //
//  	< number > = 1 or 2                      //
//  	1 - use image                            //
//  	2 - use text				 //
///////////////////////////////////////////////////

#include <amxmodx>
#include <fakemeta>

#define LEVELS 8

new kills[33] = {0,...};
new timekill[33] = {0,...};
new victims[33] = {0,...};
new levels[8] = {1, 2, 3, 4, 5, 6, 7, 8};

new spr_current[33] = {0,...}
new spr_current_2[33] = {0,...}
new time_show_set[33] = {0,...}
new iconstatus, time_show = 2, g_firstBlood, g_lastkill
new g_FM_Running


public plugin_init() {
	register_plugin("Effects Killer","1.0","NST")
	
	register_event("TextMsg", "eRestart", "a", "2&#Game_C", "2&#Game_w")
	register_event("SendAudio", "eEndRound", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw")
	register_event("RoundTime", "eNewRound", "bc")
	
	register_cvar("nst_ek_time_kill","8")
	register_cvar("nst_ek_sex","1")
	register_cvar("nst_ek_type","1")
	
	register_forward(FM_PlayerPreThink,"check_spr")
	iconstatus = get_user_msgid("StatusIcon")
	g_FM_Running = is_module_loaded("FakeMeta")
	//return PLUGIN_CONTINUE
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{
	if (killer == victim) return PLUGIN_HANDLED
	kills[victim] = 0
	
	new team[6],sex[6]
	if (get_user_team(killer) == 1) team = "T"
	else team = "CT"
	
	new sex_cvar = get_cvar_num("nst_ek_sex")
	if (sex_cvar == 2) sex = "woman"
	else sex = "man"

	new killer_name[32], victim_name[32]	
	get_user_name(killer, killer_name, 31)
	get_user_name(victim, victim_name, 31)
	
	victims[victim] = killer
	new headshot = (hitplace == HIT_HEAD) ? 1 : 0

	new sec_c = get_systime()
	new timekill_cvar = get_cvar_num("nst_ek_time_kill")
	
	new timeleft = sec_c-timekill[killer]
	timekill[killer] = sec_c
	if (timeleft<=timekill_cvar) kills[killer] += 1;
	else kills[killer] = 1;
	if (kills[killer]>LEVELS) kills[killer] = 1
	
	new players_ct[32], players_t[32], ict, ite
	get_players(players_ct,ict,"ae","CT")   
	get_players(players_t,ite,"ae","TERRORIST")
	if (ict == 0 || ite == 0) g_lastkill = 1
	
	new g_revenge = 0
	if (victim == victims[killer])
	{
		g_revenge = 1
		victims[killer] = 0
	}
		
	
	new check_spr2, check_sound
	if (g_lastkill == 1)
	{
		g_lastkill = 0
		show_spr(killer, 15)
		show_msg(killer,"LAST KILL")
	}	
	else if (g_revenge == 1)
	{
		show_spr(killer, 16)
		show_msg(killer,"PHUC THU")
		client_cmd(killer,"spk misc/MultiKill/%s/Revenge_%s", sex, team)
	}
	else if((wpnindex != CSW_KNIFE) && (wpnindex != CSW_HEGRENADE) && !can_see_fm(killer, victim)) 
	{
		if (headshot) show_spr(killer, 20)
		else show_spr(killer, 19)
		show_msg(killer,"WALL SHOT")
	}
	else if (headshot && wpnindex)
	{
		show_spr(killer, 12)
		show_msg(killer,"HEADSHOT")
		if (kills[killer] == 1)
		{
			client_cmd(killer,"spk misc/MultiKill/%s/Headshot_%s", sex, team)
			check_sound = 1
		}
	}
	else if (wpnindex == CSW_KNIFE)
	{
		show_spr(killer, 14)
		show_msg(killer,"KNIFE KILL")
		if (kills[killer] == 1)
		{
			client_cmd(killer,"spk misc/MultiKill/%s/Knifekill_%s", sex, team)
			check_sound = 1
		}
	}
	else if (wpnindex == CSW_HEGRENADE)
	{
		show_spr(killer, 11)
		show_msg(killer,"HEGRENADE KILL")
		if (kills[killer] == 1)
		{
			client_cmd(killer,"spk misc/MultiKill/%s/Grenadekill_%s", sex, team)
			check_sound = 1
		}
	}
	else check_spr2 = 1
	if (check_spr2 == 1) hide_spr(killer, spr_current_2[killer])
	

	if (g_firstBlood)
	{
		g_firstBlood = 0
		show_spr(killer, 9)
		show_msg(killer,"FIRST KILL")
		if (check_sound != 1) client_cmd(killer, "spk misc/MultiKill/%s/MultiKill_1_%s", sex, team);
	}
	else {
		for (new i = 0; i < LEVELS; i++)
		{
			if (kills[killer] == levels[i])
			{
				show_spr(killer, (i+1))
				
				new msg[33]
				format (msg ,33, "%i KILL", (i+1));
				show_msg(killer, msg);
				
				if (check_sound != 1) client_cmd(killer, "spk misc/MultiKill/%s/MultiKill_%i_%s", sex, (i+1), team);
				return PLUGIN_CONTINUE;
			}
		}
	}


	return PLUGIN_CONTINUE
}

public bomb_defused(defuser)
{
	new sex[6]
	new sex_cvar = get_cvar_num("nst_ek_sex")
	if (sex_cvar == 2) sex = "woman"
	else sex = "man"
	
	show_spr(defuser, 17)
	client_cmd(defuser, "spk misc/MultiKill/%s/C4_Defuse", sex);
}

public bomb_planted(planter)
{
	new sex[6]
	new sex_cvar = get_cvar_num("nst_ek_sex")
	if (sex_cvar == 2) sex = "woman"
	else sex = "man"

	show_spr(planter, 18)
	client_cmd(planter, "spk misc/MultiKill/%s/C4_Set", sex);
}

public show_msg(killer, msg[])
{
	new type_cvar = get_cvar_num("nst_ek_type")
	if (type_cvar == 2)
	{
		set_hudmessage(0, 204, 0, -1.0, 0.65, 1, 0.02, 3.0, 0.3, 0.3, 2)
		show_hudmessage(killer, msg);
	}
	return PLUGIN_CONTINUE
}

public show_spr(id, idspr)
{
	new type_cvar = get_cvar_num("nst_ek_type")
	if (type_cvar == 1)
	{
		
		new sec_c = get_systime()
		time_show_set[id] = sec_c

		hide_spr(id, spr_current[id])
		if (idspr==11 || idspr==12 || idspr==13 || idspr==14 || idspr==15 || idspr==16 || idspr==19 || idspr==20)
		{
			hide_spr(id, spr_current_2[id])
			spr_current_2[id] = idspr
		}
		else
		{
			spr_current[id] = idspr
		}
		
		new spr_name[33]
		spr_name = get_sprname(idspr)
		
		if(!(pev(id,pev_button) & FL_ONGROUND))
		{    
			message_begin(MSG_ONE,iconstatus,{0,0,0},id);
			write_byte(1); // status (0=hide, 1=show, 2=flash)
			write_string(spr_name); // sprite name
			message_end();
		}
	}
	return PLUGIN_CONTINUE
} 

public hide_spr(id, idspr)
{
	if (idspr > 0)
	{
		new spr_name[33]
		spr_name = get_sprname(idspr)
		
		if(!(pev(id,pev_button) & FL_ONGROUND))
		{    
			message_begin(MSG_ONE,iconstatus,{0,0,0},id);
			write_byte(0); // status (0=hide, 1=show, 2=flash)
			write_string(spr_name); // sprite name
			message_end();
			if (idspr==11 || idspr==12 || idspr==13 || idspr==14 || idspr==15 || idspr==16 || idspr==19 || idspr==20) spr_current_2[id] = 0
			else spr_current[id] = 0
		}
	}
	return PLUGIN_CONTINUE
}  

public check_spr(id)
{
	new idspr = spr_current[id]
	new idspr_2 = spr_current_2[id]
	if (idspr > 0 || idspr_2 > 0)
	{
		new sec_c = get_systime()
		new time_check = sec_c - time_show_set[id]
		if (time_check>time_show)
		{
			hide_spr(id, idspr)
			hide_spr(id, idspr_2)
		}
	}

	return PLUGIN_CONTINUE
}  


public eNewRound()
{
	if (read_data(1) == floatround(get_cvar_float("mp_roundtime") * 60.0,floatround_floor))
	{
		g_firstBlood = 1
		for (new i = 0; i < 33; i++)
		{
			timekill[i] = 0
		}
	}
}

public eRestart()
{
	eEndRound()
	g_firstBlood = 1
}

public eEndRound()
{

}


get_sprname(idspr)
{
	new spr_name[33]
	if (idspr==1) spr_name = "kill_1"
	if (idspr==2) spr_name = "kill_2"
	if (idspr==3) spr_name = "kill_3"
	if (idspr==4) spr_name = "kill_4"
	if (idspr==5) spr_name = "kill_5"
	if (idspr==6) spr_name = "kill_6"
	if (idspr==7) spr_name = "kill_7"
	if (idspr==8) spr_name = "kill_8"
	if (idspr==9) spr_name = "kill_first"
	if (idspr==11) spr_name = "kill_he"
	if (idspr==12) spr_name = "kill_headshot"
	if (idspr==13) spr_name = "kill_headshot_gold"
	if (idspr==14) spr_name = "kill_knife"
	if (idspr==15) spr_name = "kill_last"
	if (idspr==16) spr_name = "kill_revenge"
	if (idspr==17) spr_name = "c4_defuse"
	if (idspr==18) spr_name = "c4_set"
	if (idspr==19) spr_name = "wall_shot"
	if (idspr==20) spr_name = "wall_shot_hs"
	
	return spr_name
}

bool:can_see_fm(entindex1, entindex2)
{
	if ((!g_FM_Running) || !entindex1 || !entindex2)
		return false
//  new ent1, ent2

	if (pev_valid(entindex1) && pev_valid(entindex1))
	{
		new flags = pev(entindex1, pev_flags)
		if (flags & EF_NODRAW || flags & FL_NOTARGET)
		{
			return false
		}

		new Float:lookerOrig[3]
		new Float:targetBaseOrig[3]
		new Float:targetOrig[3]
		new Float:temp[3]

		pev(entindex1, pev_origin, lookerOrig)
		pev(entindex1, pev_view_ofs, temp)
		lookerOrig[0] += temp[0]
		lookerOrig[1] += temp[1]
		lookerOrig[2] += temp[2]

		pev(entindex2, pev_origin, targetBaseOrig)
		pev(entindex2, pev_view_ofs, temp)
		targetOrig[0] = targetBaseOrig [0] + temp[0]
		targetOrig[1] = targetBaseOrig [1] + temp[1]
		targetOrig[2] = targetBaseOrig [2] + temp[2]

		engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the had of seen player
		if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
		{
			return false
		} 
		else 
		{
			new Float:flFraction
			get_tr2(0, TraceResult:TR_flFraction, flFraction)
			if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
			{
				return true
			}
			else
			{
				targetOrig[0] = targetBaseOrig [0]
				targetOrig[1] = targetBaseOrig [1]
				targetOrig[2] = targetBaseOrig [2]
				engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the body of seen player
				get_tr2(0, TraceResult:TR_flFraction, flFraction)
				if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
				{
					return true
				}
				else
				{
					targetOrig[0] = targetBaseOrig [0]
					targetOrig[1] = targetBaseOrig [1]
					targetOrig[2] = targetBaseOrig [2] - 17.0
					engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the legs of seen player
					get_tr2(0, TraceResult:TR_flFraction, flFraction)
					if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
					{
						return true
					}
				}
			}
		}
	}
	return false
}
