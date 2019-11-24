
// https://forums.alliedmods.net/showthread.php?t=145716 
//NPC FEATURES



#include <amxmodx>
#include <amxmisc>
#include <ZombieMod5>
#include <ScenarioMod>

#define ZB_CLASSNAME "ZOMBIE"
#define NAME_MAP "zs_behind2"

#define TASK_CREATE 323422

#define HEALTH 20.0
#define ATTACK_RANGE 60.0

#define SPEED_NORMAL 210.0
#define SPEED_FAST 230.0

#define MAX_ZOMBIES 50
#define MODEL "models/player/ZB5_Regular_NEW/ZB5_Regular_NEW.mdl"

new const ZombieSound[][] =
{
"ZB5/Scenario/zbs_death_1.wav"
}
enum
{
ANIM_IDLE = 1,
ANIM_WALK = 3,
ANIM_RUN = 4,
ANIM_ATTACK = 76,
ANIM_DIE = 101
}

enum
{
STATE_IDLE = 0,
STATE_MOVE,
STATE_ATTACK,
STATE_DEATH
}

new const spawn_file[] = "%s/scenario/%s.cfg"

new Float:g_spawn[MAX_ZOMBIES][3], m_iBlood[2]
new g_total, g_State, g_RegHam, Float:Time1
public plugin_init()
{
if(!zbs_is_scenario()) return	

RegisterHam(Ham_TakeDamage, "info_target", "npc_TakeDamage"); 
RegisterHam(Ham_Killed, "info_target", "npc_Killed"); 
RegisterHam(Ham_Think, "info_target", "npc_Think"); 
RegisterHam(Ham_TraceAttack, "info_target", "npc_TraceAttack"); 
RegisterHam(Ham_ObjectCaps, "player", "npc_ObjectCaps", 1 ); 

register_forward(FM_EmitSound, "npc_EmitSound");  
}

public plugin_precache()
{
for(new i = 0; i < sizeof(ZombieSound); i++)
PrecacheSound(ZombieSound[i])	

m_iBlood[0] = precache_model("sprites/blood.spr")
m_iBlood[1] = precache_model("sprites/bloodspray.spr")	

load_spawn()
}
 public zp_fw_round_new()
 {
    new iEnt = -1; 
     
    //Scan and find all of the NPC classnames 
    while( ( iEnt = find_ent_by_class(iEnt, g_NpcClassName) ) ) 
    { 
        //If we find a NPC which is dead... 
        if(g_NpcDead[iEnt]) 
        { 
            //Reset the solid box 
            entity_set_int(iEnt, EV_INT_solid, SOLID_BBOX); 
            //Make our NPC able to take damage again 
            entity_set_float(iEnt, EV_FL_takedamage, 1.0); 
            //Make our NPC instanstly think 
            entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.01); 
             
            //Reset the NPC boolean to false 
            g_NpcDead[iEnt] = false; 
        }     
         
        //Reset the health of our NPC 
        entity_set_float(iEnt, EV_FL_health, 250.0); 
    }	
 }
public zp_fw_game_start()
{
if(!zbs_is_scenario()) return	

set_task(1.0, "Create_Zombie", TASK_CREATE, _, _, "b")
}
public zp_fw_game_end()
{	
if(!zbs_is_scenario()) return	

if(task_exists(TASK_CREATE))
remove_task(TASK_CREATE)

remove_entity_name(ZB_CLASSNAME)	
}
public Create_Zombie()
{				
if(Get_Zombie_Alive() <= MAX_ZOMBIES)
{
static Float:Origin[3]
static ent		
ent = create_entity("info_target")

if(!pev_valid(ent))
return;

set_pev(ent, pev_classname, ZB_CLASSNAME)
engfunc(EngFunc_SetModel, ent, MODEL)
set_pev(ent, pev_modelindex, engfunc(EngFunc_ModelIndex, MODEL))

set_pev(ent, pev_gravity, 1.0)
set_pev(ent, pev_solid, SOLID_SLIDEBOX)
set_pev(ent, pev_movetype, MOVETYPE_PUSHSTEP)	

set_pev(ent, pev_takedamage, DAMAGE_YES)
set_pev(ent, pev_health, 10000.0 + HEALTH)

engfunc(EngFunc_SetSize, ent, {-16.0, -16.0, -36.0}, {16.0, 16.0, 36.0})	

collect_spawn_point(Origin)
engfunc(EngFunc_SetOrigin, ent, Origin)	

g_State = STATE_IDLE
drop_to_floor(ent)

if(!g_RegHam)
{
g_RegHam = 1
RegisterHamFromEntity(Ham_TraceAttack, ent, "fw_TraceAttack")
//RegisterHamFromEntity(Ham_TakeDamage, ent, "fw_TakeDamage")
}
set_pev(ent, pev_nextthink, get_gametime() + 1.0)
}
}
public npc_TakeDamage(iEnt, inflictor, attacker, Float:damage, bits) 
{ 
    //Make sure we only catch our NPC by checking the classname 
    new className[32]; 
    entity_get_string(iEnt, EV_SZ_classname, className, charsmax(className)) 
     
    if(!equali(className, g_NpcClassName)) 
        return; 
         
    //Play a random animation when damanged 
    Util_PlayAnimation(iEnt, random_num(13, 17), 1.25); 

    //Make our NPC say something when it is damaged 
    //NOTE: Interestingly... Our NPC mouth (which is a controller) moves!! That saves us some work!! 
    emit_sound(iEnt, CHAN_VOICE, g_NpcSoundPain[random(sizeof g_NpcSoundPain)],  VOL_NORM, ATTN_NORM, 0, PITCH_NORM) 
} 

public npc_Killed(iEnt) 
{ 
    new className[32]; 
    entity_get_string(iEnt, EV_SZ_classname, className, charsmax(className)) 
     
    if(!equali(className, g_NpcClassName)) 
        return HAM_IGNORED; 

    //Player a death animation once our NPC is killed 
    Util_PlayAnimation(iEnt, random_num(25, 30)) 

    //Because our NPC may look like it is laying down.  
    //The bounding box size is still there and it is impossible to change it so we will make the solid of our NPC to nothing 
    entity_set_int(iEnt, EV_INT_solid, SOLID_NOT); 

    //The voice of the NPC when it is dead 
    emit_sound(iEnt, CHAN_VOICE, g_NpcSoundDeath[random(sizeof g_NpcSoundDeath)],  VOL_NORM, ATTN_NORM, 0, PITCH_NORM) 

    //Our NPC is dead so it shouldn't take any damage and play any animations 
    entity_set_float(iEnt, EV_FL_takedamage, 0.0); 
    //Our death boolean should now be true!! 
    g_NpcDead[iEnt] = true; 
         
    //The most important part of this forward!! We have to block the death forward. 
    return HAM_SUPERCEDE 
} 

public npc_Think(iEnt) 
{ 
    if(!is_valid_ent(iEnt)) 
        return; 
     
    static className[32]; 
    entity_get_string(iEnt, EV_SZ_classname, className, charsmax(className)) 
     
    if(!equali(className, g_NpcClassName)) 
        return; 
     
    //We can remove our NPC here if we wanted to but I left this blank as I personally like it when there is a NPC coprse laying around 
    if(g_NpcDead[iEnt]) 
    { 
        return; 
    } 
         
    //Our NPC just spawned 
    if(g_NpcSpawn[iEnt]) 
    { 
        static Float: mins[3], Float: maxs[3]; 
        pev(iEnt, pev_absmin, mins); 
        pev(iEnt, pev_absmax, maxs); 

        //Draw a box which is the size of the bounding NPC 
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY) 
        write_byte(TE_BOX) 
        engfunc(EngFunc_WriteCoord, mins[0]) 
        engfunc(EngFunc_WriteCoord, mins[1]) 
        engfunc(EngFunc_WriteCoord, mins[2]) 
        engfunc(EngFunc_WriteCoord, maxs[0]) 
        engfunc(EngFunc_WriteCoord, maxs[1]) 
        engfunc(EngFunc_WriteCoord, maxs[2]) 
        write_short(100) 
        write_byte(random_num(25, 255)) 
        write_byte(random_num(25, 255)) 
        write_byte(random_num(25, 255)) 
        message_end(); 
         
        //Our NPC spawn boolean is now set to false 
        g_NpcSpawn[iEnt] = false; 
    } 
     
    //Choose a random idle animation 
    Util_PlayAnimation(iEnt, NPC_IdleAnimations[random(sizeof NPC_IdleAnimations)]); 

    //Make our NPC think every so often 
    entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + random_float(5.0, 10.0)); 
} 

public npc_TraceAttack(iEnt, attacker, Float: damage, Float: direction[3], trace, damageBits) 
{ 
    if(!is_valid_ent(iEnt)) 
        return; 
     
    new className[32]; 
    entity_get_string(iEnt, EV_SZ_classname, className, charsmax(className)) 
     
    if(!equali(className, g_NpcClassName)) 
        return; 
         
    //Retrieve the end of the trace 
    new Float: end[3] 
    get_tr2(trace, TR_vecEndPos, end); 
     
    //This message will draw blood sprites at the end of the trace 
    message_begin(MSG_BROADCAST,SVC_TEMPENTITY) 
    write_byte(TE_BLOODSPRITE) 
    engfunc(EngFunc_WriteCoord, end[0]) 
    engfunc(EngFunc_WriteCoord, end[1]) 
    engfunc(EngFunc_WriteCoord, end[2]) 
    write_short(spr_blood_spray) 
    write_short(spr_blood_drop) 
    write_byte(247) // color index 
    write_byte(random_num(1, 5)) // size 
    message_end() 
} 

public npc_EmitSound(id, channel, sample[], Float:volume, Float:attn, flag, pitch) 
{ 
    //Make sure player is alive 
    if(!is_user_connected(id)) 
        return FMRES_SUPERCEDE; 

    //Catch the current button player is pressing 
    new iButton = get_user_button(id); 
                     
    //If the player knifed the NPC 
    if(g_Hit[id]) 
    {     
        //Catch the string and make sure its a knife  
        if (sample[0] == 'w' && sample[1] == 'e' && sample[8] == 'k' && sample[9] == 'n') 
        { 
            //Catch the file of _hitwall1.wav or _slash1.wav/_slash2.wav 
            if(sample[17] == 's' || sample[17] == 'w') 
            { 
                //If player is slashing then play the knife hit sound 
                if(iButton & IN_ATTACK) 
                { 
                    emit_sound(id, CHAN_WEAPON, g_NpcSoundKnifeHit[random(sizeof g_NpcSoundKnifeHit)], volume, attn, flag, pitch); 
                } 
                //If player is tabbing then play the stab sound 
                else if(iButton & IN_ATTACK2) 
                { 
                    emit_sound(id,CHAN_WEAPON, g_NpcSoundKnifeStab, volume, attn, flag, pitch); 
                } 

                //Reset our boolean as player is not hitting NPC anymore 
                g_Hit[id] = false; 
                 
                //Block any further sounds to be played 
                return FMRES_SUPERCEDE 
            } 
        } 
    } 
     
    return FMRES_IGNORED 
}  







// SPAWN ORIGIN
public load_spawn()
{
// Check for spawns points of the current map
new cfgdir[32], mapname[32], filepath[100], linedata[64]
get_configsdir(cfgdir, charsmax(cfgdir))
get_mapname(mapname, charsmax(mapname))
formatex(filepath, charsmax(filepath), spawn_file, cfgdir, mapname)

// Load spawns points
if (file_exists(filepath))
{
new file = fopen(filepath,"rt"), row[4][6]

while (file && !feof(file))
{
fgets(file, linedata, charsmax(linedata))

// invalid spawn
if(!linedata[0] || str_count(linedata,' ') < 2) continue;

// get spawn point data
parse(linedata,row[0],5,row[1],5,row[2],5)

// origin
g_spawn[g_total][0] = floatstr(row[0])
g_spawn[g_total][1] = floatstr(row[1])
g_spawn[g_total][2] = floatstr(row[2])

g_total++
if (g_total >= MAX_ZOMBIES) 
break
}
if (file) fclose(file)
}
}
check_spawn_zombie(Float:origin[3]) // By Sontung0
{
new Float:originE[3], Float:origin1[3], Float:origin2[3]
new ent = -1
while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", ZB_CLASSNAME)) != 0)
{
pev(ent, pev_origin, originE)

// xoy
origin1 = origin
origin2 = originE
origin1[2] = origin2[2] = 0.0
if (vector_distance(origin1, origin2) <= 32.0) return 0;
}
return 1;
}
collect_spawn_point(Float:origin[3]) // By Sontung0
{
for (new i = 1; i <= g_total*3 ; i++)
{
origin = g_spawn[random(g_total)]
if (check_spawn_zombie(origin)) return 1;
}

return 0;
}
str_count(const str[], searchchar) // By Twilight Suzuka
{
new count, i, len = strlen(str)

for (i = 0; i <= len; i++)
{
if(str[i] == searchchar)
count++
}

return count;
}
stock get_damage_body(body, Float:damage) 
{
switch(body) 
{
case HIT_HEAD: damage *= 3.0
case HIT_STOMACH: damage *= 2.0
case HIT_CHEST: damage *= 1.9
case HIT_LEFTARM: damage *= 1.75
case HIT_RIGHTARM: damage *= 1.75
case HIT_LEFTLEG: damage *= 1.25
case HIT_RIGHTLEG: damage *= 1.25
default: damage *= 1.0
}
return floatround(damage)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
