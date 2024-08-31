/obj/item/seeds/amauri
	name = "amauri seed pack"
	desc = "These seeds grow into amauri plants. Grows bulbs full of potent toxins."
	icon = 'modular_doppler/xenoarch/icons/seeds.dmi'
	icon_state = "amauri"
	species = "amauri"
	plantname = "Amauri Plant"
	product = /obj/item/food/grown/amauri
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'modular_doppler/xenoarch/icons/growing.dmi'
	icon_grow = "amauri-stage"
	growthstages = 3
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/preserved)
	reagents_add = list(/datum/reagent/toxin = 0.1, /datum/reagent/toxin/venom = 0.1, /datum/reagent/toxin/hot_ice = 0.1)

/obj/item/food/grown/amauri
	seed = /obj/item/seeds/amauri
	name = "amauri"
	desc = "A toxic amauri bulb, you shouldn't eat this."
	icon = 'modular_doppler/xenoarch/icons/harvest.dmi'
	icon_state = "amauri"
	filling_color = "#FF4500"
	bite_consumption_mod = 0.5
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/toxin
	tastes = list("poison" = 1)
