SUBSYSTEM_DEF(research)
	name = "Research"
	priority = FIRE_PRIORITY_RESEARCH
	wait = 1 SECONDS
	dependencies = list(
		/datum/controller/subsystem/processing/station,
	)

	/// An associative list of techweb node typepaths to instances.
	var/list/techweb_nodes = list()
	/// An associative list of design typepaths to instances.
	var/list/techweb_designs = list()

	/// An associative list of item typepaths to a list of design typepaths that build that item
	/// e.g: [/obj/item/wrench --> [/datum/design/wrench...]]
	var/list/item_to_design = list()

	/// List of all techwebs, generating points or not.
	/// Autolathes, Mechfabs, and others all have shared techwebs, for example.
	var/list/datum/techweb/techwebs = list()

	/// A list of techweb node paths that all techwebs start with.
	var/list/techweb_nodes_starting = list()
	/// An associative list of item paths to a list of techweb nodes that depend on that item.
	/// e.g: [/obj/item/scalpel/alien --> [/datum/techweb_node/alien/base, /datum/techweb_node/alien/engi...]]
	var/list/techweb_unlock_items = list()
	/// A list of techweb node paths that are hidden by default. Associative for faster lookups.
	var/list/techweb_nodes_hidden = list()
	/// A list of techweb node paths that are exclusive to the BEPIS.
	var/list/techweb_nodes_experimental = list()
	/// An associative list of item paths to a list of points granted. Used in the destructive analyzer only.
	var/list/techweb_point_items = list(
		/obj/item/assembly/signaler/anomaly = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	)
	/// An associative list of all point types that techwebs will have and their respective 'abbreviated' name.
	/// If you introduce a new point type, ADD IT HERE AS WELL!
	var/list/point_types = list(TECHWEB_POINT_TYPE_GENERIC = "Gen. Res.")

	//----------------------------------------------
	var/list/single_server_income = list(
		TECHWEB_POINT_TYPE_GENERIC = TECHWEB_SINGLE_SERVER_INCOME,
	)
	//^^^^^^^^ ALL OF THESE ARE PER SECOND! ^^^^^^^^

	/// The global list of raw anomaly types that have been refined, for hard limits.
	var/list/created_anomaly_types = list()
	/// The hard limits of cores created for each anomaly type. For faster code lookup without switch statements.
	var/list/anomaly_hard_limit_by_type = list(
		/obj/item/assembly/signaler/anomaly/bluespace = MAX_CORES_BLUESPACE,
		/obj/item/assembly/signaler/anomaly/pyro = MAX_CORES_PYRO,
		/obj/item/assembly/signaler/anomaly/grav = MAX_CORES_GRAVITATIONAL,
		/obj/item/assembly/signaler/anomaly/vortex = MAX_CORES_VORTEX,
		/obj/item/assembly/signaler/anomaly/flux = MAX_CORES_FLUX,
		/obj/item/assembly/signaler/anomaly/hallucination = MAX_CORES_HALLUCINATION,
		/obj/item/assembly/signaler/anomaly/bioscrambler = MAX_CORES_BIOSCRAMBLER,
		/obj/item/assembly/signaler/anomaly/dimensional = MAX_CORES_DIMENSIONAL,
		/obj/item/assembly/signaler/anomaly/ectoplasm = MAX_CORES_ECTOPLASMIC,
		/obj/item/assembly/signaler/anomaly/weather = MAX_CORES_WEATHER,
	)

	/// Lookup list for ordnance briefers.
	var/list/datum/experiment/ordnance/ordnance_experiments = list()
	/// Lookup list for scipaper partners.
	var/list/datum/scientific_partner/scientific_partners = list()

/datum/controller/subsystem/research/Initialize()
	initialize_designs()
	initialize_nodes()
	initialize_ordnance_experiments()
	new /datum/techweb/science()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/research/fire()
	for(var/datum/techweb/techweb as anything in techwebs)
		if(!techweb.should_generate_points)
			continue

		// Point generation
		var/list/bitcoins = list()
		for(var/obj/machinery/rnd/server/miner as anything in techweb.techweb_servers)
			if(miner.working)
				bitcoins = single_server_income.Copy()
				break //Just need one to work.

		if(!isnull(techweb.last_income))
			var/income_time_difference = world.time - techweb.last_income
			techweb.last_bitcoins = bitcoins // Doesn't take tick drift into account
			for(var/point_type in bitcoins)
				bitcoins[point_type] *= (income_time_difference / 10) * techweb.income_modifier
			techweb.adjust_multiple_points(bitcoins)

		techweb.last_income = world.time

		// Research queue
		if(length(techweb.research_queue_nodes))
			techweb.research_node(techweb.research_queue_nodes[1]) // Attempt to research the first node in queue if possible

			for(var/node_path in techweb.research_queue_nodes)
				var/datum/techweb_node/node = techweb_nodes[node_path]
				if(node.is_free(techweb)) // Automatically research all free nodes in queue if any
					techweb.research_node(node)

/datum/controller/subsystem/research/proc/initialize_designs()
	for(var/datum/design/design_path as anything in valid_subtypesof(/datum/design))
		var/datum/design/new_design = new design_path()
		// This design doesn't want to exist. OK THEN!
		if(QDELING(new_design))
			continue

		var/build_path = design_path::build_path
		if(!isnull(build_path))
			LAZYADD(item_to_design[build_path], design_path)

		techweb_designs[design_path] = new_design

/datum/controller/subsystem/research/proc/initialize_nodes()
	for(var/datum/techweb_node/node_path as anything in valid_subtypesof(/datum/techweb_node))
		var/datum/techweb_node/new_node = new node_path()
		// This node doesn't want to exist. OK THEN!
		if(QDELING(new_node))
			continue

		if(new_node.node_flags & TECHWEB_NODE_STARTER)
			techweb_nodes_starting += node_path
		if(new_node.node_flags & TECHWEB_NODE_HIDDEN)
			techweb_nodes_hidden[node_path] = TRUE // assoc for speed
		if(new_node.node_flags & TECHWEB_NODE_EXPERIMENTAL)
			techweb_nodes_experimental += node_path

		// Tell our unlocked designs that we unlock them
		for(var/design_path in new_node.unlocked_designs)
			var/datum/design/unlocked_design = techweb_designs[design_path]
			unlocked_design.unlocked_by += node_path

		// Register that our required items unlock us
		for(var/required_item_path in new_node.required_items_to_unlock)
			LAZYADD(techweb_unlock_items[required_item_path], node_path)

		techweb_nodes[node_path] = new_node

	// We have to do this after the above loop to ensure everything has been initialized
	for(var/node_path, _node in techweb_nodes)
		var/datum/techweb_node/node = _node
		// Tell our prerequisite nodes that we are unlocked by them
		for(var/prerequisite_path in node.prerequisite_nodes)
			var/datum/techweb_node/prerequisite_node = techweb_nodes[prerequisite_path]
			LAZYADD(prerequisite_node.unlocked_nodes, node_path)

/datum/controller/subsystem/research/proc/initialize_ordnance_experiments()
	for (var/datum/experiment/ordnance/experiment_path as anything in subtypesof(/datum/experiment/ordnance))
		if (experiment_path::experiment_proper)
			ordnance_experiments += new experiment_path()

	for(var/partner_path in subtypesof(/datum/scientific_partner))
		var/datum/scientific_partner/partner = new partner_path
		if(!length(partner.accepted_experiments))
			for (var/datum/experiment/ordnance/ordnance_experiment as anything in ordnance_experiments)
				partner.accepted_experiments += ordnance_experiment.type
		scientific_partners += partner

/**
 * Goes through all techwebs and goes through their servers to find ones on a valid z-level
 * Returns the full list of all techweb servers.
 */
/datum/controller/subsystem/research/proc/get_available_servers(turf/location)
	var/list/local_servers = list()
	if(location)
		for (var/datum/techweb/individual_techweb as anything in techwebs)
			local_servers += find_valid_servers(location, individual_techweb)
	return local_servers

/**
 * Goes through an individual techweb's servers and finds one on a valid z-level
 * Returns a list of existing ones, or an empty list otherwise.
 * Args:
 * - checking_web - The techweb we're checking the servers of.
 */
/datum/controller/subsystem/research/proc/find_valid_servers(turf/location, datum/techweb/checking_web)
	var/list/valid_servers = list()
	for(var/obj/machinery/rnd/server/server as anything in checking_web.techweb_servers)
		if(!is_valid_z_level(get_turf(server), location))
			continue
		valid_servers += server
	return valid_servers

/// Returns true if you can make an anomaly core of the provided type
/datum/controller/subsystem/research/proc/is_core_available(core_type)
	if (!ispath(core_type, /obj/item/assembly/signaler/anomaly))
		return FALSE // The fuck are you checking this random object for?
	var/already_made = created_anomaly_types[core_type] || 0
	var/hard_limit = anomaly_hard_limit_by_type[core_type]
	return already_made < hard_limit

/// Increase our tracked number of cores of this type
/datum/controller/subsystem/research/proc/increment_existing_anomaly_cores(core_type)
	var/existing = created_anomaly_types[core_type] || 0
	created_anomaly_types[core_type] = existing + 1

/// Helper proc to turn an associative list of points into a more human readable format.
/proc/techweb_point_display_generic(list/point_list)
	var/list/ret = list()
	for(var/point_type, point_amount in point_list)
		ret += "[SSresearch.point_types[point_type] || "ERRORED POINT TYPE"]: [point_amount]"
	return ret.Join("<BR>")
