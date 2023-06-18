/**
 * This vending machine supports a list of items that changes based on the user/card's access.
 */
/obj/machinery/vending/access
	name = "access-based vending machine"
	/// Internal variable to store our access list
	var/list/access_lists
	/// Should we auto build our product list? 0 means no
	var/auto_build_products = 0

/**
 * This is where you generate the list to store what items each access grants.
 * Should be an assosciative list where the key is the access as a string and the value is the items typepath.
 * You can also set it to TRUE instead of a list to allow them to purchase anything.
 */
/obj/machinery/vending/access/proc/build_access_list(list/access_lists)
	return

/obj/machinery/vending/access/Initialize(mapload)
	var/list/_list = new
	build_access_list(_list)
	access_lists = _list
	if(auto_build_products)
		products = list()
		for(var/access in access_lists)
			for(var/item in (access_lists[access]))
				if(!ispath(item))
					continue
				if(item in products)
					continue
				products[item] = auto_build_products
	return ..()

/obj/machinery/vending/access/ui_static_data(mob/user)
	. = ..()
	if(issilicon(user))
		return // Silicons get to view all items regardless

	.["product_records"] = list() // Vending machine code is bad; I hate it
	if(!iscarbon(user))
		return

	var/mob/living/carbon/carbon_user = user
	var/obj/item/card/id/user_id = carbon_user.get_idcard(TRUE)
	if(onstation && !user_id && !(obj_flags & EMAGGED))
		return

	// Alright so, this is the EXACT SAME LOOP as our base proc; however we check to see if the user is allowed to purchase it first.
	for (var/datum/data/vending_product/record in product_records)
		if(!allow_purchase(user_id, record.product_path))
			continue
		var/list/data = list(
			path = replacetext(replacetext("[record.product_path]", "/obj/item/", ""), "/", "-"),
			name = record.name,
			price = record.custom_price || default_price,
			max_amount = record.max_amount,
			ref = REF(record)
		)
		.["product_records"] += list(data)

/// Check if the list of given access is allowed to purchase the given product
/obj/machinery/vending/access/proc/allow_purchase(var/obj/item/card/id/user_id, product_path)
	if(obj_flags & EMAGGED || !onstation)
		return TRUE
	. = FALSE
	var/list/access = user_id.access
	for(var/acc in access)
		acc = "[acc]" // U G L Y
		if(!((acc) in access_lists))
			continue

		if(isnum(access_lists[acc]) && access_lists[acc])
			return access_lists[acc]

		if(product_path in (access_lists[acc]))
			return TRUE

/// Debug version to verify access checking is working and functional
/obj/machinery/vending/access/debug
	auto_build_products = TRUE

/obj/machinery/vending/access/debug/build_access_list(list/access_lists)
	access_lists["[ACCESS_ENGINEERING]"] = TRUE
	access_lists["[ACCESS_EVA]"] = list(/obj/item/crowbar)
	access_lists["[ACCESS_SECURITY]"] = list(/obj/item/wrench, /obj/item/gun/ballistic/revolver/mateba)
