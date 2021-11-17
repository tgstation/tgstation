#define PEN_ROTATIONS 2

/**
 * Uplinks
 *
 * The uplink handler, used to handle a traitor's TC and experience points and the uplink UI.
**/
/datum/uplink_handler
	/// The amount of telecrystals contained in this traitor has
	var/telecrystals = 0
	/// The current uplink flag of this uplink
	var/uplink_flag = NONE
	/// The amount of experience points this traitor has
	var/progression_points = 0
	/// Associative array of uplink item = stock left
	var/list/item_stock = list()
	/// Whether this uplink handler has objectives.
	var/has_objectives = TRUE
	/// Current objectives taken
	var/list/active_objectives = list()
	/// Potential objectives that can be taken
	var/list/potential_objectives = list()
	/// The role that this uplink handler is associated to.
	var/assigned_role
	/// Whether this is in debug mode or not. If in debug mode, allows all purchases
	var/debug_mode = FALSE

/datum/uplink_handler/proc/can_purchase_item(mob/user, datum/uplink_item/to_purchase)
	if(debug_mode)
		return TRUE

	if(!(to_purchase.purchasable_from & uplink_flag))
		return FALSE

	if(to_purchase.restricted_roles && !(assigned_role in to_purchase.restricted_roles))
		return FALSE

	var/stock = item_stock[to_purchase.type] || INFINITY
	if(telecrystals < to_purchase.cost || stock <= 0 || progression_points < to_purchase.progression_minimum)
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
	return TRUE

/datum/uplink_handler/proc/take_objective(mob/user, datum/traitor_objective/to_take)
	if(!(to_take in potential_objectives))
		return

	potential_objectives -= to_take
	active_objectives += to_take
