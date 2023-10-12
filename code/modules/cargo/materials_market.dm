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
	/// What items can be converted into a stock block? Must be a stack subtype based on current implementation.
	var/static/list/exportable_material_items = list(
		/obj/item/stack/sheet/iron, //God why are we like this
		/obj/item/stack/sheet/glass, //No really, God why are we like this
		/obj/item/stack/sheet/mineral,
		/obj/item/stack/tile/mineral,
		/obj/item/stack/ore,
		/obj/item/stack/sheet/bluespace_crystal,
		/obj/item/stack/rods
	)
	/// Are we ordering sheets from our own card balance or the cargo budget?
	var/ordering_private = TRUE
	/// Currently, can we order sheets from our own card balance or the cargo budget?
	var/can_buy_via_budget = FALSE

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
		var/amount = 0
		var/value = 0
		var/material_to_export
		var/obj/item/stack/exportable = O
		for(var/datum/material/mat as anything in SSstock_market.materials_prices)
			if(exportable.has_material_type(mat))
				amount = exportable.amount
				value = SSstock_market.materials_prices[mat]
				material_to_export = mat
				break //This is only for trading non-alloys, so we can break here

		if(!amount)
			say("Not enough material. Aborting.")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE)
			return TRUE
		qdel(exportable)
		var/obj/item/stock_block/new_block = new /obj/item/stock_block(drop_location())
		new_block.export_value = amount * value * MARKET_PROFIT_MODIFIER
		new_block.export_mat = material_to_export
		new_block.quantity = amount
		to_chat(user, span_notice("You have created a stock block worth [new_block.export_value] cr! Sell it before it becomes liquid!"))
		playsound(src, 'sound/machines/synth_yes.ogg', 50, FALSE)
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
		var/color_string = ""
		if (initial(traded_mat.greyscale_colors))
			color_string = splicetext(initial(traded_mat.greyscale_colors), 7, length(initial(traded_mat.greyscale_colors)), "") //slice it to a standard 6 char hex
		else if(initial(traded_mat.color))
			color_string = initial(traded_mat.color)
		material_data += list(list(
			"name" = initial(traded_mat.name),
			"price" = SSstock_market.materials_prices[traded_mat],
			"quantity" = SSstock_market.materials_quantity[traded_mat],
			"trend" = trend_string,
			"color" = color_string,
			))

	can_buy_via_budget = FALSE
	var/obj/item/card/id/used_id_card
	if(isliving(user))
		var/mob/living/living_user = user
		used_id_card = living_user.get_idcard(TRUE)
		can_buy_via_budget = (ACCESS_CARGO in used_id_card?.GetAccess())

	var/balance = 0
	if(!ordering_private)
		var/datum/bank_account/dept = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(dept)
			balance = dept.account_balance
	else
		balance = used_id_card?.registered_account?.account_balance

	var/market_crashing = FALSE
	if(HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING))
		market_crashing = TRUE

	data["catastrophe"] = market_crashing
	data["materials"] = material_data
	data["creditBalance"] = balance
	data["orderingPrive"] = ordering_private
	data["canOrderCargo"] = can_buy_via_budget
	return data

/obj/machinery/materials_market/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	//You must have an ID to be able to do something
	var/mob/living/living_user = ui.user
	var/obj/item/card/id/used_id_card = living_user.get_idcard(TRUE)
	if(isnull(used_id_card))
		say("No ID Found")
		return

	switch(action)
		if("buy")
			var/material_str = params["material"]
			var/quantity = text2num(params["quantity"])

			var/datum/material/material_bought
			var/obj/item/stack/sheet/sheet_to_buy
			for(var/datum/material/mat as anything in SSstock_market.materials_prices)
				if(initial(mat.name) == material_str)
					material_bought = mat
					break
			if(!material_bought)
				CRASH("Invalid material name passed to materials market!")

			//if multiple users open the UI some of them may not have the required access so we recheck
			var/is_ordering_private = ordering_private
			if(!(ACCESS_CARGO in used_id_card.GetAccess())) //no cargo access then force private purchase
				is_ordering_private = TRUE

			var/datum/bank_account/account_payable
			if(is_ordering_private)
				account_payable = used_id_card.registered_account
			else if(can_buy_via_budget)
				account_payable = SSeconomy.get_dep_account(ACCOUNT_CAR)
			if(!account_payable)
				say("No bank account detected!")
				return

			sheet_to_buy = initial(material_bought.sheet_type)
			if(!sheet_to_buy)
				CRASH("Material with no sheet type being sold on materials market!")
			var/cost = SSstock_market.materials_prices[material_bought] * quantity
			if(cost > account_payable.account_balance)
				to_chat(living_user, span_warning("You don't have enough money to buy that!"))
				return

			var/list/things_to_order = list()
			things_to_order += (sheet_to_buy)
			things_to_order[sheet_to_buy] = quantity
			// We want to count how many stacks of all sheets we're ordering to make sure they don't exceed the limit of 10
			// If we already have a custom order on SSshuttle, we should add the things to order to that order
			for(var/datum/supply_order/order in SSshuttle.shopping_list)
				// Must be a Galactic Materials Market order and payed by the null account(if ordered via cargo budget) or by correct user for private purchase
				if(order.orderer_rank == "Galactic Materials Market" && ( \
					(!is_ordering_private && order.paying_account == null) || \
					(is_ordering_private && order.paying_account != null && order.orderer == living_user) \
				))
					// Check if this order exceeded its limit
					var/prior_stacks = 0
					for(var/obj/item/stack/sheet/sheet as anything in order.pack.contains)
						prior_stacks += ROUND_UP(order.pack.contains[sheet] / 50)
						if(prior_stacks >= 10)
							to_chat(usr, span_notice("You already have 10 stacks of sheets on order! Please wait for them to arrive before ordering more."))
							playsound(usr, 'sound/machines/synth_no.ogg', 35, FALSE)
							return
					// Append to this order
					order.append_order(things_to_order, cost)
					return

			//Now we need to add a cargo order for quantity sheets of material_bought.sheet_type
			var/datum/supply_pack/custom/minerals/mineral_pack = new(
				purchaser = is_ordering_private ? living_user : "Cargo", \
				cost = cost, \
				contains = things_to_order, \
			)
			var/datum/supply_order/new_order = new(
				pack = mineral_pack,
				orderer = living_user,
				orderer_rank = "Galactic Materials Market",
				orderer_ckey = living_user.ckey,
				paying_account = is_ordering_private ? account_payable : null,
				cost_type = "credit",
				can_be_cancelled = FALSE
			)
			say("Thank you for your purchase! It will arrive on the next cargo shuttle!")
			SSshuttle.shopping_list += new_order
			return
		if("toggle_budget")
			if(!can_buy_via_budget)
				return
			ordering_private = !ordering_private

/obj/item/stock_block
	name = "stock block"
	desc = "A block of stock. It's worth a certain amount of money, based on a sale on the materials market. Ship it on the cargo shuttle to claim your money."
	icon = 'icons/obj/economy.dmi'
	icon_state = "stock_block"
	/// How many credits was this worth when created?
	var/export_value = 0
	/// What is the name of the material this was made from?
	var/datum/material/export_mat
	/// Quantity of export material
	var/quantity = 0
	/// Is this stock block currently updating it's value with the market (aka fluid)?
	var/fluid = FALSE

/obj/item/stock_block/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] is worth [export_value] cr, from selling [quantity] sheets of [initial(export_mat?.name)].")
	if(fluid)
		. += span_warning("\The [src] is currently liquid! It's value is based on the market price.")
	else
		. += span_notice("\The [src]'s value is still [span_boldnotice("locked in")]. [span_boldnotice("Sell it")] before it's value becomes liquid!")

/obj/item/stock_block/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(value_warning)), 2.5 MINUTES)
	addtimer(CALLBACK(src, PROC_REF(update_value)), 5 MINUTES)

/obj/item/stock_block/proc/value_warning()
	visible_message(span_warning("\The [src] is starting to become liquid!"))
	icon_state = "stock_block_fluid"
	update_appearance(UPDATE_ICON_STATE)

/obj/item/stock_block/proc/update_value()
	if(!export_mat)
		return
	if(!SSstock_market.materials_prices[export_mat])
		return
	export_value = quantity * SSstock_market.materials_prices[export_mat] * MARKET_PROFIT_MODIFIER
	icon_state = "stock_block_liquid"
	update_appearance(UPDATE_ICON_STATE)
	visible_message(span_warning("\The [src] becomes liquid!"))

