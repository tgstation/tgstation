/obj/item/modular_computer/laptop/preset/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))

/obj/item/modular_computer/laptop/preset/civilian
	desc = "A low-end laptop often used for personal recreation."
	starting_programs = list(
		/datum/computer_file/program/chatclient,
	)
