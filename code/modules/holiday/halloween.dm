//spooky halloween stuff. only tick on halloween!!!
//uses super seekrit double proc definition stuffs. remember to call ..()!
/mob/dead/observer/say(var/message)
	..()
	for(var/mob/M in hearers(src, 1))
		if(!M.stat)
			if(M.job == "Chaplain")
				if (prob (49))
					M.show_message("<span class='game'><i>You hear muffled speech... but nothing is there...</i></span>", 2)
					if(prob(20))
						playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
				else
					M.show_message("<span class='game'><i>You hear muffled speech... you can almost make out some words...</i></span>", 2)
//				M.show_message("<span class='game'><i>[stutter(message)]</i></span>", 2)
					if(prob(30))
						playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
			else
				if(prob(50))
					return
				else if(prob (95))
					M.show_message("<span class='game'><i>You hear muffled speech... but nothing is there...</i></span>", 2)
					if(prob(20))
						playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)
				else
					M.show_message("<span class='game'><i>You hear muffled speech... you can almost make out some words...</i></span>", 2)
//				M.show_message("<span class='game'><i>[stutter(message)]</i></span>", 2)
					playsound(src.loc, pick('sound/effects/ghost.ogg','sound/effects/ghost2.ogg'), 10, 1)


///HALLOWEEN CONTENT

//spooky foods
/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookyskull
	name = "skull cookie"
	desc = "Spooky! It's got delicious calcium flavouring!"
	icon = 'icons/obj/halloween_items.dmi'
	icon_state = "skeletoncookie"

/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookycoffin
	name = "coffin cookie"
	desc = "Spooky! It's got delicious coffee flavouring!"
	icon = 'icons/obj/halloween_items.dmi'
	icon_state = "coffincookie"

//spooky recipes

/datum/recipe/sugarcookie/spookyskull
	reagents = list("flour" = 5, "sugar" = 5, "milk" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookyskull

/datum/recipe/sugarcookie/spookycoffin
	reagents = list("flour" = 5, "sugar" = 5, "coffee" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookycoffin

//spooky items

/obj/item/weapon/storage/spooky
	name = "trick-o-treat bag"
	desc = "A Pumpkin shaped bag that holds all sorts of goodies!"
	icon = 'icons/obj/halloween_items.dmi'
	icon_state = "treatbag"

/obj/item/weapon/storage/spooky/New()
	..()
	for(var/distrobuteinbag=0 to 6)
		var/type = pick(/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookyskull,
		/obj/item/weapon/reagent_containers/food/snacks/sugarcookie/spookycoffin,
		/obj/item/weapon/reagent_containers/food/snacks/candy_corn,
		/obj/item/weapon/reagent_containers/food/snacks/candy,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar)
		new type(src)
