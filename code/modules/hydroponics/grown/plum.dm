// Plum
/obj/item/seeds/plum
	name = "pack of plum seeds"
	desc = "These seeds grow into plum trees."
	icon_state = "seed-plum"
	species = "plum"
	plantname = "Plum Tree"
	product = /obj/item/food/grown/plum
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "plum-grow"
	icon_dead = "plum-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/one_bite)
	mutatelist = list(/obj/item/seeds/plum/plumb)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1, /datum/reagent/impurity/rosenol = 0.04)

/obj/item/food/grown/plum
	seed = /obj/item/seeds/plum
	name = "plum"
	desc = "A poet's favorite fruit. Noice."
	icon_state = "plum"
	foodtypes = FRUIT
	juice_results = list(/datum/reagent/consumable/plumjuice = 0)
	tastes = list("plum" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/plumwine

// Plumb
/obj/item/seeds/plum/plumb
	name = "pack of plumb seeds"
	desc = "These seeds grow into plumb trees."
	icon_state = "seed-plumb"
	species = "plumb"
	plantname = "Plumb Tree"
	product = /obj/item/food/grown/plum/plumb
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1, /datum/reagent/lead = 0.04)
	rarity = 30

/obj/item/food/grown/plum/plumb
	seed = /obj/item/seeds/plum/plumb
	name = "plumb"
	desc = "It feels very heavy."
	icon_state = "plumb"
	distill_reagent = null
	wine_power = 50
