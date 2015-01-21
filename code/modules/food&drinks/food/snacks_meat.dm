//Not only meat, actually, but also snacks that are almost meat, such as fish meat or tofu


////////////////////////////////////////////FISH////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/cubancarp
	name = "\improper Cuban carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon_state = "cubancarp"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/cubancarp/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("capsaicin", 3)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	icon_state = "fishfillet"

/obj/item/weapon/reagent_containers/food/snacks/carpmeat/New()
	..()
	eatverb = pick("bite","chew","choke down","gnaw","swallow","chomp")
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("carpotoxin", 2)
	reagents.add_reagent("vitamin", 2)
	bitesize = 6

/obj/item/weapon/reagent_containers/food/snacks/carpmeat/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."

/obj/item/weapon/reagent_containers/food/snacks/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon_state = "fishfingers"

/obj/item/weapon/reagent_containers/food/snacks/fishfingers/New()
	..()
	reagents.add_reagent("nutriment", 4)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fishandchips
	name = "fish and chips"
	desc = "I do say so myself chap."
	icon_state = "fishandchips"

/obj/item/weapon/reagent_containers/food/snacks/fishandchips/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 3

////////////////////////////////////////////MEATS AND ALIKE////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/tofu
	name = "tofu"
	desc = "We all love tofu."
	icon_state = "tofu"

/obj/item/weapon/reagent_containers/food/snacks/tofu/New()
	..()
	reagents.add_reagent("nutriment", 3)
	bitesize = 3


/obj/item/weapon/reagent_containers/food/snacks/tomatomeat
	name = "tomato slice"
	desc = "A slice from a huge tomato."
	icon_state = "tomatomeat"

/obj/item/weapon/reagent_containers/food/snacks/tomatomeat/New()
	..()
	reagents.add_reagent("nutriment", 3)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/bearmeat
	name = "bear meat"
	desc = "A very manly slab of meat."
	icon_state = "bearmeat"

/obj/item/weapon/reagent_containers/food/snacks/bearmeat/New()
	..()
	reagents.add_reagent("nutriment", 12)
	reagents.add_reagent("morphine", 5)
	reagents.add_reagent("vitamin", 2)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "xenomeat"

/obj/item/weapon/reagent_containers/food/snacks/xenomeat/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("vitamin", 1)
	src.bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spidermeat
	name = "spider meat"
	desc = "A slab of spider meat."
	icon_state = "spidermeat"

/obj/item/weapon/reagent_containers/food/snacks/spidermeat/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("toxin", 3)
	reagents.add_reagent("vitamin", 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon_state = "spiderleg"

/obj/item/weapon/reagent_containers/food/snacks/spiderleg/New()
	..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("toxin", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/cornedbeef
	name = "corned beef and cabbage"
	desc = "Now you can feel like a real tourist vacationing in Ireland."
	icon_state = "cornedbeef"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/cornedbeef/New()
	..()
	reagents.add_reagent("nutriment", 6)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/faggot
	name = "faggot"
	desc = "A great meal all round. Not a cord of wood."
	icon_state = "faggot"

/obj/item/weapon/reagent_containers/food/snacks/faggot/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"

/obj/item/weapon/reagent_containers/food/snacks/sausage/New()
	..()
	eatverb = pick("bite","chew","nibble","deep throat","gobble","chomp")
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 1)
	bitesize = 2


/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "wing fang chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("vitamin", 2)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/human/kebab
	name = "-kebab"
	icon_state = "kebab"
	desc = "A human meat, on a stick."
	trash = /obj/item/stack/rods

/obj/item/weapon/reagent_containers/food/snacks/human/kebab/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/monkeykebab
	name = "meat-kebab"
	icon_state = "kebab"
	desc = "Delicious meat, on a stick."
	trash = /obj/item/stack/rods

/obj/item/weapon/reagent_containers/food/snacks/monkeykebab/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/tofukebab
	name = "tofu-kebab"
	icon_state = "kebab"
	desc = "Vegan meat, on a stick."
	trash = /obj/item/stack/rods

/obj/item/weapon/reagent_containers/food/snacks/tofukebab/New()
	..()
	reagents.add_reagent("nutriment", 8)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/meatsteak
	name = "meat steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/meatsteak/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("blackpepper", 1)
	reagents.add_reagent("vitamin", 1)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/monkeycube
	name = "monkey cube"
	desc = "Just add water!"
	icon_state = "monkeycube"
	bitesize = 12
	wrapped = 0

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/New()
	..()
	reagents.add_reagent("nutriment",10)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/afterattack(obj/O, mob/user,proximity)
	if(!proximity) return
	if(istype(O,/obj/structure/sink) && !wrapped)
		user << "<span class='notice'>You place [src] under a stream of water...</span>"
		user.drop_item()
		loc = get_turf(O)
		return Expand()
	..()

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/attack_self(mob/user)
	if(wrapped)
		Unwrap(user)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Expand()
	visible_message("<span class='notice'>[src] expands!</span>")
	new /mob/living/carbon/monkey(get_turf(src))
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/monkeycube/proc/Unwrap(mob/user)
	icon_state = "monkeycube"
	desc = "Just add water!"
	user << "<span class='notice'>You unwrap the cube.</span>"
	wrapped = 0


/obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped
	desc = "Still wrapped in some paper."
	icon_state = "monkeycubewrap"
	wrapped = 1

/obj/item/weapon/reagent_containers/food/snacks/enchiladas
	name = "enchiladas"
	desc = "Viva La Mexico!"
	icon_state = "enchiladas"

/obj/item/weapon/reagent_containers/food/snacks/enchiladas/New()
	..()
	reagents.add_reagent("nutriment",8)
	reagents.add_reagent("capsaicin", 6)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/stew
	name = "stew"
	desc = "A nice and warm stew. Healthy and strong."
	icon_state = "stew"
	trash = /obj/item/trash/snack_bowl

/obj/item/weapon/reagent_containers/food/snacks/stew/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 10)
	reagents.add_reagent("tomatojuice", 5)
	reagents.add_reagent("oculine", 5)
	reagents.add_reagent("water", 5)
	bitesize = 10

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat
	name = "stewed soy meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat/New()
	..()
	eatverb = pick("slurp","sip","suck","inhale","drink")
	reagents.add_reagent("nutriment", 8)
	bitesize = 2


/* No more of this
/obj/item/weapon/reagent_containers/food/snacks/telebacon
	name = "tele bacon"
	desc = "It tastes a little odd but it is still delicious."
	icon_state = "bacon"
	var/obj/item/device/radio/beacon/bacon/baconbeacon
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/telebacon/New()
	..()
	reagents.add_reagent("nutriment", 4)
	baconbeacon = new /obj/item/device/radio/beacon/bacon(src)
/obj/item/weapon/reagent_containers/food/snacks/telebacon/On_Consume()
	if(!reagents.total_volume)
		baconbeacon.loc = usr
		baconbeacon.digest_delay()
*/


/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon_state = "spiderlegcooked"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg/New()
	..()
	reagents.add_reagent("nutriment", 3)
	reagents.add_reagent("toxin", 2)
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon_state = "spidereggsham"
	trash = /obj/item/trash/plate

/obj/item/weapon/reagent_containers/food/snacks/spidereggsham/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("toxin", 3)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself."
	icon_state = "sashimi"

/obj/item/weapon/reagent_containers/food/snacks/sashimi/New()
	..()
	reagents.add_reagent("nutriment", 6)
	reagents.add_reagent("toxin", 5)
	bitesize = 3
