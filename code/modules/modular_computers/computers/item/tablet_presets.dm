/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	starting_programs = list(
		/datum/computer_file/program/ntnetdownload/syndicate,
		/datum/computer_file/program/radar/fission360,
	)

/obj/item/modular_computer/tablet/nukeops/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
