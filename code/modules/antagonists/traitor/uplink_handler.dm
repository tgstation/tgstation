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
	/// Associative array of stock keys = stock left. For items that don't share stock, the key is their typepath
	var/list/item_stock = list(UPLINK_SHARED_STOCK_KITS = 1 , UPLINK_SHARED_STOCK_SURPLUS = 1)
	/// Extra stuff that can be purchased by an uplink, regardless of flag.
	var/list/extra_purchasable = list()
	/// Objectives that must be completed for traitor greentext. Set by the traitor datum.
	var/list/primary_objectives
	/// The role that this uplink handler is associated to.
	var/assigned_role
	/// The species this uplink handler is associated to.
	var/assigned_species
	/// Whether this is in debug mode or not. If in debug mode, allows all purchases. Bypasses the shop lock.
	var/debug_mode = FALSE
	/// Whether the shop is locked or not. If set to true, nothing can be purchased.
	var/shop_locked = FALSE
	/// Callback which returns true if you can choose to replace your objectives with different ones
	var/datum/callback/can_replace_objectives
	/// Callback which performs that operation
	var/datum/callback/replace_objectives
	///Reference to a contractor hub that the infiltrator can run, if they purchase it.
	var/datum/contractor_hub/contractor_hub

/datum/uplink_handler/Destroy(force)
	can_replace_objectives = null
	replace_objectives = null
	return ..()

/// Called whenever an update occurs on this uplink handler. Used for UIs
/datum/uplink_handler/proc/on_update()
	SEND_SIGNAL(src, COMSIG_UPLINK_HANDLER_ON_UPDATE)
	return

/// Checks if traitor has enough reputation to purchase an item
/datum/uplink_handler/proc/not_enough_reputation(datum/uplink_item/to_purchase)
	return has_progression && progression_points < to_purchase.progression_minimum

/// Checks if there are enough joined players to purchase an item
/datum/uplink_handler/proc/not_enough_population(datum/uplink_item/to_purchase)
	return length(GLOB.joined_player_list) < to_purchase.population_minimum

/// Checks for uplink flags as well as items restricted to roles and species
/datum/uplink_handler/proc/check_if_restricted(datum/uplink_item/to_purchase)
	if(!to_purchase.can_be_bought(src))
		return FALSE
	if((to_purchase in extra_purchasable))
		return TRUE
	if(!(to_purchase.purchasable_from & uplink_flag))
		return FALSE
	if(length(to_purchase.restricted_roles) && !(assigned_role in to_purchase.restricted_roles))
		return FALSE
	if(length(to_purchase.restricted_species) && !(assigned_species in to_purchase.restricted_species))
		return FALSE
	return TRUE

/datum/uplink_handler/proc/can_purchase_item(mob/user, datum/uplink_item/to_purchase)
	if(debug_mode)
		return TRUE

	if(shop_locked)
		return FALSE

	if(to_purchase.lock_other_purchases)
		// Can't purchase an uplink item that locks other purchases if you've already purchased something
		if(length(purchase_log.purchase_log) > 0)
			return FALSE

	if(!check_if_restricted(to_purchase))
		return FALSE

	if(not_enough_reputation(to_purchase) || not_enough_population(to_purchase))
		return FALSE

	if(telecrystals < to_purchase.cost)
		return FALSE

	var/current_stock = item_stock[to_purchase.stock_key]
	var/stock = current_stock != null ? current_stock : INFINITY
	if(stock <= 0)
		return FALSE

	return TRUE

/datum/uplink_handler/proc/purchase_item(mob/user, datum/uplink_item/to_purchase, atom/movable/source)
	if(!can_purchase_item(user, to_purchase))
		return

	if(to_purchase.limited_stock != -1 && !(to_purchase.stock_key in item_stock))
		item_stock[to_purchase.stock_key] = to_purchase.limited_stock

	telecrystals -= to_purchase.cost
	to_purchase.purchase(user, src, source)

	if(to_purchase.stock_key in item_stock)
		item_stock[to_purchase.stock_key] -= 1

	SSblackbox.record_feedback("nested tally", "traitor_uplink_items_bought", 1, list("[initial(to_purchase.name)]", "[to_purchase.cost]"))
	on_update()
	return TRUE

/datum/uplink_handler/proc/purchase_raw_tc(mob/user, amount, atom/movable/source)
	if(shop_locked)
		return FALSE
	if(telecrystals < amount)
		return FALSE

	telecrystals -= amount
	var/tcs = new /obj/item/stack/telecrystal(get_turf(user), amount)
	user.put_in_hands(tcs)

	log_uplink("[key_name(user)] purchased [amount] raw telecrystals from [source]'s uplink")
	on_update()
	return TRUE

///Helper to add telecrystals to the uplink handler, calling set_telecrystals.
/datum/uplink_handler/proc/add_telecrystals(amount)
	set_telecrystals(telecrystals + amount)

///Sets how many telecrystals the uplink handler has, then updates the UI for any players watching.
/datum/uplink_handler/proc/set_telecrystals(amount)
	telecrystals = amount
	on_update()
