
SUBSYSTEM_DEF(research)
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_RESEARCH
	var/list/invalid_design_ids = list()
	var/list/invalid_node_ids = list()

/datum/controller/subsystem/research/Initialize()
	initialize_all_techweb_nodes()
	initialize_all_techweb_designs()
	return ..()
