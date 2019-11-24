#if defined _zbs_shop_included
    #endinput
#endif

#define _zbs_shop_included

#if AMXX_VERSION_NUM >= 175
    #pragma reqlib zbs_shop
    #if !defined AMXMODX_NOAUTOLOAD
        #pragma loadlib zbs_shop
    #endif
#else
    #pragma library zbs_shop
#endif

native zbs_shop_item_add( const szName[ ], const iCost, const iLevel, const szHandler[ ] );