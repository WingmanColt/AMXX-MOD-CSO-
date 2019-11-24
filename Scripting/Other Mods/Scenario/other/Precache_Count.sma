#include <amxmodx>
#include <orpheu>
#include <orpheu_stocks>

enum PrecacheData
{
Sound,
Model,
Generic
}

new g_iPrecacheCount[ PrecacheData ];

public plugin_init()
{
log_amx( "%i Sounds loaded, %i Models loaded, %i Generics loaded", g_iPrecacheCount[ Model ], g_iPrecacheCount[ Sound ], g_iPrecacheCount[ Generic ] );
}

public plugin_precache()
{
OrpheuRegisterHook( OrpheuGetEngineFunction( "pfnPrecacheSound", "PrecacheSound" ), "PrecacheSound" );
OrpheuRegisterHook( OrpheuGetEngineFunction( "pfnPrecacheModel", "PrecacheModel" ), "PrecacheModel" );
OrpheuRegisterHook( OrpheuGetEngineFunction( "pfnPrecacheGeneric", "PrecacheGeneric" ), "PrecacheGeneric" );
}

public PrecacheSound()
{
g_iPrecacheCount[ Sound ] ++;
}

public PrecacheModel()
{
g_iPrecacheCount[ Model ] ++;
}

public PrecacheGeneric()
{
g_iPrecacheCount[ Generic ] ++;
}
