/*
 * Vending machine types - Can be found under /code/modules/vending/
 */

/*

/obj/machinery/vending/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	products = list()
	contraband = list()
	premium = list()
*/

#define MAX_VENDING_INPUT_AMOUNT 30
/**
 * # vending record datum
 *
 * A datum that represents a product that is vendable
 */
/datum/data/vending_product
	name = "generic"
	///Typepath of the product that is created when this record "sells"
	var/product_path = null
	///How many of this product we currently have
	var/amount = 0
	///How many we can store at maximum
	var/max_amount = 0
	///Does the item have a custom price override
	var/custom_price
	///Does the item have a custom premium price override
	var/custom_premium_price
	///Whether spessmen with an ID with an age below AGE_MINOR (20 by default) can buy this item
	var/age_restricted = FALSE
	///Whether the product can be recolored by the GAGS system
	var/colorable
	/// The category the product was in, if any.
	/// Sourced directly from product_categories.
	var/category
	///List of items that have been returned to the vending machine.
	var/list/returned_products

/**
 * # vending machines
 *
 * Captalism in the year 2525, everything in a vending machine, even love
 */
/obj/machinery/vending
	name = "\improper Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "generic"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	max_integrity = 300
	integrity_failure = 0.33
	armor_type = /datum/armor/machinery_vending
	circuit = /obj/item/circuitboard/machine/vendor
	payment_department = ACCOUNT_SRV
	light_power = 0.7
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	voice_filter = "alimiter=0.9,acompressor=threshold=0.2:ratio=20:attack=10:release=50:makeup=2,highpass=f=1000"

	/// Is the machine active (No sales pitches if off)!
	var/active = 1
	///Are we ready to vend?? Is it time??
	var/vend_ready = TRUE
	///Next world time to send a purchase message
	var/purchase_message_cooldown
	///The ref of the last mob to shop with us
	var/last_shopper
	var/tilted = FALSE
	/// If tilted, this variable should always be the rotation that was applied when we were tilted. Stored for the purposes of unapplying it.
	var/tilted_rotation = 0
	var/tiltable = TRUE
	var/squish_damage = 75
	/// The chance, in percent, of this vendor performing a critical hit on anything it crushes via [tilt].
	var/crit_chance = 15
	/// If set to a critical define in crushing.dm, anything this vendor crushes will always be hit with that effect.
	var/forcecrit = null
	var/num_shards = 7
	var/list/pinned_mobs = list()
	///Icon for the maintenance panel overlay
	var/panel_type = "panel1"

	/**
	  * List of products this machine sells
	  *
	  * form should be list(/type/path = amount, /type/path2 = amount2)
	  */
	var/list/products = list()

	/**
	 * List of products this machine sells, categorized.
	 * Can only be used as an alternative to `products`, not alongside it.
	 *
	 * Form should be list(
	 * 	"name" = "Category Name",
	 * 	"icon" = "UI Icon (Font Awesome or tgfont)",
	 * 	"products" = list(/type/path = amount, ...),
	 * )
	 */
	var/list/product_categories = null

	/**
	  * List of products this machine sells when you hack it
	  *
	  * form should be list(/type/path = amount, /type/path2 = amount2)
	  */
	var/list/contraband = list()

	/**
	  * List of premium products this machine sells
	  *
	  * form should be list(/type/path, /type/path2) as there is only ever one in stock
	  */
	var/list/premium = list()

	///String of slogans separated by semicolons, optional
	var/product_slogans = ""
	///String of small ad messages in the vending screen - random chance
	var/product_ads = ""

	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
	var/list/slogan_list = list()
	///Small ad messages in the vending screen - random chance of popping up whenever you open it
	var/list/small_ads = list()
	///Message sent post vend (Thank you for shopping!)
	var/vend_reply
	///Last world tick we sent a vent reply
	var/last_reply = 0
	///Last world tick we sent a slogan message out
	var/last_slogan = 0
	///How many ticks until we can send another
	var/slogan_delay = 6000
	///Icon when vending an item to the user
	var/icon_vend
	///Icon to flash when user is denied a vend
	var/icon_deny
	///World ticks the machine is electified for
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	///When this is TRUE, we fire items at customers! We're broken!
	var/shoot_inventory = FALSE
	///How likely this is to happen (prob 100) per second
	var/shoot_inventory_chance = 1
	//Stop spouting those godawful pitches!
	var/shut_up = FALSE
	///can we access the hidden inventory?
	var/extended_inventory = FALSE
	///Are we checking the users ID
	var/scan_id = TRUE
	///Coins that we accept?
	var/obj/item/coin/coin
	///Bills we accept?
	var/obj/item/stack/spacecash/bill
	///Default price of items if not overridden
	var/default_price = 25
	///Default price of premium items if not overridden
	var/extra_price = 50
	///Whether our age check is currently functional
	var/age_restrictions = TRUE
	/**
	  * Is this item on station or not
	  *
	  * if it doesn't originate from off-station during mapload, everything is free
	  * if it's off-station during mapload, it's also safe from the brand intelligence event
	  */
	var/onstation = TRUE
	/**
	 * A variable to change on a per instance basis on the map that allows the instance
	 * to ignore whether it's on the station or not.
	 * Useful to force cost and ID requirements. DO NOT APPLY THIS GLOBALLY.
	 */
	var/onstation_override = FALSE

	var/list/vending_machine_input = list()
	///Display header on the input view
	var/input_display_header = "Custom Vendor"

	//The type of refill canisters used by this machine.
	var/obj/item/vending_refill/refill_canister = null

	/// how many items have been inserted in a vendor
	var/loaded_items = 0

	///Name of lighting mask for the vending machine
	var/light_mask

	/// used for narcing on underages
	var/obj/item/radio/sec_radio

/**
 * Initialize the vending machine
 *
 * Builds the vending machine inventory, sets up slogans and other such misc work
 *
 * This also sets the onstation var to:
 * * FALSE - if the machine was maploaded on a zlevel that doesn't pass the is_station_level check
 * * TRUE - all other cases
 */
/datum/armor/machinery_vending
	melee = 20
	fire = 50
	acid = 70

/obj/machinery/vending/Initialize(mapload)
	var/build_inv = FALSE
	if(!refill_canister)
		circuit = null
		build_inv = TRUE
	. = ..()
	set_wires(new /datum/wires/vending(src))

	if(SStts.tts_enabled)
		var/static/vendor_voice_by_type = list()
		if(!vendor_voice_by_type[type])
			vendor_voice_by_type[type] = pick(SStts.available_speakers)
		voice = vendor_voice_by_type[type]

	if(build_inv) //non-constructable vending machine
		build_inventories()

	slogan_list = splittext(product_slogans, ";")
	// So not all machines speak at the exact same time.
	// The first time this machine says something will be at slogantime + this random value,
	// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
	last_slogan = world.time + rand(0, slogan_delay)
	power_change()

	if(mapload) //check if it was initially created off station during mapload.
		if(!is_station_level(z))
			if(!onstation_override)
				onstation = FALSE
			if(circuit)
				circuit.onstation = onstation //sync up the circuit so the pricing schema is carried over if it's reconstructed.
		else if(HAS_TRAIT(SSstation, STATION_TRAIT_VENDING_SHORTAGE))
			for (var/datum/data/vending_product/product_record as anything in product_records + coin_records + hidden_records)
				/**
				 * in average, it should be 37.5% of the max amount, rounded up to the nearest int,
				 * tho the max boundary can be as low/high as 50%/100%
				 */
				var/max_amount = rand(CEILING(product_record.amount * 0.5, 1), product_record.amount)
				product_record.amount = rand(0, max_amount)
			if(tiltable && prob(6)) // 1 in 17 chance to start tilted (as an additional hint to the station trait behind it)
				INVOKE_ASYNC(src, PROC_REF(tilt), loc)
	else if(circuit && (circuit.onstation != onstation)) //check if they're not the same to minimize the amount of edited values.
		onstation = circuit.onstation //if it was constructed outside mapload, sync the vendor up with the circuit's var so you can't bypass price requirements by moving / reconstructing it off station.

/obj/machinery/vending/Destroy()
	QDEL_NULL(wires)
	QDEL_NULL(coin)
	QDEL_NULL(bill)
	QDEL_NULL(sec_radio)
	return ..()

/obj/machinery/vending/can_speak()
	return !shut_up

/obj/machinery/vending/emp_act(severity)
	. = ..()
	var/datum/language_holder/vending_languages = get_language_holder()
	var/datum/wires/vending/vending_wires = wires
	// if the language wire got pulsed during an EMP, this will make sure the language_iterator is synched correctly
	vending_languages.selected_language = vending_languages.spoken_languages[vending_wires.language_iterator]

//Better would be to make constructable child
/obj/machinery/vending/RefreshParts()
	SHOULD_CALL_PARENT(FALSE)
	if(!component_parts)
		return

	build_products_from_categories()

	product_records = list()
	hidden_records = list()
	coin_records = list()

	build_inventories(start_empty = TRUE)

	for(var/obj/item/vending_refill/VR in component_parts)
		restock(VR)

/obj/machinery/vending/deconstruct(disassembled = TRUE)
	if(!refill_canister) //the non constructable vendors drop metal instead of a machine frame.
		if(!(flags_1 & NODECONSTRUCT_1))
			new /obj/item/stack/sheet/iron(loc, 3)
		qdel(src)
	else
		..()

/obj/machinery/vending/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & BROKEN)
		set_light(0)
		return
	set_light(powered() ? MINIMUM_USEFUL_LIGHT_RANGE : 0)


/obj/machinery/vending/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return ..()
	icon_state = "[initial(icon_state)][powered() ? null : "-off"]"
	return ..()


/obj/machinery/vending/update_overlays()
	. = ..()
	if(panel_open)
		. += panel_type
	if(light_mask && !(machine_stat & BROKEN) && powered())
		. += emissive_appearance(icon, light_mask, src)

/obj/machinery/vending/atom_break(damage_flag)
	. = ..()
	if(!.)
		return

	var/dump_amount = 0
	var/found_anything = TRUE
	while (found_anything)
		found_anything = FALSE
		for(var/record in shuffle(product_records))
			var/datum/data/vending_product/R = record

			//first dump any of the items that have been returned, in case they contain the nuke disk or something
			for(var/obj/returned_obj_to_dump in R.returned_products)
				LAZYREMOVE(R.returned_products, returned_obj_to_dump)
				returned_obj_to_dump.forceMove(get_turf(src))
				step(returned_obj_to_dump, pick(GLOB.alldirs))
				R.amount--

			if(R.amount <= 0) //Try to use a record that actually has something to dump.
				continue
			var/dump_path = R.product_path
			if(!dump_path)
				continue
			R.amount--
			// busting open a vendor will destroy some of the contents
			if(found_anything && prob(80))
				continue

			var/obj/obj_to_dump = new dump_path(loc)
			step(obj_to_dump, pick(GLOB.alldirs))
			found_anything = TRUE
			dump_amount++
			if (dump_amount >= 16)
				return

/**
 * Build the inventory of the vending machine from it's product and record lists
 *
 * This builds up a full set of /datum/data/vending_products from the product list of the vending machine type
 * Arguments:
 * * productlist - the list of products that need to be converted
 * * recordlist - the list containing /datum/data/vending_product datums
 * * categories - A list in the format of product_categories to source category from
 * * startempty - should we set vending_product record amount from the product list (so it's prefilled at roundstart)
 */
/obj/machinery/vending/proc/build_inventory(list/productlist, list/recordlist, list/categories, start_empty = FALSE)
	default_price = round(initial(default_price))
	extra_price = round(initial(extra_price))
	if(HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING))
		default_price *= SSeconomy.inflation_value()
		extra_price *= SSeconomy.inflation_value()

	var/list/product_to_category = list()
	for (var/list/category as anything in categories)
		var/list/products = category["products"]
		for (var/product_key in products)
			product_to_category[product_key] = category

	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		if(isnull(amount))
			amount = 0

		var/obj/item/temp = typepath
		var/datum/data/vending_product/R = new /datum/data/vending_product()
		R.name = initial(temp.name)
		R.product_path = typepath
		if(!start_empty)
			R.amount = amount
		R.max_amount = amount
		///Prices of vending machines are all increased uniformly.
		R.custom_price = round(initial(temp.custom_price))
		R.custom_premium_price = round(initial(temp.custom_premium_price))
		if(HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING))
			R.custom_price = round(initial(temp.custom_price) * SSeconomy.inflation_value())
			R.custom_premium_price = round(initial(temp.custom_premium_price) * SSeconomy.inflation_value())
		R.age_restricted = initial(temp.age_restricted)
		R.colorable = !!(initial(temp.greyscale_config) && initial(temp.greyscale_colors) && (initial(temp.flags_1) & IS_PLAYER_COLORABLE_1))
		R.category = product_to_category[typepath]
		recordlist += R

/obj/machinery/vending/proc/build_inventories(start_empty)
	build_inventory(products, product_records, product_categories, start_empty)
	build_inventory(contraband, hidden_records, create_categories_from(contraband, "mask", "Contraband"), start_empty)
	build_inventory(premium, coin_records, create_categories_from(premium, "coins", "Premium"), start_empty)

/obj/machinery/vending/proc/create_categories_from(products, icon, name)
	return list(list(
		"name" = name,
		"icon" = icon,
		"products" = products,
	))

/obj/machinery/vending/proc/build_products_from_categories()
	if (isnull(product_categories))
		return

	products = list()

	for (var/list/category in product_categories)
		var/list/category_products = category["products"]
		for (var/product_key in category_products)
			products[product_key] += category_products[product_key]

/**
 * Reassign the prices of the vending machine as a result of the inflation value, as provided by SSeconomy
 *
 * This rebuilds both /datum/data/vending_products lists for premium and standard products based on their most relevant pricing values.
 * Arguments:
 * * recordlist - the list of standard product datums in the vendor to refresh their prices.
 * * premiumlist - the list of premium product datums in the vendor to refresh their prices.
 */
/obj/machinery/vending/proc/reset_prices(list/recordlist, list/premiumlist)
	var/crash_status = HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING)
	default_price = round(initial(default_price))
	extra_price = round(initial(extra_price))
	if(crash_status)
		default_price *= SSeconomy.inflation_value()
		extra_price *= SSeconomy.inflation_value()

	for(var/R in recordlist)
		var/datum/data/vending_product/record = R
		var/obj/item/potential_product = record.product_path
		record.custom_price = round(initial(potential_product.custom_price))
		if(crash_status)
			record.custom_price = round(initial(potential_product.custom_price) * SSeconomy.inflation_value())
	for(var/R in premiumlist)
		var/datum/data/vending_product/record = R
		var/obj/item/potential_product = record.product_path
		var/premium_sanity = round(initial(potential_product.custom_premium_price))
		if(premium_sanity)
			record.custom_premium_price = round(premium_sanity)
			if(crash_status)
				record.custom_premium_price = round(premium_sanity * SSeconomy.inflation_value())
			continue
		//For some ungodly reason, some premium only items only have a custom_price
		record.custom_premium_price = round(extra_price + (initial(potential_product.custom_price)))
		if(crash_status)
			record.custom_premium_price = round(extra_price + (initial(potential_product.custom_price) * (SSeconomy.inflation_value() - 1)))

/**
 * Refill a vending machine from a refill canister
 *
 * This takes the products from the refill canister and then fills the products,contraband and premium product categories
 *
 * Arguments:
 * * canister - the vending canister we are refilling from
 */
/obj/machinery/vending/proc/restock(obj/item/vending_refill/canister)
	if (!canister.products)
		canister.products = products.Copy()
	if (!canister.contraband)
		canister.contraband = contraband.Copy()
	if (!canister.premium)
		canister.premium = premium.Copy()

	. = 0

	if (isnull(canister.product_categories) && !isnull(product_categories))
		canister.product_categories = product_categories.Copy()

	if (!isnull(canister.product_categories))
		var/list/products_unwrapped = list()
		for (var/list/category as anything in canister.product_categories)
			var/list/products = category["products"]
			for (var/product_key in products)
				products_unwrapped[product_key] += products[product_key]

		. += refill_inventory(products_unwrapped, product_records)
	else
		. += refill_inventory(canister.products, product_records)

	. += refill_inventory(canister.contraband, hidden_records)
	. += refill_inventory(canister.premium, coin_records)

	return .

/**
 * Refill our inventory from the passed in product list into the record list
 *
 * Arguments:
 * * productlist - list of types -> amount
 * * recordlist - existing record datums
 */
/obj/machinery/vending/proc/refill_inventory(list/productlist, list/recordlist)
	. = 0
	for(var/R in recordlist)
		var/datum/data/vending_product/record = R
		var/diff = min(record.max_amount - record.amount, productlist[record.product_path])
		if (diff)
			productlist[record.product_path] -= diff
			record.amount += diff
			. += diff

/**
 * Set up a refill canister that matches this machines products
 *
 * This is used when the machine is deconstructed, so the items aren't "lost"
 */
/obj/machinery/vending/proc/update_canister()
	if (!component_parts)
		return

	var/obj/item/vending_refill/R = locate() in component_parts
	if (!R)
		CRASH("Constructible vending machine did not have a refill canister")

	unbuild_inventory_into(product_records, R.products, R.product_categories)

	R.contraband = unbuild_inventory(hidden_records)
	R.premium = unbuild_inventory(coin_records)

/**
 * Given a record list, go through and and return a list of type -> amount
 */
/obj/machinery/vending/proc/unbuild_inventory(list/recordlist)
	. = list()
	for(var/R in recordlist)
		var/datum/data/vending_product/record = R
		.[record.product_path] += record.amount

/// Put stuff in product_categories if the products have a category, otherwise put them in products
/obj/machinery/vending/proc/unbuild_inventory_into(list/product_records, list/products, list/product_categories)
	products?.Cut()
	product_categories?.Cut()

	var/others_have_category = null

	var/list/categories_to_index = list()

	for (var/datum/data/vending_product/record as anything in product_records)
		var/list/category = record.category
		var/has_category = !isnull(category)

		if (isnull(others_have_category))
			others_have_category = has_category
		else if (others_have_category != has_category)
			if (has_category)
				WARNING("[record.product_path] in [type] has a category, but other products don't")
			else
				WARNING("[record.product_path] in [type] does not have a category, but other products do")

			continue

		if (has_category)
			var/index = categories_to_index.Find(category)

			if (index)
				var/list/category_in_list = product_categories[index]
				var/list/products_in_category = category_in_list["products"]
				products_in_category[record.product_path] += record.amount
			else
				categories_to_index += list(category)
				index = categories_to_index.len

				var/list/category_clone = category.Copy()

				var/list/initial_product_list = list()
				initial_product_list[record.product_path] = record.amount
				category_clone["products"] = initial_product_list

				product_categories += list(category_clone)
		else
			products[record.product_path] = record.amount

/obj/machinery/vending/crowbar_act(mob/living/user, obj/item/I)
	if(!component_parts)
		return FALSE
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/vending/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!panel_open)
		return FALSE
	if(default_unfasten_wrench(user, tool, time = 6 SECONDS))
		unbuckle_all_mobs(TRUE)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	return FALSE

/obj/machinery/vending/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(anchored)
		default_deconstruction_screwdriver(user, icon_state, icon_state, I)
		update_appearance()
	else
		to_chat(user, span_warning("You must first secure [src]."))
	return TRUE

/obj/machinery/vending/attackby(obj/item/I, mob/living/user, params)
	if(panel_open && is_wire_tool(I))
		wires.interact(user)
		return

	if(refill_canister && istype(I, refill_canister))
		if (!panel_open)
			to_chat(user, span_warning("You should probably unscrew the service panel first!"))
		else if (machine_stat & (BROKEN|NOPOWER))
			to_chat(user, span_notice("[src] does not respond."))
		else
			//if the panel is open we attempt to refill the machine
			var/obj/item/vending_refill/canister = I
			if(canister.get_part_rating() == 0)
				to_chat(user, span_warning("[canister] is empty!"))
			else
				// instantiate canister if needed
				var/transferred = restock(canister)
				if(transferred)
					to_chat(user, span_notice("You loaded [transferred] items in [src]."))
				else
					to_chat(user, span_warning("There's nothing to restock!"))
			return
	if(compartmentLoadAccessCheck(user) && !user.combat_mode)
		if(canLoadItem(I))
			loadingAttempt(I,user)

		if(istype(I, /obj/item/storage/bag)) //trays USUALLY
			var/obj/item/storage/T = I
			var/loaded = 0
			var/denied_items = 0
			for(var/obj/item/the_item in T.contents)
				if(contents.len >= MAX_VENDING_INPUT_AMOUNT) // no more than 30 item can fit inside, legacy from snack vending although not sure why it exists
					to_chat(user, span_warning("[src]'s compartment is full."))
					break
				if(canLoadItem(the_item) && loadingAttempt(the_item,user))
					T.atom_storage?.attempt_remove(the_item, src)
					loaded++
				else
					denied_items++
			if(denied_items)
				to_chat(user, span_warning("[src] refuses some items!"))
			if(loaded)
				to_chat(user, span_notice("You insert [loaded] dishes into [src]'s compartment."))
	else
		. = ..()
		if(tiltable && !tilted && I.force)
			if(isclosedturf(get_turf(user))) //If the attacker is inside of a wall, immediately fall in the other direction, with no chance for goodies.
				var/opposite_direction = REVERSE_DIR(get_dir(src, user))
				var/target = get_step(src, opposite_direction)
				tilt(get_turf(target))
				return
			switch(rand(1, 100))
				if(1 to 5)
					freebie(user, 3)
				if(6 to 15)
					freebie(user, 2)
				if(16 to 25)
					freebie(user, 1)
				if(26 to 75)
					return
				if(76 to 100)
					tilt(user)

/obj/machinery/vending/proc/freebie(mob/fatty, freebies)
	visible_message(span_notice("[src] yields [freebies > 1 ? "several free goodies" : "a free goody"]!"))

	for(var/i in 1 to freebies)
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
		for(var/datum/data/vending_product/R in shuffle(product_records))

			if(R.amount <= 0) //Try to use a record that actually has something to dump.
				continue
			var/dump_path = R.product_path
			if(!dump_path)
				continue
			if(R.amount > LAZYLEN(R.returned_products)) //always give out new stuff that costs before free returned stuff, because of the risk getting gibbed involved
				new dump_path(get_turf(src))
			else
				var/obj/returned_obj_to_dump = LAZYACCESS(R.returned_products, LAZYLEN(R.returned_products)) //first in, last out
				LAZYREMOVE(R.returned_products, returned_obj_to_dump)
				returned_obj_to_dump.forceMove(get_turf(src))
			R.amount--
			break

/// Tilts ontop of the atom supplied, if crit is true some extra shit can happen. See [fall_and_crush] for return values.
/obj/machinery/vending/proc/tilt(atom/fatty, local_crit_chance = crit_chance, forced_crit = forcecrit)
	if(QDELETED(src) || !has_gravity(src))
		return

	. = NONE

	var/picked_rotation = pick(90, 270)
	if(Adjacent(fatty))
		. = fall_and_crush(get_turf(fatty), squish_damage, local_crit_chance, forced_crit, 6 SECONDS, rotation = picked_rotation)

		if (. & SUCCESSFULLY_FELL_OVER)
			visible_message(span_danger("[src] tips over!"))
			tilted = TRUE
			tilted_rotation = picked_rotation
			layer = ABOVE_MOB_LAYER
			SET_PLANE_IMPLICIT(src, GAME_PLANE_UPPER)

	if(get_turf(fatty) != get_turf(src))
		throw_at(get_turf(fatty), 1, 1, spin = FALSE, quickstart = FALSE)

/**
 * Causes src to fall onto [target], crushing everything on it (including itself) with [damage]
 * and a small chance to do a spectacular effect per entity (if a chance above 0 is provided).
 *
 * Args:
 * * turf/target: The turf to fall onto. Cannot be null.
 * * damage: The raw numerical damage to do by default.
 * * chance_to_crit: The percent chance of a critical hit occuring. Default: 0
 * * forced_crit_case: If given a value from crushing.dm, [target] and it's contents will always be hit with that specific critical hit. Default: null
 * * paralyze_time: The time, in deciseconds, a given mob/living will be paralyzed for if crushed.
 * * crush_dir: The direction the crush is coming from. Default: dir of src to [target].
 * * damage_type: The type of damage to do. Default: BRUTE
 * * damage_flag: The attack flag for armor purposes. Default: MELEE
 * * rotation: The angle of which to rotate src's transform by on a successful tilt. Default: 90.
 *
 * Returns: A collection of bitflags defined in crushing.dm. Read that file's documentation for info.
 */
/atom/movable/proc/fall_and_crush(turf/target, damage, chance_to_crit = 0, forced_crit_case = null, paralyze_time, crush_dir = get_dir(get_turf(src), target), damage_type = BRUTE, damage_flag = MELEE, rotation = 90)

	ASSERT(!isnull(target))

	var/flags_to_return = NONE

	if (!target.is_blocked_turf(TRUE, src, list(src)))
		for(var/atom/atom_target in (target.contents) + target)
			if (isarea(atom_target))
				continue

			if (SEND_SIGNAL(atom_target, COMSIG_PRE_TILT_AND_CRUSH, src) & COMPONENT_IMMUNE_TO_TILT_AND_CRUSH)
				continue

			var/crit_case = forced_crit_case
			if (isnull(crit_case) && chance_to_crit > 0)
				if (prob(chance_to_crit))
					crit_case = pick_weight(get_crit_crush_chances())
			var/crit_rebate_mult = 1 // lessen the normal damage we deal for some of the crits

			if (!isnull(crit_case))
				crit_rebate_mult = fall_and_crush_crit_rebate_table(crit_case)
				apply_crit_crush(crit_case, atom_target)

			var/adjusted_damage = damage * crit_rebate_mult
			var/crushed
			if (isliving(atom_target))
				crushed = TRUE
				var/mob/living/carbon/living_target = atom_target
				var/was_alive = (living_target.stat != DEAD)
				var/blocked = living_target.run_armor_check(attack_flag = damage_flag)
				if (iscarbon(living_target))
					var/mob/living/carbon/carbon_target = living_target
					if(prob(30))
						carbon_target.apply_damage(max(0, adjusted_damage), damage_type, blocked = blocked, forced = TRUE, spread_damage = TRUE, attack_direction = crush_dir) // the 30% chance to spread the damage means you escape breaking any bones
					else
						var/brute = (damage_type == BRUTE ? damage : 0) * 0.5
						var/burn = (damage_type == BURN ? damage : 0) * 0.5
						carbon_target.take_bodypart_damage(brute, burn, check_armor = TRUE, wound_bonus = 5) // otherwise, deal it to 2 random limbs (or the same one) which will likely shatter something
						carbon_target.take_bodypart_damage(brute, burn, check_armor = TRUE, wound_bonus = 5)
					carbon_target.AddElement(/datum/element/squish, 80 SECONDS)
				else
					living_target.apply_damage(adjusted_damage, damage_type, blocked = blocked, forced = TRUE, attack_direction = crush_dir)

				living_target.Paralyze(paralyze_time)
				living_target.emote("scream")
				playsound(living_target, 'sound/effects/blobattack.ogg', 40, TRUE)
				playsound(living_target, 'sound/effects/splat.ogg', 50, TRUE)
				post_crush_living(living_target, was_alive)
				flags_to_return |= (SUCCESSFULLY_CRUSHED_MOB|SUCCESSFULLY_CRUSHED_ATOM)

			else if (atom_target.uses_integrity && !(atom_target.invisibility > SEE_INVISIBLE_LIVING) && !(is_type_in_typecache(atom_target, GLOB.WALLITEMS_INTERIOR) || is_type_in_typecache(atom_target, GLOB.WALLITEMS_EXTERIOR)))
				atom_target.take_damage(adjusted_damage, damage_type, damage_flag, FALSE, crush_dir)
				crushed = TRUE
				flags_to_return |= SUCCESSFULLY_CRUSHED_ATOM

			if (crushed)
				atom_target.visible_message(span_danger("[atom_target] is crushed by [src]!"), span_userdanger("You are crushed by [src]!"))
				SEND_SIGNAL(atom_target, COMSIG_POST_TILT_AND_CRUSH, src)

		var/matrix/to_turn = turn(transform, rotation)
		animate(src, transform = to_turn, 0.2 SECONDS)
		playsound(src, 'sound/effects/bang.ogg', 40)

		visible_message(span_danger("[src] tips over, slamming hard onto [target]!"))
		flags_to_return |= SUCCESSFULLY_FELL_OVER
		post_tilt()
	else
		visible_message(span_danger("[src] rebounds comically as it fails to slam onto [target]!"))

	Move(target, crush_dir) // we still TRY to move onto it for shit like teleporters
	return flags_to_return

/**
 * Exists for the purposes of custom behavior.
 * Called directly after [crushed] is crushed.
 *
 * Args:
 * * mob/living/crushed: The mob that was crushed.
 * * was_alive: Boolean. True if the mob was alive before the crushing.
 */
/atom/movable/proc/post_crush_living(mob/living/crushed, was_alive)
	return

/**
 * Exists for the purposes of custom behavior.
 * Called directly after src actually rotates and falls over.
 */
/atom/movable/proc/post_tilt()
	return

/obj/machinery/vending/post_crush_living(mob/living/crushed, was_alive)

	if(was_alive && crushed.stat == DEAD && crushed.client)
		crushed.client.give_award(/datum/award/achievement/misc/vendor_squish, crushed) // good job losing a fight with an inanimate object idiot

	add_memory_in_range(crushed, 7, /datum/memory/witness_vendor_crush, protagonist = crushed, antagonist = src)

	return ..()

/**
 * Allows damage to be reduced on certain crit cases.
 * Args:
 * * crit_case: The critical case chosen.
 */
/atom/movable/proc/fall_and_crush_crit_rebate_table(crit_case)

	ASSERT(!isnull(crit_case))

	switch(crit_case)
		if (CRUSH_CRIT_SHATTER_LEGS)
			return 0.2
		else
			return 1

/obj/machinery/vending/fall_and_crush_crit_rebate_table(crit_case)

	if (crit_case == VENDOR_CRUSH_CRIT_GLASSCANDY)
		return 0.33

	return ..()

/**
 * Returns a assoc list of (critcase -> num), where critcase is a critical define in crushing.dm and num is a weight.
 * Use with pickweight to acquire a random critcase.
 */
/atom/movable/proc/get_crit_crush_chances()
	RETURN_TYPE(/list)

	var/list/weighted_crits = list()

	weighted_crits[CRUSH_CRIT_SHATTER_LEGS] = 100
	weighted_crits[CRUSH_CRIT_PARAPALEGIC] = 80
	weighted_crits[CRUSH_CRIT_HEADGIB] = 20
	weighted_crits[CRUSH_CRIT_SQUISH_LIMB] = 100

	return weighted_crits

/obj/machinery/vending/get_crit_crush_chances()
	var/list/weighted_crits = ..()

	weighted_crits[VENDOR_CRUSH_CRIT_GLASSCANDY] = 100
	weighted_crits[VENDOR_CRUSH_CRIT_PIN] = 100

	return weighted_crits

/**
 * Should be where critcase effects are actually implemented. Use this to apply critcases.
 * Args:
 * * crit_case: The chosen critcase, defined in crushing.dm.
 * * atom/atom_target: The target to apply the critical hit to. Cannot be null. Can be anything except /area.
 *
 * Returns:
 * TRUE if a crit case is successfully applied, FALSE otherwise.
 */
/atom/movable/proc/apply_crit_crush(crit_case, atom/atom_target)
	switch (crit_case)
		if(CRUSH_CRIT_SHATTER_LEGS) // shatter their legs and bleed 'em
			if (!iscarbon(atom_target))
				return FALSE
			var/mob/living/carbon/carbon_target = atom_target
			carbon_target.bleed(150)
			var/obj/item/bodypart/leg/left/left_leg = carbon_target.get_bodypart(BODY_ZONE_L_LEG)
			if(left_leg)
				left_leg.receive_damage(brute = 200)
			var/obj/item/bodypart/leg/right/right_leg = carbon_target.get_bodypart(BODY_ZONE_R_LEG)
			if(right_leg)
				right_leg.receive_damage(brute = 200)
			if(left_leg || right_leg)
				carbon_target.visible_message(span_danger("[carbon_target]'s legs shatter with a sickening crunch!"), span_userdanger("Your legs shatter with a sickening crunch!"))
			return TRUE
		if(CRUSH_CRIT_PARAPALEGIC) // paralyze this binch
			// the new paraplegic gets like 4 lines of losing their legs so skip them
			if (!iscarbon(atom_target))
				return FALSE
			var/mob/living/carbon/carbon_target = atom_target
			visible_message(span_danger("[carbon_target]'s spinal cord is obliterated with a sickening crunch!"), ignored_mobs = list(carbon_target))
			carbon_target.gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic)
			return TRUE
		if(CRUSH_CRIT_SQUISH_LIMB) // limb squish!
			if (!iscarbon(atom_target))
				return FALSE
			var/mob/living/carbon/carbon_target = atom_target
			for(var/obj/item/bodypart/squish_part in carbon_target.bodyparts)
				if(IS_ORGANIC_LIMB(squish_part))
					var/type_wound = pick(list(/datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/moderate))
					squish_part.force_wound_upwards(type_wound, wound_source = "crushed by [src]")
				else
					squish_part.receive_damage(brute=30)
			carbon_target.visible_message(span_danger("[carbon_target]'s body is maimed underneath the mass of [src]!"), span_userdanger("Your body is maimed underneath the mass of [src]!"))
			return TRUE
		if(CRUSH_CRIT_HEADGIB) // skull squish!
			if (!iscarbon(atom_target))
				return FALSE
			var/mob/living/carbon/carbon_target = atom_target
			var/obj/item/bodypart/head/carbon_head = carbon_target.get_bodypart(BODY_ZONE_HEAD)
			if(carbon_head)
				if(carbon_head.dismember())
					carbon_target.visible_message(span_danger("[carbon_head] explodes in a shower of gore beneath [src]!"),	span_userdanger("Oh f-"))
					carbon_head.drop_organs()
					qdel(carbon_head)
					new /obj/effect/gibspawner/human/bodypartless(get_turf(carbon_target))
			return TRUE

	return FALSE

/obj/machinery/vending/apply_crit_crush(crit_case, atom_target)
	. = ..()

	if (.)
		return TRUE

	switch (crit_case)
		if (VENDOR_CRUSH_CRIT_GLASSCANDY)
			if (!iscarbon(atom_target))
				return FALSE
			var/mob/living/carbon/carbon_target = atom_target
			for(var/i in 1 to num_shards)
				var/obj/item/shard/shard = new /obj/item/shard(get_turf(carbon_target))
				shard.embedding = list(embed_chance = 100, ignore_throwspeed_threshold = TRUE, impact_pain_mult = 1, pain_chance = 5)
				shard.updateEmbedding()
				carbon_target.hitby(shard, skipcatch = TRUE, hitpush = FALSE)
				shard.embedding = list()
				shard.updateEmbedding()
			return TRUE
		if (VENDOR_CRUSH_CRIT_PIN) // pin them beneath the machine until someone untilts it
			if (!isliving(atom_target))
				return FALSE
			var/mob/living/living_target = atom_target
			forceMove(get_turf(living_target))
			buckle_mob(living_target, force=TRUE)
			living_target.visible_message(span_danger("[living_target] is pinned underneath [src]!"), span_userdanger("You are pinned down by [src]!"))
			return TRUE

	return FALSE

/obj/machinery/vending/proc/untilt(mob/user)
	if(user)
		user.visible_message(span_notice("[user] rights [src]."), \
			span_notice("You right [src]."))

	unbuckle_all_mobs(TRUE)

	tilted = FALSE
	layer = initial(layer)
	SET_PLANE_IMPLICIT(src, initial(plane))

	var/matrix/to_turn = turn(transform, -tilted_rotation)
	animate(src, transform = to_turn, 0.2 SECONDS)
	tilted_rotation = 0

/obj/machinery/vending/proc/loadingAttempt(obj/item/I, mob/user)
	. = TRUE
	if(!user.transferItemToLoc(I, src))
		return FALSE
	to_chat(user, span_notice("You insert [I] into [src]'s input compartment."))

	for(var/datum/data/vending_product/product_datum in product_records + coin_records + hidden_records)
		if(ispath(I.type, product_datum.product_path))
			product_datum.amount++
			LAZYADD(product_datum.returned_products, I)
			return

	if(vending_machine_input[format_text(I.name)])
		vending_machine_input[format_text(I.name)]++
	else
		vending_machine_input[format_text(I.name)] = 1
	loaded_items++

/obj/machinery/vending/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	if(!force)
		return
	. = ..()

/**
 * Is the passed in user allowed to load this vending machines compartments? This only is ran if we are using a /obj/item/storage/bag to load the vending machine, and not a dedicated restocker.
 *
 * Arguments:
 * * user - mob that is doing the loading of the vending machine
 */
/obj/machinery/vending/proc/compartmentLoadAccessCheck(mob/user)
	if(!req_access || allowed(user) || (obj_flags & EMAGGED) || !scan_id)
		return TRUE

	to_chat(user, span_warning("[src]'s input compartment blinks red: Access denied."))
	return FALSE

/obj/machinery/vending/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W))
		return FALSE
	if((flags_1 & NODECONSTRUCT_1) && !W.works_from_distance)
		return FALSE
	if(!component_parts || !refill_canister)
		return FALSE

	var/moved = 0
	if(panel_open || W.works_from_distance)
		if(W.works_from_distance)
			display_parts(user)
		for(var/I in W)
			if(istype(I, refill_canister))
				moved += restock(I)
	else
		display_parts(user)
	if(moved)
		to_chat(user, span_notice("[moved] items restocked."))
		W.play_rped_sound()
	return TRUE

/obj/machinery/vending/on_deconstruction()
	update_canister()
	. = ..()

/obj/machinery/vending/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "product lock disabled")
	return TRUE

/obj/machinery/vending/interact(mob/user)
	if (!isAI(user))
		if(seconds_electrified && !(machine_stat & NOPOWER))
			if(shock(user, 100))
				return

		if(tilted && !user.buckled && !isAdminGhostAI(user))
			to_chat(user, span_notice("You begin righting [src]."))
			if(do_after(user, 50, target=src))
				untilt(user)
			return

	return ..()

/obj/machinery/vending/attack_robot_secondary(mob/user, list/modifiers)
	. = ..()
	if (!Adjacent(user, src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/vending/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/vending),
	)

/obj/machinery/vending/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vending", name)
		ui.open()

/obj/machinery/vending/ui_static_data(mob/user)
	var/list/data = list()
	data["onstation"] = onstation
	data["department"] = payment_department
	data["jobDiscount"] = DEPARTMENT_DISCOUNT
	data["product_records"] = list()

	var/list/categories = list()

	data["product_records"] = collect_records_for_static_data(product_records, categories)
	data["coin_records"] = collect_records_for_static_data(coin_records, categories, premium = TRUE)
	data["hidden_records"] = collect_records_for_static_data(hidden_records, categories, premium = TRUE)

	data["categories"] = categories

	return data

/obj/machinery/vending/proc/collect_records_for_static_data(list/records, list/categories, premium)
	var/static/list/default_category = list(
		"name" = "Products",
		"icon" = "cart-shopping",
	)

	var/list/out_records = list()

	for (var/datum/data/vending_product/record as anything in records)
		var/list/static_record = list(
			path = replacetext(replacetext("[record.product_path]", "/obj/item/", ""), "/", "-"),
			name = record.name,
			price = premium ? (record.custom_premium_price || extra_price) : (record.custom_price || default_price),
			max_amount = record.max_amount,
			ref = REF(record),
		)

		var/list/category = record.category || default_category
		if (!isnull(category))
			if (!(category["name"] in categories))
				categories[category["name"]] = list(
					"icon" = category["icon"],
				)

			static_record["category"] = category["name"]

		if (premium)
			static_record["premium"] = TRUE

		out_records += list(static_record)

	return out_records

/obj/machinery/vending/ui_data(mob/user)
	. = list()
	var/obj/item/card/id/C
	if(isliving(user))
		var/mob/living/L = user
		C = L.get_idcard(TRUE)
	if(C?.registered_account)
		.["user"] = list()
		.["user"]["name"] = C.registered_account.account_holder
		.["user"]["cash"] = C.registered_account.account_balance
		if(C.registered_account.account_job)
			.["user"]["job"] = C.registered_account.account_job.title
			.["user"]["department"] = C.registered_account.account_job.paycheck_department
		else
			.["user"]["job"] = "No Job"
			.["user"]["department"] = DEPARTMENT_UNASSIGNED
	.["stock"] = list()

	for (var/datum/data/vending_product/product_record as anything in product_records + coin_records + hidden_records)
		var/list/product_data = list(
			name = product_record.name,
			amount = product_record.amount,
			colorable = product_record.colorable,
		)

		.["stock"][product_record.name] = product_data

	.["extended_inventory"] = extended_inventory

/obj/machinery/vending/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("vend")
			. = vend(params)
		if("select_colors")
			. = select_colors(params)

/obj/machinery/vending/proc/can_vend(user, silent=FALSE)
	. = FALSE
	if(!vend_ready)
		return
	if(panel_open)
		to_chat(user, span_warning("The vending machine cannot dispense products while its service panel is open!"))
		return
	return TRUE

/obj/machinery/vending/proc/select_colors(list/params)
	. = TRUE
	if(!can_vend(usr))
		return
	var/datum/data/vending_product/product = locate(params["ref"])
	var/atom/fake_atom = product.product_path

	var/list/allowed_configs = list()
	var/config = initial(fake_atom.greyscale_config)
	if(!config)
		return
	allowed_configs += "[config]"
	if(ispath(fake_atom, /obj/item))
		var/obj/item/item = fake_atom
		if(initial(item.greyscale_config_worn))
			allowed_configs += "[initial(item.greyscale_config_worn)]"
		if(initial(item.greyscale_config_inhand_left))
			allowed_configs += "[initial(item.greyscale_config_inhand_left)]"
		if(initial(item.greyscale_config_inhand_right))
			allowed_configs += "[initial(item.greyscale_config_inhand_right)]"

	var/datum/greyscale_modify_menu/menu = new(
		src, usr, allowed_configs, CALLBACK(src, PROC_REF(vend_greyscale), params),
		starting_icon_state=initial(fake_atom.icon_state),
		starting_config=initial(fake_atom.greyscale_config),
		starting_colors=initial(fake_atom.greyscale_colors)
	)
	menu.ui_interact(usr)

/obj/machinery/vending/proc/vend_greyscale(list/params, datum/greyscale_modify_menu/menu)
	if(usr != menu.user)
		return
	vend(params, menu.split_colors)

/obj/machinery/vending/proc/vend(list/params, list/greyscale_colors)
	. = TRUE
	if(!can_vend(usr))
		return
	vend_ready = FALSE //One thing at a time!!
	var/datum/data/vending_product/R = locate(params["ref"])
	var/list/record_to_check = product_records + coin_records
	if(extended_inventory)
		record_to_check = product_records + coin_records + hidden_records
	if(!R || !istype(R) || !R.product_path)
		vend_ready = TRUE
		return
	var/price_to_use = default_price
	if(R.custom_price)
		price_to_use = R.custom_price
	if(R in hidden_records)
		if(!extended_inventory)
			vend_ready = TRUE
			return
	else if (!(R in record_to_check))
		vend_ready = TRUE
		message_admins("Vending machine exploit attempted by [ADMIN_LOOKUPFLW(usr)]!")
		return
	if (R.amount <= 0)
		speak("Sold out of [R.name].")
		flick(icon_deny,src)
		vend_ready = TRUE
		return
	if(onstation)
		var/obj/item/card/id/C
		if(isliving(usr))
			var/mob/living/L = usr
			C = L.get_idcard(TRUE)
		if(!C)
			speak("No card found.")
			flick(icon_deny,src)
			vend_ready = TRUE
			return
		else if (!C.registered_account)
			speak("No account found.")
			flick(icon_deny,src)
			vend_ready = TRUE
			return
		else if(!C.registered_account.account_job)
			speak("Departmental accounts have been blacklisted from personal expenses due to embezzlement.")
			flick(icon_deny, src)
			vend_ready = TRUE
			return
		else if(age_restrictions && R.age_restricted && (!C.registered_age || C.registered_age < AGE_MINOR))
			speak("You are not of legal age to purchase [R.name].")
			if(!(usr in GLOB.narcd_underages))
				if (isnull(sec_radio))
					sec_radio = new (src)
					sec_radio.set_listening(FALSE)
				sec_radio.set_frequency(FREQ_SECURITY)
				sec_radio.talk_into(src, "SECURITY ALERT: Underaged crewmember [usr] recorded attempting to purchase [R.name] in [get_area(src)]. Please watch for substance abuse.", FREQ_SECURITY)
				GLOB.narcd_underages += usr
			flick(icon_deny,src)
			vend_ready = TRUE
			return
		var/datum/bank_account/account = C.registered_account
		if(account.account_job && account.account_job.paycheck_department == payment_department)
			price_to_use = max(round(price_to_use * DEPARTMENT_DISCOUNT), 1) //No longer free, but signifigantly cheaper.
		if(coin_records.Find(R) || hidden_records.Find(R))
			price_to_use = R.custom_premium_price ? R.custom_premium_price : extra_price
		if(LAZYLEN(R.returned_products))
			price_to_use = 0 //returned items are free
		if(price_to_use && !account.adjust_money(-price_to_use, "Vending: [R.name]"))
			speak("You do not possess the funds to purchase [R.name].")
			flick(icon_deny,src)
			vend_ready = TRUE
			return
		var/datum/bank_account/D = SSeconomy.get_dep_account(payment_department)
		if(D)
			D.adjust_money(price_to_use)
			SSblackbox.record_feedback("amount", "vending_spent", price_to_use)
			SSeconomy.track_purchase(account, price_to_use, name)
			log_econ("[price_to_use] credits were inserted into [src] by [account.account_holder] to buy [R].")
	if(last_shopper != REF(usr) || purchase_message_cooldown < world.time)
		var/vend_response = vend_reply || "Thank you for shopping with [src]!"
		speak(vend_response)
		purchase_message_cooldown = world.time + 5 SECONDS
		//This is not the best practice, but it's safe enough here since the chances of two people using a machine with the same ref in 5 seconds is fuck low
		last_shopper = REF(usr)
	use_power(active_power_usage)
	if(icon_vend) //Show the vending animation if needed
		flick(icon_vend,src)
	playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)
	var/obj/item/vended_item
	if(!LAZYLEN(R.returned_products)) //always give out free returned stuff first, e.g. to avoid walling a traitor objective in a bag behind paid items
		vended_item = new R.product_path(get_turf(src))
	else
		vended_item = LAZYACCESS(R.returned_products, LAZYLEN(R.returned_products)) //first in, last out
		LAZYREMOVE(R.returned_products, vended_item)
		vended_item.forceMove(get_turf(src))
	if(greyscale_colors)
		vended_item.set_greyscale(colors=greyscale_colors)
	R.amount--
	if(usr.CanReach(src) && usr.put_in_hands(vended_item))
		to_chat(usr, span_notice("You take [R.name] out of the slot."))
	else
		to_chat(usr, span_warning("[capitalize(R.name)] falls onto the floor!"))
	SSblackbox.record_feedback("nested tally", "vending_machine_usage", 1, list("[type]", "[R.product_path]"))
	vend_ready = TRUE

/obj/machinery/vending/process(seconds_per_tick)
	if(machine_stat & (BROKEN|NOPOWER))
		return PROCESS_KILL
	if(!active)
		return

	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(last_slogan + slogan_delay <= world.time && slogan_list.len > 0 && !shut_up && SPT_PROB(2.5, seconds_per_tick))
		var/slogan = pick(slogan_list)
		speak(slogan)
		last_slogan = world.time

	if(shoot_inventory && SPT_PROB(shoot_inventory_chance, seconds_per_tick))
		throw_item()
/**
 * Speak the given message verbally
 *
 * Checks if the machine is powered and the message exists
 *
 * Arguments:
 * * message - the message to speak
 */
/obj/machinery/vending/proc/speak(message)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(!message)
		return

	say(message)

/obj/machinery/vending/power_change()
	. = ..()
	if(powered())
		START_PROCESSING(SSmachines, src)

//Somebody cut an important wire and now we're following a new definition of "pitch."
/**
 * Throw an item from our internal inventory out in front of us
 *
 * This is called when we are hacked, it selects a random product from the records that has an amount > 0
 * This item is then created and tossed out in front of us with a visible message
 */
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return FALSE

	for(var/datum/data/vending_product/R in shuffle(product_records))
		if(R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if(!dump_path)
			continue
		if(R.amount > LAZYLEN(R.returned_products)) //always throw new stuff that costs before free returned stuff, because of the hacking effort and time between throws involved
			throw_item = new dump_path(loc)
		else
			throw_item = LAZYACCESS(R.returned_products, LAZYLEN(R.returned_products)) //first in, last out
			throw_item.forceMove(loc)
			LAZYREMOVE(R.returned_products, throw_item)
		R.amount--
		break
	if(!throw_item)
		return FALSE

	pre_throw(throw_item)

	throw_item.throw_at(target, 16, 3)
	visible_message(span_danger("[src] launches [throw_item] at [target]!"))
	return TRUE
/**
 * A callback called before an item is tossed out
 *
 * Override this if you need to do any special case handling
 *
 * Arguments:
 * * I - obj/item being thrown
 */
/obj/machinery/vending/proc/pre_throw(obj/item/I)
	return
/**
 * Shock the passed in user
 *
 * This checks we have power and that the passed in prob is passed, then generates some sparks
 * and calls electrocute_mob on the user
 *
 * Arguments:
 * * user - the user to shock
 * * prb - probability the shock happens
 */
/obj/machinery/vending/proc/shock(mob/living/user, prb)
	if(!istype(user) || machine_stat & (BROKEN|NOPOWER)) // unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 0.7, check_range))
		return TRUE
	else
		return FALSE
/**
 * Are we able to load the item passed in
 *
 * Arguments:
 * * I - the item being loaded
 * * user - the user doing the loading
 */
/obj/machinery/vending/proc/canLoadItem(obj/item/I, mob/user)
	if((I.type in products) || (I.type in premium) || (I.type in contraband))
		return TRUE
	to_chat(user, span_warning("[src] does not accept [I]!"))
	return FALSE

/obj/machinery/vending/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	. = ..()
	var/mob/living/L = AM
	if(tilted || !istype(L) || !prob(20 * (throwingdatum.speed - L.throw_speed))) // hulk throw = +20%, neckgrab throw = +20%
		return

	tilt(L)

/obj/machinery/vending/attack_tk_grab(mob/user)
	to_chat(user, span_warning("[src] seems to resist your mental grasp!"))

///Crush the mob that the vending machine got thrown at
/obj/machinery/vending/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(isliving(hit_atom))
		tilt(fatty=hit_atom)
	return ..()

/obj/machinery/vending/custom
	name = "Custom Vendor"
	icon_state = "custom"
	icon_deny = "custom-deny"
	max_integrity = 400
	payment_department = NO_FREEBIES
	light_mask = "custom-light-mask"
	refill_canister = /obj/item/vending_refill/custom
	/// where the money is sent
	var/datum/bank_account/linked_account
	/// max number of items that the custom vendor can hold
	var/max_loaded_items = 20
	/// Base64 cache of custom icons.
	var/list/base64_cache = list()
	panel_type = "panel20"

/obj/machinery/vending/custom/compartmentLoadAccessCheck(mob/user)
	. = FALSE
	if(!isliving(user))
		return FALSE
	var/mob/living/living_user = user
	var/obj/item/card/id/id_card = living_user.get_idcard(FALSE)
	if(id_card?.registered_account && id_card.registered_account == linked_account)
		return TRUE

/obj/machinery/vending/custom/canLoadItem(obj/item/I, mob/user)
	. = FALSE
	if(I.flags_1 & HOLOGRAM_1)
		speak("This vendor cannot accept nonexistent items.")
		return
	if(loaded_items >= max_loaded_items)
		speak("There are too many items in stock.")
		return
	if(isstack(I))
		speak("Loose items may cause problems, try to use it inside wrapping paper.")
		return
	if(I.custom_price)
		return TRUE

/obj/machinery/vending/custom/ui_interact(mob/user)
	if(!linked_account)
		balloon_alert(user, "no registered owner")
		return FALSE
	return ..()

/obj/machinery/vending/custom/ui_data(mob/user)
	. = ..()
	.["access"] = compartmentLoadAccessCheck(user)
	.["vending_machine_input"] = list()
	for (var/O in vending_machine_input)
		if(vending_machine_input[O] > 0)
			var/base64
			var/price = 0
			for(var/obj/item/T in contents)
				if(format_text(T.name) == O)
					price = T.custom_price
					if(!base64)
						if(base64_cache[T.type])
							base64 = base64_cache[T.type]
						else
							base64 = icon2base64(getFlatIcon(T, no_anim=TRUE))
							base64_cache[T.type] = base64
					break
			var/list/data = list(
				name = O,
				price = price,
				img = base64,
				amount = vending_machine_input[O],
				colorable = FALSE
			)
			.["vending_machine_input"] += list(data)

/obj/machinery/vending/custom/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("dispense")
			if(isliving(usr))
				vend_act(usr, params["item"])
			vend_ready = TRUE
			return TRUE

/obj/machinery/vending/custom/attackby(obj/item/I, mob/user, params)
	if(!linked_account && isliving(user))
		var/mob/living/L = user
		var/obj/item/card/id/C = L.get_idcard(TRUE)
		if(C?.registered_account)
			linked_account = C.registered_account
			speak("\The [src] has been linked to [C].")

	if(compartmentLoadAccessCheck(user))
		if(istype(I, /obj/item/pen))
			name = tgui_input_text(user, "Set name", "Name", name, 20)
			desc = tgui_input_text(user, "Set description", "Description", desc, 60)
			slogan_list += tgui_input_text(user, "Set slogan", "Slogan", "Epic", 60)
			last_slogan = world.time + rand(0, slogan_delay)
			return

	return ..()

/obj/machinery/vending/custom/crowbar_act(mob/living/user, obj/item/I)
	return FALSE

/obj/machinery/vending/custom/deconstruct(disassembled)
	unbuckle_all_mobs(TRUE)
	var/turf/current_turf = get_turf(src)
	if(current_turf)
		for(var/obj/item/stored_item in contents)
			stored_item.forceMove(current_turf)
		explosion(src, devastation_range = -1, light_impact_range = 3)
	return ..()

/**
 * Vends an item to the user. Handles all the logic:
 * Updating stock, account transactions, alerting users.
 * @return -- TRUE if a valid condition was met, FALSE otherwise.
 */
/obj/machinery/vending/custom/proc/vend_act(mob/living/user, choice)
	if(!vend_ready)
		return
	var/obj/item/dispensed_item
	var/obj/item/card/id/id_card = user.get_idcard(TRUE)
	vend_ready = FALSE
	if(!id_card || !id_card.registered_account || !id_card.registered_account.account_job)
		balloon_alert(usr, "no card found")
		flick(icon_deny, src)
		return TRUE
	var/datum/bank_account/payee = id_card.registered_account
	for(var/obj/stock in contents)
		if(format_text(stock.name) == choice)
			dispensed_item = stock
			break
	if(!dispensed_item)
		return FALSE
	/// Charges the user if its not the owner
	if(!compartmentLoadAccessCheck(user))
		if(!payee.has_money(dispensed_item.custom_price))
			balloon_alert(user, "insufficient funds")
			return TRUE
		/// Make the transaction
		payee.adjust_money(-dispensed_item.custom_price, , "Vending: [dispensed_item]")
		linked_account.adjust_money(dispensed_item.custom_price, "Vending: [dispensed_item] Bought")
		linked_account.bank_card_talk("[payee.account_holder] made a [dispensed_item.custom_price] \
		cr purchase at your custom vendor.")
		/// Log the transaction
		SSblackbox.record_feedback("amount", "vending_spent", dispensed_item.custom_price)
		log_econ("[dispensed_item.custom_price] credits were spent on [src] buying a \
		[dispensed_item] by [payee.account_holder], owned by [linked_account.account_holder].")
		/// Make an alert
		if(last_shopper != REF(usr) || purchase_message_cooldown < world.time)
			speak("Thank you for your patronage [user]!")
			purchase_message_cooldown = world.time + 5 SECONDS
			last_shopper = REF(usr)
	/// Remove the item
	loaded_items--
	use_power(active_power_usage)
	vending_machine_input[choice] = max(vending_machine_input[choice] - 1, 0)
	if(user.CanReach(src) && user.put_in_hands(dispensed_item))
		to_chat(user, span_notice("You take [dispensed_item.name] out of the slot."))
	else
		to_chat(user, span_warning("[capitalize(dispensed_item.name)] falls onto the floor!"))
	return TRUE

/obj/machinery/vending/custom/unbreakable
	name = "Indestructible Vendor"
	resistance_flags = INDESTRUCTIBLE

/obj/item/vending_refill/custom
	machine_name = "Custom Vendor"
	icon_state = "refill_custom"
	custom_premium_price = PAYCHECK_CREW

/obj/machinery/vending/custom/greed //name and like decided by the spawn
	icon_state = "greed"
	icon_deny = "greed-deny"
	panel_type = "panel4"
	max_integrity = 700
	max_loaded_items = 40
	light_mask = "greed-light-mask"
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT * 5)

/obj/machinery/vending/custom/greed/Initialize(mapload)
	. = ..()
	//starts in a state where you can move it
	set_panel_open(TRUE)
	set_anchored(FALSE)
	add_overlay(panel_type)
	//and references the deity
	name = "[GLOB.deity]'s Consecrated Vendor"
	desc = "A vending machine created by [GLOB.deity]."
	slogan_list = list("[GLOB.deity] says: It's your divine right to buy!")
	add_filter("vending_outline", 9, list("type" = "outline", "color" = COLOR_VERY_SOFT_YELLOW))
	add_filter("vending_rays", 10, list("type" = "rays", "size" = 35, "color" = COLOR_VIVID_YELLOW))

#undef MAX_VENDING_INPUT_AMOUNT
