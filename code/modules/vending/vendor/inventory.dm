//================================STOCKING IN ITEMS=================================

/**
 * Build the inventory of the vending machine from its product and record lists
 *
 * This builds up a full set of /datum/data/vending_products from the product list of the vending machine type
 * Arguments:
 * * productlist - the list of products that need to be converted
 * * recordlist - the list containing /datum/data/vending_product datums
 * * categories - A list in the format of product_categories to source category from
 * * startempty - should we set vending_product record amount from the product list (so it's prefilled at roundstart)
 * * premium - Whether the ending products shall have premium or default prices
 */
/obj/machinery/vending/proc/_build_inventory(list/productlist, list/recordlist, list/categories, start_empty = FALSE, premium = FALSE)
	PRIVATE_PROC(TRUE)

	var/inflation_value = HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING) ? SSeconomy.inflation_value() : 1
	default_price = round(initial(default_price) * inflation_value)
	extra_price = round(initial(extra_price) * inflation_value)

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
		var/datum/data/vending_product/new_record = new /datum/data/vending_product()
		new_record.name = initial(temp.name)
		new_record.product_path = typepath
		if(!start_empty)
			new_record.amount = amount
		new_record.max_amount = amount

		///Prices of vending machines are all increased uniformly.
		var/custom_price = round(initial(temp.custom_price) * inflation_value)
		if(!premium)
			new_record.price = custom_price || default_price
		else
			var/premium_custom_price = round(initial(temp.custom_premium_price) * inflation_value)
			if(!premium_custom_price && custom_price) //For some ungodly reason, some premium only items only have a custom_price
				new_record.price = extra_price + custom_price
			else
				new_record.price = premium_custom_price || extra_price

		new_record.age_restricted = initial(temp.age_restricted)
		new_record.colorable = !!(initial(temp.greyscale_config) && initial(temp.greyscale_colors) && (initial(temp.flags_1) & IS_PLAYER_COLORABLE_1))
		new_record.category = product_to_category[typepath]
		recordlist += new_record

/**Builds all available inventories for the vendor - standard, contraband and premium
 * Arguments:
 * start_empty - bool to pass into build_inventory that determines whether a product entry starts with available stock or not
*/
/obj/machinery/vending/proc/build_inventories(start_empty)
	_build_inventory(products, product_records, product_categories, start_empty)
	_build_inventory(contraband, hidden_records, list(list("name" = "Contraband", "icon" = "mask", "products" = contraband)), start_empty, premium = TRUE)
	_build_inventory(premium, coin_records, list(list("name" = "Premium", "icon" = "coins", "products" = premium)), start_empty, premium = TRUE)

//Better would be to make constructable child
/obj/machinery/vending/RefreshParts()
	SHOULD_CALL_PARENT(FALSE)
	if(!component_parts)
		return

	if(product_categories)
		products = list()
		for(var/list/category as anything in product_categories)
			products |= category["products"]

	product_records = list()
	hidden_records = list()
	coin_records = list()

	build_inventories(start_empty = TRUE)
	for(var/obj/item/vending_refill/installed_refill in component_parts)
		restock(installed_refill)

/**
 * Refill a category from the refill canister
 *
 * Arguments:
 * * list/productlist - the product list from the canister tor ead from
 * * list/recordlist - the record list to write into
 */
/obj/machinery/vending/proc/_refill_inventory(list/productlist, list/recordlist)
	PRIVATE_PROC(TRUE)

	. = 0
	for(var/datum/data/vending_product/record as anything in recordlist)
		var/diff = min(record.max_amount - record.amount, productlist[record.product_path])
		if (diff)
			productlist[record.product_path] -= diff
			record.amount += diff
			. += diff

/**
 * Refill a vending machine from a refill canister
 *
 * This takes the products from the refill canister and then fills the products, contraband and premium product categories
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

		. += _refill_inventory(products_unwrapped, product_records)
	else
		. += _refill_inventory(canister.products, product_records)

	. += _refill_inventory(canister.contraband, hidden_records)
	. += _refill_inventory(canister.premium, coin_records)


//===========================VENDING OUT ITEMS================================

/**
 * Whether this vendor can vend items or not.
 * arguments:
 * user - current customer
 */
/obj/machinery/vending/proc/can_vend(user)
	PROTECTED_PROC(TRUE)

	. = FALSE
	if(!vend_ready || !is_operational)
		return
	if(panel_open)
		to_chat(user, span_warning("The vending machine cannot dispense products while its service panel is open!"))
		return
	return TRUE

/**
 * The entire shebang of vending the picked item. Processes the vending and initiates the payment for the item.
 * arguments:
 * greyscale_colors - greyscale config for the item we're about to vend, if any
 */
/obj/machinery/vending/proc/vend(list/params, mob/user, list/greyscale_colors)
	. = TRUE
	if(!can_vend(user))
		return
	vend_ready = FALSE //One thing at a time!!
	var/datum/data/vending_product/item_record = locate(params["ref"])
	var/list/record_to_check = product_records + coin_records
	if(extended_inventory)
		record_to_check = product_records + coin_records + hidden_records
	if(!item_record || !istype(item_record) || !item_record.product_path)
		vend_ready = TRUE
		return
	var/price_to_use = item_record.price
	if(item_record in hidden_records)
		if(!extended_inventory)
			vend_ready = TRUE
			return
	else if (!(item_record in record_to_check))
		vend_ready = TRUE
		message_admins("Vending machine exploit attempted by [ADMIN_LOOKUPFLW(user)]!")
		return
	if (item_record.amount <= 0)
		speak("Sold out of [item_record.name].")
		flick(icon_deny, src)
		vend_ready = TRUE
		return
	if(onstation)
		// Here we do additional handing ahead of the payment component's logic, such as age restrictions and additional logging
		var/obj/item/card/id/card_used
		var/mob/living/living_user
		if(isliving(user))
			living_user = user
			card_used = living_user.get_idcard(TRUE)
		if(age_restrictions && item_record.age_restricted && (!card_used.registered_age || card_used.registered_age < AGE_MINOR))
			speak("You are not of legal age to purchase [item_record.name].")
			if(!(user in GLOB.narcd_underages))
				aas_config_announce(/datum/aas_config_entry/vendomat_age_control, list(
					"PERSON" = usr.name,
					"LOCATION" = get_area_name(src),
					"VENDOR" = name,
					"PRODUCT" = item_record.name
				), src, list(RADIO_CHANNEL_SECURITY))
				GLOB.narcd_underages += user
			flick(icon_deny, src)
			vend_ready = TRUE
			return

		if(!proceed_payment(card_used, living_user, item_record, price_to_use, params["discountless"]))
			vend_ready = TRUE
			return

	if(last_shopper != REF(user) || purchase_message_cooldown < world.time)
		var/vend_response = vend_reply || "Thank you for shopping with [src]!"
		speak(vend_response)
		purchase_message_cooldown = world.time + 5 SECONDS
		//This is not the best practice, but it's safe enough here since the chances of two people using a machine with the same ref in 5 seconds is fuck low
		last_shopper = REF(user)
	use_energy(active_power_usage)
	if(icon_vend) //Show the vending animation if needed
		flick(icon_vend, src)

	// Always give out free returned stuff first, e.g. to avoid walling a traitor objective in a bag behind paid items
	var/obj/item/vended_item = dispense(item_record, get_turf(src), dispense_returned = LAZYLEN(item_record.returned_products))

	if(greyscale_colors)
		vended_item.set_greyscale(colors=greyscale_colors)
	if(user.CanReach(src) && user.put_in_hands(vended_item))
		to_chat(user, span_notice("You take [item_record.name] out of the slot."))
		vended_item.do_pickup_animation(user, src)
	else
		to_chat(user, span_warning("[capitalize(format_text(item_record.name))] falls onto the floor!"))
	SSblackbox.record_feedback("nested tally", "vending_machine_usage", 1, list("[type]", "[item_record.product_path]"))
	vend_ready = TRUE

/**
 * Common proc that dispenses an item. Called when the item is vended, or gotten some other way.
 *
 * Arguments
 * * datum/data/vending_product/item_record - the vending record which contains the information of the item to dispense
 * * atom/spawn_location - location to dispense the item to
 * * silent - should we play the vending sound
 * * dispense_returned - are we vending out an returned item
*/
///
/obj/machinery/vending/proc/dispense(datum/data/vending_product/item_record, atom/spawn_location, silent = FALSE, dispense_returned = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	if(!silent)
		playsound(src, 'sound/machines/machine_vend.ogg', 50, TRUE, extrarange = -3)

	var/obj/item/vended_item
	if(dispense_returned)
		vended_item = LAZYACCESS(item_record.returned_products, LAZYLEN(item_record.returned_products)) //first in, last out
		LAZYREMOVE(item_record.returned_products, vended_item)
		vended_item.forceMove(spawn_location)
	else
		vended_item = new item_record.product_path(spawn_location)
		if(vended_item.type in contraband)
			ADD_TRAIT(vended_item, TRAIT_CONTRABAND, INNATE_TRAIT)

	on_dispense(vended_item, dispense_returned)
	item_record.amount--
	return vended_item

/**
 * A proc meant to perform custom behavior on newly dispensed items.
 *
 * Arguments
 * * obj/item/vended_item - the item that has just been dispensed
 * * dispense_returned - is this item an returned product
*/
/obj/machinery/vending/proc/on_dispense(obj/item/vended_item, dispense_returned = FALSE)
	PROTECTED_PROC(TRUE)

	return

/**
 * Handles payment processing: discounts, logging, balance change etc.
 * arguments:
 * paying_id_card - the id card that will be billed for the product.
 * mob_paying - the mob that is trying to purchase the item.
 * product_to_vend - the product record of the item we're trying to vend.
 * price_to_use - price of the item we're trying to vend.
 * discountless - whether or not to apply discounts
 */
/obj/machinery/vending/proc/proceed_payment(obj/item/card/id/paying_id_card, mob/living/mob_paying, datum/data/vending_product/product_to_vend, price_to_use, discountless)
	PROTECTED_PROC(TRUE)

	if(QDELETED(paying_id_card)) //not available(null) or somehow is getting destroyed
		speak("You do not possess an ID to purchase [product_to_vend.name].")
		return FALSE
	var/datum/bank_account/account = paying_id_card.registered_account
	if(account.account_job && account.account_job.paycheck_department == payment_department && !discountless)
		price_to_use = max(round(price_to_use * DEPARTMENT_DISCOUNT), 1) //No longer free, but signifigantly cheaper.
	if(LAZYLEN(product_to_vend.returned_products))
		price_to_use = 0 //returned items are free
	if(price_to_use && (attempt_charge(src, mob_paying, price_to_use) & COMPONENT_OBJ_CANCEL_CHARGE))
		speak("You do not possess the funds to purchase [product_to_vend.name].")
		flick(icon_deny,src)
		vend_ready = TRUE
		return FALSE
	//actual payment here
	var/datum/bank_account/paying_id_account = SSeconomy.get_dep_account(payment_department)
	if(paying_id_account)
		SSblackbox.record_feedback("amount", "vending_spent", price_to_use)
		SSeconomy.track_purchase(account, price_to_use, name)
		log_econ("[price_to_use] credits were inserted into [src] by [account.account_holder] to buy [product_to_vend].")
	credits_contained += round(price_to_use * VENDING_CREDITS_COLLECTION_AMOUNT)
	return TRUE
