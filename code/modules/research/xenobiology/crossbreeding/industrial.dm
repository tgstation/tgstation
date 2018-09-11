/*
Industrial extracts:
	Slowly consume plasma, produce items with it.
*/
/obj/item/slimecross/industrial
	name = "industrial extract"
	desc = "A gel-like, sturdy extract, fond of plasma and industry."
	container_type = INJECTABLE | DRAWABLE
	effect = "industrial"
	icon_state = "industrial_still"
	var/plasmarequired = 2 //Units of plasma required to be consumed to produce item.
	var/itempath = /obj/item //The item produced by the extract.
	var/plasmaabsorbed = 0 //Units of plasma aborbed by the extract already. Absorbs at a rate of 2u/obj tick.
	var/itemamount = 1 //How many items to spawn

/obj/item/slimecross/industrial/examine(mob/user)
	..()
	to_chat(user, "It currently has [plasmaabsorbed] units of plasma floating inside the outer shell, out of [plasmarequired] units.")

/obj/item/slimecross/industrial/proc/do_after_spawn(obj/item/spawned)
	return

/obj/item/slimecross/industrial/Initialize()
	. = ..()
	create_reagents(100)
	START_PROCESSING(SSobj,src)

/obj/item/slimecross/industrial/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/item/slimecross/industrial/process()
	var/IsWorking = FALSE
	if(reagents.has_reagent("plasma",amount = 2) && plasmarequired > 1) //Can absorb as much as 2
		IsWorking = TRUE
		reagents.remove_reagent("plasma",2)
		plasmaabsorbed += 2
	else if(reagents.has_reagent("plasma",amount = 1)) //Can absorb as little as 1
		IsWorking = TRUE
		reagents.remove_reagent("plasma",1)
		plasmaabsorbed += 1

	if(plasmaabsorbed >= plasmarequired)
		playsound(src, 'sound/effects/attackblob.ogg', 50, 1)
		plasmaabsorbed -= plasmarequired
		for(var/i = 0, i < itemamount, i++)
			do_after_spawn(new itempath(get_turf(src)))
	else if(IsWorking)
		playsound(src, 'sound/effects/bubbles.ogg', 5, 1)
	if(IsWorking)
		icon_state = "industrial"
	else
		icon_state = "industrial_still"

/obj/item/slimecross/industrial/grey
	colour = "grey"
	itempath = /obj/item/reagent_containers/food/snacks/monkeycube
	itemamount = 5

/obj/item/slimecross/industrial/orange
	colour = "orange"
	plasmarequired = 6
	itempath = /obj/item/lighter/slime

/obj/item/slimecross/industrial/purple
	colour = "purple"
	plasmarequired = 5
	itempath = /obj/item/slimecrossbeaker/autoinjector/regenpack

/obj/item/slimecross/industrial/blue
	colour = "blue"
	plasmarequired = 10
	itempath = /obj/item/extinguisher

/obj/item/slimecross/industrial/metal
	colour = "metal"
	plasmarequired = 3
	itempath = /obj/item/stack/sheet/metal/ten

/obj/item/slimecross/industrial/yellow
	colour = "yellow"
	plasmarequired = 5
	itempath = /obj/item/stock_parts/cell/high

/obj/item/slimecross/industrial/yellow/do_after_spawn(obj/item/spawned)
	var/obj/item/stock_parts/cell/high/C = spawned
	if(istype(C))
		C.charge = rand(0,C.maxcharge/2)

/obj/item/slimecross/industrial/darkpurple
	colour = "dark purple"
	plasmarequired = 10
	itempath = /obj/item/stack/sheet/mineral/plasma

/obj/item/slimecross/industrial/darkblue
	colour = "dark blue"
	plasmarequired = 6
	itempath = /obj/item/slimepotion/fireproof

/obj/item/slimecross/industrial/darkblue/do_after_spawn(obj/item/spawned)
	var/obj/item/slimepotion/fireproof/potion = spawned
	if(istype(potion))
		potion.uses = 1

/obj/item/slimecross/industrial/silver
	colour = "silver"
	plasmarequired = 1
	//Item picked below.

/obj/item/slimecross/industrial/silver/process()
	itempath = pick(list(get_random_food(), get_random_drink()))
	..()

/obj/item/slimecross/industrial/bluespace
	colour = "bluespace"
	plasmarequired = 7
	itempath = /obj/item/stack/ore/bluespace_crystal/artificial

/obj/item/slimecross/industrial/sepia
	colour = "sepia"
	plasmarequired = 2
	itempath = /obj/item/camera

/obj/item/slimecross/industrial/cerulean
	colour = "cerulean"
	plasmarequired = 5
	itempath = /obj/item/slimepotion/enhancer

/obj/item/slimecross/industrial/pyrite
	colour = "pyrite"
	plasmarequired = 2
	itempath = /obj/item/toy/crayon/spraycan

/obj/item/slimecross/industrial/red
	colour = "red"
	plasmarequired = 5
	itempath = /obj/item/slimecrossbeaker/bloodpack

/obj/item/slimecross/industrial/green
	colour = "green"
	plasmarequired = 7
	itempath = /obj/item/slimecrossbeaker/autoinjector/slimejelly

/obj/item/slimecross/industrial/pink
	colour = "pink"
	plasmarequired = 6
	itempath = /obj/item/slimecrossbeaker/autoinjector/peaceandlove

/obj/item/slimecross/industrial/gold
	colour = "gold"
	plasmarequired = 10

/obj/item/slimecross/industrial/gold/process()
	itempath = pick(/obj/item/coin/silver, /obj/item/coin/iron, /obj/item/coin/gold, /obj/item/coin/diamond, /obj/item/coin/plasma, /obj/item/coin/uranium)
	..()

/obj/item/slimecross/industrial/oil
	colour = "oil"
	plasmarequired = 4
	itempath = /obj/item/grenade/iedcasing

/obj/item/slimecross/industrial/black //What does this have to do with black slimes? No clue! Fun, though
	colour = "black"
	plasmarequired = 6
	itempath = /obj/item/storage/fancy/cigarettes/cigpack_xeno

/obj/item/slimecross/industrial/lightpink
	colour = "light pink"
	plasmarequired = 3
	itempath = /obj/item/storage/fancy/heart_box

/obj/item/slimecross/industrial/adamantine
	colour = "adamantine"
	plasmarequired = 10
	itempath = /obj/item/stack/sheet/mineral/adamantine

/obj/item/slimecross/industrial/rainbow
	colour = "rainbow"
	plasmarequired = 5
	//Item picked below.

/obj/item/slimecross/industrial/rainbow/process()
	itempath = pick(subtypesof(/obj/item/slime_extract))
	..()
