// Citrus - base type
/obj/item/food/grown/citrus
	seed = /obj/item/seeds/lime
	name = "citrus"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	foodtypes = FRUIT
	wine_power = 30

// Lime
/obj/item/seeds/lime
	name = "pack of lime seeds"
	desc = "These are very sour seeds."
	icon_state = "seed-lime"
	species = "lime"
	plantname = "Lime Tree"
	product = /obj/item/food/grown/citrus/lime
	lifespan = 55
	endurance = 50
	yield = 4
	potency = 15
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/orange)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/food/grown/citrus/lime
	seed = /obj/item/seeds/lime
	name = "lime"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	juice_results = list(/datum/reagent/consumable/limejuice = 0)

// Orange
/obj/item/seeds/orange
	name = "pack of orange seeds"
	desc = "Sour seeds."
	icon_state = "seed-orange"
	species = "orange"
	plantname = "Orange Tree"
	product = /obj/item/food/grown/citrus/orange
	lifespan = 60
	endurance = 50
	yield = 5
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/lime, /obj/item/seeds/orange_3d)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/food/grown/citrus/orange
	seed = /obj/item/seeds/orange
	name = "orange"
	desc = "It's a tangy fruit."
	icon_state = "orange"
	foodtypes = ORANGES
	juice_results = list(/datum/reagent/consumable/orangejuice = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/triple_sec

// Lemon
/obj/item/seeds/lemon
	name = "pack of lemon seeds"
	desc = "These are sour seeds."
	icon_state = "seed-lemon"
	species = "lemon"
	plantname = "Lemon Tree"
	product = /obj/item/food/grown/citrus/lemon
	lifespan = 55
	endurance = 45
	yield = 4
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/firelemon)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05)

/obj/item/food/grown/citrus/lemon
	seed = /obj/item/seeds/lemon
	name = "lemon"
	desc = "When life gives you lemons, make lemonade."
	icon_state = "lemon"
	juice_results = list(/datum/reagent/consumable/lemonjuice = 0)

// Combustible lemon
/obj/item/seeds/firelemon //combustible lemon is too long so firelemon
	name = "pack of combustible lemon seeds"
	desc = "When life gives you lemons, don't make lemonade. Make life take the lemons back! Get mad! I don't want your damn lemons!"
	icon_state = "seed-firelemon"
	species = "firelemon"
	plantname = "Combustible Lemon Tree"
	product = /obj/item/food/grown/firelemon
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/bomb_plant/potency_based)
	lifespan = 55
	endurance = 45
	yield = 4
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.05, /datum/reagent/fuel = 0.05)

/obj/item/food/grown/firelemon
	seed = /obj/item/seeds/firelemon
	name = "Combustible Lemon"
	desc = "Made for burning houses down."
	icon_state = "firelemon"
	alt_icon = "firelemon_active"
	foodtypes = FRUIT
	wine_power = 70

//3D Orange
/obj/item/seeds/orange_3d
	name = "pack of extradimensional orange seeds"
	desc = "Polygonal seeds."
	icon_state = "seed-orange"
	species = "orange"
	plantname = "Extradimensional Orange Tree"
	product = /obj/item/food/grown/citrus/orange_3d
	lifespan = 60
	endurance = 50
	yield = 5
	potency = 20
	instability = 64
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.05, /datum/reagent/medicine/haloperidol = 0.15) //insert joke about the effects of haloperidol and our glorious headcoder here

/obj/item/food/grown/citrus/orange_3d
	seed = /obj/item/seeds/orange_3d
	name = "extradimensional orange"
	desc = "You can hardly wrap your head around this thing."
	icon_state = "orang"
	foodtypes = ORANGES
	alt_icon = "orange"
	bite_consumption_mod = 2
	juice_results = list(/datum/reagent/consumable/orangejuice = 0)
	distill_reagent = /datum/reagent/toxin/mindbreaker
	tastes = list("polygons" = 1, "bluespace" = 1, "the true nature of reality" = 1)

/obj/item/food/grown/citrus/orange_3d/pickup(mob/user)
	. = ..()
	icon_state = alt_icon

/obj/item/food/grown/citrus/orange_3d/dropped(mob/user)
	. = ..()
	icon_state = initial(icon_state)
