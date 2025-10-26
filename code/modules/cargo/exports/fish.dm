/datum/export/fish
	cost = 30
	k_hit_percentile = 0.03
	unit_name = "fish"
	export_types = list(/obj/item/fish)

/datum/export/fish/get_base_cost(obj/item/fish/fish)
	return fish.get_export_price(..())
