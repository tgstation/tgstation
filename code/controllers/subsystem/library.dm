SUBSYSTEM_DEF(library)
	name = "Library Loading"
	flags = SS_NO_FIRE

	var/list/shelves_to_load = list()

/datum/controller/subsystem/library/Initialize()
	. = ..()
	load_shelves()

/datum/controller/subsystem/library/proc/load_shelves()
	for(var/obj/structure/bookcase/case_to_load as anything in shelves_to_load)
		case_to_load.load_shelf()
	shelves_to_load = null
