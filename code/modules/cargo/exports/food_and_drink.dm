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

/datum/export/food/get_cost(obj/item/food/object, allowed_categories, apply_elastic)
	if(HAS_TRAIT(object, TRAIT_FOOD_SILVER))
		return FOOD_PRICE_WORTHLESS

	var/elastic_cost = ..()
	if(object.venue_value)
		var/elastic_percent = elastic_cost / init_cost
		return round(object.venue_value * elastic_percent)

	return elastic_cost
