/obj/item/weapon/reagent_containers/food/snacks/soup
	w_class = 3
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/soup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")

/obj/item/weapon/reagent_containers/food/snacks/soup/wish
	name = "wish soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	list_reagents = list("nutriment" = 2, "water" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/wish/New()
	..()
	if(prob(25))
		desc = "A wish come true!"
		reagents.add_reagent("nutriment", 9)
		reagents.add_reagent("vitamin", 1)
	else
		reagents.add_reagent("water", 10)

/obj/item/weapon/reagent_containers/food/snacks/soup/meatball
	name = "meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/slime
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	list_reagents = list("nutriment" = 2, "slimejelly" = 5, "water" = 10, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/blood
	name = "tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	list_reagents = list("nutriment" = 2, "blood" = 10, "water" = 5, "vitamin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/soup/clownstears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	list_reagents = list("nutriment" = 4, "banana" = 5, "water" = 10, "vitamin" = 8)

/obj/item/weapon/reagent_containers/food/snacks/soup/vegetable
	name = "vegetable soup"
	desc = "A true vegan meal."
	icon_state = "vegetablesoup"
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/soup/nettle
	name = "nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	list_reagents = list("nutriment" = 8, "omnizine" = 5, "water" = 6, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/mystery
	name = "mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	list_reagents = list("nutriment" = 6, "tomatojuice" = 2)
	var/extra_reagent = null
/obj/item/weapon/reagent_containers/food/snacks/soup/mystery/New()
	..()

	extra_reagent = pick("capsaicin", "frostoil", "omnizine", "banana", "blood", "slimejelly", "toxin", "banana", "carbon", "oculine")
	reagents.add_reagent("[extra_reagent]", 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/hotchili
	name = "hot chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	list_reagents = list("nutriment" = 8, "capsaicin" = 1, "tomatojuice" = 2, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/soup/coldchili
	name = "cold chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	list_reagents = list("nutriment" = 5, "frostoil" = 1, "tomatojuice" = 2, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/soup/monkeysdelight
	name = "monkey's delight"
	desc = "A delicious soup with dumplings and hunks of monkey meat simmered to perfection, in a broth that tastes faintly of bananas."
	icon_state = "monkeysdelight"
	list_reagents = list("nutriment" = 10, "banana" = 5, "blackpepper" = 1, "sodiumchloride" = 1, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/tomato
	name = "tomato soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	list_reagents = list("nutriment" = 8, "tomatojuice" = 10, "vitamin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/soup/milo
	name = "milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 3)

/obj/item/weapon/reagent_containers/food/snacks/soup/mushroom
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	list_reagents = list("nutriment" = 8, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/beet
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	list_reagents = list("nutriment" = 8, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/beet/New()
	..()
	name = pick("borsch","bortsch","borstch","borsh","borshch","borscht")


/obj/item/weapon/reagent_containers/food/snacks/soup/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "mushroomhallucinogen" = 6)

/obj/item/weapon/reagent_containers/food/snacks/soup/amanitajelly
	name = "amanita jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	bitesize = 3
	list_reagents = list("nutriment" = 6, "amatoxin" = 6, "mushroomhallucinogen" = 6)

/obj/item/weapon/reagent_containers/food/snacks/soup/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	list_reagents = list("nutriment" = 10, "tomatojuice" = 5, "oculine" = 5, "water" = 5)
	bitesize = 7
