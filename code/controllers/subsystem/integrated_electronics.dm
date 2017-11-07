SUBSYSTEM_DEF(integrated_electronics)
	name = "integrated electronics"
	flags = SS_NO_FIRE

/datum/controller/subsystem/Initialize(start_timeofday)
	initialize_integrated_circuits_list()
	return ..()