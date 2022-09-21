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

/datum/design/rolling_paper_pack
	name = "Rolling Paper Pack"
	id = "rolling_paper_pack"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/storage/fancy/rollingpapers
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/leather
	name = "Sheet of Leather"
	id = "leather"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 150)
	build_path = /obj/item/stack/sheet/leather
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/secbelt
	name = "Security Belt"
	id = "secbelt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/security
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/medbelt
	name = "Medical Belt"
	id = "medbel"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/medical
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/janibelt
	name = "Janitorial Belt"
	id = "janibelt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/janitor
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/plantbelt
	name = "Botanical Belt"
	id = "plantbelt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/plant
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/s_holster
	name = "Shoulder Holster"
	id = "s_holster"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 400)
	build_path = /obj/item/storage/belt/holster
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/rice_hat
	name = "Rice Hat"
	id = "rice_hat"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/clothing/head/costume/rice_hat
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)
