<<<<<<< HEAD
/obj/item/stack/sheet/animalhide
	name = "hide"
	desc = "Something went wrong."
	origin_tech = "biotech=3"

/obj/item/stack/sheet/animalhide/human
	name = "human skin"
	desc = "The by-product of human farming."
	singular_name = "human skin piece"
	icon_state = "sheet-hide"

var/global/list/datum/stack_recipe/human_recipes = list( \
	new/datum/stack_recipe("bloated human costume", /obj/item/clothing/suit/hooded/bloated_human, 5, on_floor = 1), \
	)

/obj/item/stack/sheet/animalhide/human/New(var/loc, var/amount=null)
	recipes = human_recipes
	return ..()

/obj/item/stack/sheet/animalhide/generic
	name = "skin"
	desc = "A piece of skin."
	singular_name = "skin piece"
	icon_state = "sheet-hide"

/obj/item/stack/sheet/animalhide/corgi
	name = "corgi hide"
	desc = "The by-product of corgi farming."
	singular_name = "corgi hide piece"
	icon_state = "sheet-corgi"

var/global/list/datum/stack_recipe/corgi_recipes = list ( \
	new/datum/stack_recipe("corgi costume", /obj/item/clothing/suit/hooded/ian_costume, 3, on_floor = 1), \
	)

/obj/item/stack/sheet/animalhide/corgi/New(var/loc, var/amount=null)
	recipes = corgi_recipes
	return ..()

/obj/item/stack/sheet/animalhide/cat
	name = "cat hide"
	desc = "The by-product of cat farming."
	singular_name = "cat hide piece"
	icon_state = "sheet-cat"

/obj/item/stack/sheet/animalhide/monkey
	name = "monkey hide"
	desc = "The by-product of monkey farming."
	singular_name = "monkey hide piece"
	icon_state = "sheet-monkey"

var/global/list/datum/stack_recipe/monkey_recipes = list ( \
	new/datum/stack_recipe("monkey mask", /obj/item/clothing/mask/gas/monkeymask, 1, on_floor = 1), \
	new/datum/stack_recipe("monkey suit", /obj/item/clothing/suit/monkeysuit, 2, on_floor = 1), \
	)

/obj/item/stack/sheet/animalhide/monkey/New(var/loc, var/amount=null)
	recipes = monkey_recipes
	return ..()

/obj/item/stack/sheet/animalhide/lizard
	name = "lizard skin"
	desc = "Sssssss..."
	singular_name = "lizard skin piece"
	icon_state = "sheet-lizard"

/obj/item/stack/sheet/animalhide/xeno
	name = "alien hide"
	desc = "The skin of a terrible creature."
	singular_name = "alien hide piece"
	icon_state = "sheet-xeno"

var/global/list/datum/stack_recipe/xeno_recipes = list ( \
	new/datum/stack_recipe("alien helmet", /obj/item/clothing/head/xenos, 1, on_floor = 1), \
	new/datum/stack_recipe("alien suit", /obj/item/clothing/suit/xenos, 2, on_floor = 1), \
	)

/obj/item/stack/sheet/animalhide/xeno/New(var/loc, var/amount=null)
	recipes = xeno_recipes
	return ..()

//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"
	origin_tech = null

/obj/item/xenos_claw
	name = "alien claw"
	desc = "The claw of a terrible creature."
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"
	origin_tech = null

/obj/item/weed_extract
	name = "weed extract"
	desc = "A piece of slimy, purplish weed."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"
	origin_tech = null

/obj/item/stack/sheet/hairlesshide
	name = "hairless hide"
	desc = "This hide was stripped of it's hair, but still needs tanning."
	singular_name = "hairless hide piece"
	icon_state = "sheet-hairlesshide"
	origin_tech = null

/obj/item/stack/sheet/wetleather
	name = "wet leather"
	desc = "This leather has been cleaned but still needs to be dried."
	singular_name = "wet leather piece"
	icon_state = "sheet-wetleather"
	origin_tech = null
	var/wetness = 30 //Reduced when exposed to high temperautres
	var/drying_threshold_temperature = 500 //Kelvin to start drying

/obj/item/stack/sheet/leather
	name = "leather"
	desc = "The by-product of mob grinding."
	singular_name = "leather piece"
	icon_state = "sheet-leather"
	origin_tech = "materials=2"

/obj/item/stack/sheet/sinew
	name = "watcher sinew"
	icon = 'icons/obj/mining.dmi'
	desc = "Long stringy filaments which presumably came from a watcher's wings."
	singular_name = "watcher sinew"
	icon_state = "sinew"
	origin_tech = "biotech=4"


var/global/list/datum/stack_recipe/sinew_recipes = list ( \
	new/datum/stack_recipe("sinew restraints", /obj/item/weapon/restraints/handcuffs/sinew, 1, on_floor = 1), \
	)

/obj/item/stack/sheet/sinew/New(var/loc, var/amount=null)
	recipes = sinew_recipes
	return ..()
		/*
 * Plates
 		*/

/obj/item/stack/sheet/animalhide/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_hide"
	singular_name = "hide plate"
	flags = NOBLUDGEON
	w_class = 3
	layer = MOB_LAYER

/obj/item/stack/sheet/animalhide/ashdrake
	name = "ash drake hide"
	desc = "The strong, scaled hide of an ash drake."
	icon = 'icons/obj/mining.dmi'
	icon_state = "dragon_hide"
	singular_name = "drake plate"
	flags = NOBLUDGEON
	w_class = 3
	layer = MOB_LAYER


//Step one - dehairing.

/obj/item/stack/sheet/animalhide/attackby(obj/item/weapon/W, mob/user, params)
	if(is_sharp(W))
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("[user] starts cutting hair off \the [src].", "<span class='notice'>You start cutting the hair off \the [src]...</span>", "<span class='italics'>You hear the sound of a knife rubbing against flesh.</span>")
		if(do_after(user,50, target = src))
			user << "<span class='notice'>You cut the hair from this [src.singular_name].</span>"
			//Try locating an exisitng stack on the tile and add to there if possible
			for(var/obj/item/stack/sheet/hairlesshide/HS in user.loc)
				if(HS.amount < 50)
					HS.amount++
					use(1)
					break
			//If it gets to here it means it did not find a suitable stack on the tile.
			var/obj/item/stack/sheet/hairlesshide/HS = new(user.loc)
			HS.amount = 1
			use(1)
	else
		return ..()


//Step two - washing..... it's actually in washing machine code.

//Step three - drying
/obj/item/stack/sheet/wetleather/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature >= drying_threshold_temperature)
		wetness--
		if(wetness == 0)
			//Try locating an exisitng stack on the tile and add to there if possible
			for(var/obj/item/stack/sheet/leather/HS in src.loc)
				if(HS.amount < 50)
					HS.amount++
					src.use(1)
					wetness = initial(wetness)
					break
			//If it gets to here it means it did not find a suitable stack on the tile.
			var/obj/item/stack/sheet/leather/HS = new(src.loc)
			HS.amount = 1
			wetness = initial(wetness)
			src.use(1)
=======
/obj/item/stack/sheet/animalhide
	icon = 'icons/obj/butchering_products.dmi'

/obj/item/stack/sheet/animalhide/human
	name = "human skin"
	desc = "The by-product of human farming."
	singular_name = "human skin piece"
	icon_state = "sheet-hide"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/corgi
	name = "corgi hide"
	desc = "The by-product of corgi farming."
	singular_name = "corgi hide piece"
	icon_state = "sheet-corgi"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/cat
	name = "cat hide"
	desc = "The by-product of cat farming."
	singular_name = "cat hide piece"
	icon_state = "sheet-cat"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/monkey
	name = "monkey hide"
	desc = "The by-product of monkey farming."
	singular_name = "monkey hide piece"
	icon_state = "sheet-monkey"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/lizard
	name = "lizard skin"
	desc = "Sssssss..."
	singular_name = "lizard skin piece"
	icon_state = "sheet-lizard"
	origin_tech = ""

/obj/item/stack/sheet/animalhide/xeno
	name = "alien hide"
	desc = "The skin of a terrible creature."
	singular_name = "alien hide piece"
	icon_state = "sheet-xeno"
	origin_tech = ""

//don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/sheet/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "chitin"
	origin_tech = ""

/obj/item/xenos_claw
	name = "alien claw"
	desc = "The claw of a terrible creature."
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "claw"
	origin_tech = ""

/obj/item/xenos_claw/attackby(obj/item/W, mob/user)
	.=..()

	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W

		if(C.use(5))
			user.drop_item(src, force_drop = 1)

			var/obj/item/clothing/mask/necklace/xeno_claw/X = new(get_turf(src))
			user.put_in_active_hand(X)
			to_chat(user, "<span class='info'>You create a necklace out of \the [src] and \the [C].</span>")

			qdel(src)
		else
			to_chat(user, "<span class='info'>You need at least 5 lengths of cable to do this!</span>")

/obj/item/weed_extract
	name = "weed extract"
	desc = "A piece of slimy, purplish weed."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"
	origin_tech = ""

/obj/item/stack/sheet/hairlesshide
	name = "hairless hide"
	desc = "This hide was stripped of it's hair, but still needs tanning."
	singular_name = "hairless hide piece"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "sheet-hairlesshide"
	origin_tech = ""

/obj/item/stack/sheet/wetleather
	name = "wet leather"
	desc = "This leather has been cleaned but still needs to be dried."
	singular_name = "wet leather piece"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "sheet-wetleather"
	origin_tech = ""
	var/wetness = 30 //Reduced when exposed to high temperautres
	var/drying_threshold_temperature = 500 //Kelvin to start drying

/obj/item/stack/sheet/leather
	name = "leather"
	desc = "The by-product of mob grinding."
	singular_name = "leather piece"
	icon = 'icons/obj/butchering_products.dmi'
	icon_state = "sheet-leather"
	origin_tech = "materials=2"



//Step one - dehairing.

/obj/item/stack/sheet/animalhide/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(	W.is_sharp() >= 1.2 )

		//visible message on mobs is defined as visible_message(var/message, var/self_message, var/blind_message)
		user.visible_message("<span class='notice'>\the [usr] starts cutting hair off \the [src]</span>", "<span class='notice'>You start cutting the hair off \the [src]</span>", "You hear the sound of a knife rubbing against flesh")

		spawn()
			if(do_after(user, src, 50))
				to_chat(user, "<span class='notice'>You cut the hair from this [src.singular_name]</span>")

				if(src.use(1))
					drop_stack(/obj/item/stack/sheet/hairlesshide, user.loc, 1, user)
		return 1
	else
		..()


//Step two - washing..... it's actually in washing machine code.

//Step three - drying
/obj/item/stack/sheet/wetleather/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature >= drying_threshold_temperature)
		wetness--
		if(wetness == 0)

			if(src.use(1))
				drop_stack(/obj/item/stack/sheet/leather, src.loc, 1)
				wetness = initial(wetness)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
