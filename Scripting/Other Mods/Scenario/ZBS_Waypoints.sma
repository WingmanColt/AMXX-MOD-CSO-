#include <amxmodx>
#include <amxmisc>

new const plugin[] =	"Civilian NPC Waypoints"
new const version[] =	"1.00"
new const author[] =	"p3tsin"

#define ACCESS		ADMIN_LEVEL_A		//access level required for amx_npcwaypoint
#define MAX_ENTRIES	100			//max number of npc entries
#define MAX_WAYPOINTS	100			//max number of waypoints per entry

new currentwp[33]
new bool:hasmenu[33]
new numentries
new numwaypoints[MAX_ENTRIES]
new waypoints[MAX_ENTRIES][MAX_WAYPOINTS][3]
new waypointfile[192]
new spr_line


public plugin_init() {
register_plugin(plugin,version,author)
register_clcmd("amx_npcwaypoint","cmdmenu",ACCESS, "- open npc waypointmenu")

static title[30]
copy(title,29, plugin)
register_menu(title,1023,"action_wpmenu")
}

public plugin_precache() {
spr_line = precache_model("sprites/rope.spr")
}

public plugin_cfg() {
new datadir[128], map[32]
get_datadir(datadir,127)
get_mapname(map,31)

format(waypointfile,191, "%s/waypoints/%s.txt",datadir,map)
if(file_exists(waypointfile)) load_waypoints()
}

public client_disconnect(id) {
currentwp[id] = 0
hasmenu[id] = false
}

public cmdmenu(id,level,cid) {
if(cmd_access(id,level,cid,1)) openmenu(id)
return PLUGIN_HANDLED
}

public openmenu(id) {
new key, current = currentwp[id]

static buffer[1024]
new len = formatex(buffer,1023, "%s: %d/%d^n^n",plugin,current+1,numentries)
len += formatex(buffer[len],1023-len, "%d. Create a new character entry^n",++key)
if(numentries) {
len += formatex(buffer[len],1023-len, "%d. Delete current entry^n",++key)
len += formatex(buffer[len],1023-len, "%d. Move to next entry: %d^n",++key,get_next_entry(id)+1)
len += formatex(buffer[len],1023-len, "%d. Move to previous entry: %d^n^n",++key,get_prev_entry(id)+1)

len += formatex(buffer[len],1023-len, "%d. Place a waypoint here: %d/%d^n",++key,numwaypoints[current],MAX_WAYPOINTS)
len += formatex(buffer[len],1023-len, "%d. Save waypoints^n",++key)
}
else {
len += formatex(buffer[len],1023-len, "#. Delete current entry^n")
len += formatex(buffer[len],1023-len, "#. Move to next entry: %d^n",get_next_entry(id)+1)
len += formatex(buffer[len],1023-len, "#. Move to previous entry: %d^n^n",get_prev_entry(id)+1)

len += formatex(buffer[len],1023-len, "#. Place a waypoint here: %d/%d^n",numwaypoints[current],MAX_WAYPOINTS)
len += formatex(buffer[len],1023-len, "#. Save waypoints^n")
}
len += formatex(buffer[len],1023-len, "0. Exit")

if(!hasmenu[id]) set_task(1.0,"update_pointers",id, "",0, "b")
hasmenu[id] = true

new menukeys = MENU_KEY_0
for(new i = 0; i < key; i++) menukeys |= (1<<i)
show_menu(id,menukeys,buffer)

static bool:direxists		//dont check if the dir existed before..
if(!direxists) {
static directory[128]
get_datadir(directory,127)
format(directory,127, "%s/waypoints",directory)
if(dir_exists(directory)) direxists = true
else client_print(id,print_chat, "[%s] Warning! Directory doesn't exist: %s",plugin,directory)
}
}

public action_wpmenu(id,key) {
new current = currentwp[id]
switch(key) {
case 0: numwaypoints[numentries] = 0, currentwp[id] = numentries++
case 1: {
remove_entry(current)
currentwp[id] = get_prev_entry(id)
}
case 2: currentwp[id] = get_next_entry(id)
case 3: currentwp[id] = get_prev_entry(id)
case 4: {
static origin[3]
new num = numwaypoints[current]++
get_user_origin(id,origin)
rvector_copy(origin,waypoints[current][num])
client_print(id,print_chat, "[%s] Placed waypoints #%d: %d %d %d",plugin,num+1,origin[0],origin[1],origin[2])
}
case 5: save_waypoints(id)
case 9: {
remove_task(id)
hasmenu[id] = false
return PLUGIN_HANDLED
}
}
openmenu(id)
return PLUGIN_HANDLED
}

public update_pointers(id) {
static origin[3], dest[3]
new current = currentwp[id], num = numwaypoints[current]
for(new i = 0; i < num; i++) {
rvector_copy(waypoints[current][i],origin)
message_begin(MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
write_byte(TE_BEAMPOINTS)		// temp entity event
write_coord(origin[0])			// startposition: x
write_coord(origin[1])			// startposition: y
write_coord(origin[2]-36)		// startposition: z
write_coord(origin[0])			// endposition: x
write_coord(origin[1])			// endposition: y
write_coord(origin[2]+36)		// endposition: z
write_short(spr_line)			// sprite index
write_byte(0)				// start frame
write_byte(0)				// framerate
write_byte(10)				// life in 0.1's
write_byte(15)				// line width in 0.1's
write_byte(0)				// noise amplitude in 0.01's
write_byte(0)				// color: red
write_byte(200)				// color: green
write_byte(0)				// color: blue
write_byte(200)				// brightness
write_byte(0)				// scroll speed in 0.1's
message_end()

if(i == num-1) rvector_copy(waypoints[current][0],dest)
else rvector_copy(waypoints[current][i+1],dest)

message_begin(MSG_ONE,SVC_TEMPENTITY,{0,0,0},id)
write_byte(TE_BEAMPOINTS)		// temp entity event
write_coord(origin[0])			// startposition: x
write_coord(origin[1])			// startposition: y
write_coord(origin[2]+25)			// startposition: z
write_coord(dest[0])			// endposition: x
write_coord(dest[1])			// endposition: y
write_coord(dest[2]+25)			// endposition: z
write_short(spr_line)			// sprite index
write_byte(0)				// start frame
write_byte(0)				// framerate
write_byte(10)				// life in 0.1's
write_byte(15)				// line width in 0.1's
write_byte(0)				// noise amplitude in 0.01's
write_byte(0)				// color: red
write_byte(0)				// color: green
write_byte(200)				// color: blue
write_byte(200)				// brightness
write_byte(0)				// scroll speed in 0.1's
message_end()
}
}

load_waypoints() {
numentries = -1
static text[32], len, orig[3][10], num
new fid = fopen(waypointfile,"rt")
while(!feof(fid)) {
len = fgets(fid, text,31)-1
if(len < 0 || text[0] == ';') continue
else if(text[len] == '^n') text[len] = 0

if(text[0] == '>') {
if(numentries > -1) numwaypoints[numentries] = num
numentries++, num = 0
}
else {
parse(text, orig[0],9, orig[1],9, orig[2],9)
waypoints[numentries][num][0] = str_to_num(orig[0])
waypoints[numentries][num][1] = str_to_num(orig[1])
waypoints[numentries][num++][2] = str_to_num(orig[2])
}
}
fclose(fid)
if(numentries > -1) numwaypoints[numentries++] = num
else numentries = 0
}

save_waypoints(id) {
static text[32], num, a, counter
new fid = fopen(waypointfile,"wt")
for(new i = 0; i < numentries; i++) {
formatex(text,31, "> #%d^n",i+1)
fprintf(fid,text)

num = numwaypoints[i]
for(a = 0; a < num; a++) {
formatex(text,31, "%d %d %d^n",waypoints[i][a][0],waypoints[i][a][1],waypoints[i][a][2])
fprintf(fid,text)
}
counter += num
}
fclose(fid)
client_print(id,print_chat, "[%s] Saved %d entries containing a total of %d waypoints",plugin,numentries,counter)
}

remove_entry(num) {
numentries--
static a, wpnum
for(new i = num; i < numentries; i++) {
wpnum = numwaypoints[i]
for(a = 0; a < wpnum; a++) rvector_copy(waypoints[i+1][a],waypoints[i][a])
}
}

stock get_next_entry(id) {
new next = currentwp[id]+1
if(next == numentries) next = 0
return next
}

stock get_prev_entry(id) {
new prev = currentwp[id]
return prev ? prev-1 : numentries-1
}

stock rvector_copy(input[3],output[3]) {
output[0] = input[0]
output[1] = input[1]
output[2] = input[2]
}

