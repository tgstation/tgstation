
/obj/item/weapon/reagent_containers/food/snacks/meatballsoup
	name = "meatball soup"
	desc = "You've got balls kid, BALLS!"
	icon_state = "meatballsoup"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/meatballsoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("water", 5)
	reagents.add_reagent("vitamin", 4)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/slimesoup
	name = "slime soup"
	desc = "If no water is available, you may substitute tears."
	icon_state = "slimesoup"

/obj/item/weapon/reagent_containers/food/snacks/slimesoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("slimejelly", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("vitamin", 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/bloodsoup
	name = "tomato soup"
	desc = "Smells like copper."
	icon_state = "tomatosoup"

/obj/item/weapon/reagent_containers/food/snacks/bloodsoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("blood", 10)
	reagents.add_reagent("water", 5)
	reagents.add_reagent("vitamin", 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/clownstears
	name = "clown's tears"
	desc = "Not very funny."
	icon_state = "clownstears"

/obj/item/weapon/reagent_containers/food/snacks/clownstears/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 4)
	reagents.add_reagent("banana", 5)
	reagents.add_reagent("water", 10)
	reagents.add_reagent("vitamin", 8)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup
	name = "vegetable soup"
	desc = "A true vegan meal."
	icon_state = "vegetablesoup"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/vegetablesoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("water", 5)
	reagents.add_reagent("vitamin", 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/nettlesoup
	name = "nettle soup"
	desc = "To think, the botanist would've beat you to death with one of these."
	icon_state = "nettlesoup"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/nettlesoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("water", 5)
	reagents.add_reagent("tricordrazine", 5)
	reagents.add_reagent("vitamin", 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/mysterysoup
	name = "mystery soup"
	desc = "The mystery is, why aren't you eating it?"
	icon_state = "mysterysoup"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/mysterysoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	switch(rand(1,10))
		if(1)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("capsaicin", 3)
			reagents.add_reagent("tomatojuice", 2)
		if(2)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("frostoil", 3)
			reagents.add_reagent("tomatojuice", 2)
		if(3)
			reagents.add_reagent("nutriment", 5)
			reagents.add_reagent("water", 5)
			reagents.add_reagent("tricordrazine", 5)
		if(4)
			reagents.add_reagent("nutriment", 5)
			reagents.add_reagent("water", 10)
		if(5)
			reagents.add_reagent("nutriment", 2)
			reagents.add_reagent("banana", 10)
		if(6)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("blood", 10)
		if(7)
			reagents.add_reagent("slimejelly", 10)
			reagents.add_reagent("water", 10)
		if(8)
			reagents.add_reagent("carbon", 10)
			reagents.add_reagent("toxin", 10)
		if(9)
			reagents.add_reagent("nutriment", 5)
			reagents.add_reagent("tomatojuice", 10)
		if(10)
			reagents.add_reagent("nutriment", 6)
			reagents.add_reagent("tomatojuice", 5)
			reagents.add_reagent("imidazoline", 5)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/wishsoup
	name = "wish soup"
	desc = "I wish this was soup."
	icon_state = "wishsoup"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/wishsoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("water", 10)
	bitesize = 5
	if(prob(25))
		desc = "A wish come true!"
		reagents.add_reagent("nutriment", 8)
		reagents.add_reagent("vitamin", 1)

/obj/item/weapon/reagent_containers/food/snacks/hotchili
	name = "hot chili"
	desc = "A five alarm Texan Chili!"
	icon_state = "hotchili"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/hotchili/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 5)
	reagents.add_reagent("capsaicin", 1)
	reagents.add_reagent("tomatojuice", 2)
	reagents.add_reagent("vitamin", 2)
	bitesize = 5


/obj/item/weapon/reagent_containers/food/snacks/coldchili
	name = "cold chili"
	desc = "This slush is barely a liquid!"
	icon_state = "coldchili"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/coldchili/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 5)
	reagents.add_reagent("frostoil", 1)
	reagents.add_reagent("tomatojuice", 2)
	reagents.add_reagent("vitamin", 2)
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight
	name = "monkey's delight"
	desc = "A delicious soup with dumplings and hunks of monkey meat simmered to perfection, in a broth that tastes faintly of bananas."
	icon_state = "monkeysdelight"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/monkeysdelight/New()
	..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("banana", 5)
	reagents.add_reagent("blackpepper", 1)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("vitamin", 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/tomatosoup
	name = "tomato soup"
	desc = "Drinking this feels like being a vampire! A tomato vampire..."
	icon_state = "tomatosoup"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/tomatosoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 5)
	reagents.add_reagent("tomatojuice", 10)
	reagents.add_reagent("vitamin", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/milosoup
	name = "milosoup"
	desc = "The universes best soup! Yum!!!"
	icon_state = "milosoup"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/milosoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("water", 5)
	reagents.add_reagent("vitamin", 3)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/mushroomsoup
	name = "chantrelle soup"
	desc = "A delicious and hearty mushroom soup."
	icon_state = "mushroomsoup"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/mushroomsoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("vitamin", 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/beetsoup
	name = "beet soup"
	desc = "Wait, how do you spell it again..?"
	icon_state = "beetsoup"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/beetsoup/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	name = pick("borsch","bortsch","borstch","borsh","borshch","borscht")
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("vitamin", 4)
	bitesize = 2
