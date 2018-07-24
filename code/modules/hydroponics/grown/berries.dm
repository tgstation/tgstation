// Berries
/obj/item/seeds/berry
	name = "pack of berry seeds"
	desc = "These seeds grow into berry bushes."
	icon_state = "seed-berry"
	species = "berry"
	plantname = "Berry Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/berries
	lifespan = 20
	maturation = 5
	production = 5
	yield = 2
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "berry-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "berry-dead" // Same for the dead icon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/berry/glow, /obj/item/seeds/berry/poison)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/berries
	seed = /obj/item/seeds/berry
	name = "bunch of berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	gender = PLURAL
	filling_color = "#FF00FF"
	bitesize_mod = 2
	foodtype = FRUIT
	juice_results = list("berryjuice" = 0)
	tastes = list("berry" = 1)
	distill_reagent = "gin"

// Poison Berries
/obj/item/seeds/berry/poison
	name = "pack of poison-berry seeds"
	desc = "These seeds grow into poison-berry bushes."
	icon_state = "seed-poisonberry"
	species = "poisonberry"
	plantname = "Poison-Berry Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/berries/poison
	mutatelist = list(/obj/item/seeds/berry/death)
	reagents_add = list("cyanide" = 0.15, "tirizene" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)
	rarity = 10 // Mildly poisonous berries are common in reality

/obj/item/reagent_containers/food/snacks/grown/berries/poison
	seed = /obj/item/seeds/berry/poison
	name = "bunch of poison-berries"
	desc = "Taste so good, you might die!"
	icon_state = "poisonberrypile"
	filling_color = "#C71585"
	foodtype = FRUIT | TOXIC
	juice_results = list("poisonberryjuice" = 0)
	tastes = list("poison-berry" = 1)
	distill_reagent = null
	wine_power = 35

// Death Berries
/obj/item/seeds/berry/death
	name = "pack of death-berry seeds"
	desc = "These seeds grow into death berries."
	icon_state = "seed-deathberry"
	species = "deathberry"
	plantname = "Death Berry Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/berries/death
	lifespan = 30
	potency = 50
	mutatelist = list()
	reagents_add = list("coniine" = 0.08, "tirizene" = 0.1, "vitamin" = 0.04, "nutriment" = 0.1)
	rarity = 30

/obj/item/reagent_containers/food/snacks/grown/berries/death
	seed = /obj/item/seeds/berry/death
	name = "bunch of death-berries"
	desc = "Taste so good, you will die!"
	icon_state = "deathberrypile"
	filling_color = "#708090"
	foodtype = FRUIT | TOXIC
	tastes = list("death-berry" = 1)
	distill_reagent = null
	wine_power = 50

// Glow Berries
/obj/item/seeds/berry/glow
	name = "pack of glow-berry seeds"
	desc = "These seeds grow into glow-berry bushes."
	icon_state = "seed-glowberry"
	species = "glowberry"
	plantname = "Glow-Berry Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/berries/glow
	lifespan = 30
	endurance = 25
	mutatelist = list()
	genes = list(/datum/plant_gene/trait/glow/berry , /datum/plant_gene/trait/noreact, /datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("uranium" = 0.25, "iodine" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/berries/glow
	seed = /obj/item/seeds/berry/glow
	name = "bunch of glow-berries"
	desc = "Nutritious!"
	icon_state = "glowberrypile"
	filling_color = "#7CFC00"
	foodtype = FRUIT
	tastes = list("glow-berry" = 1)
	distill_reagent = null
	wine_power = 60

// Cherries
/obj/item/seeds/cherry
	name = "pack of cherry pits"
	desc = "Careful not to crack a tooth on one... That'd be the pits."
	icon_state = "seed-cherry"
	species = "cherry"
	plantname = "Cherry Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/cherries
	lifespan = 35
	endurance = 35
	maturation = 5
	production = 5
	growthstages = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "cherry-grow"
	icon_dead = "cherry-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/cherry/blue)
	reagents_add = list("nutriment" = 0.07, "sugar" = 0.07)

/obj/item/reagent_containers/food/snacks/grown/cherries
	seed = /obj/item/seeds/cherry
	name = "cherries"
	desc = "Great for toppings!"
	icon_state = "cherry"
	gender = PLURAL
	filling_color = "#FF0000"
	bitesize_mod = 2
	foodtype = FRUIT
	grind_results = list("cherryjelly" = 0)
	tastes = list("cherry" = 1)
	wine_power = 30

// Blue Cherries
/obj/item/seeds/cherry/blue
	name = "pack of blue cherry pits"
	desc = "The blue kind of cherries."
	icon_state = "seed-bluecherry"
	species = "bluecherry"
	plantname = "Blue Cherry Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/bluecherries
	mutatelist = list()
	reagents_add = list("nutriment" = 0.07, "sugar" = 0.07)
	rarity = 10

/obj/item/reagent_containers/food/snacks/grown/bluecherries
	seed = /obj/item/seeds/cherry/blue
	name = "blue cherries"
	desc = "They're cherries that are blue."
	icon_state = "bluecherry"
	filling_color = "#6495ED"
	bitesize_mod = 2
	foodtype = FRUIT
	grind_results = list("bluecherryjelly" = 0)
	tastes = list("blue cherry" = 1)
	wine_power = 50

// Grapes
/obj/item/seeds/grape
	name = "pack of grape seeds"
	desc = "These seeds grow into grape vines."
	icon_state = "seed-grapes"
	species = "grape"
	plantname = "Grape Vine"
	product = /obj/item/reagent_containers/food/snacks/grown/grapes
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	growthstages = 2
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "grape-grow"
	icon_dead = "grape-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/grape/green)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1, "sugar" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/grapes
	seed = /obj/item/seeds/grape
	name = "bunch of grapes"
	desc = "Nutritious!"
	icon_state = "grapes"
	dried_type = /obj/item/reagent_containers/food/snacks/no_raisin/healthy
	filling_color = "#FF1493"
	bitesize_mod = 2
	foodtype = FRUIT
	juice_results = list("grapejuice" = 0)
	tastes = list("grape" = 1)
	distill_reagent = "wine"

// Green Grapes
/obj/item/seeds/grape/green
	name = "pack of green grape seeds"
	desc = "These seeds grow into green-grape vines."
	icon_state = "seed-greengrapes"
	species = "greengrape"
	plantname = "Green-Grape Vine"
	product = /obj/item/reagent_containers/food/snacks/grown/grapes/green
	reagents_add = list("kelotane" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1, "sugar" = 0.1)
	// No rarity: technically it's a beneficial mutant, but it's not exactly "new"...
	mutatelist = list()

/obj/item/reagent_containers/food/snacks/grown/grapes/green
	seed = /obj/item/seeds/grape/green
	name = "bunch of green grapes"
	icon_state = "greengrapes"
	filling_color = "#7FFF00"
	tastes = list("green grape" = 1)
	distill_reagent = "cognac"
