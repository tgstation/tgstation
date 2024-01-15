/obj/item/gun/microfusion/mcr01
	name = "MCR-01"
	desc = "An advanced, modular energy weapon produced by Micron Control Systems. These cutting edge weapons differ from traditional beam weaponry in producing individual bolts, as well as being customizable to the user's preferences."
	icon_state = "mcr01"
	inhand_icon_state = "mcr01"
	shaded_charge = TRUE

/obj/item/gun/microfusion/mcr01/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_MICRON)

/// Gun for cargo crates.
/obj/item/gun/microfusion/mcr01/advanced
	name = "advanced MCR-01"
	cell_type = /obj/item/stock_parts/cell/microfusion/advanced
	phase_emitter_type = /obj/item/microfusion_phase_emitter/advanced

/* THESE ARE STILL UTTERLY BROKEN
/obj/item/gun/microfusion/mcr01/nanocarbon
	name = "Nanocarbon Destroyer"
	desc = "The pinnacle of the Nanocarbon weapon line. This weapon is the ultimate in power and performance. It is capable of firing a wide variety of beams, including a wide range of energy types, and is capable of firing a wide variety of frequencies."
	icon_state = "mcr01"
	inhand_icon_state = "mcr01"
	shaded_charge = TRUE
	phase_emitter_type = /obj/item/microfusion_phase_emitter/nanocarbon
	cell_type = /obj/item/stock_parts/cell/microfusion/nanocarbon
	attachments = list(
		/obj/item/microfusion_gun_attachment/pulse,
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/rail,
		/obj/item/microfusion_gun_attachment/camo,
	)

//For syndicate uplink.
/obj/item/gun/microfusion/mcr01/syndie
	name = "SCR-01"
	desc = "A Syndicate brand copy of the MCR-01. It comes with a proprietary suppressor and some tactical attachments."
	cell_type = /obj/item/stock_parts/cell/microfusion/advanced
	phase_emitter_type = /obj/item/microfusion_phase_emitter/advanced
	attachments = list(
		/obj/item/microfusion_gun_attachment/barrel/suppressor,
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/rail,
		/obj/item/microfusion_gun_attachment/syndi_camo,
	)
*/

/*
*	MICROFUSION SPAWNERS
*/

/obj/effect/spawner/armory_spawn/microfusion
	guns = list(
		/obj/item/gun/microfusion/mcr01,
		/obj/item/gun/microfusion/mcr01,
		/obj/item/gun/microfusion/mcr01,
		/obj/item/gun/microfusion/mcr01,
	)

