/**
 * # Techweb
 *
 * A datum representing a research techweb
 *
 * Techweb datums are meant to store unlocked research, being able to be stored
 * on research consoles, servers, and disks. They are NOT global.
 */
/datum/techweb
	/// The id/name of the whole Techweb viewable to players.
	var/id = "Generic"
	/// Organization name, used for display
	var/organization = "Third-Party"

	/// A list of researched nodes. Associative for faster lookup.
	var/list/researched_nodes = list()
	/// Visible nodes, doesn't mean it can be researched. Associative for faster lookup.
	var/list/visible_nodes = list()
	/// Nodes that can immediately be researched, all reqs met. Associative for faster lookup.
	var/list/available_nodes = list()
	/// A list of unlocked designs. Associative for faster lookup.
	var/list/researched_designs = list()
	/// Custom inserted designs like from disks that should survive recalculation.
	var/list/custom_designs = list()
	/// Hidden nodes. Used for unhiding nodes when requirements are met by removing the entry of the node. Associative for faster lookup.
	var/list/hidden_nodes = list()
	/// A list of nodes that have been boosted. Associative for faster lookup.
	var/list/boosted_nodes = list()
	/// List of items already deconstructed for research points, preventing infinite research point generation.
	var/list/deconstructed_items = list()
	/// Available research points, type = number
	var/list/research_points = list()
	/// Game logs of research nodes, "node_name" "node_cost" "node_researcher" "node_research_location"
	var/list/research_logs = list()
	/// Current per-second production, used for display only.
	var/list/last_bitcoins = list()
	/// Mutations discovered by genetics, this way they are shared and cant be destroyed by destroying a single console
	var/list/discovered_mutations = list()
	/// Assoc list, id = number, 1 is available, 2 is all reqs are 1, so on
	var/list/tiers = list()
	/// This is a list of all incomplete experiment datums that are accessible for scientists to complete
	var/list/datum/experiment/available_experiments = list()
	/// An associative list of all experiment typepaths to instances that have been completed
	var/list/completed_experiments = list()
	/// Assoc list of all experiment datums that have been skipped, to tech point reward for completing them -
	/// That is, upon researching a node without completing its associated discounts, their experiments go here.
	/// Completing these experiments will have a refund.
	var/list/datum/experiment/skipped_experiment_types = list()

	/// All RD consoles connected to this individual techweb.
	var/list/obj/machinery/computer/rdconsole/consoles_accessing = list()
	/// All research servers connected to this individual techweb.
	var/list/obj/machinery/rnd/server/techweb_servers = list()

	/// Boolean on whether the techweb should generate research points overtime.
	var/should_generate_points = FALSE
	/// A multiplier applied to all research gain, cut in half if the Master server was sabotaged.
	var/income_modifier = 1
	/// The amount of research points generated the techweb generated the latest time it generated.
	var/last_income

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
	/// Assoc list of nodes queued for automatic research when there are enough points available
	/// e.g: [/datum/techweb_node/mining --> /mob/living/carbon/human (weakref)]
	var/list/research_queue_nodes = list()

/datum/techweb/New()
	SSresearch.techwebs += src
	for(var/node_path in SSresearch.techweb_nodes_starting)
		research_node(SSresearch.techweb_nodes[node_path], TRUE, FALSE, FALSE)
	hidden_nodes = SSresearch.techweb_nodes_hidden.Copy()
	initialize_published_papers()
	return ..()

/datum/techweb/Destroy()
	researched_nodes = null
	researched_designs = null
	available_nodes = null
	visible_nodes = null
	custom_designs = null
	SSresearch.techwebs -= src
	return ..()

/datum/techweb/proc/recalculate_nodes(recalculate_designs = FALSE)
	if(recalculate_designs)
		researched_designs = custom_designs.Copy()
	var/list/all_of_our_nodes = researched_nodes | visible_nodes | available_nodes
	for(var/node_path in all_of_our_nodes)
		update_node_status(SSresearch.techweb_nodes[node_path])
		CHECK_TICK

/// Adjusts the amount of a certain point type
/datum/techweb/proc/adjust_points(point_type, point_amount)
	if(!SSresearch.point_types[point_type] || !point_amount)
		return
	research_points[point_type] = max(FLOOR(research_points[point_type] + point_amount, 0.1), 0)

/// Adjusts the amount of multiple point types
/datum/techweb/proc/adjust_multiple_points(list/point_list)
	for(var/point_type, point_amount in point_list)
		adjust_points(point_type, point_amount)

/// Adjust all point types by this amount
/datum/techweb/proc/adjust_all_points(point_amount)
	var/list/new_points = SSresearch.point_types.Copy()
	for(var/point_type in new_points)
		new_points[point_type] = point_amount
	adjust_multiple_points(new_points)

/// Takes all of the research from a tech disk
/datum/techweb/proc/absorb_techdisk(obj/item/disk/tech_disk/disk)
	for(var/node_path in disk.stored_nodes - researched_nodes)
		CHECK_TICK
		research_node(node_path, TRUE, FALSE, FALSE)
	recalculate_nodes()

/datum/techweb/proc/get_visible_nodes() //The way this is set up is shit but whatever.
	return visible_nodes - hidden_nodes

/datum/techweb/proc/get_available_nodes()
	return available_nodes - hidden_nodes

/datum/techweb/proc/get_researched_nodes()
	return researched_nodes - hidden_nodes

/**
 * Adds a design to this techweb
 *
 * Arguments:
 * * design - The instance or typepath of the design to add
 * * custom - Boolean on whether the node should also be added to custom_designs
 * * add_to - A custom list to add the node to, overwriting research_designs.
 */
/datum/techweb/proc/add_design(datum/design/design, custom = FALSE, list/add_to)
	if(ispath(design))
		design = SSresearch.techweb_designs[design]
	if(!istype(design))
		return FALSE

	if(custom)
		custom_designs[design.type] = TRUE

	if(add_to)
		add_to[design.type] = TRUE
	else
		researched_designs[design.type] = TRUE

	for(var/unlocked_by in design.unlocked_by)
		hidden_nodes -= unlocked_by

	SEND_SIGNAL(src, COMSIG_TECHWEB_ADD_DESIGN, design, custom)
	return TRUE

/**
 * Removes a design from this techweb
 *
 * Arguments:
 * * design - The instance or typepath of the design to remove
 * * custom - Boolean on whether the node should also be removed from custom_designs
 */
/datum/techweb/proc/remove_design(datum/design/design, custom = FALSE)
	if(ispath(design))
		design = SSresearch.techweb_designs[design]
	if(!istype(design))
		return FALSE

	if(custom)
		custom_designs -= design.type

	researched_designs -= design.type

	SEND_SIGNAL(src, COMSIG_TECHWEB_REMOVE_DESIGN, design, custom)
	return TRUE

/datum/techweb/proc/can_afford(list/point_list)
	for(var/point_type, point_amount in point_list)
		if(research_points[point_type] < point_amount)
			return FALSE
	return TRUE

/**
 * Checks if all experiments have been completed for a given node on this techweb
 *
 * Arguments:
 * * node - the node to check
 */
/datum/techweb/proc/have_experiments_for_node(datum/techweb_node/node)
	for (var/experiment_type in node.required_experiments)
		if (!completed_experiments[experiment_type])
			return FALSE
	return TRUE

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
	// check active experiments for experiment of this type
	for (var/datum/experiment/experiment as anything in available_experiments)
		if (experiment.type == experiment_type)
			return FALSE
	// check completed experiments for experiments of this type
	for (var/completed_experiment_type in completed_experiments)
		if (completed_experiment_type == experiment_type)
			return FALSE
	available_experiments += new experiment_type(src)
	return TRUE

/**
 * Adds a list of experiments to this techweb by their types, ensures that no duplicates are added.
 *
 * Arguments:
 * * experiment_list - the list of types of experiments to add
 */
/datum/techweb/proc/add_experiments(list/experiment_list)
	. = TRUE
	for (var/datum/experiment/experiment as anything in experiment_list)
		if(!add_experiment(experiment))
			. = FALSE // don't return here because add_experiment() does important stuff

/**
 * Notifies the techweb that an experiment has been completed, updating internal state of the techweb to reflect this.
 *
 * Arguments:
 * * completed_experiment - the experiment which was completed
 */
/datum/techweb/proc/complete_experiment(datum/experiment/completed_experiment)
	available_experiments -= completed_experiment
	completed_experiments[completed_experiment.type] = completed_experiment

	var/result_text = "[completed_experiment] has been completed"
	var/refund = skipped_experiment_types[completed_experiment.type] || 0
	if(refund > 0)
		adjust_points(TECHWEB_POINT_TYPE_GENERIC, refund)
		result_text += ", refunding [refund] points"
		// Nothing more to gain here, but we keep it in the list to prevent double dipping
		skipped_experiment_types[completed_experiment.type] = -1
	var/points_rewarded
	if(LAZYLEN(completed_experiment.points_reward))
		adjust_multiple_points(completed_experiment.points_reward)
		points_rewarded = ",[refund > 0 ? " and" : ""] rewarding [completed_experiment.get_points_reward_text()]"
		result_text += points_rewarded
	result_text += "!"

	SEND_SIGNAL(src, COMSIG_TECHWEB_EXPERIMENT_COMPLETED, completed_experiment)
	log_research("[completed_experiment.name] ([completed_experiment.type]) has been completed on techweb [id]/[organization][refund ? ", refunding [refund] points" : ""][points_rewarded].")
	return result_text

/datum/techweb/proc/printout_points()
	return techweb_point_display_generic(research_points)

/// Adds a node to this techweb's research queue
/datum/techweb/proc/enqueue_node(node_path, mob/user)
	var/queue_first = FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/list/access = human_user.wear_id?.GetAccess()
		if(ACCESS_RD in access)
			queue_first = TRUE

	if(research_queue_nodes[node_path])
		if(!queue_first)
			return FALSE
		// Remove to be able to place first
		research_queue_nodes -= node_path // Remove to be able to place first

	var/datum/weakref/user_weakref = WEAKREF(user)
	for(var/queued_node, node_queuer in research_queue_nodes)
		if(node_queuer == user_weakref)
			research_queue_nodes -= queued_node

	if (queue_first)
		research_queue_nodes.Insert(1, node_path)
	research_queue_nodes[node_path] = user_weakref

	return TRUE

/datum/techweb/proc/dequeue_node(node_path, mob/user)
	var/datum/weakref/queuer_weakref = research_queue_nodes[node_path]
	var/mob/queuer = queuer_weakref?.resolve()
	if(isnull(queuer) || queuer != user)
		return FALSE
	research_queue_nodes -= node_path
	return TRUE

/**
 * Adds a node to this techweb
 *
 * Arguments:
 * * node - The typepath or instance of the node to research
 * * force - If TRUE, availability checks are ignored
 * * auto_adjust_cost - If TRUE, the node's point cost(s) are deducted from this techweb
 * * get_that_dosh - If TRUE, the science budget gains [SSeconomy.techweb_bounty] moneys
 * * research_source - The thing responsible for researching this node. Used in overrides.
 */
/datum/techweb/proc/research_node(datum/techweb_node/node, force = FALSE, auto_adjust_cost = TRUE, get_that_dosh = TRUE, atom/research_source)
	if(ispath(node))
		node = SSresearch.techweb_nodes[node]
	if(!istype(node))
		return FALSE

	update_node_status(node)
	if(!force && (!available_nodes[node.type] || (auto_adjust_cost && !can_afford(node.get_price(src))) || !have_experiments_for_node(node)))
		return FALSE

	var/log_message = "[id]/[organization] researched node [node.type]"
	if(auto_adjust_cost)
		var/list/node_cost = node.get_price(src)
		for(var/point_type in node_cost)
			node_cost[point_type] *= -1
		adjust_multiple_points(node_cost)
		log_message += " at the cost of [json_encode(node_cost)]"

	//Add to our researched list
	researched_nodes[node.type] = TRUE

	// Track any experiments we skipped relating to this
	for(var/missed_experiment in node.discount_experiments)
		if(completed_experiments[missed_experiment] || skipped_experiment_types[missed_experiment])
			continue
		skipped_experiment_types[missed_experiment] = node.discount_experiments[missed_experiment]

	// Gain the experiments from the new node
	for(var/unlocked_path in node.unlocked_nodes)
		visible_nodes[unlocked_path] = TRUE
		var/datum/techweb_node/unlocked_node = SSresearch.techweb_nodes[unlocked_path]
		if (LAZYLEN(unlocked_node.required_experiments))
			add_experiments(unlocked_node.required_experiments)
		if (LAZYLEN(unlocked_node.discount_experiments))
			add_experiments(unlocked_node.discount_experiments)
		update_node_status(unlocked_node)

	// Gain more new experiments
	if (LAZYLEN(node.experiments_to_unlock))
		add_experiments(node.experiments_to_unlock)

	// Unlock what the research actually unlocks
	for(var/design_path in node.unlocked_designs)
		add_design(design_path)
	update_node_status(node)
	if(get_that_dosh)
		var/datum/bank_account/science_department_bank_account = SSeconomy.get_dep_account(ACCOUNT_SCI)
		science_department_bank_account?.adjust_money(SSeconomy.techweb_bounty)
		log_message += ", gaining [SSeconomy.techweb_bounty] to [science_department_bank_account] for it."

	// Avoid logging the same 300+ lines at the beginning of every round
	if (MC_RUNNING())
		log_research(log_message)

	// Dequeue
	research_queue_nodes -= node.type

	return TRUE

/**
 * Removes a node from this techweb
 *
 * Arguments:
 * * node_path - The instance or typepath of the node to remove
 */
/datum/techweb/proc/unresearch_node(datum/techweb_node/node_path)
	if(istype(node_path))
		node_path = node_path.type

	researched_nodes -= node_path
	recalculate_nodes(recalculate_designs = TRUE) //Fully rebuild the tree.

/// Boosts a techweb node.
/datum/techweb/proc/boost_techweb_node(datum/techweb_node/node, list/point_list)
	if(!istype(node))
		return FALSE
	LAZYINITLIST(node.discount_boosts)
	for(var/point_type, point_amount in point_list) // Essentially applies the greater boost(s) between the newer and any existing.
		node.discount_boosts[point_type] = max(node.discount_boosts[point_type], point_amount)
	boosted_nodes[node.type] = TRUE
	unhide_node(node)
	update_node_status(node)
	return TRUE

///Removes a node from the hidden_nodes list, making it viewable and researchable (if no experiments are required).
/datum/techweb/proc/unhide_node(datum/techweb_node/node)
	if(!istype(node))
		return FALSE
	hidden_nodes -= node.type
	///Make it available if the prereq ids are already researched
	update_node_status(node)
	return TRUE

/datum/techweb/proc/update_tiers(datum/techweb_node/base)
	var/list/current = list(base)
	while (length(current))
		var/list/next = list()
		for (var/datum/techweb_node/node as anything in current)
			var/tier = 0
			if (!researched_nodes[node.type])  // researched is tier 0
				for (var/prerequisite_path in node.prerequisite_nodes)
					var/prereq_tier = tiers[prerequisite_path]
					tier = max(tier, prereq_tier + 1)

			if (tier != tiers[node.type])
				tiers[node.type] = tier
				for (var/unlocked_path in node.unlocked_nodes)
					next += SSresearch.techweb_nodes[unlocked_path]
		current = next

/datum/techweb/proc/update_node_status(datum/techweb_node/node)
	var/researched = FALSE
	var/available = FALSE
	var/visible = FALSE
	if(researched_nodes[node.type])
		researched = TRUE
	var/needed = LAZYLEN(node.prerequisite_nodes)
	for(var/prerequisite_path in node.prerequisite_nodes)
		if(researched_nodes[prerequisite_path])
			visible = TRUE
			needed--
	if(!needed)
		available = TRUE
	researched_nodes -= node.type
	available_nodes -= node.type
	visible_nodes -= node.type
	if(hidden_nodes[node.type]) //Hidden.
		return

	if(researched)
		researched_nodes[node.type] = TRUE
		var/list/Dear_tg_station_13_maintainers_COMMA_I_am_writing_this_variable_like_this_because_I_am_curious_if_you_guys_actually_review_the_code_that_comes_across_your_desk_PERIOD_If_you_see_this_COMMA_please_let_me_know = LAZYCOPY(node.unlocked_designs)
		for(var/design_path in Dear_tg_station_13_maintainers_COMMA_I_am_writing_this_variable_like_this_because_I_am_curious_if_you_guys_actually_review_the_code_that_comes_across_your_desk_PERIOD_If_you_see_this_COMMA_please_let_me_know - researched_designs)
			add_design(SSresearch.techweb_designs[design_path])
	else if(available)
		available_nodes[node.type] = TRUE
	else if(visible)
		visible_nodes[node.type] = TRUE

	update_tiers(node)

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

		experiment.finish_experiment(linked_web_override = src)

	return TRUE

/// Returns a flat list of all design datums this techweb has researched.
/datum/techweb/proc/get_researched_design_datums()
	var/list/datum/design/designs = list()
	for(var/design_path in researched_designs)
		designs += SSresearch.techweb_designs[design_path]
	return designs
