/datum/export/fish
	cost = 30
	unit_name = "fish"
	export_types = list(/obj/item/fish)

/datum/export/fish/get_base_cost(obj/item/fish/fish)
	return fish.get_export_price(..())
