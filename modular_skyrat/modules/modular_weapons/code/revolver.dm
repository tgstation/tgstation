////////////////////////
//ID: MODULAR_WEAPONS //
////////////////////////

///////////////
// REVOLVERS //
///////////////
//		Revolving rifles! We have three versions. An improvised slower firing one, a normal one, and a golden premium one.
//		The gold rifle uses .45, it's only 5 more points of damage unfortunately. Fun hint: A box of .45 bullets functions the same as a speedloader.
//

/obj/item/gun/ballistic/revolver/rifle
	name = "\improper .38 Revolving Rifle"
	desc = "A revolving rifle chambered in .38. "
	icon = 'modular_skyrat/modules/modular_weapons/icons/obj/guns/projectile40x32.dmi'
	icon_state = "revolving-rifle"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38	//This is just a detective's revolver but it's too big for bags..
	pixel_x = -4	// It's centred on a 40x32 pixel spritesheet.
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY // The entire purpose of this is that it's a bulky rifle instead of a revolver.
	slot_flags = ITEM_SLOT_BELT
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	lefthand_file = 'modular_skyrat/modules/modular_weapons/icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'modular_skyrat/modules/modular_weapons/icons/mob/inhands/weapons/64x_guns_right.dmi'
	pixel_x = -8
	inhand_icon_state = "revolving"
	company_flag = COMPANY_IZHEVSK
	dirt_modifier = 0.75

/obj/item/gun/ballistic/revolver/rifle/improvised
	name = "\improper Improvised .38 Revolving Rifle"
	desc = "A crudely made revolving rifle. It fires .38 rounds. The cylinder doesn't rotate very well."
	icon_state = "revolving-rifle"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38	//TAs far as improvised weapons go, this is fairly decent, this isn't half bad.
	fire_delay = 15
	recoil = 1
	company_flag = null

/obj/item/gun/ballistic/revolver/rifle/gold
	name = "\improper .45 Revolving Rifle"
	desc = "A gold trimmed revolving rifle! It fires .45 bullets."
	icon_state = "revolving-rifle-gold"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev45	//Gold! We're using .45 because TG's 10mm does 40 damage, this does 30.
	w_class = WEIGHT_CLASS_BULKY
	inhand_icon_state = "revolving_gold"

// .45 Cylinder

/obj/item/ammo_box/magazine/internal/cylinder/rev45
	name = "revolver .45 cylinder"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = list(".45")
	max_ammo = 6
