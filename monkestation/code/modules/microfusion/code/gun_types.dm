/obj/item/gun/microfusion/mcr01
	name = "MCR-01"
	desc = "An advanced, modular energy weapon produced by Allstar Lasers Incorporated. These cutting edge weapons differ from traditional beam weaponry in producing individual bolts, as well as utilizing hotswapped cells rather than being tied to immobile power sources."
	icon_state = "mcr01"
	inhand_icon_state = "mcr01"
	shaded_charge = TRUE

/// Gun for cargo crates.
/obj/item/gun/microfusion/mcr01/advanced
	name = "Advanced MCR-01"
	cell_type = /obj/item/stock_parts/cell/microfusion/advanced
	phase_emitter_type = /obj/item/microfusion_phase_emitter/advanced

/obj/item/gun/microfusion/mcr01/nanocarbon
	name = "Nanocarbon Destroyer"
	desc = "The pinnacle of the Nanocarbon weapon line. This weapon is the ultimate in power and performance. It is capable of firing a wide variety of beams, including a wide range of energy types, and is capable of firing a wide variety of frequencies."
	icon_state = "mcr01"
	inhand_icon_state = "mcr01"
	shaded_charge = TRUE

/obj/item/storage/box/ammo_box/microfusion/advanced
	name = "advanced microfusion cell container"
	desc = "A box filled with microfusion cells."

/obj/item/storage/box/ammo_box/microfusion/advanced/PopulateContents()
	new /obj/item/storage/bag/ammo(src)
	new /obj/item/stock_parts/cell/microfusion/advanced(src)
	new /obj/item/stock_parts/cell/microfusion/advanced(src)
	new /obj/item/stock_parts/cell/microfusion/advanced(src)

//////////////MICROFUSION SPAWNERS
/obj/effect/spawner/armory_spawn/microfusion
	icon_state = "random_rifle"
	gun_count = 4
	guns = list(
		/obj/item/gun/microfusion/mcr01,
		/obj/item/gun/microfusion/mcr01,
		/obj/item/gun/microfusion/mcr01,
		/obj/item/gun/microfusion/mcr01,
	)

