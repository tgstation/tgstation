/**
 * # Techweb
 *
 * A datum representing a research techweb
 *
 * Techweb datums are meant to store unlocked research, being able to be stored
 * on research consoles, servers, and disks. They are NOT global.
 */
/datum/techweb
	/// Already unlocked and all designs are now available. Assoc list, id = TRUE
	var/list/researched_nodes = list()
	/// Visible nodes, doesn't mean it can be researched. Assoc list, id = TRUE
	var/list/visible_nodes = list()
	/// Nodes that can immediately be researched, all reqs met. assoc list, id = TRUE
	var/list/available_nodes = list()
	/// Designs that are available for use. Assoc list, id = TRUE
	var/list/researched_designs = list()
	/// Custom inserted designs like from disks that should survive recalculation.
	var/list/custom_designs = list()
	/// Already boosted nodes that can't be boosted again. node id = path of boost object.
	var/list/boosted_nodes = list()
	/// Hidden nodes. id = TRUE. Used for unhiding nodes when requirements are met by removing the entry of the node.
	var/list/hidden_nodes = list()
	/// Items already deconstructed for a generic point boost, path = list(point_type = points)
	var/list/deconstructed_items = list()
	/// Available research points, type = number
	var/list/research_points = list()
	var/list/obj/machinery/computer/rdconsole/consoles_accessing = list()
	var/id = "generic"
	/// IC logs
	var/list/research_logs = list()
	/// Organization name, used for display
	var/organization = "Third-Party"
	/// Current per-second production, used for display only.
	var/list/last_bitcoins = list()
	/// Mutations discovered by genetics, this way they are shared and cant be destroyed by destroying a single console
	var/list/discovered_mutations = list()
	/// Assoc list, id = number, 1 is available, 2 is all reqs are 1, so on
	var/list/tiers = list()
	/// Available experiments
	var/list/available_experiments = list()
	/// Completed experiments
	var/list/completed_experiments = list()
	
	/**
	 * Assoc list of relationships with various partners
	 * scientific_cooperation[partner_typepath] = relationship
	 */
	var/list/scientific_cooperation
	/**
	  * Assoc list of papers already published by the crew. 
	  * published_papers[experiment_typepath][tier] = paper
	  * Filled with nulls on init, populated only on publication.
	*/
	var/list/published_papers

/datum/techweb/New()
	SSresearch.techwebs += src
	for(var/i in SSresearch.techweb_nodes_starting)
		var/datum/techweb_node/DN = SSresearch.techweb_node_by_id(i)
		research_node(DN, TRUE, FALSE, FALSE)
	hidden_nodes = SSresearch.techweb_nodes_hidden.Copy()
	initialize_published_papers()
	return ..()
/datum/techweb/admin
	id = "ADMIN"
	organization = "CentCom"

/datum/techweb/admin/New() //All unlocked.
	. = ..()
	for(var/i in SSresearch.techweb_nodes)
		var/datum/techweb_node/TN = SSresearch.techweb_nodes[i]
		research_node(TN, TRUE, TRUE, FALSE)
	for(var/i in SSresearch.point_types)
		research_points[i] = INFINITY
	hidden_nodes = list()

/datum/techweb/science //Global science techweb for RND consoles.
	id = "SCIENCE"
	organization = "Nanotrasen"

/datum/techweb/bepis //Should contain only 1 BEPIS tech selected at random.
	id = "EXPERIMENTAL"
	organization = "Nanotrasen R&D"

/datum/techweb/bepis/New(remove_tech = TRUE)
	. = ..()
	var/bepis_id = pick(SSresearch.techweb_nodes_experimental) //To add a new tech to the BEPIS, add the ID to this pick list.
	var/datum/techweb_node/BN = (SSresearch.techweb_node_by_id(bepis_id))
	hidden_nodes -= BN.id //Has to be removed from hidden nodes
	research_node(BN, TRUE, FALSE, FALSE)
	update_node_status(BN)
	if(remove_tech)
		SSresearch.techweb_nodes_experimental -= bepis_id

/datum/techweb/Destroy()
	researched_nodes = null
	researched_designs = null
	available_nodes = null
	visible_nodes = null
	custom_designs = null
	SSresearch.techwebs -= src
	return ..()

/datum/techweb/proc/recalculate_nodes(recalculate_designs = FALSE, wipe_custom_designs = FALSE)
	var/list/datum/techweb_node/processing = list()
	for(var/id in researched_nodes)
		processing[id] = TRUE
	for(var/id in visible_nodes)
		processing[id] = TRUE
	for(var/id in available_nodes)
		processing[id] = TRUE
	if(recalculate_designs)
		researched_designs = custom_designs.Copy()
		if(wipe_custom_designs)
			custom_designs = list()
	for(var/id in processing)
		update_node_status(SSresearch.techweb_node_by_id(id), FALSE)
		CHECK_TICK
	for(var/v in consoles_accessing)
		var/obj/machinery/computer/rdconsole/V = v
		V.updateUsrDialog()

/datum/techweb/proc/add_point_list(list/pointlist)
	for(var/i in pointlist)
		if(SSresearch.point_types[i] && pointlist[i] > 0)
			research_points[i] += pointlist[i]

/datum/techweb/proc/add_points_all(amount)
	var/list/l = SSresearch.point_types.Copy()
	for(var/i in l)
		l[i] = amount
	add_point_list(l)

/datum/techweb/proc/remove_point_list(list/pointlist)
	for(var/i in pointlist)
		if(SSresearch.point_types[i] && pointlist[i] > 0)
			research_points[i] = max(0, research_points[i] - pointlist[i])

/datum/techweb/proc/remove_points_all(amount)
	var/list/l = SSresearch.point_types.Copy()
	for(var/i in l)
		l[i] = amount
	remove_point_list(l)

/datum/techweb/proc/modify_point_list(list/pointlist)
	for(var/i in pointlist)
		if(SSresearch.point_types[i] && pointlist[i] != 0)
			research_points[i] = max(0, research_points[i] + pointlist[i])

/datum/techweb/proc/modify_points_all(amount)
	var/list/l = SSresearch.point_types.Copy()
	for(var/i in l)
		l[i] = amount
	modify_point_list(l)

/datum/techweb/proc/copy_research_to(datum/techweb/receiver, unlock_hidden = TRUE) //Adds any missing research to theirs.
	if(unlock_hidden)
		for(var/i in receiver.hidden_nodes)
			CHECK_TICK
			if(available_nodes[i] || researched_nodes[i] || visible_nodes[i])
				receiver.hidden_nodes -= i //We can see it so let them see it too.
	for(var/i in researched_nodes)
		CHECK_TICK
		receiver.research_node_id(i, TRUE, FALSE, FALSE)
	for(var/i in researched_designs)
		CHECK_TICK
		receiver.add_design_by_id(i)
	receiver.recalculate_nodes()

/datum/techweb/proc/copy()
	var/datum/techweb/returned = new()
	returned.researched_nodes = researched_nodes.Copy()
	returned.visible_nodes = visible_nodes.Copy()
	returned.available_nodes = available_nodes.Copy()
	returned.researched_designs = researched_designs.Copy()
	returned.hidden_nodes = hidden_nodes.Copy()
	return returned

/datum/techweb/proc/get_visible_nodes() //The way this is set up is shit but whatever.
	return visible_nodes - hidden_nodes

/datum/techweb/proc/get_available_nodes()
	return available_nodes - hidden_nodes

/datum/techweb/proc/get_researched_nodes()
	return researched_nodes - hidden_nodes

/datum/techweb/proc/add_point_type(type, amount)
	if(!SSresearch.point_types[type] || (amount <= 0))
		return FALSE
	research_points[type] += amount
	return TRUE

/datum/techweb/proc/modify_point_type(type, amount)
	if(!SSresearch.point_types[type])
		return FALSE
	research_points[type] = max(0, research_points[type] + amount)
	return TRUE

/datum/techweb/proc/remove_point_type(type, amount)
	if(!SSresearch.point_types[type] || (amount <= 0))
		return FALSE
	research_points[type] = max(0, research_points[type] - amount)
	return TRUE

/datum/techweb/proc/add_design_by_id(id, custom = FALSE)
	return add_design(SSresearch.techweb_design_by_id(id), custom)

/datum/techweb/proc/add_design(datum/design/design, custom = FALSE)
	if(!istype(design))
		return FALSE
	SEND_SIGNAL(src, COMSIG_TECHWEB_ADD_DESIGN, design, custom)
	researched_designs[design.id] = TRUE
	if(custom)
		custom_designs[design.id] = TRUE
	return TRUE

/datum/techweb/proc/remove_design_by_id(id, custom = FALSE)
	return remove_design(SSresearch.techweb_design_by_id(id), custom)

/datum/techweb/proc/remove_design(datum/design/design, custom = FALSE)
	if(!istype(design))
		return FALSE
	if(custom_designs[design.id] && !custom)
		return FALSE
	SEND_SIGNAL(src, COMSIG_TECHWEB_REMOVE_DESIGN, design, custom)
	custom_designs -= design.id
	researched_designs -= design.id
	return TRUE

/datum/techweb/proc/get_point_total(list/pointlist)
	for(var/i in pointlist)
		. += pointlist[i]

/datum/techweb/proc/can_afford(list/pointlist)
	for(var/i in pointlist)
		if(research_points[i] < pointlist[i])
			return FALSE
	return TRUE

/**
 * Checks if all experiments have been completed for a given node on this techweb
 *
 * Arguments:
 * * node - the node to check
 */
/datum/techweb/proc/have_experiments_for_node(datum/techweb_node/node)
	. = TRUE
	for (var/experiment_type in node.required_experiments)
		if (!completed_experiments[experiment_type])
			return FALSE

/**
 * Checks if a node can be unlocked on this techweb, having the required points and experiments
 *
 * Arguments:
 * * node - the node to check
 */
/datum/techweb/proc/can_unlock_node(datum/techweb_node/node)
	return can_afford(node.get_price(src)) && have_experiments_for_node(node)

/**
 * Adds an experiment to this techweb by its type, ensures that no duplicates are added.
 *
 * Arguments:
 * * experiment_type - the type of the experiment to add
 */
/datum/techweb/proc/add_experiment(experiment_type)
	. = TRUE
	// check active experiments for experiment of this type
	for (var/available_experiment in available_experiments)
		var/datum/experiment/experiment = available_experiment
		if (experiment.type == experiment_type)
			return FALSE
	// check completed experiments for experiments of this type
	for (var/completed_experiment in completed_experiments)
		var/datum/experiment/experiment = completed_experiment
		if (experiment == experiment_type)
			return FALSE
	available_experiments += new experiment_type()

/**
 * Adds a list of experiments to this techweb by their types, ensures that no duplicates are added.
 *
 * Arguments:
 * * experiment_list - the list of types of experiments to add
 */
/datum/techweb/proc/add_experiments(list/experiment_list)
	. = TRUE
	for (var/experiment_type in experiment_list)
		var/datum/experiment/experiment = experiment_type
		. = . && add_experiment(experiment)

/**
 * Notifies the techweb that an experiment has been completed, updating internal state of the techweb to reflect this.
 *
 * Arguments:
 * * completed_experiment - the experiment which was completed
 */
/datum/techweb/proc/complete_experiment(datum/experiment/completed_experiment)
	available_experiments -= completed_experiment
	completed_experiments[completed_experiment.type] = completed_experiment

/datum/techweb/proc/printout_points()
	return techweb_point_display_generic(research_points)

/datum/techweb/proc/research_node_id(id, force, auto_update_points, get_that_dosh_id)
	return research_node(SSresearch.techweb_node_by_id(id), force, auto_update_points, get_that_dosh_id)

/datum/techweb/proc/research_node(datum/techweb_node/node, force = FALSE, auto_adjust_cost = TRUE, get_that_dosh = TRUE)
	if(!istype(node))
		return FALSE
	update_node_status(node)
	if(!force)
		if(!available_nodes[node.id] || (auto_adjust_cost && (!can_afford(node.get_price(src)))) || !have_experiments_for_node(node))
			return FALSE
	if(auto_adjust_cost)
		remove_point_list(node.get_price(src))
	researched_nodes[node.id] = TRUE //Add to our researched list
	for(var/id in node.unlock_ids)
		visible_nodes[id] = TRUE
		var/datum/techweb_node/unlocked_node = SSresearch.techweb_node_by_id(id)
		if (unlocked_node.required_experiments.len > 0)
			add_experiments(unlocked_node.required_experiments)
		if (unlocked_node.discount_experiments.len > 0)
			add_experiments(unlocked_node.discount_experiments)
		update_node_status(unlocked_node)
	for(var/id in node.design_ids)
		add_design_by_id(id)
	update_node_status(node)
	if(get_that_dosh)
		var/datum/bank_account/science_department_bank_account = SSeconomy.get_dep_account(ACCOUNT_SCI)
		science_department_bank_account?.adjust_money(SSeconomy.techweb_bounty)
	return TRUE

/datum/techweb/science/research_node(datum/techweb_node/node, force = FALSE, auto_adjust_cost = TRUE, get_that_dosh = TRUE) //When something is researched, triggers the proc for this techweb only
	. = ..()
	if(.)
		node.on_research()

/datum/techweb/proc/unresearch_node_id(id)
	return unresearch_node(SSresearch.techweb_node_by_id(id))

/datum/techweb/proc/unresearch_node(datum/techweb_node/node)
	if(!istype(node))
		return FALSE
	researched_nodes -= node.id
	recalculate_nodes(TRUE) //Fully rebuild the tree.

/// Boosts a techweb node.
/datum/techweb/proc/boost_techweb_node(datum/techweb_node/node, list/pointlist)
	if(!istype(node))
		return FALSE
	LAZYINITLIST(boosted_nodes[node.id])
	for(var/point_type in pointlist)
		boosted_nodes[node.id][point_type] = max(boosted_nodes[node.id][point_type], pointlist[point_type])
	if(node.autounlock_by_boost)
		hidden_nodes -= node.id
	update_node_status(node)
	return TRUE

/// Boosts a techweb node by using items.
/datum/techweb/proc/boost_with_item(datum/techweb_node/node, itempath)
	if(!istype(node) || !ispath(itempath))
		return FALSE
	var/list/boost_amount = node.boost_item_paths[itempath]
	boost_techweb_node(node, boost_amount)
	return TRUE

/datum/techweb/proc/update_tiers(datum/techweb_node/base)
	var/list/current = list(base)
	while (current.len)
		var/list/next = list()
		for (var/node_ in current)
			var/datum/techweb_node/node = node_
			var/tier = 0
			if (!researched_nodes[node.id])  // researched is tier 0
				for (var/id in node.prereq_ids)
					var/prereq_tier = tiers[id]
					tier = max(tier, prereq_tier + 1)

			if (tier != tiers[node.id])
				tiers[node.id] = tier
				for (var/id in node.unlock_ids)
					next += SSresearch.techweb_node_by_id(id)
		current = next

/datum/techweb/proc/update_node_status(datum/techweb_node/node, autoupdate_consoles = TRUE)
	var/researched = FALSE
	var/available = FALSE
	var/visible = FALSE
	if(researched_nodes[node.id])
		researched = TRUE
	var/needed = node.prereq_ids.len
	for(var/id in node.prereq_ids)
		if(researched_nodes[id])
			visible = TRUE
			needed--
	if(!needed)
		available = TRUE
	researched_nodes -= node.id
	available_nodes -= node.id
	visible_nodes -= node.id
	if(hidden_nodes[node.id]) //Hidden.
		return
	if(researched)
		researched_nodes[node.id] = TRUE
		for(var/id in node.design_ids)
			add_design(SSresearch.techweb_design_by_id(id))
	else
		if(available)
			available_nodes[node.id] = TRUE
		else
			if(visible)
				visible_nodes[node.id] = TRUE
	update_tiers(node)
	if(autoupdate_consoles)
		for(var/v in consoles_accessing)
			var/obj/machinery/computer/rdconsole/V = v
			V.updateUsrDialog()

//Laggy procs to do specific checks, just in case. Don't use them if you can just use the vars that already store all this!
/datum/techweb/proc/designHasReqs(datum/design/D)
	for(var/i in researched_nodes)
		var/datum/techweb_node/N = SSresearch.techweb_node_by_id(i)
		if(N.design_ids[D.id])
			return TRUE
	return FALSE

/datum/techweb/proc/isDesignResearched(datum/design/D)
	return isDesignResearchedID(D.id)

/datum/techweb/proc/isDesignResearchedID(id)
	return researched_designs[id]? SSresearch.techweb_design_by_id(id) : FALSE

/datum/techweb/proc/isNodeResearched(datum/techweb_node/N)
	return isNodeResearchedID(N.id)

/datum/techweb/proc/isNodeResearchedID(id)
	return researched_nodes[id]? SSresearch.techweb_node_by_id(id) : FALSE

/datum/techweb/proc/isNodeVisible(datum/techweb_node/N)
	return isNodeResearchedID(N.id)

/datum/techweb/proc/isNodeVisibleID(id)
	return visible_nodes[id]? SSresearch.techweb_node_by_id(id) : FALSE

/datum/techweb/proc/isNodeAvailable(datum/techweb_node/N)
	return isNodeAvailableID(N.id)

/datum/techweb/proc/isNodeAvailableID(id)
	return available_nodes[id]? SSresearch.techweb_node_by_id(id) : FALSE

/datum/techweb/specialized
	var/allowed_buildtypes = ALL

/datum/techweb/specialized/add_design(datum/design/D)
	if(!(D.build_type & allowed_buildtypes))
		return FALSE
	return ..()

/datum/techweb/specialized/autounlocking
	var/design_autounlock_buildtypes = NONE
	var/design_autounlock_categories = list("initial") //if a design has a buildtype that matches the abovea and either has a category in this or this is null, unlock it.
	var/node_autounlock_ids = list() //autounlock nodes of this type.

/datum/techweb/specialized/autounlocking/New()
	..()
	autounlock()

/datum/techweb/specialized/autounlocking/proc/autounlock()
	for(var/id in node_autounlock_ids)
		research_node_id(id, TRUE, FALSE, FALSE)
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(id)
		if(D.build_type & design_autounlock_buildtypes)
			for(var/i in D.category)
				if(i in design_autounlock_categories)
					add_design_by_id(D.id)
					break

/datum/techweb/specialized/autounlocking/autolathe
	design_autounlock_buildtypes = AUTOLATHE
	allowed_buildtypes = AUTOLATHE

/datum/techweb/specialized/autounlocking/limbgrower
	design_autounlock_buildtypes = LIMBGROWER
	allowed_buildtypes = LIMBGROWER

/datum/techweb/specialized/autounlocking/biogenerator
	design_autounlock_buildtypes = BIOGENERATOR
	allowed_buildtypes = BIOGENERATOR

/datum/techweb/specialized/autounlocking/smelter
	design_autounlock_buildtypes = SMELTER
	allowed_buildtypes = SMELTER

/datum/techweb/specialized/autounlocking/exofab
	allowed_buildtypes = MECHFAB

/// Fill published_papers with nulls.
/datum/techweb/proc/initialize_published_papers()
	published_papers = list()
	scientific_cooperation = list()
	for (var/datum/experiment/ordnance/ordnance_experiment as anything in SSresearch.ordnance_experiments)
		var/max_tier = min(length(ordnance_experiment.gain), length(ordnance_experiment.target_amount))
		var/list/tier_list[max_tier]
		published_papers[ordnance_experiment.type] = tier_list
	for (var/datum/scientific_partner/partner as anything in SSresearch.scientific_partners)
		scientific_cooperation[partner.type] = 0

/// Publish the paper into our techweb. Cancel if we are not allowed to.
/datum/techweb/proc/add_scientific_paper(datum/scientific_paper/paper_to_add)
	if(!paper_to_add.allowed_to_publish(src))
		return FALSE
	paper_to_add.publish_paper(src)

	// If we haven't published a paper in the same topic ...
	if(locate(paper_to_add.experiment_path) in published_papers[paper_to_add.experiment_path])
		return TRUE	
	// Quickly add and complete it.
	// PS: It's also possible to use add_experiment() together with a list/available_experiments check
	// to determine if we need to run all this, but this pretty much does the same while only needing one evaluation.

	add_experiment(paper_to_add.experiment_path)

	for (var/datum/experiment/experiment as anything in available_experiments)
		if(experiment.type != paper_to_add.experiment_path)
			continue

		experiment.completed = TRUE
		complete_experiment(experiment)
		if(length(GLOB.experiment_handlers))
			var/datum/component/experiment_handler/handler = GLOB.experiment_handlers[1]
			handler.announce_message_to_all("The [experiment.name] has been completed!")	
	
	return TRUE
