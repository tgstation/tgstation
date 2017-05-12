/obj/item/weapon/reagent_containers/food/snacks/soup
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/food/soupsalad.dmi'
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	bitesize = 5
	volume = 80
	list_reagents = list("nutriment" = 8, "water" = 5, "vitamin" = 4)
	tastes = list("tasteless soup" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")

/obj/item/weapon/reagent_containers/food/snacks/soup/wish
	name = "wish soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	list_reagents = list("water" = 10)
	tastes = list("wishes" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/wish/New()
	var/wish_true = prob(25)
	if(wish_true)
		desc = "A wish come true!"
		bonus_reagents = list("nutriment" = 9, "vitamin" = 1)
	..()
	if(wish_true)
		reagents.add_reagent("nutriment", 9)
		reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/meatball
	name = "meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)
	tastes = list("meat" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/slime
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"
	bonus_reagents = list("nutriment" = 1, "slimejelly" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 5, "slimejelly" = 5, "water" = 5, "vitamin" = 4)
	tastes = list("slime" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/blood
	name = "tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 6)
	list_reagents = list("nutriment" = 2, "blood" = 10, "water" = 5, "vitamin" = 4)
	tastes = list("iron" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/wingfangchu
	name = "wing fang chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	bonus_reagents = list("nutriment" = 1, "vitamin" = 2)
	list_reagents = list("nutriment" = 6, "soysauce" = 5, "vitamin" = 2)
	tastes = list("soy" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/clownstears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"
	bonus_reagents = list("nutriment" = 1, "banana" = 5, "vitamin" = 8)
	list_reagents = list("nutriment" = 4, "banana" = 5, "water" = 5, "vitamin" = 8)
	tastes = list("a bad joke" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/vegetable
	name = "vegetable soup"
	desc = "A true vegan meal."
	icon_state = "vegetablesoup"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 4)
	tastes = list("vegetables" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/nettle
	name = "nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	bonus_reagents = list("nutriment" = 1, "omnizine" = 5, "vitamin" = 5)
	tastes = list("nettles" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/mystery
	name = "mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	var/extra_reagent = null
	list_reagents = list("nutriment" = 6)
	tastes = list("chaos" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/mystery/New()
	extra_reagent = pick("capsaicin", "frostoil", "omnizine", "banana", "blood", "slimejelly", "toxin", "banana", "carbon", "oculine")
	bonus_reagents = list("[extra_reagent]" = 5, "nutriment" = 6)
	..()
	reagents.add_reagent("[extra_reagent]", 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/hotchili
	name = "hot chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	bonus_reagents = list("nutriment" = 1, "tomatojuice" = 2, "vitamin" = 2)
	list_reagents = list("nutriment" = 5, "capsaicin" = 1, "tomatojuice" = 2, "vitamin" = 2)
	tastes = list("hot peppers" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/coldchili
	name = "cold chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	bonus_reagents = list("nutriment" = 1, "tomatojuice" = 2, "vitamin" = 2)
	list_reagents = list("nutriment" = 5, "frostoil" = 1, "tomatojuice" = 2, "vitamin" = 2)
	tastes = list("tomato" = 1, "mint" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/monkeysdelight
	name = "monkey's delight"
	desc = "A delicious soup with dumplings and hunks of monkey meat simmered to perfection, in a broth that tastes faintly of bananas."
	icon_state = "monkeysdelight"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)
	list_reagents = list("nutriment" = 10, "banana" = 5, "vitamin" = 5)
	tastes = list("the jungle" = 1, "banana" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/tomato
	name = "tomato soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	bonus_reagents = list("nutriment" = 1, "tomatojuice" = 10, "vitamin" = 3)
	list_reagents = list("nutriment" = 5, "tomatojuice" = 10, "vitamin" = 3)
	tastes = list("tomato" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/tomato/eyeball
	name = "eyeball soup"
	desc = "It looks back at you..."
	icon_state = "eyeballsoup"
	bonus_reagents = list("nutriment" = 1, "liquidgibs" = 3)
	tastes = list("tomato" = 1, "squirming" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/milo
	name = "milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 3)
	tastes = list("milo" = 1) // wtf is milo

/obj/item/weapon/reagent_containers/food/snacks/soup/mushroom
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)
	list_reagents = list("nutriment" = 8, "vitamin" = 4)
	tastes = list("mushroom" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/beet
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/soup/beet/New()
	..()
	name = pick("borsch","bortsch","borstch","borsh","borshch","borscht")
	tastes = list(name = 1)


/obj/item/weapon/reagent_containers/food/snacks/soup/spacylibertyduff
	name = "spacy liberty duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	bitesize = 3
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)
	list_reagents = list("nutriment" = 6, "mushroomhallucinogen" = 6)
	tastes = list("jelly" = 1, "mushroom" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/amanitajelly
	name = "amanita jelly"
	desc = "Looks curiously toxic."
	icon_state = "amanitajelly"
	bitesize = 3
	bonus_reagents = list("nutriment" = 1, "vitamin" = 5)
	list_reagents = list("nutriment" = 6, "mushroomhallucinogen" = 3, "amatoxin" = 6)
	tastes = list("jelly" = 1, "mushroom" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	bonus_reagents = list("nutriment" = 1, "tomatojuice" = 5, "vitamin" = 5)
	list_reagents = list("nutriment" = 10, "oculine" = 5, "tomatojuice" = 5, "vitamin" = 5)
	bitesize = 7
	volume = 100
	tastes = list("tomato" = 1, "carrot" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/sweetpotato
	name = "sweet potato soup"
	desc = "Delicious sweet potato in soup form."
	icon_state = "sweetpotatosoup"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 5)
	tastes = list("sweet potato" = 1)

/obj/item/weapon/reagent_containers/food/snacks/soup/beet/red
	name = "red beet soup"
	desc = "Quite a delicacy."
	icon_state = "redbeetsoup"
	bonus_reagents = list("nutriment" = 4, "vitamin" = 6)
	tastes = list("beet" = 1)
