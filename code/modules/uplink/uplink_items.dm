
// TODO: Work into reworked uplinks.
/proc/create_uplink_sales(num, datum/uplink_category/category, limited_stock, list/sale_items)
	var/list/sales = list()
	var/list/sale_items_copy = sale_items.Copy()
	for (var/i in 1 to num)
		var/datum/uplink_item/taken_item = pick_n_take(sale_items_copy)
		var/datum/uplink_item/uplink_item = new taken_item.type()
		var/discount = uplink_item.get_discount()
		var/list/disclaimer = list("Void where prohibited.", "Not recommended for children.", "Contains small parts.", "Check local laws for legality in region.", "Do not taunt.", "Not responsible for direct, indirect, incidental or consequential damages resulting from any defect, error or failure to perform.", "Keep away from fire or flames.", "Product is provided \"as is\" without any implied or expressed warranties.", "As seen on TV.", "For recreational use only.", "Use only as directed.", "16% sales tax will be charged for orders originating within Space Nebraska.")
		uplink_item.limited_stock = limited_stock
		if(uplink_item.cost >= 20) //Tough love for nuke ops
			discount *= 0.5
		uplink_item.category = category
		uplink_item.cost = max(round(uplink_item.cost * discount),1)
		uplink_item.name += " ([round(((initial(uplink_item.cost)-uplink_item.cost)/initial(uplink_item.cost))*100)]% off!)"
		uplink_item.desc += " Normally costs [initial(uplink_item.cost)] TC. All sales final. [pick(disclaimer)]"
		uplink_item.item = taken_item.item

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
	/// Alternative path for refunds, in case the item purchased isn't what is actually refunded (ie: holoparasites).
	var/refund_path = null
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
	var/restricted_species = list()
	/// The minimum amount of progression needed for this item to be added to uplinks.
	var/progression_minimum = 0
	/// Whether this purchase is visible in the purchase log.
	var/purchase_log_vis = TRUE // Visible in the purchase log?
	/// Whether this purchase is restricted or not (VR/Events related)
	var/restricted = FALSE
	/// Can this item be deconstructed to unlock certain techweb research nodes?
	var/illegal_tech = TRUE
	// String to be shown instead of the price, e.g for the Random item.
	var/cost_override_string = ""

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

/datum/uplink_item/proc/get_discount()
	return pick(4;0.75,2;0.5,1;0.25)

/datum/uplink_item/proc/purchase(mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	var/atom/A = spawn_item(item, user, uplink_handler, source)
	log_uplink("[key_name(user)] purchased [src] for [cost] telecrystals from [source]'s uplink")
	if(purchase_log_vis && uplink_handler.purchase_log)
		uplink_handler.purchase_log.LogPurchase(A, src, cost)

/datum/uplink_item/proc/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	if(!spawn_path)
		return
	var/atom/A
	if(ispath(spawn_path))
		A = new spawn_path(get_turf(user))
	else
		A = spawn_path
	if(ishuman(user) && isitem(A))
		var/mob/living/carbon/human/H = user
		if(H.put_in_hands(A))
			to_chat(H, span_boldnotice("[A] materializes into your hands!"))
			return A
	to_chat(user, span_boldnotice("[A] materializes onto the floor!"))
	return A

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

// Special equipment (Dynamically fills in uplink component)
/datum/uplink_item/special_equipment
	category = "Objective-Specific Equipment"
	name = "Objective-Specific Equipment"
	desc = "Equipment necessary for accomplishing specific objectives. If you are seeing this, something has gone wrong."
	limited_stock = 1
	illegal_tech = FALSE

/datum/uplink_item/special_equipment/purchase(mob/user, datum/component/uplink/U)
	..()
	if(user?.mind?.failed_special_equipment)
		user.mind.failed_special_equipment -= item

/// Code that enables the ability to have limited stock that is shared by different items
/datum/shared_uplink_stock
