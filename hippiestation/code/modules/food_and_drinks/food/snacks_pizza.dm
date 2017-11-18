/obj/item/reagent_containers/food/snacks/pizza/cornpotato
	name = "cornpotato-pizza"
	desc = "The most disgusting pizza in galaxy."
	icon = 'hippiestaation/icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "pizzacornpotato"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/cornpotato
	bonus_reagents = list("nutriment" = 8, "vitamin" = 8)
	tastes = list("crust" = 1, "disgusting" = 4, "cheese" = 1, "corn" = 1, "potato" = 1)
	foodtype = GRAIN | VEGETABLES | GROSS

/obj/item/reagent_containers/food/snacks/pizzaslice/cornpotato
	name = "cornpotato-pizza slice"
	desc = "A slice of the most disgusting pizza in galaxy."
	icon = 'hippiestaation/icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "pizzacornpotatoslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "disgusting" = 4, "cheese" = 1, "corn" = 1, "potato" = 1)
	foodtype = GRAIN | VEGETABLES | GROSS