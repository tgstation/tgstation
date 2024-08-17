// Berries
/obj/item/seeds/berry
	name = "berry seed pack"
	desc = "These seeds grow into berry bushes."
	icon_state = "seed-berry"
	species = "berry"
	plantname = "Berry Bush"
	product = /obj/item/food/grown/berries
	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	instability = 30
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_grow = "berry-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "berry-dead" // Same for the dead icon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/berry/glow, /obj/item/seeds/berry/poison)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/berries
	seed = /obj/item/seeds/berry
	name = "bunch of berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	gender = PLURAL
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/berryjuice
	tastes = list("berry" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/gin

// Poison Berries
/obj/item/seeds/berry/poison
	name = "poison-berry seed pack"
	desc = "These seeds grow into poison-berry bushes."
	icon_state = "seed-poisonberry"
	species = "poisonberry"
	plantname = "Poison-Berry Bush"
	product = /obj/item/food/grown/berries/poison
	mutatelist = list(/obj/item/seeds/berry/death)
	reagents_add = list(/datum/reagent/toxin/cyanide = 0.15, /datum/reagent/toxin/staminatoxin = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 10 // Mildly poisonous berries are common in reality

/obj/item/food/grown/berries/poison
	seed = /obj/item/seeds/berry/poison
	name = "bunch of poison-berries"
	desc = "Taste so good, you might die!"
	icon_state = "poisonberrypile"
	bite_consumption_mod = 3
	foodtypes = FRUIT | TOXIC
	juice_typepath = /datum/reagent/consumable/poisonberryjuice
	tastes = list("poison-berry" = 1)
	distill_reagent = null
	wine_power = 35

// Death Berries
/obj/item/seeds/berry/death
	name = "death-berry seed pack"
	desc = "These seeds grow into death berries."
	icon_state = "seed-deathberry"
	species = "deathberry"
	plantname = "Death Berry Bush"
	product = /obj/item/food/grown/berries/death
	lifespan = 30
	potency = 50
	mutatelist = null
	reagents_add = list(/datum/reagent/toxin/coniine = 0.08, /datum/reagent/toxin/staminatoxin = 0.1, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = 30

/obj/item/food/grown/berries/death
	seed = /obj/item/seeds/berry/death
	name = "bunch of death-berries"
	desc = "Taste so good, you will die!"
	icon_state = "deathberrypile"
	bite_consumption_mod = 3
	foodtypes = FRUIT | TOXIC
	juice_typepath = /datum/reagent/consumable/poisonberryjuice
	tastes = list("death-berry" = 1)
	distill_reagent = null
	wine_power = 50

// Glow Berries
/obj/item/seeds/berry/glow
	name = "glow-berry seed pack"
	desc = "These seeds grow into glow-berry bushes."
	icon_state = "seed-glowberry"
	species = "glowberry"
	plantname = "Glow-Berry Bush"
	product = /obj/item/food/grown/berries/glow
	lifespan = 30
	endurance = 25
	mutatelist = null
	genes = list(/datum/plant_gene/trait/glow/white, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/uranium = 0.25, /datum/reagent/iodine = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)
	rarity = PLANT_MODERATELY_RARE
	graft_gene = /datum/plant_gene/trait/glow/white

/obj/item/food/grown/berries/glow
	seed = /obj/item/seeds/berry/glow
	name = "bunch of glow-berries"
	desc = "Nutritious!"
	bite_consumption_mod = 3
	icon_state = "glowberrypile"
	foodtypes = FRUIT
	tastes = list("glow-berry" = 1)
	distill_reagent = null
	wine_power = 60

// Grapes
/obj/item/seeds/grape
	name = "grape seed pack"
	desc = "These seeds grow into grape vines."
	icon_state = "seed-grapes"
	species = "grape"
	plantname = "Grape Vine"
	product = /obj/item/food/grown/grapes
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	growthstages = 2
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_grow = "grape-grow"
	icon_dead = "grape-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/grape/green)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1, /datum/reagent/consumable/sugar = 0.1)

/obj/item/food/grown/grapes
	seed = /obj/item/seeds/grape
	name = "bunch of grapes"
	desc = "Nutritious!"
	icon_state = "grapes"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/grapejuice
	tastes = list("grape" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/wine

/obj/item/food/grown/grapes/make_dryable()
	AddElement(/datum/element/dryable, /obj/item/food/no_raisin/healthy)

// Green Grapes
/obj/item/seeds/grape/green
	name = "green grape seed pack"
	desc = "These seeds grow into green-grape vines."
	icon_state = "seed-greengrapes"
	species = "greengrape"
	plantname = "Green-Grape Vine"
	product = /obj/item/food/grown/grapes/green
	reagents_add = list( /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1, /datum/reagent/consumable/sugar = 0.1, /datum/reagent/medicine/c2/aiuri = 0.2)
	mutatelist = null

/obj/item/food/grown/grapes/green
	seed = /obj/item/seeds/grape/green
	name = "bunch of green grapes"
	icon_state = "greengrapes"
	bite_consumption_mod = 3
	tastes = list("green grape" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/cognac

// Toechtauese Berries
/obj/item/seeds/toechtauese
	name = "töchtaüse berry seed pack"
	desc = "These seeds grow into töchtaüse bushes."
	icon_state = "seed-toechtauese"
	species = "toechtauese"
	plantname = "Töchtaüse Bush"
	product = /obj/item/food/grown/toechtauese
	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	instability = 30
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_grow = "toechtauese-grow"
	icon_dead = "toechtauese-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/toxin/itching_powder = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/food/grown/toechtauese
	seed = /obj/item/seeds/toechtauese
	name = "töchtaüse berries"
	desc = "A branch with töchtaüse berries on it. They're a favourite on the Mothic Fleet, but not in this form."
	icon_state = "toechtauese_branch"
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/toechtauese_juice
	tastes = list("fiery itchy pain" = 1)
	distill_reagent = /datum/reagent/toxin/itching_powder

/obj/item/seeds/lanternfruit
	name = "lanternfruit seed pack"
	desc = "These seeds grow into lanternfruit pods."
	icon_state = "seed-lanternfruit"
	species = "lanternfruit"
	plantname = "Lanternfruit Pod"
	product = /obj/item/food/grown/lanternfruit
	lifespan = 35
	endurance = 35
	maturation = 5
	production = 5
	growthstages = 3
	instability = 15
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_grow = "lanternfruit-grow"
	icon_dead = "lanternfruit-dead"
	icon_harvest = "lanternfruit-harvest"
	genes = list(/datum/plant_gene/trait/glow/yellow)
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.07, /datum/reagent/sulfur = 0.07, /datum/reagent/consumable/sugar = 0.07, /datum/reagent/consumable/liquidelectricity = 0.07)
	graft_gene = /datum/plant_gene/trait/glow/yellow

/obj/item/food/grown/lanternfruit
	seed = /obj/item/seeds/lanternfruit
	name = "lanternfruits"
	desc = "A sofly glowing fruit with a handle-shaped stem, an Ethereal favorite!"
	icon_state = "lanternfruit"
	foodtypes = FRUIT
	tastes = list("tv static" = 1, "sour pear" = 1, "grapefruit" = 1)
	distill_reagent = /datum/reagent/consumable/ethanol/wine_voltaic
