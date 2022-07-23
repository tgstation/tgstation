/obj/machinery/rnd/production/protolathe
	name = "protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/protolathe
	categories = list(
								"Power Designs",
								"Medical Designs",
								"Bluespace Designs",
								"Stock Parts",
								"Equipment",
								"Tool Designs",
								"Mining Designs",
								"Electronics",
								"Weapons",
								"Ammo",
								"Firing Pins",
								"Computer Parts",
								"Circuitry"
								)
	production_animation = "protolathe_n"
	allowed_buildtypes = PROTOLATHE

/obj/machinery/rnd/production/protolathe/deconstruct(disassembled)
	usr.log_message("[disassembled ? "disassembled" : "deconstructed"] protolathe of type [type] at [get_area_name(src, TRUE)].", LOG_GAME)

	return ..()

/obj/machinery/rnd/production/protolathe/Initialize(mapload)
	if(!mapload)
		usr.log_message("constructed protolathe of type [type] at [get_area_name(src, TRUE)].", LOG_GAME)

	return ..()

/// Special subtype protolathe for offstation use. Has a more limited available design selection.
/obj/machinery/rnd/production/protolathe/offstation
	name = "ancient protolathe"
	desc = "Converts raw materials into useful objects. Its ancient construction may limit its ability to print all known technology."
	circuit = /obj/item/circuitboard/machine/protolathe/offstation
	allowed_buildtypes = AWAY_LATHE
	charges_tax = FALSE
