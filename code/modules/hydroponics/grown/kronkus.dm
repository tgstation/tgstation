/obj/item/seeds/kronkus
	name = "pack of kronkus seeds"
	desc = "A pack of highly illegal kronkus seeds.\nPossession of these seeds carries the death penalty in 7 sectors."
	icon_state = "seed-kronkus"
	plant_icon_offset = 6
	species = "kronkus"
	plantname = "Kronkus Vine"
	product = /obj/item/food/grown/kronkus
	//shitty stats, because botany is easy
	lifespan = 60
	endurance = 10
	maturation = 8
	production = 4
	yield = 3
	growthstages = 3
	growing_icon = 'icons/obj/service/hydroponics/growing.dmi'
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05)

/obj/item/seeds/kronkus/Initialize(mapload, nogenes)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/food/grown/kronkus
	seed = /obj/item/seeds/kronkus
	name = "kronkus vine segment"
	desc = "A piece of mature kronkus vine. It exudes a sharp and noxious odor."
	icon_state = "kronkus"
	filling_color = "#37946e"
	foodtypes = VEGETABLES | TOXIC
	distill_reagent = /datum/reagent/kronkus_extract

/obj/item/food/grown/kronkus/Initialize(mapload, nogenes)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)
