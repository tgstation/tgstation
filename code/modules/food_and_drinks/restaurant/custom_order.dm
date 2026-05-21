/**
 * custom order datums
 * Used for less generic orders (ice cream for example)
 * without snowflaking venue and customer code too much.
 */
/datum/custom_order

/**
 * Returns the object that will be stored in the controller blackboard for the customer bot.
 * Normally but not necessarily, this would be the custom order itself. The moth clothing is a
 * good example of an exception to that.
 */
/datum/custom_order/proc/dispense_order()
	return src

///Whether or not the order is correct. Only relevant if dispense_order didn't return another object.
/datum/custom_order/proc/is_correct_order(obj/item/object_used)
	if(SEND_SIGNAL(object_used, COMSIG_ITEM_IS_CORRECT_CUSTOM_ORDER, src) & COMPONENT_CORRECT_ORDER)
		return TRUE

/// Returns the appearance of the order that appears when hovering over the mob with the cursor
/datum/custom_order/proc/get_order_appearance()
	stack_trace("[type]/get_order_appearance() not set")
	return image(icon = 'icons/effects/effects.dmi' , icon_state = "thought_bubble") // empty thought bubble

/// Returns the order line shout by the mob and also shown to the player when examining it.
/datum/custom_order/proc/get_order_line()
	stack_trace("[type]/get_order_line() not set")
	return  "broken custom order pls call a coder"

/**
 * Handles what the bot does with the order when it gets it
 *
 * Return [TRANSACTION_SUCCESS] to denote the order went through successfully (Not generally necessary to include here)
 * Return [TRANSACTION_HANDLED] to not do any further handling of the order by the
 */
/datum/custom_order/proc/handle_get_order(mob/living/basic/robot_customer/customer_pawn, obj/item/order_item)
	return NONE

/datum/custom_order/moth_clothing
	/// The item type that we want to order, usually clothing
	var/wanted_clothing_type

/datum/custom_order/moth_clothing/New(mob/living/basic/robot_customer/customer, datum/venue/our_venue)
	var/datum/weakref/portal_ref = our_venue.current_visitors[customer]
	var/obj/machinery/restaurant_portal/portal = portal_ref.resolve()
	var/mob/living/carbon/buffet = portal?.turned_on_portal?.resolve()
	if (!istype(buffet)) // Always asks for the clothes that you have on, but this is a fallback.
		wanted_clothing_type = pick_weight(list(
			/obj/item/clothing/head/utility/chefhat = 3,
			/obj/item/clothing/shoes/sneakers/black = 3,
			/obj/item/clothing/gloves/color/black = 1,
		))
		return

	var/list/orderable = list()

	if (!QDELETED(buffet.head))
		orderable[buffet.head.type] = 5

	if (!QDELETED(buffet.gloves))
		orderable[buffet.gloves.type] = 5

	if (!QDELETED(buffet.shoes))
		orderable[buffet.shoes.type] = 1

	if(!length(orderable))
		orderable = list(
			/obj/item/clothing/head/utility/chefhat = 3,
			/obj/item/clothing/shoes/sneakers/black = 3,
			/obj/item/clothing/gloves/color/black = 1,
		)

	wanted_clothing_type = pick_weight(orderable)


/datum/custom_order/moth_clothing/get_order_appearance(datum/venue/our_venue)
	return our_venue.get_food_appearance(wanted_clothing_type)

/datum/custom_order/moth_clothing/get_order_line(datum/venue/our_venue)
	return our_venue.order_food_line(wanted_clothing_type)

/datum/custom_order/moth_clothing/dispense_order()
	. = wanted_clothing_type
	qdel(src) // This datum is no longer needed.

/datum/custom_order/icecream
	/// The list of flavors we want.
	var/list/wanted_flavors = list()
	/// The type of cone we want the ice cream served in
	var/obj/item/food/icecream/cone_type = /obj/item/food/icecream
	/// stores tha name of our order generated on New()
	var/icecream_name

/datum/custom_order/icecream/New(mob/living/basic/robot_customer/customer)
	if(prob(33))
		cone_type = /obj/item/food/icecream/chocolate
	var/static/list/possible_flavors = list()
	for(var/flavour in GLOB.ice_cream_flavours)
		//only request standard flavors that are available from the ice cream vat
		if(!GLOB.ice_cream_flavours[flavour].hidden && flavour != ICE_CREAM_CUSTOM)
			possible_flavors += flavour

	for(var/iteration in 1 to rand(1, DEFAULT_MAX_ICE_CREAM_SCOOPS))
		var/chosen_flavor = pick(possible_flavors)
		wanted_flavors += chosen_flavor

	var/list/unique_list = unique_list(wanted_flavors)
	if(wanted_flavors.len > 1 && length(unique_list) == 1)
		icecream_name = "[make_tuple(wanted_flavors.len)] [wanted_flavors[1]] ice cream ([initial(cone_type.name)])"
	else
		sortTim(wanted_flavors, cmp = GLOBAL_PROC_REF(cmp_text_asc))
		icecream_name = "[english_list(wanted_flavors)] ice cream ([initial(cone_type.name)])"

/datum/custom_order/icecream/get_order_line(datum/venue/our_venue)
	return "I'll take \a [icecream_name]"

/datum/custom_order/icecream/get_order_appearance(datum/venue/our_venue)
	var/image/food_image = image(icon = 'icons/effects/effects.dmi' , icon_state = "thought_bubble")
	var/image/i_scream = image('icons/obj/service/kitchen.dmi', initial(cone_type.icon_state))

	var/added_offset = 0
	for(var/flavor in wanted_flavors)
		var/image/scoop = image('icons/obj/service/kitchen.dmi', "icecream_custom")
		scoop.color = GLOB.ice_cream_flavours[flavor].color
		scoop.pixel_z = added_offset
		i_scream.overlays += scoop
		added_offset += ICE_CREAM_SCOOP_OFFSET
	food_image.add_overlay(i_scream)

	return food_image

/datum/custom_order/reagent
	/// This is the typepath of reagent we desire
	var/datum/reagent/consumable/nutriment/soup/reagent_type
	/// What typepath container we want it to be in
	var/obj/item/container_needed
	/// How many reagents is needed
	var/reagents_needed = VENUE_BAR_MINIMUM_REAGENTS

/datum/custom_order/reagent/New(mob/living/basic/robot_customer/customer, reagent_type)
	. = ..()
	src.reagent_type = reagent_type

/datum/custom_order/reagent/get_order_line(datum/venue/our_venue)
	return "I'll take [reagents_needed]u of [initial(reagent_type.name)]"

/datum/custom_order/reagent/get_order_appearance(datum/venue/our_venue)
	var/image/food_image = image(icon = 'icons/effects/effects.dmi' , icon_state = "thought_bubble")
	var/datum/glass_style/draw_as = GLOB.glass_style_singletons[container_needed][reagent_type]
	var/image/drink_image = image(
		icon = draw_as?.icon || initial(reagent_type.fallback_icon) || initial(container_needed.icon),
		icon_state = draw_as?.icon_state || initial(reagent_type.fallback_icon_state) || initial(container_needed.icon_state),
	)
	food_image.add_overlay(drink_image)
	return food_image

/datum/custom_order/reagent/handle_get_order(mob/living/basic/robot_customer/customer_pawn, obj/item/order_item)
	. = TRANSACTION_HANDLED

	for(var/datum/reagent/reagent as anything in order_item.reagents?.reagent_list)
		if(reagent.type == reagent_type)
			. |= SEND_SIGNAL(reagent, COMSIG_REAGENT_SOLD_TO_CUSTOMER, customer_pawn, order_item)

	playsound(customer_pawn, 'sound/items/drink.ogg', rand(10, 50), TRUE)
	order_item.reagents.clear_reagents()

/datum/custom_order/reagent/is_correct_order(obj/item/object_used)
	if(..())
		return TRUE
	if(!istype(object_used, container_needed) || isnull(object_used.reagents))
		return FALSE

	var/datum/reagents/holder = object_used.reagents
	// The container must be majority reagent
	var/datum/reagent/master_reagent = holder.get_master_reagent()
	if(master_reagent?.type != reagent_type)
		return FALSE
	// We must fulfill the sample size threshold
	if(reagents_needed > holder.total_volume)
		return FALSE
	// Also must be at least 1/3rd of that reagent, prevent cheese
	if(holder.get_reagent_amount(reagent_type) < holder.total_volume * 0.33)
		return FALSE
	return TRUE

/datum/custom_order/reagent/drink
	container_needed = /obj/item/reagent_containers/cup/glass/drinkingglass

/datum/custom_order/reagent/drink/handle_get_order(mob/living/basic/robot_customer/customer_pawn, obj/item/order_item)
	customer_pawn.visible_message(
		span_danger("[customer_pawn] slurps up [order_item] in one go!"),
		span_danger("You slurp up [order_item] in one go."),
	)
	return ..()

/datum/custom_order/reagent/soup
	container_needed = /obj/item/reagent_containers/cup/bowl

	/// What serving we picked for the order
	var/picked_serving

/datum/custom_order/reagent/soup/New(mob/living/basic/robot_customer/customer, reagent_type)
	. = ..()
	var/list/serving_sizes = list(
		"small serving (15u)" = 15,
		"medium serving (20u)" = 20,
		"large serving (25u)" = 25,
	)
	picked_serving = pick(serving_sizes)
	reagents_needed = serving_sizes[picked_serving]

/datum/custom_order/reagent/soup/get_order_line(datum/venue/our_venue)
	return "I'll take a [picked_serving] of [initial(reagent_type.name)]"

/datum/custom_order/reagent/soup/handle_get_order(mob/living/basic/robot_customer/customer_pawn, obj/item/order_item)
	customer_pawn.visible_message(
		span_danger("[customer_pawn] pours [order_item] right down [customer_pawn.p_their()] hatch!"),
		span_danger("You pour [order_item] down your hatch in one go."),
	)
	return ..()
