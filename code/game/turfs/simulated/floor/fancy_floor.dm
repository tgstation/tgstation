/* In this file:
 * Wood floor
 * Grass floor
 * Carpet floor
 */

/turf/simulated/floor/wood
	icon_state = "wood"
	floor_tile = /obj/item/stack/tile/wood
	broken_states = list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

/turf/simulated/floor/wood/attackby(obj/item/C as obj, mob/user as mob, params)
	if(..())
		return
	if(istype(C, /obj/item/weapon/screwdriver))
		if(broken || burnt)
			return
		user << "<span class='danger'>You unscrew the planks.</span>"
		new floor_tile(src)
		make_plating()
		playsound(src, 'sound/items/Screwdriver.ogg', 80, 1)
		return

/turf/simulated/floor/grass
	name = "Grass patch"
	icon_state = "grass"
	floor_tile = /obj/item/stack/tile/grass
	broken_states = list("sand")
	ignoredirt = 1

/turf/simulated/floor/grass/New()
	..()
	spawn(1)
		update_icon()

/turf/simulated/floor/fancy/grass/attackby(obj/item/C as obj, mob/user as mob, params)
	if(..())
		return
	if(istype(C, /obj/item/weapon/shovel))
		new /obj/item/weapon/ore/glass(src)
		new /obj/item/weapon/ore/glass(src) //Make some sand if you shovel grass
		user << "<span class='notice'>You shovel the grass.</span>"
		make_plating()

/turf/simulated/floor/carpet
	name = "Carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	broken_states = list("damaged")
	smooth = 1
	canSmoothWith = null

/turf/simulated/floor/carpet/New()
	..()
	spawn(1)
		update_icon()

/turf/simulated/floor/carpet/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if(smoother)
			smoother.smooth()
	else
		make_plating()
		if(smoother)
			smoother.update_neighbors()

/turf/simulated/floor/carpet/break_tile()
	broken = 1
	update_icon()

/turf/simulated/floor/carpet/burn_tile()
	burnt = 1
	update_icon()