/**
 * # Techweb
 *
 * A datum representing a research techweb
 *
 * Techweb datums are meant to store unlocked research, being able to be stored
 * on research consoles, servers, and disks. They are NOT global.
 */
/datum/techweb
	///The id/name of the whole Techweb viewable to players.
	var/id = "Generic"
	/// Organization name, used for display
	var/organization = "Third-Party"

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
	/// A list of all experiment datums that have been complete
	var/list/datum/experiment/completed_experiments = list()
	/// Assoc list of all experiment datums that have been skipped, to tech point reward for completing them -
	/// That is, upon researching a node without completing its associated discounts, their experiments go here.
	/// Completing these experiments will have a refund.
	var/list/datum/experiment/skipped_experiment_types = list()

	///All RD consoles connected to this individual techweb.
	var/list/datum/consoles_accessing = list()
	///All research servers connected to this individual techweb.
	var/list/obj/machinery/rnd/server/techweb_servers = list()

	///Boolean on whether the techweb should generate research points overtime.
	var/should_generate_points = FALSE
	///A multiplier applied to all research gain, cut in half if the Master server was sabotaged.
	var/income_modifier = 1
	///The amount of research points generated the techweb generated the latest time it generated.
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
	/// A list of ID cards that have been used to permit access to the techweb for research, for access control
	var/list/obj/item/card/id/users_accessing

/datum/techweb/New()
	SSresearch.techwebs += src
	for(var/i in SSresearch.techweb_nodes_starting)
		var/datum/techweb_node/DN = SSresearch.techweb_node_by_id(i)
		research_node(DN, TRUE, FALSE, FALSE)
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
		update_node_status(SSresearch.techweb_node_by_id(id))
		CHECK_TICK

/datum/techweb/proc/add_point_list(list/pointlist)
	for(var/i in pointlist)
		if((i in SSresearch.point_types) && pointlist[i] > 0)
			research_points[i] += pointlist[i]

/datum/techweb/proc/add_points_all(amount)
	var/list/l = SSresearch.point_types.Copy()
	for(var/i in l)
		l[i] = amount
	add_point_list(l)

/datum/techweb/proc/remove_point_list(list/pointlist)
	for(var/i in pointlist)
		if((i in SSresearch.point_types) && pointlist[i] > 0)
			research_points[i] = max(0, research_points[i] - pointlist[i])

/datum/techweb/proc/remove_points_all(amount)
	var/list/l = SSresearch.point_types.Copy()
	for(var/i in l)
		l[i] = amount
	remove_point_list(l)

/datum/techweb/proc/modify_point_list(list/pointlist)
	for(var/i in pointlist)
		if((i in SSresearch.point_types) && pointlist[i] != 0)
			research_points[i] = max(0, research_points[i] + pointlist[i])

/datum/techweb/proc/modify_points_all(amount)
	var/list/l = SSresearch.point_types.Copy()
	for(var/i in l)
		l[i] = amount
	modify_point_list(l)

/datum/techweb/proc/copy_research_to(datum/techweb/receiver) //Adds any missing research to theirs.
	for(var/i in receiver.hidden_nodes)
		CHECK_TICK
		if(get_available_nodes()[i] || get_researched_nodes()[i] || get_visible_nodes()[i])
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
	if(!(type in SSresearch.point_types) || (amount <= 0))
		return FALSE
	research_points[type] += amount
	return TRUE

/datum/techweb/proc/modify_point_type(type, amount)
	if(!(type in SSresearch.point_types))
		return FALSE
	research_points[type] = max(0, research_points[type] + amount)
	return TRUE

/datum/techweb/proc/remove_point_type(type, amount)
	if(!(type in SSresearch.point_types) || (amount <= 0))
		return FALSE
	research_points[type] = max(0, research_points[type] - amount)
	return TRUE

/**
 * add_design_by_id
 * The main way to add add designs to techweb
 * Uses the techweb node's ID
 * Args:
 * id - the ID of the techweb node to research
 * custom - Boolean on whether the node should also be added to custom_designs
 * add_to - A custom list to add the node to, overwriting research_designs.
 */
/datum/techweb/proc/add_design_by_id(id, custom = FALSE, list/add_to)
	return add_design(SSresearch.techweb_design_by_id(id), custom, add_to)

/datum/techweb/proc/add_design(datum/design/design, custom = FALSE, list/add_to)
	if(!istype(design))
		return FALSE
	SEND_SIGNAL(src, COMSIG_TECHWEB_ADD_DESIGN, design, custom)
	if(custom)
		custom_designs[design.id] = TRUE

	if(add_to)
		add_to[design.id] = TRUE
	else
		researched_designs[design.id] = TRUE

	for(var/list/datum/techweb_node/unlocked_nodes as anything in design.unlocked_by)
		hidden_nodes -= unlocked_nodes

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
	available_experiments += new experiment_type(src)

/**
 * Adds a list of experiments to this techweb by their types, ensures that no duplicates are added.
 *
 * Arguments:
 * * experiment_list - the list of types of experiments to add
 */
/datum/techweb/proc/add_experiments(list/experiment_list)
	. = TRUE
	for (var/datum/experiment/experiment as anything in experiment_list)
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

	var/result_text = "[completed_experiment] has been completed"
	var/refund = skipped_experiment_types[completed_experiment.type] || 0
	if(refund > 0)
		add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = refund))
		result_text += ", refunding [refund] points"
		// Nothing more to gain here, but we keep it in the list to prevent double dipping
		skipped_experiment_types[completed_experiment.type] = -1
	var/points_rewarded
	if(completed_experiment.points_reward)
		add_point_list(completed_experiment.points_reward)
		points_rewarded = ",[refund > 0 ? " and" : ""] rewarding "
		var/list/english_list_keys = list()
		for(var/points_type in completed_experiment.points_reward)
			english_list_keys += "[completed_experiment.points_reward[points_type]] [points_type]"
		points_rewarded += "[english_list(english_list_keys)] points"
		result_text += points_rewarded
	result_text += "!"

	log_research("[completed_experiment.name] ([completed_experiment.type]) has been completed on techweb [id]/[organization][refund ? ", refunding [refund] points" : ""][points_rewarded].")
	return result_text

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
	var/log_message = "[id]/[organization] researched node [node.id]"
	if(auto_adjust_cost)
		var/list/node_cost = node.get_price(src)
		remove_point_list(node_cost)
		log_message += " at the cost of [json_encode(node_cost)]"

	//Add to our researched list
	researched_nodes[node.id] = TRUE

	// Track any experiments we skipped relating to this
	for(var/missed_experiment in node.discount_experiments)
		if(completed_experiments[missed_experiment] || skipped_experiment_types[missed_experiment])
			continue
		skipped_experiment_types[missed_experiment] = node.discount_experiments[missed_experiment]

	// Gain the experiments from the new node
	for(var/id in node.unlock_ids)
		visible_nodes[id] = TRUE
		var/datum/techweb_node/unlocked_node = SSresearch.techweb_node_by_id(id)
		if (unlocked_node.required_experiments.len > 0)
			add_experiments(unlocked_node.required_experiments)
		if (unlocked_node.discount_experiments.len > 0)
			add_experiments(unlocked_node.discount_experiments)
		update_node_status(unlocked_node)

	// Gain more new experiments
	if (node.experiments_to_unlock.len)
		add_experiments(node.experiments_to_unlock)

	// Unlock what the research actually unlocks
	for(var/id in node.design_ids)
		add_design_by_id(id)
	update_node_status(node)
	if(get_that_dosh)
		var/datum/bank_account/science_department_bank_account = SSeconomy.get_dep_account(ACCOUNT_SCI)
		science_department_bank_account?.adjust_money(SSeconomy.techweb_bounty)
		log_message += ", gaining [SSeconomy.techweb_bounty] to [science_department_bank_account] for it."

	// Avoid logging the same 300+ lines at the beginning of every round
	if (MC_RUNNING())
		log_research(log_message)

	return TRUE

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
	unhide_node(node)
	update_node_status(node)
	return TRUE

///Removes a node from the hidden_nodes list, making it viewable and researchable (if no experiments are required).
/datum/techweb/proc/unhide_node(datum/techweb_node/node)
	if(!istype(node))
		return FALSE
	hidden_nodes -= node.id
	///Make it available if the prereq ids are already researched
	update_node_status(node)
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

/datum/techweb/proc/update_node_status(datum/techweb_node/node)
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
		var/announcetext = complete_experiment(experiment)
		if(length(GLOB.experiment_handlers))
			var/datum/component/experiment_handler/handler = GLOB.experiment_handlers[1]
			handler.announce_message_to_all(announcetext)

	return TRUE

/* A proc that returns whether a console is locked or not, if you can't tell.
 * Consoles can currently either be an actual computer, or a program on a PDA (which does most of its logic off the PDA in question), so we can't strictly type the first
 * argument (yet).
 * In most cases, a user is hoping that this returns FALSE, denoting the console is NOT locked.
 * obj/console - The console to check
 * mob/living/user - The user to check; a user can be locked out if the entire console itself isn't
 */
/datum/techweb/proc/is_console_locked(obj/console, mob/living/user)
	. = FALSE // let's assume a permissive use of research consoles
	if (console.obj_flags & EMAGGED) // goddamnit their GUI is decrypting our firewall!! we need more kilobytes!
		return .
	if(!consoles_accessing[console])
		stack_trace("[console] was not properly added to [src]'s list of consoles_accessing.")
		return TRUE // your eldritch bugged out console is locked in that case, guy...
	if(consoles_accessing[console]["locked"]) // they've locked down our motherboard... we'll have to go in through MAC addressing
		. = TRUE
		return .
	if(HAS_SILICON_ACCESS(user)) // silicons can't be added to locked out users so we won't get to checking for them
		return .
	/// The ID card in question that should serve as a user entry for whatever console.
	var/obj/item/id/id_card = user.get_idcard()
	if(!id_card) // Can't access the research web without an ID
		. = TRUE
		return .
	if(users_access[id_card]["locked"]) // the RD, Captain, or AI have specifically locked you out?! all you did was blow the budget on combat mechs!
		. = TRUE
		return .
	return . // if you have gotten through the gauntlet of locked cases, you can blow the research budget to your heart's content (ADVANCED SANITATION TECH BABY)

/* Signal handler for verifying this can respond to a query. Currently just a yes/no check.
* No scenarios to return an invalid response for now, to facilitate server controller access locking
* even if the PDA is out of signal.
* datum/source - src
* datum/inquirer - The object doing the query; for validation of query access in the future
*/
/obj/machinery/computer/rdconsole/proc/validate_console_query(datum/source, datum/inquirer)
	SIGNAL_HANDLER

	return RESEARCH_CONSOLE_QUERY_VALID

/* Whenever this program is installed, it puts together a list of relevant data for server controller queries
* However, it can also update singular fields if needed; current projected use cases are for things that we
* don't want rebuilding the whole query with respect to performance considerations, or for l33t haxxorz updating
* their query responses with erroneous information: Science McNotAnAntag says, "RD, look! The AI is researching bombs! You should let me valiantly card it!"
* single_field - null by default, if not null, the value of the field to update
* value - null by default, if not null, the value to update the field with
*/
/obj/machinery/computer/rdconsole/proc/update_query_reply(single_field = null, value = null)

	if(single_field) // If we're updating a single field then ONLY update the single field... obviously...
		query_reply[single_field] = value
	else
		query_reply["console_name"] = src
		query_reply["console_location"] = get_area(src)
		query_reply["console_locked"] = locked
		query_reply["console_ref"] = REF(src)
	if(stored_research)
		stored_research.consoles_accessing[src] = console_query_reply()

/* Handler for the various interfaces that would query console information.
* queried_field - null by default, if not null return the whole query, else just the field
* datum/inquirer - The object doing the query; to be used for logging purposes
*/
/obj/machinery/computer/rdconsole/proc/console_query_reply(queried_field = null, datum/inquirer = null)

	if(queried_field)
		return query_reply[queried_field]

	return query_reply
