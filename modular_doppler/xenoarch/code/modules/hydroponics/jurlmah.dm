/obj/item/seeds/jurlmah
	name = "jurlmah seed pack"
	desc = "These seeds grow into jurlmah plants. Often used as makeshift cryo-treatment in areas where a dedicated cryotube setup is impossible."
	icon = 'modular_doppler/xenoarch/icons/seeds.dmi'
	icon_state = "jurlmah"
	species = "jurlmah"
	plantname = "Jurlmah Plant"
	product = /obj/item/food/grown/jurlmah
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'modular_doppler/xenoarch/icons/growing.dmi'
	icon_grow = "jurlmah-stage"
	growthstages = 5
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/blue)
	reagents_add = list(/datum/reagent/medicine/cryoxadone = 0.1, /datum/reagent/inverse/healing/tirimol  = 0.1, /datum/reagent/consumable/frostoil = 0.1)

/obj/item/food/grown/jurlmah
	seed = /obj/item/seeds/jurlmah
	name = "jurlmah"
	desc = "A frosty jurlmah fruit, it feels cold to the touch."
	icon = 'modular_doppler/xenoarch/icons/harvest.dmi'
	icon_state = "jurlmah"
	filling_color = "#FF4500"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/medicine/cryoxadone
	tastes = list("snow" = 1)
