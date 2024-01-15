/// Proc that is overridden in /gun/ballistic and /gun/energy to attach the gun safety component to a gun
/obj/item/gun/proc/give_gun_safeties()
	return

// Ballistic Weapons

/obj/item/gun/ballistic/give_gun_safeties()
	AddComponent(/datum/component/gun_safety)

/obj/item/gun/ballistic/bow/give_gun_safeties()
	return

/obj/item/gun/ballistic/rifle/enchanted/give_gun_safeties()
	return

/obj/item/gun/ballistic/automatic/laser/ctf/give_gun_safeties()
	return

/obj/item/gun/ballistic/shotgun/ctf/give_gun_safeties()
	return

/obj/item/gun/ballistic/automatic/laser/ctf/marksman/give_gun_safeties()
	return

/obj/item/gun/ballistic/automatic/pistol/deagle/ctf/give_gun_safeties()
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/give_gun_safeties()
	return

// Energy Weapons

/obj/item/gun/energy/give_gun_safeties()
	AddComponent(/datum/component/gun_safety)

/obj/item/gun/energy/plasmacutter/give_gun_safeties()
	return

/obj/item/gun/energy/recharge/kinetic_accelerator/give_gun_safeties()
	return

// Syringe Guns

/obj/item/gun/syringe/blowgun/give_gun_safeties()
	return
