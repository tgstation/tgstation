/obj/item/seeds/vaporsac
	name = "vaporsac seed pack"
	desc = "These seeds grow into vaporsac plants. Normally vaporsac plants spread by floating through the air and exploding, but this strand of vaporsac thankfully does not."
	icon = 'modular_doppler/xenoarch/icons/seeds.dmi'
	icon_state = "vaporsac"
	species = "vaporsac"
	plantname = "Vaporsac Plant"
	product = /obj/item/food/grown/vaporsac
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'modular_doppler/xenoarch/icons/growing.dmi'
	icon_grow = "vaporsac-stage"
	growthstages = 3
	genes = list(/datum/plant_gene/trait/squash, /datum/plant_gene/trait/smoke)
	reagents_add = list(/datum/reagent/nitrous_oxide = 0.1, /datum/reagent/medicine/muscle_stimulant = 0.1, /datum/reagent/medicine/coagulant = 0.1)

/obj/item/food/grown/vaporsac
	seed = /obj/item/seeds/vaporsac
	name = "vaporsac"
	desc = "An buoyant vaporsac, full of aerosolized chemicals."
	icon = 'modular_doppler/xenoarch/icons/harvest.dmi'
	icon_state = "vaporsac"
	filling_color = "#FF4500"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/nitrous_oxide
	tastes = list("sleep" = 1)
