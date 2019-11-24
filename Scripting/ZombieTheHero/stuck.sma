#include < amxmodx > 
#include < fakemeta > 
#include < hamsandwich > 

new g_iStucks[ 33 ]; 
new Float:g_flLastThink[ 33 ]; 

public plugin_init( ) { 
    register_forward( FM_PlayerPreThink, "FwdPlayerPreThink" ); 
} 

public FwdPlayerPreThink( id ) { 
    if( is_user_alive(id) ) { 
        static Float:flGametime; 
        flGametime = get_gametime( ); 
         
        if( g_flLastThink[ id ] < flGametime ) { 
            g_flLastThink[ id ] = flGametime + 0.2; 
             
            static Float:vOrigin[ 3 ]; 
            pev( id, pev_origin, vOrigin ); 
             
            if( IsUserStuck( id, vOrigin ) ) { 
                if( pev( id, pev_movetype ) != MOVETYPE_NOCLIP ) { 
                    if( ++g_iStucks[ id ] >= 7 ) { 
                        user_kill( id ); 
                    } 
                } 
            } else 
                g_iStucks[ id ] = 0; 
        } 
    } 
} 

IsUserStuck( id, const Float:vOrigin[ 3 ] ) { 
    engfunc( EngFunc_TraceHull, vOrigin, vOrigin, IGNORE_MONSTERS, pev( id, pev_flags ) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN, id, 0 ); 
     
    return get_tr2( 0, TR_StartSolid ); 
}  