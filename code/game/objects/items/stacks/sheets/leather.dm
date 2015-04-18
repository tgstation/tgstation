/obj/item/stack/sheet/animalhide/human
	name = "human skin"
	desc = "The by-product of human farming."
	singular_name = "human skin piece"
	icon_state = "sheet-hide"
	origin_tech = null

/obj/item/stack/sheet/animalhide/corgi
	name = "corgi hide"
	desc = "The by-product of corgi farming."
	singular_name = "corgi hide piece"
	icon_state = "sheet-corgi"
	origin_tech = null

/obj/item/stack/sheet/animalhide/cat
	name = "cat hide"
	desc = "The by-product of cat farming."
	singular_name = "cat hide piece"
	icon_state = "sheet-cat"
	origin_tech = null

/obj/item/stack/sheet/animalhide/monkey
	name = "monkey hide"
	desc = "The by-product of monkey farming."
	singular_name = "monkey hide piece"
	icon_state = "sheet-monkey"
	origin_tech = null

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
	origin_tech = null

/obj/item/stack/sheet/animalhide/xeno
	name = "alien hide"
	desc = "The skin of a terrible creature."
	singular_name = "alien hide piece"
	icon_state = "sheet-xeno"
	origin_tech = null

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



//Step one - dehairing.

/obj/item/stack/sheet/animalhide/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(	istype(W, /obj/item/weapon/kitchenknife) || \
		istype(W, /obj/item/weapon/kitchen/utensil/knife) || \
		istype(W, /obj/item/weapon/twohanded/fireaxe) || \
		istype(W, /obj/item/weapon/hatchet) )

		//visible message on mobs is defined as visible_message(var/message, var/self_message, var/blind_message)
		usr.visible_message("<span class='notice'>\the [usr] starts cutting hair off \the [src].</span>", "<span class='notice'>You start cutting the hair off \the [src]...</span>", "You hear the sound of a knife rubbing against flesh")
		if(do_after(user,50))
			usr << "<span class='notice'>You cut the hair from this [src.singular_name].</span>"
			//Try locating an exisitng stack on the tile and add to there if possible
			for(var/obj/item/stack/sheet/hairlesshide/HS in usr.loc)
				if(HS.amount < 50)
					HS.amount++
					src.use(1)
					break
			//If it gets to here it means it did not find a suitable stack on the tile.
			var/obj/item/stack/sheet/hairlesshide/HS = new(usr.loc)
			HS.amount = 1
			src.use(1)
	else
		..()


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
