///Helper to create a typepath to be used in the UI
#define SANITIZED_PATH(path)(replacetext(replacetext("[path]", "/obj/item/", ""), "/", "-"))

/obj/machinery/vending/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/vending),
	)

/obj/machinery/vending/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vending", name)
		ui.open()


/**
 * Returns a list of given product records of the vendor to be used in UI.
 * arguments:
 * records - list of records available
 * categories - list of categories available
 * premium - bool of whether a record should be priced by a custom/premium price or not
 */
/obj/machinery/vending/proc/collect_records_for_static_data(list/records, list/categories, premium)
	PROTECTED_PROC(TRUE)

	var/static/list/default_category = list(
		"name" = "Products",
		"icon" = "cart-shopping",
	)

	var/list/out_records = list()

	for (var/datum/data/vending_product/record as anything in records)
		var/list/static_record = list(
			path = SANITIZED_PATH(record.product_path),
			name = record.name,
			price = record.price,
			ref = REF(record),
			colorable = record.colorable,
		)

		var/atom/printed = record.product_path
		// If it's not GAGS and has no innate colors we have to care about, we use DMIcon
		if(ispath(printed, /atom) \
			&& (!initial(printed.greyscale_config) || !initial(printed.greyscale_colors)) \
			&& !initial(printed.color) \
		)
			static_record["icon"] = initial(printed.icon)
			static_record["icon_state"] = initial(printed.icon_state)

		var/list/category = record.category || default_category
		if (!isnull(category))
			if (!(category["name"] in categories))
				categories[category["name"]] = list("icon" = category["icon"])

			static_record["category"] = category["name"]

		if (premium)
			static_record["premium"] = TRUE

		out_records += list(static_record)

	return out_records

/obj/machinery/vending/ui_static_data(mob/user)
	var/list/data = list()
	data["onstation"] = onstation
	if(ad_list.len)
		data["ad"] = ad_list[rand(1, ad_list.len)]
	data["all_products_free"] = all_products_free
	data["department"] = payment_department
	data["jobDiscount"] = DEPARTMENT_DISCOUNT
	data["product_records"] = list()
	data["displayed_currency_icon"] = displayed_currency_icon
	data["displayed_currency_name"] = displayed_currency_name

	var/list/categories = list()

	data["product_records"] = collect_records_for_static_data(product_records, categories)
	data["coin_records"] = collect_records_for_static_data(coin_records, categories, premium = TRUE)
	data["hidden_records"] = collect_records_for_static_data(hidden_records, categories, premium = TRUE)

	data["categories"] = categories

	return data


/**
 * Returns the balance that the vendor will use for proceeding payment. Most vendors would want to use the user's
 * card's account credits balance.
 * arguments:
 * passed_id - the id card that will be billed for the product
 */
/obj/machinery/vending/proc/fetch_balance_to_use(obj/item/card/id/passed_id)
	PROTECTED_PROC(TRUE)

	return passed_id.registered_account.account_balance

/obj/machinery/vending/ui_data(mob/user)
	. = list()

	var/obj/item/card/id/card_used
	var/held_cash = 0
	if(isliving(user))
		var/mob/living/living_user = user
		card_used = living_user.get_idcard(TRUE)
		held_cash = living_user.tally_physical_credits()

	var/list/user_data = null
	if(card_used?.registered_account)
		user_data = list()
		user_data["name"] = card_used.registered_account.account_holder
		user_data["cash"] = fetch_balance_to_use(card_used) + held_cash
		if(card_used.registered_account.account_job)
			user_data["job"] = card_used.registered_account.account_job.title
			user_data["department"] = card_used.registered_account.account_job.paycheck_department
		else
			user_data["job"] = "No Job"
			user_data["department"] = DEPARTMENT_UNASSIGNED
	.["user"] = user_data

	.["stock"] = list()
	for (var/datum/data/vending_product/product_record as anything in product_records + coin_records + hidden_records)
		.["stock"][SANITIZED_PATH(product_record.product_path)] = list(
			amount = product_record.amount,
			free = length(product_record.returned_products)
		)

	if(prob(10) && ad_list.len)
		.["ad"] = ad_list[rand(1, ad_list.len)]

	.["extended_inventory"] = extended_inventory

/obj/machinery/vending/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("vend")
			. = vend(params, ui.user)
		if("select_colors")
			var/datum/data/vending_product/product = locate(params["ref"])
			if(!istype(product))
				return FALSE
			var/atom/fake_atom = product.product_path
			var/config = initial(fake_atom.greyscale_config)
			if(!config)
				return FALSE

			var/list/allowed_configs = list("[config]")
			if(ispath(fake_atom, /obj/item))
				var/obj/item/item = fake_atom
				if(initial(item.greyscale_config_worn))
					allowed_configs += "[initial(item.greyscale_config_worn)]"
				if(initial(item.greyscale_config_inhand_left))
					allowed_configs += "[initial(item.greyscale_config_inhand_left)]"
				if(initial(item.greyscale_config_inhand_right))
					allowed_configs += "[initial(item.greyscale_config_inhand_right)]"
			var/datum/greyscale_modify_menu/menu = new(
				src, ui.user, allowed_configs, CALLBACK(src, PROC_REF(_vend_greyscale), params, ui.user),
				starting_icon_state=initial(fake_atom.icon_state),
				starting_config = initial(fake_atom.greyscale_config),
				starting_colors = initial(fake_atom.greyscale_colors)
			)
			menu.ui_interact(ui.user)
			return TRUE

/**
 * Vends a greyscale modified item.
 * arguments:
 * menu - greyscale config menu that has been used to vend the item
 */
/obj/machinery/vending/proc/_vend_greyscale(list/params, mob/user, datum/greyscale_modify_menu/menu)
	PRIVATE_PROC(TRUE)

	if(user != menu.user)
		return
	vend(params, user, menu.split_colors)

#undef SANITIZED_PATH
