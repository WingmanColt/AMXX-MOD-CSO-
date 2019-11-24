#include <amxmodx>
#include <ZombieMod5>

new g_weapon[3]
public plugin_init()
{	
g_weapon[0] = zb5_register_weapon("AK-47", "Kalashnikov", WPN_RIFLES, 0, 0)
g_weapon[1] = zb5_register_weapon("M4A1", "Carabine", WPN_RIFLES, 0, 0)	
g_weapon[2] = zb5_register_weapon("Desert Eeagle", "1.50 R", WPN_PISTOLS, 0, 0)
}

public zb5_weapon_selected_post(id, wpnid)
{
if(wpnid == g_weapon[0]) Get_WPN(id, 1)
else if(wpnid == g_weapon[1]) Get_WPN(id, 2)
else if(wpnid == g_weapon[2]) Get_WPN(id, 3)
}
public Get_WPN(id, Weapon)
{
switch(Weapon)
{
case 1:
{
drop_weapons(id, 1);
	
fm_give_item(id, "weapon_ak47")	
cs_set_user_bpammo(id, CSW_AK47, 250)	
}
case 2:
{
drop_weapons(id, 1);
	
fm_give_item(id, "weapon_m4a1")
cs_set_user_bpammo(id, CSW_M4A1, 250)	
}
case 3:
{	
drop_weapons(id, 2);

fm_give_item(id, "weapon_deagle")
cs_set_user_bpammo(id, CSW_DEAGLE, 100)
}
}

}
