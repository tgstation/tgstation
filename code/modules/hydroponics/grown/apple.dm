// Apple
/obj/item/weapon/reagent_containers/food/snacks/grown/apple
	seed = /obj/item/seeds/appleseed
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	filling_color = "#FF4500"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.1)
	bitesize = 100 // Always eat the apple in one bite


// Posioned Apple
/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned
	seed = /obj/item/seeds/poisonedappleseed
	reagents_add = list("cyanide" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)


// Gold Apple
/obj/item/weapon/reagent_containers/food/snacks/grown/apple/gold
	seed = /obj/item/seeds/goldappleseed
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	filling_color = "#FFD700"
	reagents_add = list("gold" = 0.2, "vitamin" = 0.04, "nutriment" = 0.1)