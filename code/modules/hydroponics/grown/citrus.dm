// Citrus - base type
/obj/item/weapon/reagent_containers/food/snacks/grown/citrus
	seed = /obj/item/seeds/lime
	name = "citrus"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	bitesize_mod = 2

// Lime
/obj/item/seeds/lime
	name = "pack of lime seeds"
	desc = "These are very sour seeds."
	icon_state = "seed-lime"
	species = "lime"
	plantname = "Lime Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime
	lifespan = 55
	endurance = 50
	yield = 4
	potency = 15
	mutatelist = list(/obj/item/seeds/orange)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.05)

/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lime
	seed = /obj/item/seeds/lime
	name = "lime"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	filling_color = "#00FF00"

// Orange
/obj/item/seeds/orange
	name = "pack of orange seeds"
	desc = "Sour seeds."
	icon_state = "seed-orange"
	species = "orange"
	plantname = "Orange Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange
	lifespan = 60
	endurance = 50
	yield = 5
	potency = 20
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	mutatelist = list(/obj/item/seeds/lime)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.05)

/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/orange
	seed = /obj/item/seeds/orange
	name = "orange"
	desc = "It's an tangy fruit."
	icon_state = "orange"
	filling_color = "#FFA500"

// Lemon
/obj/item/seeds/lemon
	name = "pack of lemon seeds"
	desc = "These are sour seeds."
	icon_state = "seed-lemon"
	species = "lemon"
	plantname = "Lemon Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon
	lifespan = 55
	endurance = 45
	yield = 4
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	mutatelist = list(/obj/item/seeds/cash)
	reagents_add = list("vitamin" = 0.04, "nutriment" = 0.05)

/obj/item/weapon/reagent_containers/food/snacks/grown/citrus/lemon
	seed = /obj/item/seeds/lemon
	name = "lemon"
	desc = "When life gives you lemons, be grateful they aren't limes."
	icon_state = "lemon"
	filling_color = "#FFD700"

// Money Lemon
/obj/item/seeds/cash
	name = "pack of money seeds"
	desc = "When life gives you lemons, mutate them into cash."
	icon_state = "seed-cash"
	species = "cashtree"
	plantname = "Money Tree"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/shell/moneyfruit
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	lifespan = 55
	endurance = 45
	yield = 4
	reagents_add = list("nutriment" = 0.05)
	rarity = 50  // Nanotrasen approves...

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/moneyfruit
	seed = /obj/item/seeds/cash
	name = "Money Fruit"
	desc = "Looks like a lemon with someone buldging from the inside."
	icon_state = "moneyfruit"
	bitesize_mod = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/shell/moneyfruit/add_juice()
	..()
	switch(seed.potency)
		if(0 to 10)
			trash = /obj/item/stack/spacecash
		if(11 to 20)
			trash = /obj/item/stack/spacecash/c10
		if(21 to 30)
			trash = /obj/item/stack/spacecash/c20
		if(31 to 40)
			trash = /obj/item/stack/spacecash/c50
		if(41 to 50)
			trash = /obj/item/stack/spacecash/c100
		if(51 to 60)
			trash = /obj/item/stack/spacecash/c200
		if(61 to 80)
			trash = /obj/item/stack/spacecash/c500
		else
			trash = /obj/item/stack/spacecash/c1000