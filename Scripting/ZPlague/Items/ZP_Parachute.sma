#include <amxmodx>
#include <fakemeta>
#include <zp50_core>
#include <ZP_Shop>

new para_ent[33] = 0;
new Float:save_gravity[33] = 1.0;

public plugin_init()
{
register_forward(FM_PlayerPreThink, "FW_PlayerPreThink");
register_event("HLTV", "EVENT_round_start", "a", "1=0", "2=0");
}
public plugin_precache()
{
precache_model("models/parachute.mdl")
}
public client_connect(id)parachute_reset(id)	
public client_disconnected(id)parachute_reset(id)
public zp_fw_core_infect_post(id)parachute_reset(id)
public zp_fw_core_cure_post(id)parachute_reset(id)	
public parachute_reset(id)
{
if(para_ent[id] > 0) {
if (pev_valid(para_ent[id]))
EF_RemoveEntity(para_ent[id])
}
para_ent[id] = 0;
save_gravity[id] = 1.0;
}

public EVENT_round_start()
{
for (new id; id <= 32; id++) parachute_reset(id);
}

public FW_PlayerPreThink(id)
{
if (!is_user_alive(id)) return

if (zp_core_is_zombie(id))
{
parachute_reset(id);
return;
}

new Float:frame

new button = pev(id,pev_button)
new oldbutton = pev(id,pev_oldbuttons)
new flags = pev(id,pev_flags)

if (para_ent[id] > 0 && (flags & FL_ONGROUND)) {

set_pev(id,pev_gravity,save_gravity)
EF_RemoveEntity(para_ent[id])
para_ent[id] = 0
return
}

if ( (button & IN_USE) && !(flags & FL_ONGROUND) ) 
{

new Float:velocity[3]
pev(id,pev_velocity,velocity)

if (velocity[2] < 0.0) {

if(para_ent[id] <= 0) {
para_ent[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString,"info_target"))
if(para_ent[id] > 0) {
set_pev(para_ent[id],pev_classname,"parachute")
set_pev(para_ent[id],pev_aiment,id)
set_pev(para_ent[id],pev_owner,id)
set_pev(para_ent[id],pev_movetype,MOVETYPE_FOLLOW)
if(!zp_nano_cloakmode(id))
engfunc(EngFunc_SetModel,para_ent[id],"models/parachute.mdl")
set_pev(para_ent[id],pev_sequence,0)
set_pev(para_ent[id],pev_gaitsequence,1)
set_pev(para_ent[id],pev_frame,0.0)
set_pev(para_ent[id],pev_fuser1,0.0)
pev(id,pev_gravity,save_gravity[id]);
}
}

if (para_ent[id] > 0) {

set_pev(id,pev_sequence,3)
set_pev(id,pev_gaitsequence,1)
set_pev(id,pev_frame,1.0)
set_pev(id,pev_framerate,1.0)
set_pev(id,pev_gravity,0.1)

velocity[2] = (velocity[2] + 40.0 < -90.0) ? velocity[2] + 40.0 : -90.0
set_pev(id,pev_velocity,velocity)

if (pev(para_ent[id],pev_sequence) == 0) {

frame = pev(para_ent[id],pev_fuser1) + 1.0
set_pev(para_ent[id],pev_fuser1,frame)
set_pev(para_ent[id],pev_frame,frame)

if (frame > 100.0) {
set_pev(para_ent[id],pev_animtime,0.0)
set_pev(para_ent[id],pev_framerate,0.4)
set_pev(para_ent[id],pev_sequence,1)
set_pev(para_ent[id],pev_gaitsequence,1)
set_pev(para_ent[id],pev_frame,0.0)
set_pev(para_ent[id],pev_fuser1,0.0)
}
}
}
}
else if (para_ent[id] > 0) {
EF_RemoveEntity(para_ent[id])
set_pev(id,pev_gravity,save_gravity[id])
para_ent[id] = 0
}
}
else if ((oldbutton & IN_USE) && para_ent[id] > 0 ) {
EF_RemoveEntity(para_ent[id])
set_pev(id,pev_gravity,save_gravity[id])
para_ent[id] = 0
}
}
public EF_RemoveEntity(ENTITY)
{
if(!pev_valid(ENTITY))
return;	
engfunc(EngFunc_RemoveEntity, ENTITY);
}
