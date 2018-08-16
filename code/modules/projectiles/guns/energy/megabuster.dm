/obj/item/gun/energy/megabuster
	name = "Mega-buster"
	desc = "An arm-mounted buster toy!"
	icon_state = "megabuster"
	item_state = "megabuster"
	w_class = WEIGHT_CLASS_SMALL
	ammo_type = list(/obj/item/ammo_casing/energy/megabuster)
	clumsy_check = FALSE
	item_flags = NEEDS_PERMIT
	selfcharge = TRUE
	cell_type = "/obj/item/stock_parts/cell/pulse"
	icon = 'modular_citadel/icons/obj/guns/VGguns.dmi'

/obj/item/gun/energy/megabuster/proto
	name = "Proto-buster"
	icon_state = "protobuster"
	item_state = "protobuster"

/obj/item/gun/energy/mmlbuster
	name = "Buster Cannon"
	desc = "An antique arm-mounted buster cannon."
	icon = 'modular_citadel/icons/obj/guns/VGguns.dmi'
	icon_state = "mmlbuster"
	item_state = "mmlbuster"
	w_class = WEIGHT_CLASS_SMALL
	ammo_type = list(/obj/item/ammo_casing/energy/buster)
	ammo_x_offset = 2