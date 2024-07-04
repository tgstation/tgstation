// TODO: Work into reworked uplinks.
/// Selects a set number of unique items from the uplink, and deducts a percentage discount from them
/proc/create_uplink_sales(num, datum/uplink_category/category, limited_stock, list/sale_items)
	var/list/sales = list()
	var/list/sale_items_copy = sale_items.Copy()
	for (var/i in 1 to num)
		var/datum/uplink_item/taken_item = pick_n_take(sale_items_copy)
		var/datum/uplink_item/uplink_item = new taken_item.type()
		var/discount = uplink_item.get_discount()
		var/static/list/disclaimer = list(
			"Void where prohibited.",
			"Not recommended for children.",
			"Contains small parts.",
			"Check local laws for legality in region.",
			"Do not taunt.",
			"Not responsible for direct, indirect, incidental or consequential damages resulting from any defect, error or failure to perform.",
			"Keep away from fire or flames.",
			"Product is provided \"as is\" without any implied or expressed warranties.",
			"As seen on TV.",
			"For recreational use only.",
			"Use only as directed.",
			"16% sales tax will be charged for orders originating within Space Nebraska.",
		)
		uplink_item.limited_stock = limited_stock
		if(uplink_item.cost >= 20) //Tough love for nuke ops
			discount *= 0.5
		uplink_item.stock_key = WEAKREF(uplink_item)
		uplink_item.category = category
		uplink_item.cost = max(round(uplink_item.cost * (1 - discount)),1)
		uplink_item.name += " ([round(((initial(uplink_item.cost)-uplink_item.cost)/initial(uplink_item.cost))*100)]% off!)"
		uplink_item.desc += " Normally costs [initial(uplink_item.cost)] TC. All sales final. [pick(disclaimer)]"
		uplink_item.item = taken_item.item
		uplink_item.discounted = TRUE

		sales += uplink_item
	return sales

/**
 * Uplink Items
 *
 * Items that can be spawned from an uplink. Can be limited by gamemode.
**/
/datum/uplink_item
	/// Name of the uplink item
	var/name = "item name"
	/// Category of the uplink
	var/datum/uplink_category/category
	/// Description of the uplink
	var/desc = "item description"
	/// Path to the item to spawn.
	var/item = null
	/// Cost of the item.
	var/cost = 0
	/// Amount of TC to refund, in case there's a TC penalty for refunds.
	var/refund_amount = 0
	/// Whether this item is refundable or not.
	var/refundable = FALSE
	// Chance of being included in the surplus crate.
	var/surplus = 100
	/// Whether this can be discounted or not
	var/cant_discount = FALSE
	/// If discounted, is true. Used to send a signal to update reimbursement.
	var/discounted = FALSE
	/// If this value is changed on two items they will share stock, defaults to not sharing stock with any other item
	var/stock_key = UPLINK_SHARED_STOCK_UNIQUE
	/// How many items of this stock can be purchased.
	var/limited_stock = -1 //Setting this above zero limits how many times this item can be bought by the same traitor in a round, -1 is unlimited
	/// A bitfield to represent what uplinks can purchase this item.
	/// See [`code/__DEFINES/uplink.dm`].
	var/purchasable_from = ALL
	/// If this uplink item is only available to certain roles. Roles are dependent on the frequency chip or stored ID.
	var/list/restricted_roles = list()
	/// The species able to purchase this uplink item.
	var/list/restricted_species = list()
	/// The minimum amount of progression needed for this item to be added to uplinks.
	var/progression_minimum = 0
	/// Whether this purchase is visible in the purchase log.
	var/purchase_log_vis = TRUE // Visible in the purchase log?
	/// Whether this purchase is restricted or not (VR/Events related)
	var/restricted = FALSE
	/// Flags related to if an item will provide illegal tech, or trips contraband detectors once spawned in as an item.
	var/uplink_item_flags = SYNDIE_ILLEGAL_TECH | SYNDIE_TRIPS_CONTRABAND
	/// String to be shown instead of the price, e.g for the Random item.
	var/cost_override_string = ""
	/// Whether this item locks all other items from being purchased. Used by syndicate balloon and a few other purchases.
	/// Can't be purchased if you've already bought other things
	/// Uses the purchase log, so items purchased that are not visible in the purchase log will not count towards this.
	/// However, they won't be purchasable afterwards.
	var/lock_other_purchases = FALSE

/datum/uplink_item/New()
	. = ..()
	if(stock_key != UPLINK_SHARED_STOCK_UNIQUE)
		return
	stock_key = type

/datum/uplink_category
	/// Name of the category
	var/name
	/// Weight of the category. Used to determine the positioning in the uplink. High weight = appears first
	var/weight = 0

/// Returns by how much percentage do we reduce the price of the selected item
/datum/uplink_item/proc/get_discount()

	var/static/list/discount_types = list(
		TRAITOR_DISCOUNT_SMALL = 4,
		TRAITOR_DISCOUNT_AVERAGE = 2,
		TRAITOR_DISCOUNT_BIG = 1,
	)

	return get_discount_value(pick_weight(discount_types))

/// Receives a traitor discount type value, returns the amount by which we will reduce the price
/datum/uplink_item/proc/get_discount_value(discount_type)
	switch(discount_type)
		if(TRAITOR_DISCOUNT_BIG)
			return 0.75
		if(TRAITOR_DISCOUNT_AVERAGE)
			return 0.5
		else
			return 0.25

/// Spawns an item and logs its purchase
/datum/uplink_item/proc/purchase(mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	var/atom/spawned_item = spawn_item(item, user, uplink_handler, source)
	log_uplink("[key_name(user)] purchased [src] for [cost] telecrystals from [source]'s uplink")
	user.playsound_local(get_turf(user), 'sound/effects/kaching.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	if(purchase_log_vis && uplink_handler.purchase_log)
		uplink_handler.purchase_log.LogPurchase(spawned_item, src, cost)
	if(lock_other_purchases)
		uplink_handler.shop_locked = TRUE

/// Spawns an item in the world
/datum/uplink_item/proc/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	if(!spawn_path)
		return
	var/atom/spawned_item
	if(ispath(spawn_path))
		spawned_item = new spawn_path(get_turf(user))
	else
		spawned_item = spawn_path
	if(refundable)
		spawned_item.AddElement(/datum/element/uplink_reimburse, (refund_amount ? refund_amount : cost))


	if(uplink_item_flags & SYNDIE_TRIPS_CONTRABAND) // Ignore things that shouldn't be detectable as contraband on the station.
		ADD_TRAIT(spawned_item, TRAIT_CONTRABAND, INNATE_TRAIT)
		for(var/obj/contained as anything in spawned_item.get_all_contents())
			ADD_TRAIT(contained, TRAIT_CONTRABAND, INNATE_TRAIT)
	var/mob/living/carbon/human/human_user = user
	if(istype(human_user) && isitem(spawned_item) && human_user.put_in_hands(spawned_item))
		to_chat(human_user, span_boldnotice("[spawned_item] materializes into your hands!"))
	else
		to_chat(user, span_boldnotice("[spawned_item] materializes onto the floor!"))
	SEND_SIGNAL(uplink_handler, COMSIG_ON_UPLINK_PURCHASE, spawned_item, user)
	return spawned_item

/// Used to create the uplink's item for generic use, rather than use by a Syndie specifically
/// Can be used to "de-restrict" some items, such as Nukie guns spawning with Syndicate pins
/datum/uplink_item/proc/spawn_item_for_generic_use(mob/user)
	var/atom/movable/created = new item(user.loc)
	if(uplink_item_flags & SYNDIE_TRIPS_CONTRABAND) // Things that shouldn't be detectable as contraband on the station.
		ADD_TRAIT(created, TRAIT_CONTRABAND, INNATE_TRAIT)
		for(var/obj/contained as anything in created.get_all_contents())
			ADD_TRAIT(contained, TRAIT_CONTRABAND, INNATE_TRAIT)
		replace_pin(created)
	else if(istype(created, /obj/item/storage/toolbox/guncase))
		for(var/obj/item/gun/gun in created)
			replace_pin(gun)

	if(isobj(created))
		var/obj/created_obj = created
		LAZYREMOVE(created_obj.req_access, ACCESS_SYNDICATE)
		LAZYREMOVE(created_obj.req_one_access, ACCESS_SYNDICATE)

	return created

/// Used by spawn_item_for_generic_use to replace the pin of a gun with a normal one
/datum/uplink_item/proc/replace_pin(obj/item/gun/gun_reward)
	PRIVATE_PROC(TRUE)

	if(!istype(gun_reward.pin, /obj/item/firing_pin/implant/pindicate))
		return

	QDEL_NULL(gun_reward.pin)
	gun_reward.pin = new /obj/item/firing_pin(gun_reward)

///For special overrides if an item can be bought or not.
/datum/uplink_item/proc/can_be_bought(datum/uplink_handler/source)
	return TRUE

/datum/uplink_category/discounts
	name = "Discounted Gear"
	weight = -1

/datum/uplink_category/discount_team_gear
	name = "Discounted Team Gear"
	weight = -1

/datum/uplink_category/limited_discount_team_gear
	name = "Limited Stock Team Gear"
	weight = -2

//Discounts (dynamically filled above)
/datum/uplink_item/discounts
	category = /datum/uplink_category/discounts
	purchasable_from = parent_type::purchasable_from & ~UPLINK_SPY // Probably not necessary but just in case

// Special equipment (Dynamically fills in uplink component)
/datum/uplink_item/special_equipment
	category = "Objective-Specific Equipment"
	name = "Objective-Specific Equipment"
	desc = "Equipment necessary for accomplishing specific objectives. If you are seeing this, something has gone wrong."
	limited_stock = 1
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND
	purchasable_from = parent_type::purchasable_from & ~UPLINK_SPY // Ditto

/datum/uplink_item/special_equipment/purchase(mob/user, datum/component/uplink/U)
	..()
	if(user?.mind?.failed_special_equipment)
		user.mind.failed_special_equipment -= item

/// Code that enables the ability to have limited stock that is shared by different items
/datum/shared_uplink_stock
