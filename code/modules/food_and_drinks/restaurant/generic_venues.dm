
/////RESTAURANT/////
/datum/venue/restaurant
	name = "restaurant"
	req_access = ACCESS_KITCHEN
	venue_type = VENUE_RESTAURANT
	min_time_between_visitor = 80 SECONDS
	max_time_between_visitor = 100 SECONDS
	customer_types = list(
		/datum/customer_data/american = 50,
		/datum/customer_data/italian = 30,
		/datum/customer_data/french = 30,
		/datum/customer_data/mexican = 30,
		/datum/customer_data/japanese = 30,
		/datum/customer_data/japanese/salaryman = 20,
		/datum/customer_data/british/bobby = 20,
		/datum/customer_data/british/gent = 20,
		/datum/customer_data/moth = 1,
		/datum/customer_data/malfunction = 1,
	)

/datum/venue/restaurant/get_food_appearance(order)
	var/appearance = SSrestaurant.food_appearance_cache[order]

	if(!appearance) //We havn't made this one before, do so now.
		var/obj/item/temp_object = new order() //Make a temp object so we can see it including any overlays
		appearance = temp_object.appearance //And then steal its appearance
		SSrestaurant.food_appearance_cache[order] = appearance //and cache it for future orders
		qdel(temp_object)

	var/image/food_image = new
	food_image.appearance = appearance
	food_image.underlays += mutable_appearance(icon = 'icons/effects/effects.dmi' , icon_state = "thought_bubble")

	return food_image

/datum/venue/restaurant/is_correct_order(atom/movable/object_used, wanted_item)
	. = ..()
	return . || object_used.type == wanted_item

/datum/venue/restaurant/order_food_line(order)
	var/obj/item/object_to_order = order
	return "I'll take \a [initial(object_to_order.name)]"

/datum/venue/restaurant/on_get_order(mob/living/basic/robot_customer/customer_pawn, obj/item/order_item)
	var/transaction_result = ..()
	if((transaction_result & TRANSACTION_HANDLED) || !(transaction_result & TRANSACTION_SUCCESS))
		return

	customer_pawn.visible_message(
		span_danger("[customer_pawn] pushes [order_item] into their mouth-shaped hole!"),
		span_danger("You push [order_item] into your mouth-shaped hole."),
	)
	playsound(customer_pawn, 'sound/items/eatfood.ogg', rand(10,50), TRUE)
	qdel(order_item)

/obj/machinery/restaurant_portal/restaurant
	linked_venue = /datum/venue/restaurant

/obj/item/holosign_creator/robot_seat/restaurant
	name = "restaurant seating indicator placer"
	holosign_type = /obj/structure/holosign/robot_seat/restaurant

/obj/structure/holosign/robot_seat/restaurant
	name = "restaurant seating"
	linked_venue = /datum/venue/restaurant


/////BAR/////
/datum/venue/bar
	name = "bar"
	req_access = ACCESS_BAR
	venue_type = VENUE_BAR
	min_time_between_visitor = 40 SECONDS
	max_time_between_visitor = 60 SECONDS
	customer_types = list(
		/datum/customer_data/american = 50,
		/datum/customer_data/italian = 30,
		/datum/customer_data/french = 30,
		/datum/customer_data/mexican = 30,
		/datum/customer_data/japanese = 30,
		/datum/customer_data/japanese/salaryman = 20,
		/datum/customer_data/british/bobby = 20,
		/datum/customer_data/british/gent = 20,
		/datum/customer_data/malfunction = 1,
	)

/obj/machinery/restaurant_portal/bar
	name = "bar portal"
	linked_venue = /datum/venue/bar

/obj/item/holosign_creator/robot_seat/bar
	name = "bar seating indicator placer"
	holosign_type = /obj/structure/holosign/robot_seat/bar

/obj/structure/holosign/robot_seat/bar
	name = "bar seating"
	linked_venue = /datum/venue/bar
