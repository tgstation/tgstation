/obj/item/ammo_casing/rocket_rpg
	name = "rocket"
	desc = "Explosive supplement to the syndicate's rocket launcher."
	icon_state = "rpground"
	caliber = "rpg"
	projectile_type = "/obj/item/projectile/rocket"
	m_amt = 15000
	w_type = RECYK_METAL
	w_class = 3.0 // Rockets don't exactly fit in pockets and cardboard boxes last I heard, try your backpack

/obj/item/ammo_casing/rocket_rpg/update_icon()
	return
