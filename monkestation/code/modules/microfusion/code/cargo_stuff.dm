/datum/supply_pack/security/armory/mcr01
	name = "MCR-01 Microfusion Crate"
	desc = "Micron Control Systems Incorporated supplied MCR-01 Microfusion weapons platform. Comes with 4 guns and 4 advanced cells!"
	cost = CARGO_CRATE_VALUE * 20
	contains = list(
		/obj/item/gun/microfusion/mcr01/advanced,
		/obj/item/gun/microfusion/mcr01/advanced,
		/obj/item/gun/microfusion/mcr01/advanced,
		/obj/item/gun/microfusion/mcr01/advanced,
		/obj/item/storage/box/ammo_box/microfusion/advanced,
		/obj/item/storage/box/ammo_box/microfusion/advanced,
		/obj/item/storage/box/ammo_box/microfusion/advanced,
		/obj/item/storage/box/ammo_box/microfusion/advanced,
	)
	crate_name = "MCR-01 Microfusion Crate"

/datum/supply_pack/security/microfusion
	name = "Assorted Microfusion Cell Crate"
	desc = "Micron Control Systems Incorporated supplied Microfusion cells and attachments!"
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/stock_parts/cell/microfusion/advanced,
		/obj/item/stock_parts/cell/microfusion/advanced,
		/obj/item/stock_parts/cell/microfusion/advanced,
		/obj/item/stock_parts/cell/microfusion/advanced,
		/obj/item/stock_parts/cell/microfusion/advanced,
		/obj/item/stock_parts/cell/microfusion/advanced,
		/obj/item/microfusion_cell_attachment/rechargeable,
		/obj/item/microfusion_cell_attachment/rechargeable,
		/obj/item/microfusion_cell_attachment/rechargeable,
		/obj/item/microfusion_cell_attachment/rechargeable,
		/obj/item/microfusion_cell_attachment/rechargeable,
		/obj/item/microfusion_cell_attachment/rechargeable,
	)
	crate_name = "Microfusion Cell Crate"

/datum/supply_pack/security/mcr01_attachments
	name = "MCR-01 Military Attachments Crate"
	desc = "Micron Control Systems Incorporated supplied MCR-01 Military spec attachments!"
	cost = CARGO_CRATE_VALUE * 15
	contains = list(
		/obj/item/microfusion_gun_attachment/scope,
		/obj/item/microfusion_gun_attachment/scope,
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/grip,
		/obj/item/microfusion_gun_attachment/rail,
		/obj/item/microfusion_gun_attachment/rail,
		/obj/item/microfusion_gun_attachment/repeater,
		/obj/item/microfusion_gun_attachment/repeater,
	)
	crate_name = "MCR-01 Military Attachments Crate"
