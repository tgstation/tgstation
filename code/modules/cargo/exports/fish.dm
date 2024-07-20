/datum/export/fish
	cost = 50
	unit_name = "fish"
	export_types = list(/obj/item/fish)

/datum/export/fish/get_cost(obj/item/fish/fish, apply_elastic)
	var/elastic_cost = ..()
	var/elastic_percent = elastic_cost / init_cost
	var/size_weight_exponentation = (fish.size * fish.weight * 0.01)^0.85
	return round(elastic_cost + size_weight_exponentation * elastic_percent)
