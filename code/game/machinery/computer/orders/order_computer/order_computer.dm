GLOBAL_LIST_EMPTY(order_console_products)

/obj/machinery/computer/order_console
	name = "Orders Console"
	desc = "An interface for ordering specific ingredients from Cargo, with an express option at the cost of more money."
	icon_screen = "request"
	icon_keyboard = "generic_key"
	light_color = LIGHT_COLOR_ORANGE

	///The current list of things we're trying to order, waiting for checkout.
	var/list/grocery_list = list()
	///Cooldown between order uses.
	COOLDOWN_DECLARE(order_cooldown)

	///The radio the console can speak into
	var/obj/item/radio/radio
	///The channel we will attempt to speak into through our radio.
	var/radio_channel = RADIO_CHANNEL_SUPPLY

	///Whether the console can only use express mode ONLY
	var/forced_express = FALSE
	///Multiplied cost to use express mode
	var/express_cost_multiplier = 2
	///Whether we should charge in mining points instead
	var/mining_point_price = FALSE
	///The categories of orderable items this console can view and purchase.
	var/order_categories = list()

/obj/machinery/computer/order_console/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.set_frequency(FREQ_SUPPLY)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

	if(GLOB.order_console_products.len)
		return
	for(var/datum/orderable_item/path as anything in subtypesof(/datum/orderable_item))
		if(!initial(path.item_path))
			continue
		GLOB.order_console_products += new path

/obj/machinery/computer/order_console/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/computer/order_console/proc/get_total_cost()
	var/cost = 0
	for(var/datum/orderable_item/item as anything in grocery_list)
		cost += grocery_list[item] * item.cost_per_order
	return cost

/obj/machinery/computer/order_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProduceConsole", name)
		ui.open()

/obj/machinery/computer/order_console/ui_data(mob/user)
	var/list/data = ..()
	data["total_cost"] = get_total_cost()
	data["off_cooldown"] = COOLDOWN_FINISHED(src, order_cooldown)

	var/obj/item/card/id/id_card
	if(isliving(user))
		var/mob/living/living_user = user
		id_card = living_user.get_idcard(TRUE)
	if(id_card)
		if(mining_point_price)
			data["points"] = id_card.mining_points
		else
			data["points"] = id_card.registered_account?.account_balance

	return data

/obj/machinery/computer/order_console/ui_static_data(mob/user)
	var/list/data = ..()
	data["forced_express"] = forced_express
	data["order_categories"] = order_categories
	data["order_datums"] = list()
	for(var/datum/orderable_item/item as anything in GLOB.order_console_products)
		if(!(item.category_index in order_categories))
			continue
		data["order_datums"] += list(list(
			"name" = item.name,
			"desc" = item.desc,
			"cat" = item.category_index,
			"ref" = REF(item),
			"cost" = item.cost_per_order,
			"amt" = grocery_list[item],
		))
	return data

/obj/machinery/computer/order_console/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!isliving(usr))
		return
	var/mob/living/living_user = usr
	//this is null if the action doesn't need it (purchase, quickpurchase)
	var/datum/orderable_item/wanted_item = locate(params["target"]) in GLOB.order_console_products
	switch(action)
		if("cart_set")
			grocery_list[wanted_item] = clamp(params["amt"], 0, 20)
			if(!grocery_list[wanted_item])
				grocery_list -= wanted_item
			update_static_data(living_user)
		if("purchase")
			if(!grocery_list.len || !COOLDOWN_FINISHED(src, order_cooldown))
				return
			if(forced_express)
				return ui_act(action = "express")
			var/obj/item/card/id/used_id_card = living_user.get_idcard(TRUE)
			if(!used_id_card || !used_id_card.registered_account)
				say("No bank account detected!")
				return
			var/final_cost = get_total_cost()
			if(mining_point_price)
				if(final_cost > used_id_card.mining_points)
					say("Sorry, but you do not have enough mining points.")
					return
				used_id_card.mining_points -= final_cost
			else
				if(!used_id_card.registered_account.adjust_money(-final_cost, "[name]: Purchase"))
					say("Sorry, but you do not have enough money.")
					return
			say("Thank you for your purchase! It will arrive on the next cargo shuttle!")
			var/message = "The kitchen has ordered groceries which will arrive on the cargo shuttle! Please make sure it gets to them as soon as possible!"
			radio.talk_into(src, message, radio_channel)
			COOLDOWN_START(src, order_cooldown, 60 SECONDS)
			order_groceries()
		if("express")
			if(!grocery_list.len || !COOLDOWN_FINISHED(src, order_cooldown))
				return
			var/obj/item/card/id/used_id_card = living_user.get_idcard(TRUE)
			if(!used_id_card || !used_id_card.registered_account)
				say("No bank account detected!")
				return
			var/final_cost = get_total_cost()
			final_cost *= express_cost_multiplier
			if(mining_point_price)
				if(final_cost > used_id_card.mining_points)
					say("Sorry, but you do not have enough mining points. Remember, Express upcharges the cost!")
					return
				used_id_card.mining_points -= final_cost
			else
				if(!used_id_card.registered_account.adjust_money(-final_cost, "[name]: Purchase"))
					say("Sorry, but you do not have enough money. Remember, Express upcharges the cost!")
					return
			var/say_message = "Thank you for your purchase!"
			if(express_cost_multiplier > 1)
				say_message += "Please note: The charge of this purchase and machine cooldown has been multiplied by [express_cost_multiplier]!"
			say(say_message)
			COOLDOWN_START(src, order_cooldown, 120 SECONDS)
			var/list/ordered_paths = list()
			for(var/datum/orderable_item/item as anything in grocery_list)//every order
				if(!(item.category_index in order_categories))
					grocery_list.Remove(item)
					continue
				for(var/amt in 1 to grocery_list[item])//every order amount
					ordered_paths += item.item_path
			podspawn(list(
				"target" = get_turf(living_user),
				"style" = STYLE_BLUESPACE,
				"spawn" = ordered_paths,
			))
			grocery_list.Cut()
	return TRUE

/obj/machinery/computer/order_console/proc/order_groceries()
	return
