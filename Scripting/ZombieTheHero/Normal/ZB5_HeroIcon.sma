#include <amxmodx>
#include <engine>
#include <ZombieMod5>

#define SPRITE_CLASSNAME "heroSPR"

const MaxSlots = 32
new bool:OnFirstPersonView[MaxSlots+1]
new SpectatingUser[MaxSlots+1]

enum _:Vector
{
X,
Y,
Z
}

enum Individual
{
Spectated,
Viewed
}

enum OriginOffset
{
FrameSide,
FrameTop,
FrameBottom,
}

enum FramePoint
{
TopLeft,
TopRight,
BottomLeft,
BottomRight
}

new Float:OriginOffsets[OriginOffset] =  {_:13.0,_:25.0,_:36.0}

new Float:ScaleMultiplier = 0.030;
new Float:ScaleLower = 0.020
new Float:SomeNonZeroValue = 1.0

new MaxPlayers
new g_player[33]

public plugin_init()
{
register_forward(FM_AddToFullPack, "addToFullPackPost",1)
MaxPlayers = get_maxplayers()
}
public plugin_natives()
{
register_native("zb5_make_icon", "spawn_sprite", 1)	
}
public client_putinserver(id)Reset_All(id)
public zp_fw_disconnected(id)Reset_All(id)
public zp_fw_core_cure_post(id)Reset_All(id)
public zp_fw_core_spawn_post(id)Reset_All(id)
public zp_fw_core_dead_post(id)Reset_All(id)
public zp_fw_core_infect_post(id)
{
if(zp_core_is_zombie(id))
Reset_All(id)
}
Reset_All(id)
{
g_player[id] = false
}
public zp_fw_round_start_post()
{
remove_entity_name(SPRITE_CLASSNAME)
}
public spawn_sprite(id)
{	
g_player[id] = create_entity("info_target")
static iEnt; iEnt = g_player[id]

if(!pev_valid(iEnt))
return;

set_pev(iEnt, pev_classname, SPRITE_CLASSNAME)
set_pev(iEnt, pev_solid, SOLID_NOT)
set_pev(iEnt, pev_movetype, MOVETYPE_FOLLOW)

set_pev(iEnt, pev_iuser1, id)
set_pev(iEnt, pev_aiment, id)

engfunc(EngFunc_SetModel, iEnt, "sprites/ZB5/zb_hero.spr")
fm_set_rendering(iEnt, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, 0)
set_pev(iEnt, pev_nextthink, get_gametime() + 0.1)
}

public addToFullPackPost(es, e, ent, host, hostflags, player, pSet)
{
if(!is_valid_ent(ent))
return FMRES_IGNORED
	
static classname[32]
pev(ent, pev_classname, classname, 31)

if(!equal(classname, SPRITE_CLASSNAME))
return FMRES_IGNORED

if(!is_user_alive(host) || zp_core_is_zombie(host))
set_es(es, ES_Effects, get_es(es, ES_Effects) | EF_NODRAW)
else if(is_user_alive(host) && !zp_core_is_zombie(host))
set_es(es, ES_Effects, get_es(es, ES_Effects) & ~EF_NODRAW)
else if(!is_user_alive(host) && !zp_core_is_zombie(host))
set_es(es, ES_Effects, get_es(es, ES_Effects) & ~EF_NODRAW)

if((1<=host<=MaxPlayers) && is_valid_ent(ent))
{		
if(pev(ent,pev_owner) == g_player[player])
{
if(engfunc(EngFunc_CheckVisibility,ent,pSet))
{
	
new spectated = OnFirstPersonView[host] ? SpectatingUser[host] : host
new aiment = pev(ent,pev_aiment)

if((spectated != aiment) && is_user_alive(aiment))
{
static ID[Individual]

ID[Spectated] = spectated
ID[Viewed] = ent

static Float:origin[Individual][Vector]

entity_get_vector(ID[Spectated],EV_VEC_origin,origin[Spectated])
get_es(es,ES_Origin,origin[Viewed])

static Float:diff[Vector]
static Float:diffAngles[Vector]

xs_vec_sub(origin[Viewed],origin[Spectated],diff)			
xs_vec_normalize(diff,diff)         

vector_to_angle(diff,diffAngles)

diffAngles[0] = -diffAngles[0];

static Float:framePoints[FramePoint][Vector]

calculateFramePoints(origin[Viewed],framePoints,diffAngles)			

static Float:eyes[Vector]

xs_vec_copy(origin[Spectated],eyes)

static Float:viewOfs[Vector]			
entity_get_vector(ID[Spectated],EV_VEC_view_ofs,viewOfs);
xs_vec_add(eyes,viewOfs,eyes);

static Float:framePointsTraced[FramePoint][Vector]

static FramePoint:closerFramePoint

if(traceEyesFrame(ID[Spectated],eyes,framePoints,framePointsTraced,closerFramePoint))
{
static Float:otherPointInThePlane[Vector]
static Float:anotherPointInThePlane[Vector]

static Float:sideVector[Vector]
static Float:topBottomVector[Vector]

angle_vector(diffAngles,ANGLEVECTOR_UP,topBottomVector)
angle_vector(diffAngles,ANGLEVECTOR_RIGHT,sideVector)

xs_vec_mul_scalar(sideVector,SomeNonZeroValue,otherPointInThePlane)
xs_vec_mul_scalar(topBottomVector,SomeNonZeroValue,anotherPointInThePlane)	

xs_vec_add(otherPointInThePlane,framePointsTraced[closerFramePoint],otherPointInThePlane)
xs_vec_add(anotherPointInThePlane,framePointsTraced[closerFramePoint],anotherPointInThePlane)

static Float:plane[4]
xs_plane_3p(plane,framePointsTraced[closerFramePoint],otherPointInThePlane,anotherPointInThePlane)

moveToPlane(plane,eyes,framePointsTraced,closerFramePoint);

static Float:middle[Vector]

static Float:half = 2.0

xs_vec_add(framePointsTraced[TopLeft],framePointsTraced[BottomRight],middle)
xs_vec_div_scalar(middle,half,middle)

new Float:scale = ScaleMultiplier * vector_distance(framePointsTraced[TopLeft],framePointsTraced[TopRight])

if(scale < ScaleLower)
scale = ScaleLower;

set_es(es,ES_AimEnt,0)
set_es(es,ES_MoveType,MOVETYPE_NONE)

set_es(es,ES_Scale,scale)
set_es(es,ES_Angles,diffAngles)
set_es(es,ES_Origin,middle)
set_es(es,ES_RenderAmt,150.0)
set_es(es,ES_RenderMode,kRenderTransAdd)
}
}
}
}
}
return FMRES_HANDLED
}

calculateFramePoints(Float:origin[Vector],Float:framePoints[FramePoint][Vector],Float:perpendicularAngles[Vector])
{
new Float:sideVector[Vector]
new Float:topBottomVector[Vector]

angle_vector(perpendicularAngles,ANGLEVECTOR_UP,topBottomVector)
angle_vector(perpendicularAngles,ANGLEVECTOR_RIGHT,sideVector)

new Float:sideDislocation[Vector]
new Float:bottomDislocation[Vector]
new Float:topDislocation[Vector]

xs_vec_mul_scalar(sideVector,Float:OriginOffsets[FrameSide],sideDislocation)
xs_vec_mul_scalar(topBottomVector,Float:OriginOffsets[FrameTop],topDislocation)	
xs_vec_mul_scalar(topBottomVector,Float:OriginOffsets[FrameBottom],bottomDislocation)

xs_vec_copy(topDislocation,framePoints[TopLeft])

xs_vec_add(framePoints[TopLeft],sideDislocation,framePoints[TopRight])
xs_vec_sub(framePoints[TopLeft],sideDislocation,framePoints[TopLeft])

xs_vec_neg(bottomDislocation,framePoints[BottomLeft])

xs_vec_add(framePoints[BottomLeft],sideDislocation,framePoints[BottomRight])
xs_vec_sub(framePoints[BottomLeft],sideDislocation,framePoints[BottomLeft])

for(new FramePoint:i = TopLeft; i <= BottomRight; i++)
xs_vec_add(origin,framePoints[i],framePoints[i])

}

traceEyesFrame(id,Float:eyes[Vector],Float:framePoints[FramePoint][Vector],Float:framePointsTraced[FramePoint][Vector],&FramePoint:closerFramePoint)
{
new Float:smallFraction = 1.0

for(new FramePoint:i = TopLeft; i <= BottomRight; i++)
{
new trace;
engfunc(EngFunc_TraceLine,eyes,framePoints[i],IGNORE_GLASS,id,trace)

new Float:fraction
get_tr2(trace, TR_flFraction,fraction);

if(fraction == 1.0)
{
return false;
}
else
{
if(fraction < smallFraction)
{
smallFraction = fraction
closerFramePoint = i;
}

get_tr2(trace,TR_EndPos,framePointsTraced[i]);
}
}

return true;
}

moveToPlane(Float:plane[4],Float:eyes[Vector],Float:framePointsTraced[FramePoint][Vector],FramePoint:alreadyInPlane)
{
new Float:direction[Vector]

for(new FramePoint:i=TopLeft;i<alreadyInPlane;i++)
{
xs_vec_sub(eyes,framePointsTraced[i],direction)
xs_plane_rayintersect(plane,framePointsTraced[i],direction,framePointsTraced[i])
}

for(new FramePoint:i=alreadyInPlane+FramePoint:1;i<=BottomRight;i++)
{
xs_vec_sub(eyes,framePointsTraced[i],direction)
xs_plane_rayintersect(plane,framePointsTraced[i],direction,framePointsTraced[i])
}
}	
