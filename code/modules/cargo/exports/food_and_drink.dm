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
	/// Have we already set the cost of this export? Necessary to avoid the cost being constantly reset.
	var/cost_obtained_from_venue_value = FALSE

/datum/export/food/get_cost(obj/object, allowed_categories, apply_elastic)
	if(HAS_TRAIT(object, TRAIT_FOOD_SILVER))
		return FOOD_PRICE_WORTHLESS

	var/obj/item/food/sold_food = object
	if(!cost_obtained_from_venue_value)
		cost = sold_food.venue_value
		cost_obtained_from_venue_value = TRUE

	return ..()
