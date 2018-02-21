
SUBSYSTEM_DEF(research)
	name = "Research"
	flags = SS_KEEP_TIMING
	priority = FIRE_PRIORITY_RESEARCH
	wait = 10
	init_order = INIT_ORDER_RESEARCH
	var/list/invalid_design_ids = list()		//associative id = number of times
	var/list/invalid_node_ids = list()			//associative id = number of times
	var/list/invalid_node_boost = list()		//associative id = error message
	var/list/obj/machinery/rnd/server/servers = list()
	var/datum/techweb/science/science_tech
	var/datum/techweb/admin/admin_tech
	var/list/techweb_nodes = list()				//associative id = node datum
	var/list/techweb_categories = list()		//category name = list(node.id = node)
	var/list/techweb_designs = list()			//associative id = node datum
	var/list/techweb_nodes_starting = list()	//associative id = node datum
	var/list/techweb_boost_items = list()		//associative double-layer path = list(id = point_discount)
	var/list/techweb_nodes_hidden = list()		//Nodes that should be hidden by default.
	var/list/techweb_point_items = list()		//path = value
	var/list/errored_datums = list()
	//----------------------------------------------
	var/single_server_income = 54.3
	var/multiserver_calculation = FALSE
	var/last_income = 0
	//^^^^^^^^ ALL OF THESE ARE PER SECOND! ^^^^^^^^

	//Aiming for 1.5 hours to max R&D
	//[88nodes * 5000points/node] / [1.5hr * 90min/hr * 60s/min]
	//Around 450000 points max???

	var/bomb_research_point_scaling = 1800

/datum/controller/subsystem/research/Initialize()
	initialize_all_techweb_designs()
	initialize_all_techweb_nodes()
	science_tech = new /datum/techweb/science
	admin_tech = new /datum/techweb/admin
	autosort_categories()
	return ..()

/datum/controller/subsystem/research/fire()
	handle_research_income()

/datum/controller/subsystem/research/proc/handle_research_income()
	var/bitcoins = 0
	if(multiserver_calculation)
		var/eff = calculate_server_coefficient()
		for(var/obj/machinery/rnd/server/miner in servers)
			bitcoins += (miner.mine() * eff)	//SLAVE AWAY, SLAVE.
	else
		for(var/obj/machinery/rnd/server/miner in servers)
			if(miner.working)
				bitcoins = single_server_income
				break			//Just need one to work.
	var/income_time_difference = world.time - last_income
	science_tech.last_bitcoins = bitcoins  // Doesn't take tick drift into account
	bitcoins *= income_time_difference / 10
	science_tech.research_points += bitcoins
	last_income = world.time

/datum/controller/subsystem/research/proc/calculate_server_coefficient()	//Diminishing returns.
	var/amt = servers.len
	if(!amt)
		return 0
	var/coeff = 100
	coeff = sqrt(coeff / amt)
	return coeff

/datum/controller/subsystem/research/proc/autosort_categories()
	for(var/i in techweb_nodes)
		var/datum/techweb_node/I = techweb_nodes[i]
		if(techweb_categories[I.category])
			techweb_categories[I.category][I.id] = I
		else
			techweb_categories[I.category] = list(I.id = I)
