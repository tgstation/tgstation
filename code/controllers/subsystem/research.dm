
SUBSYSTEM_DEF(research)
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_RESEARCH

/datum/controller/subsystem/research/Initialize()
	initialize_all_techweb_nodes()
	initialize_all_techweb_designs()
	return ..()
