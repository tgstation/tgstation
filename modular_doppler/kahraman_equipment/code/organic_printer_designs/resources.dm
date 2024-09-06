/datum/design/organic_plastic
	name = "Plastic Sheet"
	id = "oganic_plastic"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 25)
	build_path = /obj/item/stack/sheet/plastic
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_AKHTER_RESOURCES,
	)

/datum/design/organic_cloth
	name = "Cloth"
	id = "oganic_cloth"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 10)
	build_path = /obj/item/stack/sheet/cloth
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_AKHTER_RESOURCES,
	)
