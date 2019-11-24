#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <zp50_core>

new ammo[3][33],string[21],cvarShowType,ammopacks

public plugin_init() {
register_logevent("round_start", 2, "1=Round_Start")
cvarShowType = register_cvar("ac_show_type", "1")
}

public round_start() {
new players[32],num,i
get_players(players,num)

for(i=1;i<num;i++) {
ammo[0][players[i]] = zp_ammopacks_get(players[i])
}
}

public client_putinserver(id) {
set_task(3.0,"func_ammo",id)
}

public func_ammo(id) {
ammopacks = zp_ammopacks_get(id)

ammo[0][id] = ammopacks
ammo[1][id] = ammopacks
ammo[2][id] = ammopacks

set_task(1.0,"change_ammo",id,_,_,"b")
}

public change_ammo(id) {
if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
return PLUGIN_HANDLED

ammo[1][id] = zp_ammopacks_get(id)

if(ammo[1][id] != ammo[2][id]) {
if(ammo[1][id] > ammo[2][id]) {
ammopacks = ammo[1][id] - ammo[2][id]
format(string,charsmax(string),"+%d AP", ammopacks)
}
else {
ammopacks = ammo[2][id] - ammo[1][id]
format(string,charsmax(string),"-%d AP", ammopacks)
}

ammo[2][id] = ammo[1][id]

if(get_pcvar_num(cvarShowType)) {
set_dhudmessage(random(256), random(256), random(256), 0.51, 0.51, 0, 6.0, 3.0)
show_dhudmessage(id, "%s", string)
}
else
client_print(id, print_center, "%s", string)
}

return PLUGIN_HANDLED
}

public client_disconnected(id) {
ammo[0][id] = 0
ammo[1][id] = 0
ammo[2][id] = 0

remove_task(id)
}
