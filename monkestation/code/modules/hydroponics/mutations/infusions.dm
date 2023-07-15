/datum/hydroponics/plant_mutation/infusion/chilly_pepper
	mutates_from = list(/obj/item/seeds/chili)
	created_product = /obj/item/food/grown/icepepper
	created_seed = /obj/item/seeds/chili/ice
	reagent_requirement = list(/datum/reagent/cryostylane, /datum/reagent/medicine/cryoxadone)

/datum/hydroponics/plant_mutation/infusion/eggy_plant
	mutates_from = list(/obj/item/seeds/eggplant)
	reagent_requirement = list(/datum/reagent/consumable/ethanol/eggnog)
	created_product = /obj/item/food/grown/shell/eggy
	created_seed = /obj/item/seeds/eggplant/eggy

/datum/hydroponics/plant_mutation/infusion/coconut_gun
	mutates_from = list(/obj/item/seeds/coconut)
	reagent_requirement = list(/datum/reagent/gunpowder)
	created_product = /obj/item/food/grown/shell/coconut_gun
	created_seed = /obj/item/seeds/coconut/gun
