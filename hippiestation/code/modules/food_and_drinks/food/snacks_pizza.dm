/obj/item/reagent_containers/food/snacks/pizza/cornpotato
	name = "cornpotato-pizza"
	desc = "A sanity destroying other thing."
	icon = 'hippiestation/icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "pizzacornpotato"
	slice_path = /obj/item/reagent_containers/food/snacks/pizzaslice/cornpotato
	bonus_reagents = list("nutriment" = 8, "vitamin" = 8, "toxin" = 3)
	tastes = list("crust" = 1, "disgusting" = 4, "cheese" = 1, "corn" = 1, "potato" = 1)
	foodtype = GRAIN | VEGETABLES | GROSS

/obj/item/reagent_containers/food/snacks/pizzaslice/cornpotato
	name = "cornpotato-pizza slice"
	desc = "A slice of a sanity destroying other thing."
	icon = 'hippiestation/icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "pizzacornpotatoslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "disgusting" = 4, "cheese" = 1, "corn" = 1, "potato" = 1)
	foodtype = GRAIN | VEGETABLES | GROSS
