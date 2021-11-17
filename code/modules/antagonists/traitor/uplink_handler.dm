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
	var/list/current_objectives = list()
	/// Potential objectives that can be taken
	var/list/potential_objectives = list()

/datum/uplink_handler/proc/purchase_item(mob/user, datum/uplink_item/to_purchase)
	if(!(to_purchase.purchasable_from & uplink_flag))
		return

	if(to_purchase.limited_stock != -1 && !(to_purchase.path in item_stock))
		item_stock[to_purchase.path] = to_purchase.limited_stock

	var/stock = item_stock[to_purchase.path] || INFINITY
	if(telecrystals < to_purchase.cost || stock <= 0 || experience_points < to_purchase.progression_minimum)
		return
	telecrystals -= to_purchase.cost
	to_purchase.purchase(user, src)

	if(to_purchase.path in item_stock)
		item_stock[to_purchase.path] -= 1

	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(to_purchase.name)]", "[to_purchase.cost]"))
	return TRUE

/datum/uplink_handler/proc/take_objective(mob/user, datum/traitor_objective/to_take)
	if(!(to_take in potential_objectives))
		return

	potential_objectives -= to_take
	current_objectives += to_take
