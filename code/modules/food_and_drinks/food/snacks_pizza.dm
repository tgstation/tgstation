
/////////////////////////////////////////////////PIZZA////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/pizza
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	slices_num = 6
	volume = 80
	list_reagents = list("nutriment" = 30, "tomatojuice" = 6, "vitamin" = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	list_reagents = list("nutriment" = 5)

/obj/item/weapon/reagent_containers/food/snacks/pizza/margherita
	name = "margherita"
	desc = "The most cheezy pizza in galaxy."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/margherita
	bonus_reagents = list("nutriment" = 5, "vitamin" = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/margherita
	name = "margherita slice"
	desc = "A slice of the most cheezy pizza in galaxy."
	icon_state = "pizzamargheritaslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizza/meat
	name = "meatpizza"
	desc = "Greasy pizza with delicious meat."
	icon_state = "meatpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/meat
	bonus_reagents = list("nutriment" = 5, "vitamin" = 8)
	list_reagents = list("nutriment" = 30, "tomatojuice" = 6, "vitamin" = 8)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/meat
	name = "meatpizza slice"
	desc = "A nutritious slice of meatpizza."
	icon_state = "meatpizzaslice"
	filling_color = "#A52A2A"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizza/mushroom
	name = "mushroom pizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/mushroom
	bonus_reagents = list("nutriment" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 30, "vitamin" = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/mushroom
	name = "mushroom pizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon_state = "mushroompizzaslice"
	filling_color = "#FFE4C4"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "mushroom" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizza/vegetable
	name = "vegetable pizza"
	desc = "No one of Tomatos Sapiens were harmed during making this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/vegetable
	bonus_reagents = list("nutriment" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 25, "tomatojuice" = 6, "oculine" = 12, "vitamin" = 5)
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/vegetable
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon_state = "vegetablepizzaslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "tomato" = 2, "cheese" = 1, "carrot" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizza/donkpocket
	name = "donkpocket pizza"
	desc = "Who thought this would be a good idea?"
	icon_state = "donkpocketpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/donkpocket
	bonus_reagents = list("nutriment" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 25, "tomatojuice" = 6, "omnizine" = 10, "vitamin" = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/donkpocket
	name = "donkpocket pizza slice"
	desc = "Smells like donkpocket."
	icon_state = "donkpocketpizzaslice"
	filling_color = "#FFA500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1, "laziness" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizza/dank
	name = "dank pizza"
	desc = "The hippie's pizza of choice."
	icon_state = "dankpizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/dank
	bonus_reagents = list("nutriment" = 2, "vitamin" = 6)
	list_reagents = list("nutriment" = 25, "doctorsdelight" = 5, "tomatojuice" = 6, "vitamin" = 5)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/dank
	name = "dank pizza slice"
	desc = "So good, man..."
	icon_state = "dankpizzaslice"
	filling_color = "#2E8B57"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizza/sassysage
	name = "sassysage pizza"
	desc = "You can really smell the sassiness."
	icon_state = "sassysagepizza"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/pizzaslice/sassysage
	bonus_reagents = list("nutriment" = 6, "vitamin" = 6)
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/sassysage
	name = "sassysage pizza slice"
	desc = "Deliciously sassy."
	icon_state = "sassysagepizzaslice"
	filling_color = "#FF4500"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1, "meat" = 1)

/obj/item/weapon/reagent_containers/food/snacks/pizzaslice/custom
	name = "pizza slice"
	icon_state = "pizzamargheritaslice"
	filling_color = "#FFFFFF"
