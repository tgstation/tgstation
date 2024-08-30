/datum/market_item
	/// Name for the item entry used in the uplink.
	var/name
	/// Description for the item entry used in the uplink.
	var/desc
	/// The category this item belongs to, should be already declared in the market that this item is accessible in.
	var/category
	/// "/datum/market"s that this item should be in, used by SSmarket on init.
	var/list/markets = list(/datum/market/blackmarket)

	/// Price for the item, if not set creates a price according to the *_min and *_max vars.
	var/price
	/// How many of this type of item is available, if not set creates a price according to the *_min and *_max vars.
	var/stock

	/// Path to or the item itself what this entry is for, this should be set even if you override spawn_item to spawn your item.
	var/atom/movable/item

	/// Used to exclude abstract/special paths from the unit test if the value matches the type itself.
	var/abstract_path

	/// Minimum price for the item if generated randomly.
	var/price_min = 0
	/// Maximum price for the item if generated randomly.
	var/price_max = 0
	/// Minimum amount that there should be of this item in the market if generated randomly. This defaults to 1 as most items will have it as 1.
	var/stock_min = 1
	/// Maximum amount that there should be of this item in the market if generated randomly.
	var/stock_max = 0
	/// Probability for this item to be available. Used by SSmarket on init.
	var/availability_prob

	///The identifier for the market item, generated on runtime and used to access them in the market categories.
	var/identifier

	///If set, these will override the shipment methods set by the market
	var/list/shipping_override

	/// Can this item be restocked
	var/restockable = TRUE

/datum/market_item/New()
	if(isnull(price))
		price = rand(price_min, price_max)
	if(isnull(stock))
		stock = rand(stock_min, stock_max)
	identifier = "[type]"

///For 'dynamic' market items generated on runtime, this proc is to be used to properly sets the item, especially if it's a hardref.
/datum/market_item/proc/set_item(path_or_ref)
	//we're replacing the item to sell, and the old item is an instance!
	if(ismovable(item))
		UnregisterSignal(item, COMSIG_QDELETING)
	item = path_or_ref
	identifier = "[path_or_ref]"
	if(ismovable(path_or_ref))
		RegisterSignal(item, COMSIG_QDELETING, PROC_REF(on_item_del))
		identifier = "[REF(src)]"

/datum/market_item/Destroy()
	item = null
	return ..()

/datum/market_item/proc/on_item_del(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// Used for spawning the wanted item, override if you need to do something special with the item.
/datum/market_item/proc/spawn_item(loc, datum/market_purchase/purchase)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MARKET_ITEM_SPAWNED, purchase.uplink, purchase.method, loc)
	if(ismovable(item))
		var/atom/movable/return_item = item
		UnregisterSignal(item, COMSIG_QDELETING)
		item.visible_message(span_notice("[item] vanishes..."))
		do_sparks(8, FALSE, item)
		if(isnull(loc))
			item.moveToNullspace()
		else
			item.forceMove(loc)
		item = null
		return return_item
	if(ispath(item))
		return new item(loc)
	CRASH("Invalid item type for market item [item || "null"]")

/**
 * Buys the item and makes SSmarket handle it.
 *
 * @param uplink The uplink that is buying the item.
 * @param buyer The mob that is buying the item.
 * @param shipping_method The shipping method used to get the market item onto the station.
 * @param legal_status The legal status of the market. Determines if the item to be spawned is contraband.
 */
/datum/market_item/proc/buy(obj/item/market_uplink/uplink, mob/buyer, shipping_method, legal_status)
	SHOULD_CALL_PARENT(TRUE)
	// Sanity
	if(!istype(uplink) || !istype(buyer))
		return FALSE

	// This shouldn't be able to happen unless there was some manipulation or admin fuckery.
	if(!item || stock <= 0)
		return FALSE

	// Alright, the item has been purchased.
	var/datum/market_purchase/purchase = new(src, uplink, shipping_method, legal_status)

	// SSmarket takes care of the shipping.
	if(SSmarket.queue_item(purchase))
		stock--
		buyer.log_message("has succesfully purchased [name] using [shipping_method] for shipping.", LOG_ECON)
		return TRUE
	return FALSE


// This exists because it is easier to keep track of all the vars this way.
/datum/market_purchase
	/// The entry being purchased.
	var/datum/market_item/entry
	/// Instance of the item being sent, used by the market telepad
	var/atom/movable/item
	/// The uplink where this purchase was done from.
	var/obj/item/market_uplink/uplink
	/// Shipping method used to buy this item.
	var/method
	/// Is this item considered contraband? If illegal, applies the contraband trait to the item when spawned.
	var/legallity

/datum/market_purchase/New(datum/market_item/entry, obj/item/market_uplink/uplink, method, legal_status)
	if(!uplink || !entry || !method)
		CRASH("[type] created with a false value arg: (entry: [entry] - uplink: [uplink] - method: [method])")
	src.entry = entry
	src.uplink = uplink
	src.method = method
	src.legallity = legal_status
	RegisterSignal(entry, COMSIG_QDELETING, PROC_REF(on_instance_del))
	RegisterSignal(uplink, COMSIG_QDELETING, PROC_REF(on_instance_del))
	if(ismovable(entry.item))
		item = entry.item
		RegisterSignal(entry.item, COMSIG_QDELETING, PROC_REF(on_instance_del))

/datum/market_purchase/Destroy()
	entry = null
	uplink = null
	SSmarket.queued_purchases -= src
	return ..()

/datum/market_purchase/proc/on_instance_del(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	// Uh oh, uplink or item is gone. We will just keep the money and you will not get your order.
	qdel(src)

/**
 * Proc that applies secondary effects to objects that are spawned via a market.
 *
 * @param spawned_item - Reference to the atom being spawned.
 * @param legal_status - Is this item considered legal? If illegal, will apply the contraband trait to the spawned item.
 */
/datum/market_purchase/proc/post_purchase_effects(atom/spawned_item)
	if(!legallity && isobj(spawned_item))
		ADD_TRAIT(spawned_item, TRAIT_CONTRABAND, INNATE_TRAIT)
