/obj/machinery/computer/order_console/mining
	name = "mining equipment vendor"
	desc = "An equipment shop for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	circuit = /obj/item/circuitboard/computer/order_console/mining

	express_cost_multiplier = 1.5
	mining_point_price = TRUE
	order_categories = list(
		CATEGORY_MINING,
		CATEGORY_CONSUMABLES,
		CATEGORY_TOYS_DRONE,
		CATEGORY_PKA,
	)

/obj/machinery/computer/order_console/mining/order_groceries()
	for(var/datum/orderable_item/ordered_item in grocery_list)
		if(!(ordered_item.category_index in order_categories))
			grocery_list.Remove(ordered_item)
			continue
		if(ordered_item in SSshuttle.mining_groceries)
			SSshuttle.mining_groceries[ordered_item] += grocery_list[ordered_item]
		else
			SSshuttle.mining_groceries[ordered_item] = grocery_list[ordered_item]
	grocery_list.Cut()

/obj/machinery/computer/order_console/mining/ui_act(action, params)
	. = ..()
	if(!.)
		flick("mining-deny", src)

/obj/machinery/computer/order_console/mining/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/mining_voucher))
		redeem_voucher(weapon, user)
		return
	return ..()

/obj/machinery/computer/order_console/mining/update_icon_state()
	icon_state = "[initial(icon_state)][powered() ? null : "-off"]"
	return ..()


/**
 * Allows user to redeem a mining voucher for one set of a mining equipment
 *
 * * Arguments:
 * * voucher The mining voucher that is being used to redeem the mining equipment
 * * redeemer The mob that is redeeming the mining equipment
 */
/obj/machinery/computer/order_console/mining/proc/redeem_voucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/static/list/set_types
	if(!set_types)
		set_types = list()
		for(var/datum/voucher_set/static_set as anything in subtypesof(/datum/voucher_set))
			set_types[initial(static_set.name)] = new static_set

	var/list/items = list()
	for(var/set_name in set_types)
		var/datum/voucher_set/current_set = set_types[set_name]
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = current_set.icon, icon_state = current_set.icon_state)
		option.info = span_boldnotice(current_set.description)
		items[set_name] = option

	var/selection = show_radial_menu(redeemer, src, items, custom_check = CALLBACK(src, .proc/check_menu, voucher, redeemer), radius = 38, require_near = TRUE, tooltips = TRUE)
	if(!selection)
		return

	var/datum/voucher_set/chosen_set = set_types[selection]
	for(var/item in chosen_set.set_items)
		new item(drop_location())

	SSblackbox.record_feedback("tally", "mining_voucher_redeemed", 1, selection)
	qdel(voucher)

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * * Arguments:
 * * voucher The mining voucher that is being used to redeem a mining equipment
 * * redeemer The living mob interacting with the menu
 */
/obj/machinery/computer/order_console/mining/proc/check_menu(obj/item/mining_voucher/voucher, mob/living/redeemer)
	if(!istype(redeemer))
		return FALSE
	if(redeemer.incapacitated())
		return FALSE
	if(QDELETED(voucher))
		return FALSE
	if(!redeemer.is_holding(voucher))
		return FALSE
	return TRUE

/obj/machinery/computer/order_console/mining/golem
	name = "golem ship equipment vendor"
	circuit = /obj/item/circuitboard/computer/order_console/mining/golem
	forced_express = TRUE
	express_cost_multiplier = 1
	order_categories = list(
		CATEGORY_GOLEM,
		CATEGORY_MINING,
		CATEGORY_CONSUMABLES,
		CATEGORY_TOYS_DRONE,
		CATEGORY_PKA,
	)

/**********************Mining Equipment Voucher**********************/

/obj/item/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment vendor."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY

/**********************Mining Point Card**********************/

/obj/item/card/mining_point_card
	name = "mining points card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data_1"

	///Amount of points this card contains.
	var/points = 500

/obj/item/card/mining_point_card/examine(mob/user)
	. = ..()
	. += span_alert("There's [points] point\s on the card.")

/obj/item/card/mining_point_card/attackby(obj/item/attacking_item, mob/user, params)
	if(!isidcard(attacking_item))
		return ..()
	if(!points)
		to_chat(user, span_alert("There's no points left on [src]."))
		return
	var/obj/item/card/id/attacking_id = attacking_item
	attacking_id.mining_points += points
	to_chat(user, span_info("You transfer [points] points to [attacking_id]."))
	points = 0
