/obj/item/seeds/vale
	name = "vale seed pack"
	desc = "These seeds grow into vale plants. Once sold as a luxury for their unique aesthetics, after the trees suddenly combusted they were taken off of the market."
	icon = 'modular_doppler/xenoarch/icons/seeds.dmi'
	icon_state = "vale"
	species = "vale"
	plantname = "Vale Plant"
	product = /obj/item/food/grown/vale
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'modular_doppler/xenoarch/icons/growing.dmi'
	icon_grow = "vale-stage"
	growthstages = 4
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/pink)
	reagents_add = list(/datum/reagent/stable_plasma = 0.1, /datum/reagent/toxin/plasma = 0.1, /datum/reagent/napalm = 0.1)

/obj/item/food/grown/vale
	seed = /obj/item/seeds/vale
	name = "vale"
	desc = "A cluster of vale leaves, keep away from open flames."
	icon = 'modular_doppler/xenoarch/icons/harvest.dmi'
	icon_state = "vale"
	filling_color = "#FF4500"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/toxin/plasma
	tastes = list("plasma" = 1)
