///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

/datum/design/milk
	name = "10u Milk"
	id = "milk"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 20)
	make_reagents = list(/datum/reagent/consumable/milk = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/soymilk
	name = "10u Soy Milk"
	id = "soymilk"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 20)
	make_reagents = list(/datum/reagent/consumable/soymilk = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/ethanol
	name = "10u Ethanol"
	id = "ethanol"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/consumable/ethanol = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/cream
	name = "10u Cream"
	id = "cream"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/consumable/cream = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/black_pepper
	name = "10u Black Pepper"
	id = "black_pepper"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 25)
	make_reagents = list(/datum/reagent/consumable/blackpepper = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/enzyme
	name = "10u Universal Enzyme"
	id = "enzyme"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/consumable/enzyme = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/flour
	name = "10u Flour"
	id = "flour_sack"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/consumable/flour = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/sugar
	name = "10u Sugar"
	id = "sugar"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/consumable/sugar = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/monkey_cube
	name = "Monkey Cube"
	id = "mcube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 250)
	build_path = /obj/item/food/monkeycube
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/seaweed_sheet
	name = "Seaweed sheet"
	id = "seaweedsheet"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	build_path = /obj/item/food/seaweedsheet
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/ez_nut   //easy nut :)
	name = "25u E-Z Nutrient"
	id = "ez_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 10)
	make_reagents = list(/datum/reagent/plantnutriment/eznutriment = 25)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/l4z_nut
	name = "25u Left 4 Zed"
	id = "l4z_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 20)
	make_reagents = list(/datum/reagent/plantnutriment/left4zednutriment = 25)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/rh_nut
	name = "25u Robust Harvest"
	id = "rh_nut"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 25)
	make_reagents = list(/datum/reagent/plantnutriment/robustharvestnutriment = 25)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/end_gro
	name = "25u Enduro Grow"
	id = "end_gro"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/plantnutriment/endurogrow = 25)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/liq_earth
	name = "25u Liquid Earthquake"
	id = "liq_earth"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/plantnutriment/liquidearthquake = 25)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/weed_killer
	name = "25u Weed Killer"
	id = "weed_killer"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	make_reagents = list(/datum/reagent/toxin/plantbgone/weedkiller = 25)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/pest_spray
	name = "25u Pest Killer"
	id = "pest_spray"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	make_reagents = list(/datum/reagent/toxin/pestkiller = 25)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/org_pest_spray
	name = "25u Organic Pest Killer"
	id = "org_pest_spray"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 80)
	make_reagents = list(/datum/reagent/toxin/pestkiller/organic = 25)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/leather
	name = "Sheet of Leather"
	id = "leather"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 150)
	build_path = /obj/item/stack/sheet/leather
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/cloth
	name = "Roll of Cloth"
	id = "cloth"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/stack/sheet/cloth
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/cardboard
	name = "Sheet of Cardboard"
	id = "cardboard"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 25)
	build_path = /obj/item/stack/sheet/cardboard
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/paper
	name = "Sheet of Paper"
	id = "paper"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 10)
	build_path = /obj/item/paper
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/rolling_paper
	name = "Sheet of Rolling Paper"
	id = "rollingpaper"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 5)
	build_path = /obj/item/rollingpaper
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)
