// Weeds
/obj/item/seeds/weeds
	name = "pack of weed seeds"
	desc = "Yo mang, want some weeds?"
	icon_state = "seed"
	species = "weeds"
	plantname = "Starthistle"
	lifespan = 100
	endurance = 50 // damm pesky weeds
	maturation = 5
	production = 1
	yield = -1
	potency = -1
	oneharvest = 1
	growthstages = 4
	plant_type = PLANT_WEED


// Cabbage
/obj/item/seeds/cabbage
	name = "pack of cabbage seeds"
	desc = "These seeds grow into cabbages."
	icon_state = "seed-cabbage"
	species = "cabbage"
	plantname = "Cabbages"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	growthstages = 1
	mutatelist = list(/obj/item/seeds/replicapod)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	seed = /obj/item/seeds/cabbage
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	filling_color = "#90EE90"
	bitesize_mod = 2


// Sugarcane
/obj/item/seeds/sugarcane
	name = "pack of sugarcane seeds"
	desc = "These seeds grow into sugarcane."
	icon_state = "seed-sugarcane"
	species = "sugarcane"
	plantname = "Sugarcane"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	lifespan = 60
	endurance = 50
	maturation = 3
	yield = 4
	growthstages = 3
	reagents_add = list("sugar" = 0.25)

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	seed = /obj/item/seeds/sugarcane
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	filling_color = "#FFD700"
	bitesize_mod = 2


// Gatfruit
/obj/item/seeds/gatfruit
	name = "pack of gatfruit seeds"
	desc = "These seeds grow into .357 revolvers."
	icon_state = "seed-gatfruit"
	species = "gatfruit"
	plantname = "gatfruit"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/shell/gatfruit
	lifespan = 20
	endurance = 20
	maturation = 40
	production = 10
	yield = 2
	potency = 60
	growthstages = 2
	rarity = 60 // Obtainable only with xenobio+superluck.
	reagents_add = list("sulfur" = 0.1, "carbon" = 0.1, "nitrogen" = 0.07, "potassium" = 0.05)

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/gatfruit
	seed = /obj/item/seeds/gatfruit
	name = "gatfruit"
	desc = "It smells like burning."
	icon_state = "gatfruit"
	origin_tech = "combat=3"
	trash = /obj/item/weapon/gun/projectile/revolver
	bitesize_mod = 2