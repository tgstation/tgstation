/obj/machinery/materials_market
	name = "galactic materials market"
	desc = "This machine allows the user to buy and sell sheets of minerals \
		across the system. Prices are known to fluxuate quite often,\
		sometimes even within the same minute. All transactions are final."
	circuit = /obj/item/circuitboard/machine/materials_market
	req_access = list(ACCESS_CARGO)
	density = TRUE
	icon = 'icons/obj/economy.dmi'
	icon_state = "mat_market"
	base_icon_state = "mat_market"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION
	var/list/exportable_material_items = list(
		/obj/item/stack/sheet/iron, //God why are we like this
		/obj/item/stack/sheet/glass, //No really, God why are we like this
		/obj/item/stack/sheet/mineral,
		/obj/item/stack/tile/mineral,
		/obj/item/stack/ore,
		/obj/item/stack/sheet/bluespace_crystal,
		/obj/item/stack/rods
	)

/obj/machinery/materials_market/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]_open"
		return ..()
	if(!is_operational || !anchored)
		icon_state = "[base_icon_state]_off"
		return ..()
	icon_state = "[base_icon_state]"
	return ..()

/obj/machinery/materials_market/wrench_act(mob/living/user, obj/item/tool)
	..()
	default_unfasten_wrench(user, tool, time = 1.5 SECONDS)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/materials_market/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_open", "[base_icon_state]", O))
		return
	else if(default_deconstruction_crowbar(O))
		return
	if(is_type_in_list(O, exportable_material_items))
		say("I'm in")
		var/amount = 0
		var/value = 0
		var/mat_name = ""
		var/obj/item/stack/exportable = O
		for(var/datum/material/mat as anything in SSstock_market.materials_prices)
			if(exportable.has_material_type(mat))
				amount = exportable.amount
				value = SSstock_market.materials_prices[mat]
				mat_name = mat.name
				break //This is only for trading non-alloys, so we can break here

		if(!amount)
			say("Not enough material. Aborting.")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE)
			return TRUE
		qdel(exportable)
		var/obj/item/stock_block/new_block = new /obj/item/stock_block(drop_location())
		new_block.export_value = amount * value
		new_block.export_name = mat_name
		balloon_alert_to_viewers("stock block created!")
		return TRUE
	return ..()


/obj/machinery/materials_market/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!anchored)
		return
	if(!ui)
		ui = new(user, src, "MatMarket", name)
		ui.open()

/obj/machinery/materials_market/ui_data(mob/user)
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

/obj/machinery/materials_market/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!isliving(usr))
		return
	switch(action)
		if("buy")
			var/material_str = params["material"]
			var/quantity = text2num(params["quantity"])

			var/datum/material/material_bought
			var/obj/item/stack/sheet/sheet_to_buy
			for(var/datum/material/mat as anything in SSstock_market.materials_prices)
				if(mat.name == material_str)
					material_bought = mat
					break
			if(!material_bought)
				CRASH("Invalid material name passed to materials market!")
			var/mob/living/living_user = usr
			var/obj/item/card/id/used_id_card = living_user.get_idcard(TRUE)
			var/cost = SSstock_market.materials_prices[mat] * quantity

			sheet_to_buy = material_bought.sheet_type
			if(!sheet_to_buy)
				CRASH("Material with no sheet type being sold on materials market!")
				return
			if(!used_id_card || !used_id_card.registered_account)
				say("No bank account detected!")
				return
			if(cost > used_id_card.registered_account.balance)
				to_chat(living_user, span_warning("You don't have enough money to buy that!"))
				return
			used_id_card.registered_account.adjust_money(-cost, "Materials Market Purchase")
			var/list/things_to_order = list()
			things_to_order += (sheet_to_buy)
			things_to_order[sheet_to_buy] = quantity
			//Now we need to add a cargo order for quantity sheets of material_bought.sheet_type
			var/datum/supply_pack/custom/minerals/mineral_pack = new(
				purchaser = living_user, \
				cost = SSstock_market.materials_prices[material_bought] * quantity, \
				contains = things_to_order, \
				)
			var/datum/supply_order/new_order = new(
				pack = mineral_pack,
				orderer = living_user,
				orderer_rank = "Galactic Materials Market",
				orderer_ckey = living_user.ckey,
				reason = "",
				paying_account = used_id_card.registered_account,
				department_destination = null,
				coupon = null,
				charge_on_purchase = FALSE,
				manifest_can_fail = FALSE,
				cost_type = "credit",
				can_be_cancelled = FALSE,
			)
			say("Thank you for your purchase! It will arrive on the next cargo shuttle!")
			SSshuttle.shopping_list += new_order

/obj/item/stock_block
	name = "stock block"
	desc = "A block of stock. It's worth a certain amount of money, based on a sale on the materials market. Ship it on the cargo shuttle to claim your money."
	icon = 'icons/obj/economy.dmi'
	icon_state = "stock_block"
	/// How many credits was this worth when created?
	var/export_value = 0
	/// What is the name of the material this was made from?
	var/export_name = "stuff"

/obj/item/stock_block/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] is worth [export_value] cr, from selling sheets of [export_name].")
