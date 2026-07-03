/datum/design/strange_seeds
	name = "Strange seed pack"
	id = "strange_seeds"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 2000)
	build_path = /obj/item/seeds/random
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/material_pouch
	name = "Material pouch"
	id = "material_pouch"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 200)
	build_path = /obj/item/storage/bag/material_pouch
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)
