///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

/datum/design/biogen
	abstract_type = /datum/design/biogen
	build_type = BIOGENERATOR
	// biomass doesn't have a sheet type, and the biogenerator isn't meant to churn out unprocessed biomass anyway.
	inherit_materials = DESIGN_DONT_INHERIT_MATS

/datum/design/biogen/milk
	name = "Synthetic Milk"
	materials = list(/datum/material/biomass = 0.4)
	make_reagent = /datum/reagent/consumable/milk
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/biogen/soymilk
	name = "Synthetic Soy Milk"
	materials = list(/datum/material/biomass = 0.4)
	make_reagent = /datum/reagent/consumable/soymilk
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/biogen/ethanol
	name = "Synthetic Ethanol"
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/ethanol
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/biogen/cream
	name = "Synthetic Cream"
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/cream
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/biogen/black_pepper
	name = "Synthetic Black Pepper"
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/blackpepper
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/biogen/enzyme
	name = "Synthetic Enzyme"
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/enzyme
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/biogen/flour
	name = "Synthetic Flour"
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/flour
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/biogen/sugar
	name = "Synthetic Sugar"
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/consumable/sugar
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/biogen/monkey_cube
	name = "Monkey Cube"
	materials = list(/datum/material/biomass = 50)
	build_path = /obj/item/food/monkeycube
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/biogen/seaweed_sheet
	name = "Seaweed Sheet"
	materials = list(/datum/material/biomass = 3)
	build_path = /obj/item/food/seaweedsheet
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_FOOD)

/datum/design/biogen/ez_nut   //easy nut :)
	name = "E-Z Nutrient"
	materials = list(/datum/material/biomass = 0.1)
	make_reagent = /datum/reagent/plantnutriment/eznutriment
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/biogen/l4z_nut
	name = "Left 4 Zed"
	materials = list(/datum/material/biomass = 0.1)
	make_reagent = /datum/reagent/plantnutriment/left4zednutriment
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/biogen/rh_nut
	name = "Robust Harvest"
	materials = list(/datum/material/biomass = 0.2)
	make_reagent = /datum/reagent/plantnutriment/robustharvestnutriment
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/biogen/end_gro
	name = "Enduro Grow"
	materials = list(/datum/material/biomass = 0.3)
	make_reagent = /datum/reagent/plantnutriment/endurogrow
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/biogen/liq_earth
	name = "Liquid Earthquake"
	materials = list(/datum/material/biomass = 0.3)
	make_reagent = /datum/reagent/plantnutriment/liquidearthquake
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/biogen/weed_killer
	name = "Weed Killer"
	materials = list(/datum/material/biomass = 0.2)
	make_reagent = /datum/reagent/toxin/plantbgone/weedkiller
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/biogen/pest_spray
	name = "Pest Killer"
	materials = list(/datum/material/biomass = 0.4)
	make_reagent = /datum/reagent/toxin/pestkiller
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/biogen/org_pest_spray
	name = "Organic Pest Killer"
	materials = list(/datum/material/biomass = 0.6)
	make_reagent = /datum/reagent/toxin/pestkiller/organic
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_CHEMICALS)

/datum/design/biogen/leather
	name = "Sheet of Leather"
	materials = list(/datum/material/biomass = 30)
	build_path = /obj/item/stack/sheet/leather
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/biogen/cloth
	name = "Sheet of Cloth"
	materials = list(/datum/material/biomass = 10)
	build_path = /obj/item/stack/sheet/cloth
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/biogen/cardboard
	name = "Sheet of Cardboard"
	materials = list(/datum/material/biomass = 5)
	build_path = /obj/item/stack/sheet/cardboard
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/biogen/paper
	name = "Sheet of Paper"
	materials = list(/datum/material/biomass = 2)
	build_path = /obj/item/paper
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/biogen/rolling_paper
	name = "Sheet of Rolling Paper"
	materials = list(/datum/material/biomass = 1)
	build_path = /obj/item/rollingpaper
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)

/datum/design/biogen/candle
	name = "Candle"
	materials = list(/datum/material/biomass = 3)
	build_path = /obj/item/flashlight/flare/candle
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BIO_MATERIALS)
