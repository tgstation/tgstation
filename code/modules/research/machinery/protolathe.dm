/obj/machinery/rnd/production/protolathe
	name = "protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/protolathe
	categories = list(
		CATEGORY_POWER_DESIGNS = list(),
		CATEGORY_MEDICAL_DESIGNS = list(),
		CATEGORY_BLUESPACE_DESIGNS = list(),
		CATEGORY_STOCK_PARTS = list(
			CATEGORY_TIER_MATERIALS,
			CATEGORY_TIER_BLUESPACE,
			CATEGORY_TIER_SUPER,
			CATEGORY_TIER_ADVANCED,
			CATEGORY_TIER_BASIC,
			CATEGORY_TIER_TELECOMS
		),
		CATEGORY_EQUIPMENT = list(),
		CATEGORY_TOOL_DESIGNS = list(),
		CATEGORY_MINING_DESIGNS = list(),
		CATEGORY_ELECTRONICS = list(),
		CATEGORY_WEAPONS = list(),
		CATEGORY_AMMO = list(),
		CATEGORY_FIRING_PINS = list(),
		CATEGORY_COMPUTER_PART = list()
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

