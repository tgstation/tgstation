/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/ //abstract type
	seed = /obj/item/seeds/limeseed
	name = "citrus"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.05)
	bitesize_mod = 2


// Lime
/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime
	seed = /obj/item/seeds/limeseed
	name = "lime"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	filling_color = "#00FF00"


// Lemon
/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon
	seed = /obj/item/seeds/lemonseed
	name = "lemon"
	desc = "When life gives you lemons, be grateful they aren't limes."
	icon_state = "lemon"
	filling_color = "#FFD700"


// Orange
/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange
	seed = /obj/item/seeds/orangeseed
	name = "orange"
	desc = "It's an tangy fruit."
	icon_state = "orange"
	filling_color = "#FFA500"


// Money Lemon
/obj/item/weapon/reagent_containers/food/snacks/grown/shell/moneyfruit
	seed = /obj/item/seeds/cashseed
	name = "Money Fruit"
	desc = "Looks like a lemon with someone buldging from the inside."
	icon_state = "moneyfruit"
	inside_type = null
	reagents_add = list("nutriment" = 0.05)
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/moneyfruit/add_juice()
	..()
	switch(potency)
		if(0 to 10)
			inside_type = /obj/item/stack/spacecash
		if(11 to 20)
			inside_type = /obj/item/stack/spacecash/c10
		if(21 to 30)
			inside_type = /obj/item/stack/spacecash/c20
		if(31 to 40)
			inside_type = /obj/item/stack/spacecash/c50
		if(41 to 50)
			inside_type = /obj/item/stack/spacecash/c100
		if(51 to 60)
			inside_type = /obj/item/stack/spacecash/c200
		if(61 to 80)
			inside_type = /obj/item/stack/spacecash/c500
		else
			inside_type = /obj/item/stack/spacecash/c1000