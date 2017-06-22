
SUBSYSTEM_DEF(research)
	name = "Research"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_RESEARCH
	var/list/invalid_design_ids = list()
	var/list/invalid_node_ids = list()
	var/list/obj/machinery/rnd/server/servers = list()
	var/datum/techweb/science/science_tech
	var/datum/techweb/admin/admin_tech
	var/list/techweb_nodes = list()
	var/list/techweb_designs = list()
	var/list/techweb_nodes_starting = list()
	var/list/techweb_boost_items = list()

/datum/controller/subsystem/research/Initialize()
	initialize_all_techweb_designs()
	initialize_all_techweb_nodes()
	science_tech = new /datum/techweb/science
	admin_tech = new /datum/techweb/admin
	return ..()

/datum/controller/subsystem/research/process()
	handle_research_income()

/datum/controller/subsystem/research/proc/handle_research_income()
	var/bitcoins = 0
	var/eff = calculate_server_coefficient()
	for(var/obj/machinery/rnd/server/miner in servers)
		bitcoins += (miner.mine() * eff)	//SLAVE AWAY, SLAVE.
	science_tech.research_points += (bitcoins / 10)

/datum/controller/subsystem/research/proc/calculate_server_coefficient()	//Diminishing returns.
	var/amt = servers.len
	var/coeff = 100
	coeff = sqrt(coeff / amt)
	return coeff
