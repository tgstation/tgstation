//Energy guns with swappable, rechargable, magazines.

/obj/item/ammo_box/magazine/recharge
 	name = "power pack"
 	desc = "A rechargeable, detachable battery that serves as a magazine for laser rifles."
 	icon_state = "oldrifle-20"
 	ammo_type = /obj/item/ammo_casing/caseless/laser
 	caliber = "laser"
 	max_ammo = 20

/obj/item/ammo_box/magazine/recharge/update_icon()
	desc = "[initial(desc)] It has [stored_ammo.len] shot\s left."
	icon_state = "oldrifle-[round(ammo_count(),4)]"


/obj/item/ammo_casing/caseless/laser
 	name = "laser casing"
 	desc = "You shouldn't be seeing this."
 	caliber = "laser"
 	icon_state = "s-casing-live"
 	projectile_type = /obj/item/projectile/beam
 	fire_sound = 'sound/weapons/Laser.ogg'


/obj/item/ammo_box/magazine/recharge/attack_self() //No popping out the "bullets"
 	return



/obj/item/weapon/gun/projectile/automatic/laser
	name = "laser rifle"
	desc = "Though sometimes mocked for the relatively weak firepower of their energy weapons, the logistic miracle of rechargable ammunition has given Nanotrasen a decisive edge over many a foe."
	icon_state = "oldrifle"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/recharge
	fire_delay = 2
	can_suppress = 0
	burst_size = 0
	actions_types = list()
	fire_sound = 'sound/weapons/Laser.ogg'

/obj/item/weapon/gun/projectile/automatic/laser/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()


/obj/item/weapon/gun/projectile/automatic/laser/update_icon()
	..()
	icon_state = "oldrifle[magazine ? "-[Ceiling(get_ammo(0)/4)*4]" : ""]"
	return