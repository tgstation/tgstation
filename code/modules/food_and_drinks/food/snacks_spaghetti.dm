
/obj/item/weapon/reagent_containers/food/snacks/spaghetti
	name = "spaghetti"
	desc = "Now that's a nic'e pasta!"
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "spaghetti"
	list_reagents = list("nutriment" = 1, "vitamin" = 1)
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
	filling_color = "#F0E68C"
	tastes = list("pasta" = 1)
	foodtype = GRAIN

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this needs more ingredients."
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "spaghettiboiled"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 2)
	list_reagents = list("nutriment" = 2, "vitamin" = 1)
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/pasta
	filling_color = "#F0E68C"
	tastes = list("pasta" = 1)
	foodtype = GRAIN

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	bitesize = 4
	bonus_reagents = list("nutriment" = 1, "tomatojuice" = 10, "vitamin" = 4)
	list_reagents = list("nutriment" = 6, "tomatojuice" = 10, "vitamin" = 4)
	filling_color = "#DC143C"
	tastes = list("pasta" = 1, "tomato" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/weapon/reagent_containers/food/snacks/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "copypasta"
	trash = /obj/item/trash/plate
	bitesize = 4
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	list_reagents = list("nutriment" = 12, "tomatojuice" = 20, "vitamin" = 8)
	filling_color = "#DC143C"
	tastes = list("pasta" = 1, "tomato" = 1)
	foodtype = GRAIN | VEGETABLES

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti
	name = "spaghetti and meatballs"
	desc = "Now that's a nic'e meatball!"
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "meatballspaghetti"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	list_reagents = list("nutriment" = 8, "vitamin" = 4)
	filling_color = "#F0E68C"
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 1)
	foodtype = GRAIN | MEAT

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "spesslaw"
	desc = "A lawyers favourite."
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "spesslaw"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 1, "vitamin" = 6)
	list_reagents = list("nutriment" = 8, "vitamin" = 6)
	filling_color = "#F0E68C"
	tastes = list("pasta" = 1, "tomato" = 1, "meat" = 1)
	foodtype = GRAIN

/obj/item/weapon/reagent_containers/food/snacks/chowmein
	name = "chow mein"
	desc = "A nice mix of noodles and fried vegetables."
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "chowmein"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 3, "vitamin" = 4)
	list_reagents = list("nutriment" = 7, "vitamin" = 6)
	tastes = list("noodle" = 1, "tomato" = 1)
	foodtype = GRAIN

/obj/item/weapon/reagent_containers/food/snacks/beefnoodle
	name = "beef noodle"
	desc = "Nutritious, beefy and noodly."
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "beefnoodle"
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	bonus_reagents = list("nutriment" = 5, "vitamin" = 6, "liquidgibs" = 3)
	tastes = list("noodle" = 1, "meat" = 1)
	foodtype = GRAIN | MEAT

/obj/item/weapon/reagent_containers/food/snacks/butternoodles
	name = "butter noodles"
	desc = "Noodles covered in savory butter. Simple and slippery, but delicious."
	icon = 'icons/obj/food/pizzaspaghetti.dmi'
	icon_state = "butternoodles"
	trash = /obj/item/trash/plate
	bonus_reagents = list("nutriment" = 8, "vitamin" = 1)
	tastes = list("noodle" = 1, "butter" = 1)
	foodtype = GRAIN | DAIRY
