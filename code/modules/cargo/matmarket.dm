/obj/machinery/materials
	name = "galactic materials market console"
	desc = "This console allows the user to buy and sell sheets of minerals \
		across the system. Prices are known to fluxuate quite often,\
		sometimes even within the same minute. All transactions are final."
	circuit = null //make a circuit for this
	req_access = list(ACCESS_CARGO)
	density = TRUE
	icon = 'icons/obj/economy.dmi'
	icon_state = "mat_market"
	base_icon_state = "mat_market"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION

/obj/machinery/materials/Initialize(mapload)
	. = ..()

/obj/machinery/materials/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]_open"
		return ..()
	if(!is_operational)
		icon_state = "[base_icon_state]_off"
		return ..()
	icon_state = "[base_icon_state]"
	return ..()

/obj/machinery/materials/wrench_act(mob/living/user, obj/item/tool)
	..()
	default_unfasten_wrench(user, tool, time = 1.5 SECONDS)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/materials/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_open", "[base_icon_state]", O))
		return
	else if(default_deconstruction_crowbar(O))
		return

/obj/machinery/materials/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MatMarket", name)
		ui.open()

/obj/machinery/materials/ui_data(mob/user)
	var/data = list()
	var/material_data
	for(var/datum/material/traded_mat as anything in SSstock_market.materials_prices)
		var/trend_string = ""
		if(SSstock_market.materials_trends[traded_mat] == 0)
			trend_string = "neutral"
		else if(SSstock_market.materials_trends[traded_mat] == 1)
			trend_string = "up"
		else if(SSstock_market.materials_trends[traded_mat] == -1)
			trend_string = "down"
		material_data += list(list(
			"name" = traded_mat.name,
			"price" = SSstock_market.materials_prices[traded_mat],
			"quantity" = SSstock_market.materials_quantity[traded_mat],
			"trend" = trend_string,
			))
	data["materials"] = material_data
	return data

/obj/machinery/materials/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("buy")
			say("Figure out how to do this right!")
		if("sell")
			say("also figure this out!")

