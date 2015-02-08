
/obj/item/weapon/reagent_containers/food/snacks/spaghetti
	name = "spaghetti"
	desc = "Now that's a nic'e pasta!"
	icon_state = "spaghetti"
	list_reagents = list("nutriment" = 1, "vitamin" = 1)
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti
	name = "boiled spaghetti"
	desc = "A plain dish of noodles, this needs more ingredients."
	icon_state = "spaghettiboiled"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 2)
	custom_food_type = /obj/item/weapon/reagent_containers/food/snacks/customizable/pasta
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/pastatomato
	name = "spaghetti"
	desc = "Spaghetti and crushed tomatoes. Just like your abusive father used to make!"
	icon_state = "pastatomato"
	trash = /obj/item/trash/plate
	bitesize = 4
	list_reagents = list("nutriment" = 1, "vitamin" = 4)
	filling_color = "#DC143C"

/obj/item/weapon/reagent_containers/food/snacks/copypasta
	name = "copypasta"
	desc = "You probably shouldn't try this, you always hear people talking about how bad it is..."
	icon_state = "copypasta"
	trash = /obj/item/trash/plate
	bitesize = 4
	list_reagents = list("nutriment" = 1, "vitamin" = 4)
	filling_color = "#DC143C"

/obj/item/weapon/reagent_containers/food/snacks/meatballspaghetti
	name = "spaghetti and meatballs"
	desc = "Now that's a nic'e meatball!"
	icon_state = "meatballspaghetti"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 1, "vitamin" = 4)
	filling_color = "#F0E68C"

/obj/item/weapon/reagent_containers/food/snacks/spesslaw
	name = "spesslaw"
	desc = "A lawyers favourite."
	icon_state = "spesslaw"
	trash = /obj/item/trash/plate
	list_reagents = list("nutriment" = 1, "vitamin" = 6)
	filling_color = "#F0E68C"
