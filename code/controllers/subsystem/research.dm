
SUBSYSTEM_DEF(research)
	name = "Research"
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
	var/list/techweb_boost_items = list()		//associative double-layer path = list(id = list(point_type = point_discount))
	var/list/techweb_nodes_hidden = list()		//Nodes that should be hidden by default.
	var/list/techweb_point_items = list(		//path = list(point type = value)
	/obj/item/assembly/signaler/anomaly = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	)
	var/list/errored_datums = list()
	var/list/point_types = list()				//typecache style type = TRUE list
	//----------------------------------------------
	var/list/single_server_income = list(TECHWEB_POINT_TYPE_GENERIC = 54.3)
	var/multiserver_calculation = FALSE
	var/last_income
	//^^^^^^^^ ALL OF THESE ARE PER SECOND! ^^^^^^^^

	//Aiming for 1.5 hours to max R&D
	//[88nodes * 5000points/node] / [1.5hr * 90min/hr * 60s/min]
	//Around 450000 points max???

/datum/controller/subsystem/research/Initialize()
	point_types = TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES
	initialize_all_techweb_designs()
	initialize_all_techweb_nodes()
	science_tech = new /datum/techweb/science
	admin_tech = new /datum/techweb/admin
	autosort_categories()
	return ..()

/datum/controller/subsystem/research/fire()
	var/list/bitcoins = list()
	if(multiserver_calculation)
		var/eff = calculate_server_coefficient()
		for(var/obj/machinery/rnd/server/miner in servers)
			var/list/result = (miner.mine())	//SLAVE AWAY, SLAVE.
			for(var/i in result)
				result[i] *= eff
				bitcoins[i] = bitcoins[i]? bitcoins[i] + result[i] : result[i]
	else
		for(var/obj/machinery/rnd/server/miner in servers)
			if(miner.working)
				bitcoins = single_server_income.Copy()
				break			//Just need one to work.
	if (!isnull(last_income))
		var/income_time_difference = world.time - last_income
		science_tech.last_bitcoins = bitcoins  // Doesn't take tick drift into account
		for(var/i in bitcoins)
			bitcoins[i] *= income_time_difference / 10
		science_tech.add_point_list(bitcoins)
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
