/obj/item/gun/energy/yellowdiamond
	name = "taser gun"
	desc = "Instantly poof any gem."
	icon_state = "taser"
	item_state = ""
	cell_type = "/obj/item/stock_parts/cell/infinite"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/yellowdiamond)
	item_flags = DROPDEL

/obj/item/gun/energy/yellowdiamond/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/datum/action/innate/gem/weapon/destabilize
	name = "Destabilize Blast"
	desc = "Instantly poof any gem."
	weapon_type = /obj/item/gun/energy/yellowdiamond