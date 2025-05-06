/datum/design/pocket_medkit
	name = "Empty Pocket First Aid Kit"
	id = "slavic_cfap"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 250)
	build_path = /obj/item/storage/pouch/cin_medkit
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_COLONIAL_MEDICAL,
	)

/datum/design/medipouch
	name = "Empty Medipen Pouch"
	id = "slavic_medipouch"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 250)
	build_path = /obj/item/storage/pouch/cin_medipens
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_COLONIAL_MEDICAL,
	)

/datum/design/sutures
	name = "Hemostatic Sutures"
	id = "slavic_suture"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 150)
	build_path = /obj/item/stack/medical/suture/bloody
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_COLONIAL_MEDICAL,
	)

/datum/design/mesh
	name = "Hemostatic Mesh"
	id = "slavic_mesh"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 150)
	build_path = /obj/item/stack/medical/mesh/bloody
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_COLONIAL_MEDICAL,
	)

/datum/design/bruise_patch
	name = "Bruise Patch"
	id = "slavic_bruise"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 250)
	build_path = /obj/item/reagent_containers/applicator/patch/libital
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_COLONIAL_MEDICAL,
	)

/datum/design/burn_patch
	name = "Burn Patch"
	id = "slavic_burn"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 250)
	build_path = /obj/item/reagent_containers/applicator/patch/aiuri
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_COLONIAL_MEDICAL,
	)

/datum/design/gauze
	name = "Medical Gauze"
	id = "slavic_gauze"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 100)
	build_path = /obj/item/stack/medical/gauze
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_COLONIAL_MEDICAL,
	)

/datum/design/epi_pill
	name = "Epinephrine Pill"
	id = "slavic_epi"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 75)
	build_path = /obj/item/reagent_containers/applicator/pill/epinephrine
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_COLONIAL_MEDICAL,
	)

/datum/design/conv_pill
	name = "Convermol Pill"
	id = "slavic_conv"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 75)
	build_path = /obj/item/reagent_containers/applicator/pill/convermol
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_COLONIAL_MEDICAL,
	)

/datum/design/multiver_pill
	name = "Multiver Pill"
	id = "slavic_multiver"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 75)
	build_path = /obj/item/reagent_containers/applicator/pill/multiver
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_COLONIAL_MEDICAL,
	)

#undef RND_CATEGORY_COLONIAL_FOOD
#undef RND_CATEGORY_COLONIAL_MEDICAL
#undef RND_CATEGORY_COLONIAL_CLOTHING
