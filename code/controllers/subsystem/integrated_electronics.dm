SUBSYSTEM_DEF(integrated_electronics)
	name = "integrated electronics"
	flags = SS_NO_FIRE

/datum/controller/subsystem/integrated_electronics/Initialize(start_timeofday)
	initialize_integrated_circuits_list()
	return ..()

/proc/initialize_integrated_circuits_list()
	for(var/thing in typesof(/obj/item/integrated_circuit))
		GLOB.all_integrated_circuits += new thing()