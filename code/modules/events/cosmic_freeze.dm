/obj/structure/snow
	name = "snow"
	layer = 2.5//above the plating and the vents, bellow most items and structures
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	alpha = 230
	anchored = 1
	density = 0
	mouse_opacity = 1

	var/has_sappling = 0
	var/dug = 0
	var/caught = 0

	var/list/foliage = list(
		"snowgrass1bb",
		"snowgrass2bb",
		"snowgrass3bb",
		"snowgrass1gb",
		"snowgrass2gb",
		"snowgrass3gb",
		"snowgrassall1",
		"snowgrassall2",
		"snowgrassall3",
		)

	var/list/sappling = list(
		"snowbush1",
		"snowbush2",
		"snowbush3",
		"snowbush4",
		"snowbush5",
		"snowbush6",
		)

	var/list/trees = list(
		"tree_1",
		"tree_2",
		"tree_3",
		"tree_4",
		"tree_5",
		"tree_6",
		)

	var/list/pinetrees = list(
		"pine_1",
		"pine_2",
		"pine_3",
		)

/obj/structure/snow/New()
	..()
	if(prob(17))
		overlays += image('icons/obj/flora/snowflora.dmi',pick(foliage))

/obj/structure/snow/attackby(obj/item/W,mob/user)
	if(istype(W,/obj/item/weapon/minihoe))
		if(has_sappling)
			has_sappling = 0
			overlays = 0

	if(istype(W,/obj/item/weapon/shovel))//using a shovel or spade harvests some snow and let's you click on the lower layers
		icon_state = "snow_dug"
		mouse_opacity = 0

/obj/structure/snow/attack_hand(mob/user)
	if(dug || caught)	return
	playsound(get_turf(src), "rustle", 50, 1)
	user << "<span class='notice'>You start digging the snow with your hands.</span>"
	if(do_after(user,30))
		caught = 1
		user << "<span class='notice'>You pick.</span>"
		user.put_in_hands(new /obj/item/stack/sheet/snow())
		icon_state = "snow_grabbed"
		sleep(400)
			if(!dug)
				icon_state = "snow"
				caught = 0
	return

/obj/item/stack/sheet/snow
	name = "snow"
	desc = "Technically water."
	singular_name = "snow ball"
	icon_state = "snow"
	melt_temperature = MELTPOINT_SNOW

/obj/item/stack/sheet/snow/New(var/loc, var/amount=null)
	recipes = snow_recipes
	pixel_x = rand(-13,13)
	pixel_y = rand(-13,13)
	return ..()

/obj/item/stack/sheet/snow/melt()
	var/turf/T = get_turf(src)
	T.wet(800)
	qdel(src)

var/global/list/datum/stack_recipe/snow_recipes = list (
	new/datum/stack_recipe("snowman", /mob/living/simple_animal, 10, time = 50, one_per_turf = 0, on_floor = 1),
	)

/obj/structure/barricade/snow
	name = "snow barricade"
	desc = "This space is blocked off by a snow barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "snowbarricade"
	anchored = 1.0
	density = 1.0
	var/health = 50.0
	var/maxhealth = 50.0

/obj/structure/barricade/snow/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/stack/sheet/snow))
		if (src.health < src.maxhealth)
			visible_message("<span class='warning'>[user] begins to repair the [src]!</span>")
			if(do_after(user,20))
				src.health = src.maxhealth
				W:use(1)
				visible_message("<span class='warning'>[user] repairs the [src]</span>")
				return
		else
			return
		return
	else
		switch(W.damtype)
			if("fire")
				src.health -= W.force * 1
			if("brute")
				src.health -= W.force * 0.75
			else
		if (src.health <= 0)
			visible_message("<span class='danger'>The barricade is smashed apart!</span>")
			new /obj/item/stack/sheet/snow(get_turf(src, 1))
			new /obj/item/stack/sheet/snow(get_turf(src, 1))
			new /obj/item/stack/sheet/snow(get_turf(src, 1))
			del(src)
		..()

/obj/structure/barricade/snow/ex_act(severity)
	switch(severity)
		if(1.0)
			visible_message("<span class='danger'>\the [src] is blown apart!</span>")
			qdel(src)
			return
		if(2.0)
			src.health -= 25
			if (src.health <= 0)
				visible_message("<span class='danger'>\the [src] is blown apart!</span>")
				new /obj/item/stack/sheet/snow(get_turf(src, 1))
				new /obj/item/stack/sheet/snow(get_turf(src, 1))
				new /obj/item/stack/sheet/snow(get_turf(src, 1))
				qdel(src)
			return

/obj/structure/barricade/snow/meteorhit()
	visible_message("<span class='danger'>\the [src] is blown apart!</span>")
	new /obj/item/stack/sheet/snow(get_turf(src, 1))
	new /obj/item/stack/sheet/snow(get_turf(src, 1))
	new /obj/item/stack/sheet/snow(get_turf(src, 1))
	del(src)
	return

/obj/structure/barricade/snow/blob_act()
	src.health -= 25
	if (src.health <= 0)
		visible_message("<span class='danger'>The blob eats through \the [src]!</span>")
		del(src)
	return

/obj/structure/barricade/snow/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)//So bullets will fly over and stuff.
	if(air_group || (height==0))
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/structure/tree
	name = "tree"
	layer = FLY_LAYER
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"
