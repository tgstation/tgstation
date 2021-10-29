/datum/design/medbandolier
	name = "Medical Bandolier"
	id = "medban"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 600)
	build_path = /obj/item/storage/belt/medbandolier
	category = list("initial","Organic Materials")

/datum/design/biomeat
	name = "Meat Product"
	id = "meatp"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 125) //Monkey Cube is more efficient, but this is easier on the chef.
	build_path = /obj/item/food/meat/slab/meatproduct
	category = list("initial","Food")
