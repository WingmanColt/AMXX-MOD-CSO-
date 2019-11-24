#include <amxmodx>
#include <ZombieMod5>
#include <ScenarioMod>

#define FIREBURN_CLASSNAME "grenade_burn"
#define pSPRITE_CLASSNAME "SPR_Player"
#define eSPRITE_CLASSNAME "SPR_Ent"
#define CRYSTAL_CLASSNAME "kurisutaru"
#define CLASS_ICON "head_icon"

#define VectorAdd(%1,%2,%3) ( %3[ 0 ] = %1[ 0 ] + %2[ 0 ], %3[ 1 ] = %1[ 1 ] + %2[ 1 ], %3[ 2 ] = %1[ 2 ] + %2[ 2 ] )

enum _:Options
{
SPRITE,
ENABLE,
FRAMES
}

enum ( <<=1 )
{
v_angle = 1,
punchangle,
angles
}

new g_iShell[4], g_had[33][Options], g_sprite_ent[512], g_sprite_player[33]
new g_IsConnected, g_IsAlive, g_IsZombie
public plugin_init()
{
Register_SafetyFunc()

register_think(FIREBURN_CLASSNAME, "fw_FireBurn_Think")	

register_forward(FM_AddToFullPack, "FM_AddToFullPack_Post", 1)
register_forward(FM_AddToFullPack, "FM_AddToFullPack_eSprite", 1)
register_forward(FM_AddToFullPack, "FM_AddToFullPack_pSprite", 1)	

register_think(CLASS_ICON, "fw_Icon_Think")
register_touch(CRYSTAL_CLASSNAME, "player", "fw_CrystalTouch")
}
public plugin_precache()
{	
g_iShell[0] = precache_model("models/ZB5/Items/wnpoth.mdl") 
g_iShell[1] = precache_model("models/ZB5/Items/shell.mdl") 
g_iShell[2] = precache_model("models/shell762.mdl")   
g_iShell[3] = precache_model("models/ZB5/Items/shotgunshell.mdl") 

PrecacheSound("ZB5/crystal_pickup.wav")
}

public plugin_natives()
{
register_native("zb5_make_shell", "EjectBrass", 1)
register_native("zb5_make_burn", "Make_FireBurn", 1)
register_native("zb5_AddTofull_Icon", "Sprite_Icon", 1)

register_native("zb5_AddTofull_eIcon", "eSpawn_Sprite", 1)
register_native("zb5_AddTofull_pIcon", "pSpawn_Sprite", 1)
register_native("zb5_valid_eIcon", "eValid_Sprite", 1)
register_native("zb5_valid_pIcon", "pValid_Sprite", 1)
}
public zp_fw_round_new()
{
remove_entity_name(eSPRITE_CLASSNAME)
remove_entity_name(pSPRITE_CLASSNAME)
remove_entity_name(FIREBURN_CLASSNAME)
remove_entity_name(CRYSTAL_CLASSNAME)
remove_entity_name(CLASS_ICON)
}
public Reset_All(id)
{
if(is_valid_ent(g_sprite_player[id]))
remove_entity(g_sprite_player[id])

arrayset(g_had[id], false, sizeof(g_had[]))	
}
public pValid_Sprite(id)return g_sprite_player[id];
public eValid_Sprite(Ent)return g_sprite_ent[Ent];

public Make_FireBurn(id, attacker, Float:Time, Float:Scale, const Model[])
{
static Ent; Ent = fm_find_ent_by_owner(-1, FIREBURN_CLASSNAME, id)
if(is_valid_ent(Ent))
return

static iEnt; iEnt = create_entity("env_sprite")
if(is_valid_ent(iEnt))
{
param_convert(5)	
static Float:Origin[3]
entity_get_vector(id, EV_VEC_origin, Origin)
entity_set_origin(iEnt, Origin)

entity_set_string(iEnt, EV_SZ_classname, FIREBURN_CLASSNAME)
entity_set_model(iEnt, Model)

entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(iEnt,EV_INT_rendermode, kRenderTransAdd)
entity_set_float(iEnt,EV_FL_renderamt, 250.0)

entity_set_edict(iEnt,EV_ENT_owner, id)
entity_set_edict(iEnt,EV_ENT_aiment, id)

entity_set_float(iEnt,EV_FL_scale, Scale)
entity_set_float(iEnt,EV_FL_frame, 0.0)

entity_set_float(iEnt, EV_FL_fuser1, get_gametime() + Time) 
entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.5)
}
}
public fw_FireBurn_Think(ent)
{
if(!is_valid_ent(ent))
return

static Float:fFrame; fFrame = entity_get_float(ent, EV_FL_frame) 
static Float:fuser2; fuser2 = entity_get_float(ent,EV_FL_fuser2)

fFrame += 1.0
if(fFrame > 15.0) fFrame = 0.0

entity_set_float(ent, EV_FL_frame, fFrame) 

static id; id = entity_get_edict(ent, EV_ENT_owner)

static NewHealth
if(get_gametime() - 1.0 > fuser2)
{
NewHealth = (get_user_health(id) - random(100))

if(NewHealth > 1)
fm_set_user_health(id, NewHealth)
else
{
remove_entity(ent)
return
}

entity_set_float(ent,EV_FL_fuser2, get_gametime())
}

static Float:fTimeRemove; fTimeRemove = entity_get_float(ent,EV_FL_fuser1)
if (get_gametime() >= fTimeRemove)
{
remove_entity(ent)
return;
}	

entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.1) 
}

public Sprite_Icon(id, Float:Glow, Float:Scale, Float:Time, const Model[], Frames)
{
param_convert(5)

g_had[id][SPRITE] = create_entity("env_sprite")
static iEnt; iEnt = g_had[id][SPRITE]

if(!is_valid_ent(iEnt))
return

entity_set_string(iEnt, EV_SZ_classname, CLASS_ICON)
entity_set_model(iEnt, Model)

entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_FLY)
entity_set_int(iEnt,EV_INT_rendermode, kRenderTransAdd)
entity_set_float(iEnt,EV_FL_renderamt, Glow)

entity_set_edict(iEnt,EV_ENT_owner, id)
entity_set_float(iEnt,EV_FL_scale, Scale)
set_pev(iEnt, pev_framerate, 1.0)
set_pev(iEnt, pev_frame, 0.0)

entity_set_float(iEnt, EV_FL_fuser1, get_gametime() + Time)
entity_set_float(iEnt, EV_FL_nextthink, get_gametime() + 0.1)

g_had[id][FRAMES] = 1
g_had[id][ENABLE] = true
}
public FM_AddToFullPack_Post(es, e, user, host, host_flags, player, p_set)
{
if(!player)
return FMRES_IGNORED

if(!Get_BitVar(g_IsConnected, host) || !Get_BitVar(g_IsAlive, user))
return FMRES_IGNORED

if(!g_had[user][ENABLE])
return FMRES_IGNORED

static Float:PlayerOrigin[3]
pev(user, pev_origin, PlayerOrigin)

PlayerOrigin[2] +=  !zb5_had_walter(user) ? 30.0 : 10.0
engfunc(EngFunc_SetOrigin, g_had[user][SPRITE], PlayerOrigin)
return FMRES_HANDLED
}

public fw_Icon_Think(iEnt)
{
if(!pev_valid(iEnt)) 
return

static id; id = pev(iEnt, pev_owner)

if(!Get_BitVar(g_IsAlive, id))
{	
g_had[id][ENABLE] = false	
engfunc(EngFunc_RemoveEntity, iEnt)
return;	
}

static Float:fFrame
pev(iEnt, pev_frame, fFrame)

fFrame += 1.0
if(fFrame >= g_had[id][FRAMES]) fFrame = 0.0
set_pev(iEnt, pev_frame, fFrame)

static Float:fTimeRemove
pev(iEnt, pev_fuser1, fTimeRemove)

if (get_gametime() >= fTimeRemove)
{
g_had[id][ENABLE] = false	
engfunc(EngFunc_RemoveEntity, iEnt)
return;
}
set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
}

public pSpawn_Sprite(ent, RenderAmt, Float:Scale, Float:Origin2, const sprite[])
{	
param_convert(5)

if(!is_valid_ent(ent))
return

g_sprite_player[ent] = create_entity("info_target")
static iEnt;iEnt = g_sprite_player[ent]	

if(is_valid_ent(iEnt))
{		
set_pev(iEnt, pev_classname, pSPRITE_CLASSNAME)
set_pev(iEnt, pev_solid, SOLID_NOT)
set_pev(iEnt, pev_movetype, MOVETYPE_FOLLOW)

set_pev(iEnt, pev_owner, ent)
set_pev(iEnt, pev_aiment, ent)

set_pev(iEnt, pev_scale, Scale)
engfunc(EngFunc_SetModel, iEnt, sprite)
fm_set_rendering(iEnt, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0)
set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
}
}
public eSpawn_Sprite(ent, RenderAmt, Float:Scale, Float:Origin2, const sprite[])
{	
param_convert(5)

if(!is_valid_ent(ent))
return

g_sprite_ent[ent] = create_entity("info_target")
static iEnt;iEnt = g_sprite_ent[ent]	

if(is_valid_ent(iEnt))
{		
static Float:orig[3]
pev(ent, pev_origin, orig)

orig[2] += Origin2

set_pev(iEnt, pev_classname, eSPRITE_CLASSNAME)
set_pev(iEnt, pev_solid, SOLID_NOT)
set_pev(iEnt, pev_movetype, MOVETYPE_NONE)

set_pev(iEnt, pev_origin, orig)
set_pev(iEnt, pev_scale, Scale)
set_pev(iEnt, pev_owner, ent)

engfunc(EngFunc_SetModel, iEnt, sprite)
fm_set_rendering(iEnt, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0)
set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
}
}

// ent sender
// host receiver
public FM_AddToFullPack_eSprite(es, e, ent, host, hostflags, player, pSet)
{
if(player || !pev_valid(ent))
return FMRES_IGNORED;

static classname[32]
pev(ent, pev_classname, classname, 31)

if(!equal(classname, eSPRITE_CLASSNAME))
return FMRES_IGNORED	

if (ent == host || !is_player(host, 1) || Get_BitVar(g_IsZombie, host))  
{
set_es(es, ES_Effects, EF_NODRAW)
return FMRES_IGNORED
}

static Float:Origin[3];
pev(ent, pev_origin, Origin)

static ptr; ptr = create_tr2()
static Float:start[3], Float:end[3], Float:fVecEnd[3], Float:vNormal[3]
static Float:Scale; Scale = entity_get_float(ent, EV_FL_scale)

entity_get_vector(host, EV_VEC_origin, start)
entity_get_vector(ent, EV_VEC_origin, end)

engfunc(EngFunc_TraceLine, start, end, IGNORE_MONSTERS, ent, ptr)
static Float:fFraction;
get_tr2(ptr, TR_flFraction, fFraction);		

get_tr2(ptr, TR_vecEndPos, fVecEnd)
get_tr2(ptr, TR_vecPlaneNormal, vNormal)

xs_vec_mul_scalar(vNormal, 7.0, vNormal)
xs_vec_add(fVecEnd, vNormal, vNormal)

set_es(es, ES_Origin, vNormal)
set_es(es, ES_Scale, Scale)

set_es(es,ES_AimEnt,0)
set_es(es,ES_MoveType,MOVETYPE_NONE)

set_es(es,ES_RenderAmt,100.0)
set_es(es,ES_RenderMode,kRenderTransAdd)

free_tr2(ptr)
return FMRES_HANDLED
}
public FM_AddToFullPack_pSprite(es, e, ent, host, hostflags, player, pSet)
{
if(player || !pev_valid(ent))
return FMRES_IGNORED;

static classname[32]
pev(ent, pev_classname, classname, 31)

if(!equal(classname, pSPRITE_CLASSNAME))
return FMRES_IGNORED	

if (ent == host || !is_player(host, 1) || Get_BitVar(g_IsZombie, host))  
{
set_es(es, ES_Effects, EF_NODRAW)
return FMRES_IGNORED
}

static Float:Origin[3];
pev(ent, pev_origin, Origin)

static ptr; ptr = create_tr2()
static Float:start[3], Float:end[3], Float:fVecEnd[3], Float:vNormal[3]
static Float:Scale; Scale = entity_get_float(ent, EV_FL_scale)

entity_get_vector(host, EV_VEC_origin, start)
entity_get_vector(ent, EV_VEC_origin, end)

engfunc(EngFunc_TraceLine, start, end, IGNORE_MONSTERS, ent, ptr)
static Float:fFraction;
get_tr2(ptr, TR_flFraction, fFraction);		

get_tr2(ptr, TR_vecEndPos, fVecEnd)
get_tr2(ptr, TR_vecPlaneNormal, vNormal)

xs_vec_mul_scalar(vNormal, 7.0, vNormal)
xs_vec_add(fVecEnd, vNormal, vNormal)

set_es(es, ES_Origin, vNormal)
set_es(es, ES_Scale, Scale)

set_es(es,ES_AimEnt,0)
set_es(es,ES_MoveType,MOVETYPE_NONE)

set_es(es,ES_RenderAmt,100.0)
set_es(es,ES_RenderMode,kRenderTransAdd)

free_tr2(ptr)
return FMRES_HANDLED
}

// CRYSTALS
public Create_Crystal(id)
{
static ent; ent = create_entity("info_target")
if(!is_valid_ent(ent))
return;

entity_set_string(ent, EV_SZ_classname, CRYSTAL_CLASSNAME)
entity_set_model(ent, "models/ZB5/Items/crystal.mdl")

entity_set_vector(ent,EV_VEC_mins, Float:{-16.0,-16.0,0.0})
entity_set_vector(ent,EV_VEC_maxs, Float:{16.0,16.0,16.0})

entity_set_int(ent,EV_INT_movetype, MOVETYPE_TOSS)
entity_set_int(ent,EV_INT_solid, SOLID_TRIGGER)

static Float:Origin[3]
entity_get_vector(id, EV_VEC_origin, Origin)

Origin[2] += 6.0
entity_set_origin(ent, Origin)

set_rendering(ent, kRenderFxGlowShell, 100, 255, 100, kRenderNormal, 0)
entity_set_int(ent,EV_INT_light_level, 180)

// Animation
entity_set_float(ent, EV_FL_animtime, get_gametime())
entity_set_float(ent, EV_FL_framerate, 1.0)
entity_set_int(ent, EV_INT_sequence, 0)

entity_set_float(ent, EV_FL_nextthink, halflife_time() + 0.1) 
}
public fw_CrystalTouch(Ent, id)
{
if(!is_valid_ent(Ent))
return
if(!is_player(id, 1))
return

if(Get_BitVar(g_IsZombie, id))
{
if(zb5_get_zombie_info(id, EVO_LV) == ORIGIN)
return

zb5_set_zombie_info(id, EVO_POINTS, 1)
}else {
zb5_set_user_exp(id, 1, 0)
zb5_get_upgrade(id)
}
if(!zb5_get_user_nvg(id))
Make_ScreenFade(id, 0.05, 127, 255, 127, 50, FADE_IN)

EmitSound(id, CHAN_ITEM, "ZB5/crystal_pickup.wav")
set_pev(Ent, pev_flags, FL_KILLME)
}


public EjectBrass(Player, mode, Float:upScale, Float:fwScale, Float:rgScale , Float:rgKoord1 , Float:rgKoord2, time2)
{	
UTIL_MakeVectors(Player, v_angle + punchangle);

static Float:vVel[ 3 ], Float:vAngle[ 3 ], Float:vOrigin[ 3 ], Float:vViewOfs[ 3 ],
i, Float:vShellOrigin[ 3 ],  Float:vShellVelocity[ 3 ], Float:vRight[ 3 ], 
Float:vUp[ 3 ], Float:vForward[ 3 ];
pev( Player, pev_velocity, vVel );
pev( Player, pev_view_ofs, vViewOfs );
pev( Player, pev_angles, vAngle );
pev( Player, pev_origin, vOrigin );
global_get( glb_v_right, vRight );
global_get( glb_v_up, vUp );
global_get( glb_v_forward, vForward );

for( i = 0; i < 3; i++ )
{
vShellOrigin[ i ] = vOrigin[ i ] + vViewOfs[ i ] + vUp[i] * upScale + vForward[i] * fwScale + vRight[ i ] * rgScale;
vShellVelocity[ i ] = vVel[ i ] + vRight[ i ] * random_float(rgKoord1, rgKoord2) + vUp[i] * random_float( 50.0, 100.0 ) + vForward[ i ] * 25.0;
}

engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vShellOrigin, 0);
write_byte(TE_MODEL);
engfunc(EngFunc_WriteCoord, vShellOrigin[0]);
engfunc(EngFunc_WriteCoord, vShellOrigin[1]);
engfunc(EngFunc_WriteCoord, vShellOrigin[2]);	
engfunc(EngFunc_WriteCoord, vShellVelocity[0]);
engfunc(EngFunc_WriteCoord, vShellVelocity[1]);
engfunc(EngFunc_WriteCoord, vShellVelocity[2]);
engfunc(EngFunc_WriteAngle, vAngle[1]);
switch(mode)
{
case 1:write_short(g_iShell[0]);
case 2:write_short(g_iShell[1]);
case 3:write_short(g_iShell[2]);
case 4:write_short(g_iShell[3]);
}
write_byte(1);
write_byte(time2); // 2.5 seconds
message_end();
}
stock UTIL_MakeVectors(pPlayer, bitsAngleType)
{	
static Float:vPunchAngle[ 3 ], Float:vAngle[ 3 ];

if( bitsAngleType & v_angle )    
pev( pPlayer, pev_v_angle, vAngle );
if( bitsAngleType & punchangle ) 
pev( pPlayer, pev_punchangle, vPunchAngle );

VectorAdd( vAngle, vPunchAngle, vAngle );
engfunc( EngFunc_MakeVectors, vAngle );
}
stock is_wall_between_points(Float:start[3], Float:end[3], ignore_ent)
{
static ptr; ptr = create_tr2()
engfunc(EngFunc_TraceLine, start, end, IGNORE_GLASS | IGNORE_MONSTERS | IGNORE_MISSILE, ignore_ent, ptr)

static fraction
get_tr2(ptr, TR_flFraction, fraction)
free_tr2(ptr)

return (fraction != 1.0)
}
/* ===============================
------------- SAFETY -------------
=================================*/
public client_connect(id)Safety_Connected(id)
public client_disconnected(id)Safety_Disconnected(id)
public client_putinserver(id)Safety_Connected(id)

Register_SafetyFunc()
{
RegisterHam(Ham_Spawn, "player", "fw_Safety_Spawn_Post", 1)
RegisterHam(Ham_Killed, "player", "fw_Safety_Killed_Post", 1)
}

Safety_Connected(id)
{
Set_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

//Reset_All(id)
}

Safety_Disconnected(id)
{
UnSet_BitVar(g_IsConnected, id)
UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

//Reset_All(id)
}

public fw_Safety_Spawn_Post(id)
{
if(!is_user_alive(id))
return

Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

if(zp_core_is_zombie(id))
Set_BitVar(g_IsZombie, id)

Reset_All(id)
}
public zp_fw_core_cure_post(id)
{
Set_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_All(id)
}

public fw_Safety_Killed_Post(id)
{
if(Get_BitVar(g_IsZombie, id))
{
if(random_num(1, 3) == 3)	
Create_Crystal(id)
}

UnSet_BitVar(g_IsAlive, id)
UnSet_BitVar(g_IsZombie, id)

Reset_All(id)
}
public zp_fw_core_infect_post(id)
{
if(!zp_core_is_zombie(id))
return;

Set_BitVar(g_IsAlive, id)
Set_BitVar(g_IsZombie, id)

Reset_All(id)
}
public is_player(id, IsAliveCheck)
{
if(!(1 <= id <= 32))
return 0
if(!Get_BitVar(g_IsConnected, id))
return 0

if(IsAliveCheck)
{
if(Get_BitVar(g_IsAlive, id)) return 1
else return 0
}

return 1
}
/* ===============================
--------- END OF SAFETY  ---------
=================================*/

/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1026\\ f0\\ fs16 \n\\ par }
*/
