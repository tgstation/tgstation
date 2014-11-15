/* In this file:
 * Wood floor
 * Grass floor
 * Carpet floor
 */

/turf/simulated/floor/wood
	name = "floor"
	icon_state = "wood"
	floor_tile = /obj/item/stack/tile/wood
	broken_states = list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

/turf/simulated/floor/wood/attackby(obj/item/C as obj, mob/user as mob)
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
	icon_state = "grass1"
	floor_tile = /obj/item/stack/tile/grass
	broken_states = list("sand1", "sand2", "sand3")

/turf/simulated/floor/grass/New()
	..()
	icon_state = "grass[pick("1","2","3","4")]"
	spawn(1)
		if(src)
			update_icon()
			fancy_update(type)

/turf/simulated/floor/grass/attackby(obj/item/C as obj, mob/user as mob)
	if(..())
		return
	if(istype(C, /obj/item/weapon/shovel))
		new /obj/item/weapon/ore/glass(src)
		new /obj/item/weapon/ore/glass(src) //Make some sand if you shovel grass
		user << "<span class='notice'>You shovel the grass.</span>"
		make_plating()

/turf/simulated/floor/grass/return_siding_icon_state()
	..()
	var/dir_sum = 0
	for(var/direction in cardinal)
		if(!istype(get_step(src,direction), /turf/simulated/floor/grass))
			dir_sum += direction
	if(dir_sum)
		return "wood_siding[dir_sum]"
	else
		return 0

/turf/simulated/floor/carpet
	name = "Carpet"
	icon_state = "carpet"
	floor_tile = /obj/item/stack/tile/carpet
	broken_states = list("carpet-broken")

/turf/simulated/floor/carpet/New()
	..()
	spawn(1)
		if(src)
			update_icon()
			fancy_update(type)

/turf/simulated/floor/carpet/update_icon()
	if(!broken && !burnt)
		if(icon_state == "carpetsymbol") //le snowflake :^)
			return

		var/connectdir = 0
		for(var/direction in cardinal)
			if(istype(get_step(src,direction),/turf/simulated/floor/carpet))
				var/turf/simulated/floor/carpet/FF = get_step(src,direction)
				if(istype(FF, /turf/simulated/floor/carpet))
					connectdir |= direction

		//Check the diagonal connections for corners, where you have, for example, connections both north and east. In this case it checks for a north-east connection to determine whether to add a corner marker or not.
		var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW

		//Northeast
		if(connectdir & NORTH && connectdir & EAST)
			if(istype(get_step(src,NORTHEAST),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,NORTHEAST)
				if(istype(FF, /turf/simulated/floor/carpet))
					diagonalconnect |= 1

		//Southeast
		if(connectdir & SOUTH && connectdir & EAST)
			if(istype(get_step(src,SOUTHEAST),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,SOUTHEAST)
				if(istype(FF, /turf/simulated/floor/carpet))
					diagonalconnect |= 2

		//Northwest
		if(connectdir & NORTH && connectdir & WEST)
			if(istype(get_step(src,NORTHWEST),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,NORTHWEST)
				if(istype(FF, /turf/simulated/floor/carpet))
					diagonalconnect |= 4

		//Southwest
		if(connectdir & SOUTH && connectdir & WEST)
			if(istype(get_step(src,SOUTHWEST),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,SOUTHWEST)
				if(istype(FF, /turf/simulated/floor/carpet))
					diagonalconnect |= 8

		icon_state = "carpet[connectdir]-[diagonalconnect]"

/turf/simulated/floor/bluecarpet
	name = "Blue carpet"
	icon_state = "bluecarpet"
	floor_tile = /obj/item/stack/tile/bluecarpet
	broken_states = list("bluecarpet-broken")

/turf/simulated/floor/bluecarpet/New()
	..()
	spawn(1)
		if(src)
			update_icon()
			fancy_update(type)

/turf/simulated/floor/bluecarpet/update_icon()
	if(!broken && !burnt)
		if(icon_state == "bluecarpetsymbol") //le snowflake :^)
			return

		var/connectdir = 0
		for(var/direction in cardinal)
			if(istype(get_step(src,direction),/turf/simulated/floor/bluecarpet))
				var/turf/simulated/floor/bluecarpet/FF = get_step(src,direction)
				if(istype(FF, /turf/simulated/floor/bluecarpet))
					connectdir |= direction

		//Check the diagonal connections for corners, where you have, for example, connections both north and east. In this case it checks for a north-east connection to determine whether to add a corner marker or not.
		var/diagonalconnect = 0 //1 = NE; 2 = SE; 4 = NW; 8 = SW

		//Northeast
		if(connectdir & NORTH && connectdir & EAST)
			if(istype(get_step(src,NORTHEAST),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,NORTHEAST)
				if(istype(FF, /turf/simulated/floor/bluecarpet))
					diagonalconnect |= 1

		//Southeast
		if(connectdir & SOUTH && connectdir & EAST)
			if(istype(get_step(src,SOUTHEAST),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,SOUTHEAST)
				if(istype(FF, /turf/simulated/floor/bluecarpet))
					diagonalconnect |= 2

		//Northwest
		if(connectdir & NORTH && connectdir & WEST)
			if(istype(get_step(src,NORTHWEST),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,NORTHWEST)
				if(istype(FF, /turf/simulated/floor/bluecarpet))
					diagonalconnect |= 4

		//Southwest
		if(connectdir & SOUTH && connectdir & WEST)
			if(istype(get_step(src,SOUTHWEST),/turf/simulated/floor))
				var/turf/simulated/floor/FF = get_step(src,SOUTHWEST)
				if(istype(FF, /turf/simulated/floor/bluecarpet))
					diagonalconnect |= 8

		icon_state = "bluecarpet[connectdir]-[diagonalconnect]"