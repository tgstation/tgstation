/// The maximum number of stacks you can place in 1 order
#define MAX_STACK_LIMIT 10
/// The order rank for all galactic material market orders
#define GALATIC_MATERIAL_ORDER "Galactic Materials Market"

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
	light_power = 3
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
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
	. = ..()
	if(default_unfasten_wrench(user, tool, time = 1.5 SECONDS) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/materials_market/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_open", "[base_icon_state]", tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/materials_market/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/materials_market/attackby(obj/item/markable_object, mob/user, list/modifiers, list/attack_modifiers)
	if(is_type_in_list(markable_object, exportable_material_items))
		if(machine_stat & NOPOWER)
			balloon_alert(user, "no power!")
			return FALSE
		var/material_to_export
		var/obj/item/stack/exportable = markable_object
		for(var/datum/material/mat as anything in SSstock_market.materials_prices)
			if(exportable.has_material_type(mat))
				material_to_export = mat
				break //This is only for trading non-alloys, so we can break here


		var/datum/export_report/report = export_item_and_contents(exportable, apply_elastic = FALSE, dry_run = TRUE) // We'll apply elastic price reduction when fully sold.
		var/price = 0
		var/amount = 0
		for(var/exported_datum in report.total_amount)
			price += report.total_value[exported_datum]
			amount += report.total_amount[exported_datum]

		if(amount <= 1)
			balloon_alert(user, "stack too small!")
			return FALSE

		if(price <= 0)
			balloon_alert(user, "not valuable enough to sell!")
			return FALSE

		qdel(markable_object)
		var/obj/item/stock_block/new_block = new /obj/item/stock_block(drop_location())
		new_block.export_value = price
		new_block.export_mat = material_to_export
		new_block.quantity = amount / SHEET_MATERIAL_AMOUNT
		to_chat(user, span_notice("You have created a stock block worth [new_block.export_value] cr! Sell it before it becomes liquid!"))
		playsound(src, 'sound/machines/synth/synth_yes.ogg', 50, FALSE)
		return TRUE
	return ..()

/obj/machinery/materials_market/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(0, 0)
	else
		set_light(initial(light_range), initial(light_power))

/**
 * Find the order purchased either privately or by cargo budget
 * Arguments
 * * [user][mob] - the user who placed this order
 * * is_ordering_private - is the player ordering privatly. If FALSE it means they are using cargo budget
 */
/obj/machinery/materials_market/proc/find_order(mob/user, is_ordering_private)
	for(var/datum/supply_order/order in SSshuttle.shopping_list)
		// Must be a Galactic Materials Market order and payed by the null account(if ordered via cargo budget) or by correct user for private purchase
		if(order.orderer_rank == GALATIC_MATERIAL_ORDER && ( \
			(!is_ordering_private && isnull(order.paying_account)) || \
			(is_ordering_private && !isnull(order.paying_account) && order.orderer == user) \
		))
			return order
	return null

/obj/machinery/materials_market/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!anchored)
		return
	if(!ui)
		ui = new(user, src, "MatMarket", name)
		ui.open()

/obj/machinery/materials_market/ui_static_data(mob/user)
	. = list()
	.["CARGO_CRATE_VALUE"] = CARGO_CRATE_VALUE

/obj/machinery/materials_market/ui_data(mob/user)
	. = list()

	//can this player use cargo budget
	var/can_buy_via_budget = FALSE
	var/obj/item/card/id/used_id_card
	if(isliving(user))
		var/mob/living/living_user = user
		used_id_card = living_user.get_idcard(TRUE)
		can_buy_via_budget = (ACCESS_CARGO in used_id_card?.GetAccess())

	//if no cargo access then force private purchase
	var/is_ordering_private = ordering_private || !can_buy_via_budget

	//find current order based on ordering mode & player
	var/datum/supply_order/current_order = find_order(user, is_ordering_private)

	var/material_data
	var/trend_string
	var/color_string
	var/sheet_to_buy
	var/requested_amount
	var/minimum_value_threshold = 0
	var/elastic_mult = 1
	for(var/datum/material/traded_mat as anything in SSstock_market.materials_prices)
		//convert trend into text
		switch(SSstock_market.materials_trends[traded_mat])
			if(0)
				trend_string = "neutral"
			if(1)
				trend_string = "up"
			else
				trend_string = "down"

		//get mat color
		var/initial_colors = initial(traded_mat.greyscale_color) || initial(traded_mat.color)
		if(initial_colors)
			color_string = splicetext(initial_colors, 7, length(initial_colors), "") //slice it to a standard 6 char hex
		else
			initial_colors = initial(traded_mat.color)
			if(initial_colors)
				color_string = initial_colors
			else
				color_string = COLOR_CYAN

		//get sheet type from material
		sheet_to_buy = initial(traded_mat.sheet_type)
		if(!sheet_to_buy)
			CRASH("Material with no sheet type being sold on materials market!")

		//get the ordered amount from the order
		requested_amount = 0
		if(!isnull(current_order))
			requested_amount = current_order.pack.contains[sheet_to_buy]

		var/min_value_override = initial(traded_mat.minimum_value_override)
		if(min_value_override)
			minimum_value_threshold = min_value_override
		else
			minimum_value_threshold = round(initial(traded_mat.value_per_unit) * SHEET_MATERIAL_AMOUNT * 0.5)

		//Pulling elastic modifier into data.
		for(var/datum/export/material/market/export_est in GLOB.exports_list)
			if(export_est.material_id == traded_mat)
				elastic_mult = (export_est.cost / export_est.init_cost) * 100

		material_data += list(list(
			"name" = initial(traded_mat.name),
			"price" = SSstock_market.materials_prices[traded_mat],
			"rarity" = initial(traded_mat.value_per_unit),
			"threshold" = minimum_value_threshold,
			"quantity" = SSstock_market.materials_quantity[traded_mat],
			"trend" = trend_string,
			"color" = color_string,
			"requested" = requested_amount,
			"elastic" = elastic_mult,
			))

	//get account balance
	var/balance = 0
	if(!ordering_private)
		var/datum/bank_account/dept = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(dept)
			balance = dept.account_balance
	else
		balance = used_id_card?.registered_account?.account_balance

	//is market crashing
	var/market_crashing = FALSE
	if(HAS_TRAIT(SSeconomy, TRAIT_MARKET_CRASHING))
		market_crashing = TRUE

	//get final order cost
	var/current_cost = 0
	if(!isnull(current_order))
		current_cost = current_order.get_final_cost()

	//pack data
	.["catastrophe"] = market_crashing
	.["materials"] = material_data
	.["creditBalance"] = balance
	.["orderBalance"] = current_cost
	.["orderingPrive"] = ordering_private
	.["canOrderCargo"] = can_buy_via_budget
	.["updateTime"] = SSstock_market.next_fire - world.time

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
	var/can_buy_via_budget = (ACCESS_CARGO in used_id_card?.GetAccess())

	//if multiple users open the UI some of them may not have the required access so we recheck
	var/is_ordering_private = ordering_private
	if(!can_buy_via_budget) //no cargo access then force private purchase
		is_ordering_private = TRUE

	switch(action)
		if("buy")
			var/material_str = params["material"]
			var/quantity = text2num(params["quantity"])

			//find material from its name
			var/datum/material/material_bought
			var/obj/item/stack/sheet/sheet_to_buy
			for(var/datum/material/mat as anything in SSstock_market.materials_prices)
				if(initial(mat.name) == material_str)
					material_bought = mat
					break
			if(!material_bought)
				CRASH("Invalid material name passed to materials market!")
			sheet_to_buy = initial(material_bought.sheet_type)
			if(!sheet_to_buy)
				CRASH("Material with no sheet type being sold on materials market!")

			//get available bank account for purchasing
			var/datum/bank_account/account_payable
			if(is_ordering_private)
				account_payable = used_id_card.registered_account
			else if(can_buy_via_budget)
				account_payable = SSeconomy.get_dep_account(ACCOUNT_CAR)
			if(!account_payable)
				say("No bank account detected!")
				return

			//sanity checks for available quantity & budget
			if(quantity > SSstock_market.materials_quantity[material_bought])
				say("Not enough materials on the market to purchase!")
				return

			var/cost = SSstock_market.materials_prices[material_bought] * quantity

			var/list/things_to_order = list()
			things_to_order += (sheet_to_buy)
			things_to_order[sheet_to_buy] = quantity

			// We want to count how many stacks of all sheets we're ordering to make sure they don't exceed the limit of 10
			// If we already have a custom order on SSshuttle, we should add the things to order to that order
			var/datum/supply_order/current_order = find_order(living_user, is_ordering_private)
			if(!isnull(current_order))
				// Check if this order exceeded the market limit
				var/prior_sheets = current_order.pack.contains[sheet_to_buy]
				if(prior_sheets + quantity > SSstock_market.materials_quantity[material_bought] )
					say("There aren't enough sheets on the market! Please wait for more sheets to be traded before adding more.")
					playsound(usr, 'sound/machines/synth/synth_no.ogg', 35, FALSE)
					return

				// Check if the order exceeded the purchase limit
				var/prior_stacks = ROUND_UP(prior_sheets / MAX_STACK_SIZE)
				if(prior_stacks >= MAX_STACK_LIMIT)
					say("There are already 10 stacks of sheets on order! Please wait for them to arrive before ordering more.")
					playsound(usr, 'sound/machines/synth/synth_no.ogg', 35, FALSE)
					return

				// Prevents you from ordering more than the available budget
				var/datum/bank_account/paying_account = account_payable
				if(!isnull(current_order.paying_account)) //order is already being paid by another account
					paying_account = current_order.paying_account
				if(current_order.get_final_cost() + cost > paying_account.account_balance)
					say("Order exceeds available budget! Please send it before purchasing more.")
					return

				// Finally Append to this order
				current_order.append_order(things_to_order, cost)
				return TRUE


			//Place a new order
			var/datum/supply_pack/custom/minerals/mineral_pack = new(
				purchaser = is_ordering_private ? living_user : "Cargo", \
				cost = cost, \
				contains = things_to_order, \
			)
			var/datum/supply_order/disposable/materials/new_order = new(
				pack = mineral_pack,
				orderer = living_user,
				orderer_rank = GALATIC_MATERIAL_ORDER,
				orderer_ckey = living_user.ckey,
				paying_account = is_ordering_private ? account_payable : null,
				cost_type = "cr",
				can_be_cancelled = FALSE
			)
			//first time order compute the correct cost and compare
			if(new_order.get_final_cost() > account_payable.account_balance)
				say("Not enough money to start purchase!")
				qdel(new_order)
				return

			say("Thank you for your purchase! It will arrive on the next cargo shuttle!")
			SSshuttle.shopping_list += new_order
			return TRUE

		if("toggle_budget")
			if(!can_buy_via_budget)
				return
			ordering_private = !ordering_private
			return TRUE

		if("clear")
			var/datum/supply_order/current_order = find_order(living_user, is_ordering_private)
			if(!isnull(current_order))
				SSshuttle.shopping_list -= current_order
				qdel(current_order)
				return TRUE

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
	/// Is this stock block currently updating its value with the market (aka fluid)?
	var/fluid = FALSE

/obj/item/stock_block/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(value_warning)), 1.5 MINUTES, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(update_value)), 3 MINUTES, TIMER_DELETE_ME)

/obj/item/stock_block/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] is worth [export_value] cr, from selling [quantity] sheets of [initial(export_mat?.name)].")
	if(fluid)
		. += span_warning("\The [src] is currently liquid! Its value is based on the market price.")
	else
		. += span_notice("\The [src]'s value is still [span_boldnotice("locked in")]. [span_boldnotice("Sell it")] before its value becomes liquid!")

/obj/item/stock_block/proc/value_warning()
	visible_message(span_warning("\The [src] is starting to become liquid!"))
	icon_state = "stock_block_fluid"
	update_appearance(UPDATE_ICON_STATE)

/obj/item/stock_block/proc/update_value()
	if(!SSstock_market.materials_prices[export_mat])
		return
	export_value = quantity * SSstock_market.materials_prices[export_mat]
	icon_state = "stock_block_liquid"
	update_appearance(UPDATE_ICON_STATE)
	visible_message(span_warning("\The [src] becomes liquid!"))
	fluid = TRUE

#undef MAX_STACK_LIMIT
#undef GALATIC_MATERIAL_ORDER
