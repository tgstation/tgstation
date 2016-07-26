//Easter start
/datum/holiday/easter/greet()
	return "Greetings! Have a Happy Easter and keep an eye out for Easter Bunnies!"

/datum/round_event_control/easter
	name = "Easter Eggselence"
	holidayID = EASTER
	typepath = /datum/round_event/easter
	weight = -1
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/easter/announce()
	priority_announce(pick("Hip-hop into Easter!","Find some Bunny's stash!","Today is National 'Hunt a Wabbit' Day.","Be kind, give Chocolate Eggs!"))


/datum/round_event_control/rabbitrelease
	name = "Release the Rabbits!"
	holidayID = EASTER
	typepath = /datum/round_event/rabbitrelease
	weight = 5
	max_occurrences = 10

/datum/round_event/rabbitrelease/announce()
	priority_announce("Unidentified furry objects detected coming aboard [station_name()]. Beware of Adorable-ness.", "Fluffy Alert", 'sound/AI/aliens.ogg')


/datum/round_event/rabbitrelease/start()
	for(var/obj/effect/landmark/R in landmarks_list)
		if(R.name != "blobspawn")
			if(prob(35))
				if(istype(R.loc,/turf/open/space))
					new /mob/living/simple_animal/chicken/rabbit/space(R.loc)
				else
					new /mob/living/simple_animal/chicken/rabbit(R.loc)

/mob/living/simple_animal/chicken/rabbit
	name = "\improper rabbit"
	desc = "The hippiest hop around."
	icon = 'icons/mob/Easter.dmi'
	icon_state = "rabbit_white"
	icon_living = "rabbit_white"
	icon_dead = "rabbit_white_dead"
	speak = list("Hop into Easter!","Come get your eggs!","Prizes for everyone!")
	speak_emote = list("sniffles","twitches")
	emote_hear = list("hops.")
	emote_see = list("hops around","bounces up and down")
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 1)
	egg_type = /obj/item/weapon/reagent_containers/food/snacks/egg/loaded
	food_type = /obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	eggsleft = 10
	eggsFertile = FALSE
	icon_prefix = "rabbit"
	feedMessages = list("It nibbles happily.","It noms happily.")
	layMessage = list("hides an egg.","scampers around suspiciously.","begins making a huge racket.","begins shuffling.")

/mob/living/simple_animal/chicken/rabbit/space
	icon_prefix = "s_rabbit"
	icon_state = "s_rabbit_white"
	icon_living = "s_rabbit_white"
	icon_dead = "s_rabbit_white_dead"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	unsuitable_atmos_damage = 0

//Easter Baskets
/obj/item/weapon/storage/bag/easterbasket
	name = "Easter Basket"
	icon = 'icons/mob/Easter.dmi'
	icon_state = "basket"
	can_hold = list(/obj/item/weapon/reagent_containers/food/snacks/egg,/obj/item/weapon/reagent_containers/food/snacks/chocolateegg,/obj/item/weapon/reagent_containers/food/snacks/boiledegg)

/obj/item/weapon/storage/bag/easterbasket/proc/countEggs()
	cut_overlays()
	add_overlay(image("icon" = icon, "icon_state" = "basket-grass", "layer" = -1))
	add_overlay(image("icon" = icon, "icon_state" = "basket-egg[contents.len <= 5 ? contents.len : 5]", "layer" = -1))

/obj/item/weapon/storage/bag/easterbasket/remove_from_storage(obj/item/W as obj, atom/new_location)
	..()
	countEggs()

/obj/item/weapon/storage/bag/easterbasket/handle_item_insertion(obj/item/I, prevent_warning = 0)
	. = ..()
	countEggs()

//Bunny Suit
/obj/item/clothing/head/bunnyhead
	name = "Easter Bunny Head"
	icon_state = "bunnyhead"
	item_state = "bunnyhead"
	desc = "Considerably more cute than 'Frank'"
	slowdown = -1
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/suit/bunnysuit
	name = "Easter Bunny Suit"
	desc = "Hop Hop Hop!"
	icon_state = "bunnysuit"
	item_state = "bunnysuit"
	slowdown = -1
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

//Egg prizes and egg spawns!
/obj/item/weapon/reagent_containers/food/snacks/egg
	var/containsPrize = FALSE

/obj/item/weapon/reagent_containers/food/snacks/egg/loaded
	containsPrize = TRUE

/obj/item/weapon/reagent_containers/food/snacks/egg/loaded/New()
	..()
	var/color = pick("blue","green","mime","orange","purple","rainbow","red","yellow")
	icon_state = "egg-[color]"
	item_color = "[color]"

/obj/item/weapon/reagent_containers/food/snacks/egg/proc/dispensePrize(turf/where)
	var/won = pick(/obj/item/clothing/head/bunnyhead,
	/obj/item/clothing/suit/bunnysuit,
	/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
	/obj/item/weapon/reagent_containers/food/snacks/chocolateegg,
	/obj/item/toy/balloon,
	/obj/item/toy/gun,
	/obj/item/toy/sword,
	/obj/item/toy/foamblade,
	/obj/item/toy/prize/ripley,
	/obj/item/toy/prize/honk,
	/obj/item/toy/carpplushie,
	/obj/item/toy/redbutton,
	/obj/item/clothing/head/collectable/rabbitears)
	new won(where)
	new/obj/item/weapon/reagent_containers/food/snacks/chocolateegg(where)

/obj/item/weapon/reagent_containers/food/snacks/egg/attack_self(mob/user)
	..()
	if(containsPrize)
		user << "<span class='notice'>You unwrap the [src] and find a prize inside!</span>"
		dispensePrize(get_turf(user))
		containsPrize = FALSE
		qdel(src)

/obj/effect/spawner/lootdrop/maintenance/New()
	..()
	loot += list(/obj/item/weapon/reagent_containers/food/snacks/egg/loaded = 15, /obj/item/weapon/storage/bag/easterbasket = 15)

//Easter Recipes + food
/obj/item/weapon/reagent_containers/food/snacks/hotcrossbun
	bitesize = 2
	name = "hot-cross bun"
	desc = "The Cross represents the Assistants that died for your sins."
	icon_state = "hotcrossbun"

/datum/crafting_recipe/food/food/hotcrossbun
	name = "Hot-Cross Bun"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/datum/reagent/consumable/sugar = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotcrossbun
	category = CAT_MISCFOOD


/obj/item/weapon/reagent_containers/food/snacks/store/cake/brioche
	name = "brioche cake"
	desc = "A ring of sweet, glazed buns."
	icon_state = "briochecake"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/cakeslice/brioche
	slices_num = 6
	bonus_reagents = list("nutriment" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/cakeslice/brioche
	name = "brioche cake slice"
	desc = "Delicious sweet-bread. Who needs anything else?"
	icon_state = "briochecake_slice"
	filling_color = "#FFD700"

/datum/crafting_recipe/food/food/briochecake
	name = "Brioche cake"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/cake/plain = 1,
		/datum/reagent/consumable/sugar = 2
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/store/cake/brioche
	category = CAT_MISCFOOD

/obj/item/weapon/reagent_containers/food/snacks/scotchegg
	name = "scotch egg"
	desc = "A boiled egg wrapped in a delicious, seasoned meatball."
	icon_state = "scotchegg"
	bonus_reagents = list("nutriment" = 2, "vitamin" = 2)
	bitesize = 3
	filling_color = "#FFFFF0"
	list_reagents = list("nutriment" = 6)

/datum/crafting_recipe/food/scotchegg
	name = "Scotch egg"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg = 1,
		/obj/item/weapon/reagent_containers/food/snacks/faggot = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/scotchegg
	category = CAT_MISCFOOD

/obj/item/weapon/reagent_containers/food/snacks/soup/mammi
	name = "Mammi"
	desc = "A bowl of mushy bread and milk. It reminds you, not too fondly, of a bowel movement."
	icon_state = "mammi"
	bonus_reagents = list("nutriment" = 3, "vitamin" = 1)
	list_reagents = list("nutriment" = 8, "vitamin" = 1)

/datum/crafting_recipe/food/mammi
	name = "Mammi"
	reqs = list(
		/obj/item/weapon/reagent_containers/food/snacks/store/bread/plain = 1,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = 1,
		/datum/reagent/consumable/milk = 5
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soup/mammi
	category = CAT_MISCFOOD

/obj/item/weapon/reagent_containers/food/snacks/chocolatebunny
	name = "chocolate bunny"
	desc = "Contains less than 10% real rabbit!"
	icon_state = "chocolatebunny"
	bonus_reagents = list("nutriment" = 1, "vitamin" = 1)
	list_reagents = list("nutriment" = 4, "sugar" = 2, "cocoa" = 2)
	filling_color = "#A0522D"

/datum/crafting_recipe/food/chocolatebunny
	name = "Chocolate bunny"
	reqs = list(
		/datum/reagent/consumable/sugar = 2,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar = 1
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chocolatebunny
	category = CAT_MISCFOOD
