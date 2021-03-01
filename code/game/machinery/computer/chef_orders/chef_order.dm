
/obj/machinery/computer/chef_order
	name = "Produce Orders Console"
	desc = "An interface for ordering fresh produce and other. A far more expensive option than the botanists, but oh well."
	icon_screen = "request"
	icon_keyboard = "generic_key"
	circuit = /obj/item/circuitboard/computer/chef_order

	var/list/order_datums = list()
	var/list/grocery_list = list()

	light_color = LIGHT_COLOR_ORANGE

/obj/machinery/computer/chef_order/Initialize()
	. = ..()

	for(var/path in subtypesof(/datum/orderable_item))
		order_datums += new path

/obj/machinery/computer/chef_order/Destroy()
	. = ..()
	QDEL_LIST(order_datums)

/obj/machinery/computer/chef_order/proc/get_total_cost()
	. = 0
	for(var/datum/orderable_item/item as anything in grocery_list)
		for(var/i in 1 to grocery_list[item]) //for how many times we bought it
			. += item.cost_per_order //add it's price

/obj/machinery/computer/chef_order/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/chef_order/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProduceConsole", name)
		ui.open()

/obj/machinery/computer/chef_order/ui_static_data(mob/user)
	. = ..()
	.["total_cost"] = get_total_cost()
	.["order_datums"] = list()
	for(var/datum/orderable_item/item as anything in order_datums)
		.["order_datums"] += list(list(
			"name" = item.name,
			"desc" = item.desc,
			"cat" = item.category_index,
			"ref" = REF(item),
			"cost" = item.cost_per_order,
			"amt" = grocery_list[item]
			))

/obj/machinery/computer/chef_order/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/chef = usr
	if(!istype(chef))
		return
	//this is null if the action doesn't need it (purchase, quickpurchase)
	var/datum/orderable_item/wanted_item = locate(params["target"]) in order_datums
	switch(action)
		if("cart_set")
			grocery_list[wanted_item] = params["amt"]
			if(!grocery_list[wanted_item])
				grocery_list -= wanted_item
			update_static_data(chef)
		if("purchase")
			var/obj/item/card/id/chef_card = chef.get_idcard(TRUE)
			var/final_cost = get_total_cost()
			if(!chef_card.registered_account.adjust_money(-final_cost))
				say("Sorry, but you do not have enough money.")
				return
			say("purchased [english_list(grocery_list)] items")
			grocery_list.Cut()
			update_static_data(chef)
	to_chat(world, action)
	. = TRUE
