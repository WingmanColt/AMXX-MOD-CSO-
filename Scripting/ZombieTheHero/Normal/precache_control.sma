#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>

#define MAPSETTINGS 0

new ConfigDirectory[] = "precacheControl"
new WeaponsDirectory[] = "weapons"

new ConfigPath[200]
new WeaponsPath[200]

const MaxFilenameLength = 100

new Array:C4Entries

enum Cvar 
{
CvarC4,
CvarCZ,
CvarHL,
CvarWeapons
}

new CvarSuffixes[Cvar][] = 
{
"c4",
"cz",
"hl",
"weapons"
}

new CvarPrefix[] = "precache_"

new Cvars[Cvar]

new HamHook:SpawnBombsiteHook1
new HamHook:SpawnBombsiteHook2

new Trie:BlockedEntries

validPathOrDie(path[])
{
if(!dir_exists(path))
{
set_fail_state("Plugin installation problem. You don't have the configuration folders in place")
}
}

Array:getFileEntries(file[],bool:isWeapon=false)
{
static path[200]

formatex(path,charsmax(path),"%s%s.ini",isWeapon ? WeaponsPath : ConfigPath , file)

if(!file_exists(path))
{
set_fail_state("Plugin installation problem. You don't have the configuration files in place")
}

new file = fopen(path,"r")

if(file)
{
new Array:array = ArrayCreate(MaxFilenameLength)

new line[MaxFilenameLength+1]

while(fgets(file,line,charsmax(line)))
{
trim(line)

ArrayPushString(array,line)
}

fclose(file)

return array
}
else
{
static msg[200]
formatex(msg,charsmax(msg),"Failed to open file [%s]",path)
set_fail_state(msg)
}

return Array:0
}

blockEntries(Array:array)
{
new entryData[MaxFilenameLength]

for(new i=0;i<ArraySize(array);i++)
{
ArrayGetString(array,i,entryData,charsmax(entryData))

TrieSetCell(BlockedEntries,entryData,true)
}
}

handleFolders()
{
get_configsdir(ConfigPath,charsmax(ConfigPath))
format(ConfigPath,charsmax(ConfigPath),"%s/%s/",ConfigPath,ConfigDirectory)

validPathOrDie(ConfigPath)

formatex(WeaponsPath,charsmax(WeaponsPath),"%s%s/",ConfigPath,WeaponsDirectory)

validPathOrDie(WeaponsPath)
}

handleCvars()
{
new FullCvar[charsmax(CvarPrefix) + 10]

new at = copy(FullCvar,charsmax(FullCvar),CvarPrefix)

for(new Cvar:i=Cvar:0;i<Cvar;i++)
{
formatex(FullCvar[at],charsmax(FullCvar) - at,CvarSuffixes[i])

Cvars[i] = !!get_pcvar_num(register_cvar(FullCvar,"0"))
}
}

blockWeapons()
{
new path[200]

get_configsdir(path,charsmax(path))

#if MAPSETTINGS
new mapname[32]
get_mapname(mapName,charsmax(mapName))
format(path,charsmax(path),"%s/weaprest_%s.ini",path, mapname)
#else
format(path,charsmax(path),"%s/weaprest.ini",path)
#endif

new file = fopen(path,"r")

if(file)
{
new line[100]

while(fgets(file,line,charsmax(line)))
{
trim(line)

if(line[0] && line[0] != ';')
{
new spaceIndex = contain(line," ")
line[spaceIndex] = 0

blockEntries(getFileEntries(line,true))
}
}

fclose(file)
}
}

public plugin_precache()
{
BlockedEntries = TrieCreate()

handleFolders()	
handleCvars()	

if(!Cvars[CvarCZ])
{
blockEntries(getFileEntries("cz"))
}

if(!Cvars[CvarHL])
{
blockEntries(getFileEntries("hl"))
}

if(!Cvars[CvarC4])
{
blockEntries(C4Entries = getFileEntries("c4",true))

SpawnBombsiteHook1 = RegisterHam(Ham_Spawn,"func_bomb_target","precacheBombsite")
SpawnBombsiteHook2 = RegisterHam(Ham_Spawn,"info_bomb_target","precacheBombsite")
}	

if(!Cvars[CvarWeapons])
{
blockWeapons()
}

register_forward(FM_PrecacheModel,"precache")
register_forward(FM_PrecacheSound,"precache")
}

public precacheBombsite()
{	
new entryData[MaxFilenameLength]

for(new i=0;i<ArraySize(C4Entries);i++)
{
ArrayGetString(C4Entries,i,entryData,charsmax(entryData))

new len = strlen(entryData)

new soundExtension[] = ".wav"

new extensionIndex = len - charsmax(soundExtension)

if(extensionIndex > 0)
{
if(equal(entryData[extensionIndex],soundExtension))
{
engfunc(EngFunc_PrecacheSound,entryData)
}
else
{
engfunc(EngFunc_PrecacheModel,entryData)
}			
}
}

DisableHamForward(SpawnBombsiteHook1)
DisableHamForward(SpawnBombsiteHook2)
}

public precache(data[])
{
if(TrieKeyExists(BlockedEntries,data))
{
return FMRES_SUPERCEDE
}

return FMRES_IGNORED
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
