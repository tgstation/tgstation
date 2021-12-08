/**
 * Uplink Handler
 *
 * The uplink handler, used to handle a traitor's TC and experience points and the uplink UI.
**/
/datum/uplink_handler
	/// The owner of this uplink handler.
	var/datum/mind/owner
	/// The amount of telecrystals contained in this traitor has
	var/telecrystals = 0
	/// The current uplink flag of this uplink
	var/uplink_flag = NONE
	/// This uplink has progression
	var/has_progression = TRUE
	/// The amount of experience points this traitor has
	var/progression_points = 0
	/// The purchase log of this uplink handler
	var/datum/uplink_purchase_log/purchase_log
	/// Associative array of uplink item = stock left
	var/list/item_stock = list()
	/// Whether this uplink handler has objectives.
	var/has_objectives = TRUE
	/// The maximum number of objectives that can be taken
	var/maximum_active_objectives = 1
	/// Current objectives taken
	var/list/active_objectives = list()
	/// Potential objectives that can be taken
	var/list/potential_objectives = list()
	/// Objectives that have been completed.
	var/list/completed_objectives = list()
	/// All objectives assigned by type to handle any duplicates
	var/list/potential_duplicate_objectives = list()
	/// The role that this uplink handler is associated to.
	var/assigned_role
	/// Whether this is in debug mode or not. If in debug mode, allows all purchases
	var/debug_mode = FALSE

/// Called whenever an update occurs on this uplink handler. Used for UIs
/datum/uplink_handler/proc/on_update()
	SEND_SIGNAL(src, COMSIG_UPLINK_HANDLER_ON_UPDATE)
	return

/datum/uplink_handler/proc/can_purchase_item(mob/user, datum/uplink_item/to_purchase)
	if(debug_mode)
		return TRUE

	if(!(to_purchase.purchasable_from & uplink_flag))
		return FALSE

	if(length(to_purchase.restricted_roles) && !(assigned_role in to_purchase.restricted_roles))
		return FALSE

	var/stock = item_stock[to_purchase.type] || INFINITY
	if(telecrystals < to_purchase.cost || stock <= 0 || (has_progression && progression_points < to_purchase.progression_minimum))
		return FALSE

	return TRUE

/datum/uplink_handler/proc/purchase_item(mob/user, datum/uplink_item/to_purchase)
	if(!can_purchase_item(user, to_purchase))
		return

	if(to_purchase.limited_stock != -1 && !(to_purchase.type in item_stock))
		item_stock[to_purchase.type] = to_purchase.limited_stock

	telecrystals -= to_purchase.cost
	to_purchase.purchase(user, src)

	if(to_purchase.type in item_stock)
		item_stock[to_purchase.type] -= 1

	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(to_purchase.name)]", "[to_purchase.cost]"))
	on_update()
	return TRUE

/// Generates objectives for this uplink handler
/datum/uplink_handler/proc/generate_objectives()
	var/potential_objectives_left = CONFIG_GET(number/maximum_potential_objectives) - length(potential_objectives)
	var/list/objectives = SStraitor.get_possible_objectives(progression_points)
	if(!length(objectives))
		return
	var/maximum_iteration = CONFIG_GET(number/maximum_potential_objectives) * 2
	for(var/i in 1 to maximum_iteration)
		if(potential_objectives_left <= 0 || !length(objectives))
			break
		var/objective_typepath = pick(objectives)
		var/datum/traitor_objective/objective = new objective_typepath(src)
		if(!objective.generate_objective(owner))
			objectives -= objective_typepath
			continue
		if(!handle_duplicate(objective))
			return
		potential_objectives += objective
		potential_objectives_left--
	on_update()

/datum/uplink_handler/proc/handle_duplicate(datum/traitor_objective/potential_duplicate)
	if(!potential_duplicate_objectives[potential_duplicate.type])
		potential_duplicate_objectives[potential_duplicate.type] = list(potential_duplicate)
		return TRUE

	for(var/datum/traitor_objective/duplicate_checker as anything in potential_duplicate_objectives[potential_duplicate.type])
		if(duplicate_checker.is_duplicate(potential_duplicate))
			return FALSE
	potential_duplicate_objectives[potential_duplicate.type] += potential_duplicate
	return TRUE

/datum/uplink_handler/proc/complete_objective(mob/user, datum/traitor_objective/to_remove)
	if(to_remove in completed_objectives)
		return

	active_objectives -= to_remove
	completed_objectives += to_remove

/datum/uplink_handler/proc/take_objective(mob/user, datum/traitor_objective/to_take)
	if(!(to_take in potential_objectives))
		return

	potential_objectives -= to_take
	active_objectives += to_take
	on_update()

/datum/uplink_handler/proc/ui_objective_act(mob/user, datum/traitor_objective/to_act_on, action)
	if(!(to_act_on in active_objectives))
		return

	to_act_on.ui_perform_action(user, action)
