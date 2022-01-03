// Eggplant
/obj/item/seeds/eggplant
	name = "pack of eggplant seeds"
	desc = "These seeds grow to produce berries that look nothing like eggs."
	icon_state = "seed-eggplant"
	species = "eggplant"
	plantname = "Eggplants"
	product = /obj/item/food/grown/eggplant
	yield = 2
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "eggplant-grow"
	icon_dead = "eggplant-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/eggplant/eggy)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/eggplant
	seed = /obj/item/seeds/eggplant
	name = "eggplant"
	desc = "Maybe there's a chicken inside?"
	icon_state = "eggplant"
	foodtypes = FRUIT
	wine_power = 20
	filling_color = "#800080"

// Egg-Plant
/obj/item/seeds/eggplant/eggy
	name = "pack of egg-plant seeds"
	desc = "These seeds grow to produce berries that look a lot like eggs."
	icon_state = "seed-eggy"
	species = "eggy"
	plantname = "Egg-Plants"
	product = /obj/item/food/grown/shell/eggy
	lifespan = 75
	production = 12
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/shell/eggy
	seed = /obj/item/seeds/eggplant/eggy
	name = "egg-plant"
	desc = "There MUST be a chicken inside."
	icon_state = "eggyplant"
	trash_type = /obj/item/food/egg
	foodtypes = MEAT
	distill_reagent = /datum/reagent/consumable/ethanol/eggnog
	filling_color = "#F8F8FF"
