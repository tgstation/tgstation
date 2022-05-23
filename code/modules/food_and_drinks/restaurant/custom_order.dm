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
	return image(icon = 'icons/obj/machines/restaurant_portal.dmi' , icon_state = "thought_bubble") // empty thought bubble

/// Returns the order line shout by the mob and also shown to the player when examining it.
/datum/custom_order/proc/get_order_line()
	stack_trace("[type]/get_order_line() not set")
	return  "broken custom order pls call a coder"

/datum/custom_order/moth_clothing
	/// The item type that we want to order, usually clothing
	var/wanted_clothing_type

/datum/custom_order/moth_clothing/New(datum/venue/our_venue)
	var/mob/living/carbon/buffet = our_venue.restaurant_portal?.turned_on_portal?.resolve()
	if (!istype(buffet)) // Always asks for the clothes that you have on, but this is a fallback.
		wanted_clothing_type = pick_weight(list(
			/obj/item/clothing/head/chefhat = 3,
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

/datum/custom_order/icecream/New()
	if(prob(33))
		cone_type = /obj/item/food/icecream/chocolate
	var/static/list/possible_flavors = list()
	for(var/flavour as anything in GLOB.ice_cream_flavours)
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
		sortTim(wanted_flavors, cmp = /proc/cmp_text_asc)
		icecream_name = "[english_list(wanted_flavors)] ice cream ([initial(cone_type.name)])"

/datum/custom_order/icecream/get_order_line(datum/venue/our_venue)
	return "I'll take \a [icecream_name]"

/datum/custom_order/icecream/get_order_appearance(datum/venue/our_venue)
	var/image/food_image = image(icon = 'icons/obj/machines/restaurant_portal.dmi' , icon_state = "thought_bubble")
	var/image/i_scream = image('icons/obj/kitchen.dmi', initial(cone_type.icon_state))

	var/added_offset = 0
	for(var/flavor in wanted_flavors)
		var/image/scoop = image('icons/obj/kitchen.dmi', GLOB.ice_cream_flavours[flavor].icon_state)
		scoop.pixel_y = added_offset
		i_scream.overlays += scoop
		added_offset += ICE_CREAM_SCOOP_OFFSET
	food_image.add_overlay(i_scream)

	return food_image
