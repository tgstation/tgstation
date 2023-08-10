/obj/item/ammo_box/magazine/recharge
	name = "power pack"
	desc = "A rechargeable, detachable battery that serves as a magazine for laser rifles."
	icon_state = "oldrifle-20"
	base_icon_state = "oldrifle"
	ammo_type = /obj/item/ammo_casing/laser
	caliber = CALIBER_LASER
	max_ammo = 20

/obj/item/ammo_box/magazine/recharge/update_desc()
	. = ..()
	desc = "[initial(desc)] It has [stored_ammo.len] shot\s left."

/obj/item/ammo_box/magazine/recharge/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]-[round(ammo_count(), 4)]"

/obj/item/ammo_box/magazine/recharge/attack_self() //No popping out the "bullets"
	return
