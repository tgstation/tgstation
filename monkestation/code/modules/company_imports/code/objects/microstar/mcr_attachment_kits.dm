/obj/item/storage/secure/briefcase/white/mcr_loadout
	name = "Microfusion Attachment Kit"

/obj/item/storage/secure/briefcase/white/mcr_loadout/hellfire

/obj/item/storage/secure/briefcase/white/mcr_loadout/hellfire/PopulateContents()
	var/static/items_inside = list(
		/obj/item/microfusion_gun_attachment/barrel/hellfire = 1,
		/obj/item/microfusion_gun_attachment/rail = 1,
		/obj/item/microfusion_gun_attachment/grip = 1,
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/secure/briefcase/white/mcr_loadout/scatter

/obj/item/storage/secure/briefcase/white/mcr_loadout/scatter/PopulateContents()
	var/static/items_inside = list(
		/obj/item/microfusion_gun_attachment/barrel/scatter = 1,
		/obj/item/microfusion_gun_attachment/rail = 1,
		/obj/item/microfusion_gun_attachment/grip = 1,
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/secure/briefcase/white/mcr_loadout/lance

/obj/item/storage/secure/briefcase/white/mcr_loadout/lance/PopulateContents()
	var/static/items_inside = list(
		/obj/item/microfusion_gun_attachment/barrel/lance = 1,
		/obj/item/microfusion_gun_attachment/scope = 1,
		/obj/item/microfusion_gun_attachment/heatsink = 1,
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/secure/briefcase/white/mcr_loadout/repeater

/obj/item/storage/secure/briefcase/white/mcr_loadout/repeater/PopulateContents()
	var/static/items_inside = list(
		/obj/item/microfusion_gun_attachment/barrel/repeater = 1,
		/obj/item/microfusion_gun_attachment/rail = 1,
		/obj/item/microfusion_gun_attachment/heatsink = 1,
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/secure/briefcase/white/mcr_loadout/tacticool

/obj/item/storage/secure/briefcase/white/mcr_loadout/tacticool/PopulateContents()
	var/static/items_inside = list(
		/obj/item/microfusion_gun_attachment/barrel/suppressor = 1,
		/obj/item/microfusion_gun_attachment/rail = 1,
		/obj/item/microfusion_gun_attachment/grip = 1,
		/obj/item/microfusion_gun_attachment/camo = 1,
		)
	generate_items_inside(items_inside,src)

// Phase emitter and cell upgrades

/obj/item/storage/secure/briefcase/white/mcr_parts
	name = "Microfusion Parts Kit"

/obj/item/storage/secure/briefcase/white/mcr_parts/enhanced

/obj/item/storage/secure/briefcase/white/mcr_parts/enhanced/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stock_parts/cell/microfusion/enhanced = 1,
		/obj/item/microfusion_phase_emitter/enhanced = 1,
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/secure/briefcase/white/mcr_parts/advanced

/obj/item/storage/secure/briefcase/white/mcr_parts/advanced/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stock_parts/cell/microfusion/advanced = 1,
		/obj/item/microfusion_phase_emitter/advanced = 1,
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/secure/briefcase/white/mcr_parts/bluespace

/obj/item/storage/secure/briefcase/white/mcr_parts/bluespace/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stock_parts/cell/microfusion/bluespace = 1,
		/obj/item/microfusion_phase_emitter/bluespace = 1,
		)
	generate_items_inside(items_inside,src)
