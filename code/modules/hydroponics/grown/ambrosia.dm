// Ambrosia - base type
/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia
	seed = /obj/item/seeds/ambrosia
	name = "ambrosia branch"
	desc = "This is a plant."
	icon_state = "ambrosiavulgaris"
	slot_flags = SLOT_HEAD
	filling_color = "#008000"
	bitesize_mod = 2

// Ambrosia Vulgaris
/obj/item/seeds/ambrosia
	name = "pack of ambrosia vulgaris seeds"
	desc = "These seeds grow into common ambrosia, a plant grown by and from medicine."
	icon_state = "seed-ambrosiavulgaris"
	species = "ambrosiavulgaris"
	plantname = "Ambrosia Vulgaris"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	lifespan = 60
	endurance = 25
	yield = 6
	potency = 5
	icon_dead = "ambrosia-dead"
	mutatelist = list(/obj/item/seeds/ambrosia/deus)
	reagents_add = list("space_drugs" = 0.15, "bicaridine" = 0.1, "kelotane" = 0.1, "vitamin" = 0.04, "nutriment" = 0.05, "toxin" = 0.1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	seed = /obj/item/seeds/ambrosia
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	origin_tech = "biotech=2"

// Ambrosia Deus
/obj/item/seeds/ambrosia/deus
	name = "pack of ambrosia deus seeds"
	desc = "These seeds grow into ambrosia deus. Could it be the food of the gods..?"
	icon_state = "seed-ambrosiadeus"
	species = "ambrosiadeus"
	plantname = "Ambrosia Deus"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus
	mutatelist = list(/obj/item/seeds/ambrosia/gaia)
	reagents_add = list("omnizine" = 0.15, "synaptizine" = 0.15, "space_drugs" = 0.1, "vitamin" = 0.04, "nutriment" = 0.05)
	rarity = 40

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus
	seed = /obj/item/seeds/ambrosia/deus
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	icon_state = "ambrosiadeus"
	filling_color = "#008B8B"
	origin_tech = "biotech=4;materials=3"

//Ambrosia Gaia
/obj/item/seeds/ambrosia/gaia
	name = "pack of ambrosia gaia seeds"
	desc = "These seeds grow into ambrosia gaia, incredibly rare but imbued with breathtaking potential."
	icon_state = "seed-ambrosia_gaia"
	species = "ambrosia_gaia"
	plantname = "Ambrosia Gaia"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/gaia
	mutatelist = list()
	reagents_add = list("earthsblood" = 0.4, "nutriment" = 0.2, "vitamin" = 0.1)
	rarity = 100 //These are some pretty good plants right here
	oneharvest = TRUE

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/gaia
	name = "ambrosia gaia"
	desc = "The bringer of light."
	icon_state = "ambrosia_gaia"
	filling_color = rgb(255, 175, 0)
	origin_tech = "biotech=7"
	luminosity = 3
	seed = /obj/item/seeds/ambrosia/gaia
