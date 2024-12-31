// Cherries
/obj/item/seeds/cherry
	name = "cherry pit pack"
	desc = "Careful not to crack a tooth on one... That'd be the pits."
	icon_state = "seed-cherry"
	species = "cherry"
	plantname = "Cherry Tree"
	product = /obj/item/food/grown/cherries
	lifespan = 35
	endurance = 35
	maturation = 5
	production = 5
	growthstages = 5
	instability = 15
	growing_icon = 'icons/obj/service/hydroponics/growing_fruits.dmi'
	icon_grow = "cherry-grow"
	icon_dead = "cherry-dead"
	icon_harvest = "cherry-harvest"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/cherry/blue, /obj/item/seeds/cherry/bulb)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.07, /datum/reagent/consumable/sugar = 0.07)

/obj/item/food/grown/cherries
	seed = /obj/item/seeds/cherry
	name = "cherries"
	desc = "Great for toppings!"
	icon_state = "cherry"
	gender = PLURAL
	bite_consumption_mod = 2
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/cherryjelly = 0)
	tastes = list("cherry" = 1)
	wine_power = 30

// Blue Cherries
/obj/item/seeds/cherry/blue
	name = "blue cherry pit pack"
	desc = "The blue kind of cherries."
	icon_state = "seed-bluecherry"
	species = "bluecherry"
	plantname = "Blue Cherry Tree"
	product = /obj/item/food/grown/bluecherries
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.07, /datum/reagent/consumable/sugar = 0.07, /datum/reagent/oxygen = 0.07)
	rarity = 10

/obj/item/food/grown/bluecherries
	seed = /obj/item/seeds/cherry/blue
	name = "blue cherries"
	desc = "They're cherries that are blue."
	icon_state = "bluecherry"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/bluecherryjelly = 0)
	tastes = list("blue cherry" = 1)
	wine_power = 50

//Cherry Bulbs
/obj/item/seeds/cherry/bulb
	name = "cherry bulb pit pack"
	desc = "The glowy kind of cherries."
	icon_state = "seed-cherrybulb"
	species = "cherrybulb"
	plantname = "Cherry Bulb Tree"
	product = /obj/item/food/grown/cherrybulbs
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/pink)
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.07, /datum/reagent/consumable/sugar = 0.07)
	rarity = 10
	graft_gene = /datum/plant_gene/trait/glow/pink

/obj/item/food/grown/cherrybulbs
	seed = /obj/item/seeds/cherry/bulb
	name = "cherry bulbs"
	desc = "They're like little Space Christmas lights!"
	icon_state = "cherry_bulb"
	bite_consumption_mod = 2
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/cherryjelly = 0)
	tastes = list("cherry" = 1)
	wine_power = 50

//Cherry Bombs
/obj/item/seeds/cherry/bomb
	name = "cherry bomb pit pack"
	desc = "They give you vibes of dread and frustration."
	icon_state = "seed-cherry_bomb"
	species = "cherry_bomb"
	plantname = "Cherry Bomb Tree"
	product = /obj/item/food/grown/cherry_bomb
	mutatelist = null
	genes = list(/datum/plant_gene/trait/bomb_plant, /datum/plant_gene/trait/modified_volume/cherry_bomb)
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/consumable/sugar = 0.1, /datum/reagent/gunpowder = 0.7)
	rarity = 60 //See above

/obj/item/food/grown/cherry_bomb
	name = "cherry bombs"
	desc = "You think you can hear the hissing of a tiny fuse."
	icon_state = "cherry_bomb"
	alt_icon = "cherry_bomb_lit"
	seed = /obj/item/seeds/cherry/bomb
	bite_consumption_mod = 3
	wine_power = 80
