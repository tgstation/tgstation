GLOBAL_DATUM(default_slime_market, /obj/machinery/computer/slime_market)

/obj/machinery/computer/slime_market
	name = "slime market console"
	desc = "Used to sell slime cores and manage intergalactic slime bounties."
	icon = 'monkestation/code/modules/slimecore/icons/machinery.dmi'
	icon_state = "market"
	icon_screen = "market_screen"
	icon_keyboard = ""
	keyboard_change_icon = FALSE
	light_color = LIGHT_COLOR_LAVENDER
	circuit = /obj/item/circuitboard/computer/slime_market
	var/obj/machinery/slime_market_pad/market_pad
	var/obj/machinery/slime_extract_requestor/request_pad
	var/stored_credits = 0

	var/static/list/slime_shop_items = list()

/obj/machinery/computer/slime_market/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	if(!GLOB.default_slime_market && is_station_level(z))
		GLOB.default_slime_market = src

	link_market_pad()

/obj/machinery/computer/slime_market/Destroy()
	. = ..()
	if(GLOB.default_slime_market == src)
		GLOB.default_slime_market = null

	if(market_pad)
		market_pad.console = null
	if(request_pad)
		request_pad.console = null

	request_pad = null
	market_pad = null

/obj/machinery/computer/slime_market/proc/link_market_pad()
	if(market_pad)
		return

	for(var/direction in GLOB.cardinals)
		market_pad = locate(/obj/machinery/slime_market_pad, get_step(src, direction))
		if(market_pad)
			market_pad.link_console()
			break

	return market_pad

/obj/machinery/computer/slime_market/attackby(obj/item/weapon, mob/user, params)
	if(panel_open)
		if(weapon.tool_behaviour == TOOL_MULTITOOL)
			if(!multitool_check_buffer(user, weapon))
				return
			var/obj/item/multitool/M = weapon
			if(!M.buffer)
				return
			var/obj/machinery/slime_extract_requestor/pad = M.buffer
			if(!istype(pad))
				return
			pad.console = src
			request_pad = pad
			to_chat(user, span_notice("You link the [pad] to the [src]."))
	. = ..()

/obj/machinery/computer/slime_market/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/xenobio_market)
	)

/obj/machinery/computer/slime_market/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "XenobioMarket", name)
		ui.open()

/obj/machinery/computer/slime_market/ui_static_data(mob/user)
	var/list/data = list()
	if(!length(slime_shop_items))
		for(var/datum/slime_store_item/subtype as anything in subtypesof(/datum/slime_store_item))
			slime_shop_items += new subtype

	data["shop_items"] = list()
	for(var/datum/slime_store_item/listed as anything in slime_shop_items)
		var/list/shop_item = list()
		shop_item += list(
			"name" = listed.name,
			"desc" = listed.desc,
			"icon_state" = initial(listed.item_path.icon_state),
			"cost" = listed.cost,
			"item_path" = listed.item_path,
		)
		data["shop_items"] += list(shop_item)
	return data

/obj/machinery/computer/slime_market/ui_data()
	var/data = list()
	var/list/prices = list()
	var/list/price_row = list()
	var/iter = 1
	for(var/core_type in (subtypesof(/obj/item/slime_extract) - subtypesof(/obj/item/slime_extract/rainbow)))
		if(iter % 4 == 1)
			prices.Add(list(list("key" = LAZYLEN(prices), "prices" = price_row.Copy())))
			price_row = list()

		if(core_type == /obj/item/slime_extract/grey)
			price_row.Add(list(list("key" = iter % 4)))
			iter += 1

		var/obj/item/slime_extract/core = core_type
		var/list/core_data = list(
			"icon" = "[initial(core.icon_state)]",
			"price" = SSresearch.slime_core_prices[core_type],
			"key" = iter % 4
		)
		price_row.Add(list(core_data))
		iter += 1

		if(core_type == /obj/item/slime_extract/grey)
			core = /obj/item/slime_extract/rainbow
			var/list/rainbow_core_data = list(
				"icon" = "[initial(core.icon_state)]",
				"price" = SSresearch.slime_core_prices[/obj/item/slime_extract/rainbow],
				"key" = iter % 4
			)
			price_row.Add(list(rainbow_core_data))
			iter += 1
			price_row.Add(list(list("key" = iter % 4)))
			iter += 1

	data["points"] = SSresearch.xenobio_points
	data["prices"] = prices
	data["requests"] = list()
	if(request_pad)
		for(var/datum/extract_request_data/request as anything in request_pad.current_requests)
			var/list/request_data = list()
			var/obj/item/request_item = request.extract_path
			request_data += list(
				"icon" = initial(request_item.icon_state),
				"amount" = request.extracts_needed,
				"name" = request.request_name,
				"payout" = request.payout,
				"amount_give" = request.extracts_given,
			)
			data["requests"] += list(request_data)

	return data

/obj/machinery/computer/slime_market/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("buy")
			for(var/datum/slime_store_item/item as anything in slime_shop_items)
				if(text2path(params["path"]) == item.item_path)
					try_buy(item)
					return TRUE

/obj/machinery/computer/slime_market/proc/return_extracts(obj/item/slime_extract/type, amount)
	for(var/i in 1 to amount)
		new type(loc)

/obj/machinery/computer/slime_market/proc/try_buy(datum/slime_store_item/attempt)
	if(SSresearch.xenobio_points < attempt.cost)
		return
	new attempt.item_path(get_turf(src))
	SSresearch.xenobio_points -= attempt.cost
