/datum/export/fish
	cost = 30
	unit_name = "fish"
	export_types = list(/obj/item/fish)

/datum/export/fish/get_cost(obj/item/fish/fish, apply_elastic)
	var/elastic_cost = ..()
	var/elastic_percent = elastic_cost / init_cost
	return fish.get_export_price(elastic_cost, elastic_percent)
