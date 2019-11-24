#include <amxmodx>
#include <ZombieMod5>

/*
new const sound[][] =
{			
"ZB5/zombi_infected1.wav", 
"ZB5/zombi_infected2.wav"
}*/
new const models[][] =
{	
"models/ZB5/Primary/p_primary_19032017.mdl",	
"models/ZB5/Primary/w_primary_19032017.mdl",		
"models/ZB5/Pistols/p_secondary_19032017.mdl",
"models/ZB5/Pistols/w_secondary_19032017.mdl",	
"models/ZB5/Items/ZB5_Items_NEW.mdl",
"models/ZB5/Items/crystal.mdl",
"models/rpgrocket.mdl"
}

public plugin_precache()
{ 	
for(new i = 0; i < sizeof(models); i++)
PrecacheModel(models[i])
}
