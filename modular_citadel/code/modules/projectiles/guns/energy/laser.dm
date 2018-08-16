/obj/item/gun/energy/laser
	name = "blaster rifle"
	desc = "a high energy particle blaster, efficient and deadly."
	icon = 'modular_citadel/icons/obj/guns/OVERRIDE_energy.dmi'
	ammo_x_offset = 1
	shaded_charge = 1
	lefthand_file = 'modular_citadel/icons/mob/inhands/OVERRIDE_guns_lefthand.dmi'
	righthand_file = 'modular_citadel/icons/mob/inhands/OVERRIDE_guns_righthand.dmi'

/obj/item/gun/energy/laser/practice
	icon_state = "laser-p"

/obj/item/gun/energy/laser/bluetag
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'

/obj/item/gun/energy/laser/redtag
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	
/obj/item/gun/energy/laser/carbine
	name = "VGS blaster carbine"
	desc = "A ruggedized laser carbine featuring much higher capacity and improved handling when compared to a normal blaster carbine."
	icon = 'modular_citadel/icons/obj/guns/cit_guns.dmi'
	icon_state = "lasernew"
	item_state = "laser"
	force = 10
	throwforce = 10
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)
	cell_type = /obj/item/stock_parts/cell/lascarbine

/obj/item/gun/energy/laser/carbine/nopin
	pin = null

/obj/item/stock_parts/cell/lascarbine
	name = "laser carbine power supply"
	maxcharge = 2500

/datum/design/lasercarbine
	name = "VGS Blaster Carbine"
	desc = "Beefed up version of a normal blaster carbine."
	id = "lasercarbine"
	build_type = PROTOLATHE
	materials = list(MAT_GOLD = 2500, MAT_METAL = 5000, MAT_GLASS = 5000)
	build_path = /obj/item/gun/energy/laser/carbine/nopin
	category = list("Weapons")