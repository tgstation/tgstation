/obj/machinery/rnd/production/protolathe
	name = "protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/protolathe
	categories = list(
								RND_CATEGORY_POWER_DESIGNS,
								RND_CATEGORY_MEDICAL_DESIGNS,
								RND_CATEGORY_BLUESPACE_DESIGNS,
								RND_CATEGORY_STOCK_PARTS,
								RND_CATEGORY_EQUIPMENT,
								RND_CATEGORY_TOOL_DESIGNS,
								RND_CATEGORY_MINING_DESIGNS,
								RND_CATEGORY_ELECTRONICS,
								RND_CATEGORY_WEAPONS,
								RND_CATEGORY_AMMO,
								RND_CATEGORY_FIRING_PINS,
								RND_CATEGORY_COMPUTER_PARTS,
								RND_CATEGORY_CIRCUITRY
								)
	production_animation = "protolathe_n"
	allowed_buildtypes = PROTOLATHE

/obj/machinery/rnd/production/protolathe/deconstruct(disassembled)
	log_game("Protolathe of type [type] [disassembled ? "disassembled" : "deconstructed"] by [key_name(usr)] at [get_area_name(src, TRUE)]")

	return ..()

/obj/machinery/rnd/production/protolathe/Initialize(mapload)
	if(!mapload)
		log_game("Protolathe of type [type] constructed by [key_name(usr)] at [get_area_name(src, TRUE)]")

	return ..()

/// Special subtype protolathe for offstation use. Has a more limited available design selection.
/obj/machinery/rnd/production/protolathe/offstation
	name = "ancient protolathe"
	desc = "Converts raw materials into useful objects. Its ancient construction may limit its ability to print all known technology."
	circuit = /obj/item/circuitboard/machine/protolathe/offstation
	allowed_buildtypes = AWAY_LATHE
	charges_tax = FALSE
