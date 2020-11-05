/obj/machinery/rnd/production/protolathe
	name = "protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/protolathe
	categories = list(
		CATEGORY_POWER_DESIGNS,
		CATEGORY_MEDICAL_DESIGNS,
		CATEGORY_BLUESPACE_DESIGNS,
		CATEGORY_STOCK_PARTS,
		CATEGORY_EQUIPMENT,
		CATEGORY_TOOL_DESIGNS,
		CATEGORY_MINING_DESIGNS,
		CATEGORY_ELECTRONICS,
		CATEGORY_WEAPONS,
		CATEGORY_AMMO,
		CATEGORY_FIRING_PINS,
		CATEGORY_COMPUTER_PARTS,
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

