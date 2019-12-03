/obj/item/blackmarket_uplink
	name = "Black Market Uplink"
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "timer-radio2"

	// UI variables.
	var/ui_x = 720
	var/ui_y = 480
	var/viewing_category
	var/viewing_market
	var/selected_item
	var/buying

	var/money = 0
	var/list/accessible_markets = list(/datum/blackmarket_market/blackmarket)

/obj/item/blackmarket_uplink/Initialize()
	. = ..()
	if(accessible_markets.len)
		viewing_market = accessible_markets[1]
		var/list/categories = SSblackmarket.markets[viewing_market].categories
		if(categories && categories.len)
			viewing_category = categories[1]

/obj/item/blackmarket_uplink/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/holochip) || istype(I, /obj/item/stack/spacecash) || istype(I, /obj/item/coin))
		var/worth = I.get_item_credit_value()
		if(!worth)
			to_chat(user, "<span class='warning'>[I] doesn't seem to be worth anything!</span>")
		money += worth
		to_chat(user, "<span class='notice'>You slot [I] into [src] and it reports a total of [money] money inserted.</span>")
		qdel(I)
		return

	. = ..()

/obj/item/blackmarket_uplink/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "blackmarket_uplink", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/item/blackmarket_uplink/ui_data(mob/user)
	var/list/data = list()
	var/datum/blackmarket_market/market = viewing_market ? SSblackmarket.markets[viewing_market] : null
	data["categories"] = market ? market.categories : null
	data["delivery_methods"] = list()
	if(market)
		for(var/delivery in market.shipping)
			data["delivery_methods"] += list(list("name" = delivery, "price" = market.shipping[delivery]))
	data["money"] = money
	data["buying"] = buying
	data["items"] = list()
	data["viewing_category"] = viewing_category
	data["viewing_market"] = viewing_market
	if(viewing_category && market)
		if(market.available_items[viewing_category])
			for(var/datum/blackmarket_item/I in market.available_items[viewing_category])
				data["items"] += list(list(
					"id" = I.type,
					"name" = I.name,
					"cost" = I.price,
					"amount" = I.stock,
					"desc" = I.desc || I.name
				))
	return data

/obj/item/blackmarket_uplink/ui_static_data(mob/user)
	var/list/data = list()
	data["delivery_method_description"] = SSblackmarket.shipping_method_descriptions
	data["ltsrbt_built"] = SSblackmarket.telepads.len
	data["markets"] = list()
	for(var/M in accessible_markets)
		var/datum/blackmarket_market/BM = SSblackmarket.markets[M]
		data["markets"] += list(list(
			"id" = M,
			"name" = BM.name
		))
	return data

/obj/item/blackmarket_uplink/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("set_category")
			if(isnull(params["category"]))
				return
			if(isnull(viewing_market))
				return
			if(!(params["category"] in SSblackmarket.markets[viewing_market].categories))
				return
			viewing_category = params["category"]
			. = TRUE
		if("set_market")
			if(isnull(params["market"]))
				return
			var/market = text2path(params["market"])
			if(!(market in accessible_markets))
				return

			viewing_market = market

			var/list/categories = SSblackmarket.markets[viewing_market].categories
			if(categories && categories.len)
				viewing_category = categories[1]
			else
				viewing_category = null
			. = TRUE
		if("select")
			if(isnull(params["item"]))
				return
			var/item = text2path(params["item"])
			selected_item = item
			buying = TRUE
			. = TRUE
		if("cancel")
			selected_item = null
			buying = FALSE
			. = TRUE
		if("buy")
			if(isnull(params["method"]))
				return
			if(isnull(selected_item))
				// Huh??
				buying = FALSE
				return
			var/datum/blackmarket_market/market = SSblackmarket.markets[viewing_market]
			if(!(params["method"] in market.shipping))
				return
			for(var/datum/blackmarket_item/I in market.available_items[viewing_category])
				if(I.type == selected_item)
					var/overall_price = I.price + market.shipping[params["method"]]
					if(overall_price > money)
						to_chat(usr, "<span class='warning'>You don't have enough money in [src] for that!</span>")
						break

					if(I.buy(src, usr, params["method"]))
						money -= market.shipping[params["method"]]

					break
			buying = FALSE
			selected_item = null

/datum/crafting_recipe/blackmarket_uplink
	name = "Black Market Uplink"
	result = /obj/item/blackmarket_uplink
	time = 30
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER, TOOL_MULTITOOL)
	reqs = list(
		/obj/item/stock_parts/subspace/amplifier = 1,
		/obj/item/stack/cable_coil = 15,
		/obj/item/radio = 1,
		/obj/item/analyzer = 1
	)
	category = CAT_MISC
