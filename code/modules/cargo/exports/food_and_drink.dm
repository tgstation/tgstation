/**
 * Original Food export file got eaten somewhere along the line and I have no idea when or where it got completely deleted.
 * Foods given a venue value are exportable to cargo as a backup to selling from venues, however at the expense of elasticity.
 */
/datum/export/food
	cost = 10
	unit_name = "serving"
	message = "of food"
	export_types = list(/obj/item/food)
	include_subtypes = TRUE
	exclude_types = list(/obj/item/food/grown)

/datum/export/food/get_cost(obj/O, allowed_categories, apply_elastic)
	. = ..()
	var/obj/item/food/sold_food = O
	tweak_description(sold_food)
	if(sold_food.flags & FOOD_SILVER_SPAWNED)
		return FOOD_WORTHLESS
	return sold_food.venue_value


