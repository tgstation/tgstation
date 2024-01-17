/datum/supply_pack/security/armory/mcr01
	name = "MCR-01 Microfusion Crate"
	desc = "Micron Control Systems Incorporated supplied MCR-01 Microfusion weapons platform. Comes with 4 advanced guns!"
	cost = CARGO_CRATE_VALUE * 20
	contains = list(
		/obj/item/gun/microfusion/mcr01/advanced,
		/obj/item/gun/microfusion/mcr01/advanced,
		/obj/item/gun/microfusion/mcr01/advanced,
		/obj/item/gun/microfusion/mcr01/advanced,
	)
	crate_name = "MCR-01 Microfusion Crate"

/datum/supply_pack/security/microfusion
	name = "Assorted Microfusion Upgrade Crate"
	desc = "Micron Control Systems Incorporated supplied Microfusion cells and emitters!"
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/microfusion_phase_emitter/advanced,
		/obj/item/microfusion_phase_emitter/advanced,
		/obj/item/stock_parts/cell/microfusion/advanced,
		/obj/item/stock_parts/cell/microfusion/advanced,
	)
	crate_name = "Microfusion Upgrade Crate"

/datum/supply_pack/security/mcr01_attachments_a
	name = "MCR-01 Military Attachments Crate Type A"
	desc = "Micron Control Systems Incorporated supplied MCR-01 Military spec attachments! This crate comes with two utilitarian repeater loadout."
	cost = CARGO_CRATE_VALUE * 14
	contains = list(
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/rail,
		/obj/item/microfusion_gun_attachment/rail,
		/obj/item/microfusion_gun_attachment/barrel/repeater,
		/obj/item/microfusion_gun_attachment/barrel/repeater,
	)
	crate_name = "MCR-01 Military Attachments Crate Type A"

/datum/supply_pack/security/mcr01_attachments_type_b
	name = "MCR-01 Military Attachments Crate Type B"
	desc = "Micron Control Systems Incorporated supplied MCR-01 Military spec attachments! This crate comes in a mixed specialist loadout."
	cost = CARGO_CRATE_VALUE * 16
	contains = list(
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/barrel/scatter,
		/obj/item/microfusion_gun_attachment/barrel/scatter,
		/obj/item/microfusion_gun_attachment/barrel/scatter,
		/obj/item/microfusion_gun_attachment/scope,
		/obj/item/microfusion_gun_attachment/barrel/lance,
	)
	crate_name = "MCR-01 Military Attachments Crate Type B"


/datum/supply_pack/security/mcr01_attachments_h
	name = "HCR-01 Military Attachments Crate Type H"
	desc = "Honkicron Clownery Systems Inhonkorated supplied HCR-01 Clownery spec attachments! This crate oddly smells of bananas."
	cost = CARGO_CRATE_VALUE * 20
	contraband = TRUE
	contains = list(
		/obj/item/microfusion_gun_attachment/barrel/honk,
		/obj/item/microfusion_gun_attachment/barrel/honk,
		/obj/item/microfusion_gun_attachment/barrel/honk,
		/obj/item/microfusion_gun_attachment/camo/honk,
		/obj/item/microfusion_gun_attachment/camo/honk,
		/obj/item/microfusion_gun_attachment/camo/honk,
		/obj/item/food/pie/cream,
		/obj/item/food/pie/cream,
		/obj/item/food/pie/cream,
	)
	crate_name = "MCR-01 Military Attachments Crate Type H"
