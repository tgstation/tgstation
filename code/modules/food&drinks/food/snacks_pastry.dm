//Pastry is a food that is made from dough which is made from wheat or rye flour.
//This file contains pastries that don't fit any existing categories.

////////////////////////////////////////////DONUTS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/donut
	name = "donut"
	icon_state = "donut1"

/obj/item/weapon/reagent_containers/food/snacks/donut/normal
	desc = "Goes great with Robust Coffee."

/obj/item/weapon/reagent_containers/food/snacks/donut/normal/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sprinkles", 1)
	reagents.add_reagent("sugar", 2)
	src.bitesize = 3
	if(prob(30))
		src.icon_state = "donut2"
		src.name = "frosted donut"
		reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos
	name = "chaos donut"
	desc = "Like life, it never quite tastes the same."

/obj/item/weapon/reagent_containers/food/snacks/donut/chaos/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("sprinkles", 1)
	reagents.add_reagent("sugar", 1)
	bitesize = 10
	switch(rand(1,10))
		if(1)
			reagents.add_reagent("nutriment", 3)
		if(2)
			reagents.add_reagent("capsaicin", 3)
		if(3)
			reagents.add_reagent("frostoil", 3)
		if(4)
			reagents.add_reagent("sprinkles", 3)
		if(5)
			reagents.add_reagent("plasma", 3)
		if(6)
			reagents.add_reagent("coco", 3)
		if(7)
			reagents.add_reagent("slimejelly", 3)
		if(8)
			reagents.add_reagent("banana", 3)
		if(9)
			reagents.add_reagent("berryjuice", 3)
		if(10)
			reagents.add_reagent("tricordrazine", 3)
	if(prob(30))
		icon_state = "donut2"
		name = "frosted chaos donut"
		reagents.add_reagent("sprinkles", 2)


/obj/item/weapon/reagent_containers/food/snacks/donut/jelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/donut/jelly/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sprinkles", 1)
	reagents.add_reagent("berryjuice", 5)
	reagents.add_reagent("vitamin", 1)
	if(prob(30))
		icon_state = "jdonut2"
		name = "Frosted Jelly Donut"
		reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sprinkles", 1)
	reagents.add_reagent("slimejelly", 5)
	reagents.add_reagent("vitamin", 1)
	bitesize = 5
	if(prob(30))
		icon_state = "jdonut2"
		name = "Frosted Jelly Donut"
		reagents.add_reagent("sprinkles", 2)

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly
	name = "jelly donut"
	desc = "You jelly?"
	icon_state = "jdonut1"
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sprinkles", 1)
	reagents.add_reagent("cherryjelly", 5)
	reagents.add_reagent("vitamin", 1)
	if(prob(30))
		icon_state = "jdonut2"
		name = "Frosted Jelly Donut"
		reagents.add_reagent("sprinkles", 2)


////////////////////////////////////////////MUFFINS////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/muffin
	name = "muffin"
	desc = "A delicious and spongy little cake."
	icon_state = "muffin"

/obj/item/weapon/reagent_containers/food/snacks/muffin/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/muffin/berry
	name = "berry muffin"
	icon_state = "berrymuffin"
	desc = "A delicious and spongy little cake, with berries."

/obj/item/weapon/reagent_containers/food/snacks/muffin/booberry
	name = "booberry muffin"
	icon_state = "berrymuffin"
	alpha = 125
	desc = "My stomach is a graveyard! No living being can quench my bloodthirst!"

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi
	name = "chawanmushi"
	desc = "A legendary egg custard that makes friends out of enemies. Probably too hot for a cat to eat."
	icon_state = "chawanmushi"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/chawanmushi/New()
	..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 1
////////////////////////////////////////////WAFFLES////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/waffles
	name = "waffles"
	desc = "Mmm, waffles."
	icon_state = "waffles"
	trash = /obj/item/trash/waffles

/obj/item/weapon/reagent_containers/food/snacks/waffles/New()
	..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen
	name = "\improper Soylent Green"
	desc = "Not made of people. Honest." //Totally people.
	icon_state = "soylent_green"
	trash = /obj/item/trash/waffles

/obj/item/weapon/reagent_containers/food/snacks/soylentgreen/New()
	..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians
	name = "\improper Soylent Virdians"
	desc = "Not made of people. Honest." //Actually honest for once.
	icon_state = "soylent_yellow"
	trash = /obj/item/trash/waffles

/obj/item/weapon/reagent_containers/food/snacks/soylenviridians/New()
	..()
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles
	name = "roffle waffles"
	desc = "Waffles from Roffle. Co."
	icon_state = "rofflewaffles"
	trash = /obj/item/trash/waffles

/obj/item/weapon/reagent_containers/food/snacks/rofflewaffles/New()
	..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("mushroomhallucinogen", 8)
	reagents.add_reagent("vitamin", 2)
	bitesize = 4

////////////////////////////////////////////OTHER////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/cookie
	name = "cookie"
	desc = "COOKIE!!!"
	icon_state = "COOKIE!!!"

/obj/item/weapon/reagent_containers/food/snacks/cookie/New()
	..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 1

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "\improper Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/New()
	..()
	reagents.add_reagent("nutriment", 4)

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie
	name = "fortune cookie"
	desc = "A true prophecy in each cookie!"
	icon_state = "fortune_cookie"

/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel
	name = "poppy pretzel"
	desc = "It's all twisted up!"
	icon_state = "poppypretzel"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/poppypretzel/New()
	..()
	reagents.add_reagent("nutriment", 5)
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit
	name = "plump helmet biscuit"
	desc = "This is a finely-prepared plump helmet biscuit. The ingredients are exceptionally minced plump helmet, and well-minced dwarven wheat flour."
	icon_state = "phelmbiscuit"

/obj/item/weapon/reagent_containers/food/snacks/plumphelmetbiscuit/New()
	..()
	if(prob(10))
		name = "exceptional plump helmet biscuit"
		desc = "Microwave is taken by a fey mood! It has cooked an exceptional plump helmet biscuit!"
		reagents.add_reagent("nutriment", 3)
		reagents.add_reagent("tricordrazine", 5)
	reagents.add_reagent("nutriment", 5)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/appletart
	name = "golden apple streusel tart"
	desc = "A tasty dessert that won't make it through a metal detector."
	icon_state = "gappletart"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/appletart/New()
	..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("gold", 5)
	reagents.add_reagent("vitamin", 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/cracker
	name = "cracker"
	desc = "It's a salted cracker."
	icon_state = "cracker"

/obj/item/weapon/reagent_containers/food/snacks/cracker/New()
	..()
	reagents.add_reagent("nutriment", 1)

/obj/item/weapon/reagent_containers/food/snacks/hotdog
	name = "hotdog"
	desc = "Fresh footlong ready to go down on."
	icon_state = "hotdog"

/obj/item/weapon/reagent_containers/food/snacks/hotdog/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("ketchup", 3)
	reagents.add_reagent("vitamin", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/meatbun
	name = "meat bun"
	desc = "Has the potential to not be Dog."
	icon_state = "meatbun"

/obj/item/weapon/reagent_containers/food/snacks/meatbun/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 2)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie
	name = "sugar cookie"
	desc = "Just like your little sister used to make."
	icon_state = "sugarcookie"

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("sugar", 3)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/chococornet/
	name = "chocolate cornet"
	desc = "Which side's the head, the fat end or the thin end?"
	icon_state = "chococornet"

/obj/item/weapon/reagent_containers/food/snacks/chococornet/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("vitamin", 1)