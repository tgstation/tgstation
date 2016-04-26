/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/floor/ex_act(severity)
	switch(severity)
		if(1.0)
			new/obj/effect/decal/cleanable/soot(src)
		if(2.0)
			if(prob(65))
				new/obj/effect/decal/cleanable/soot(src)
		if(3.0)
			if(prob(20))
				new/obj/effect/decal/cleanable/soot(src)
			return
	return

/turf/unsimulated/floor/attack_paw(user as mob)
	return src.attack_hand(user)

/turf/unsimulated/floor/cultify()
	if((icon_state != "cult")&&(icon_state != "cult-narsie"))
		name = "engraved floor"
		icon_state = "cult"
		turf_animation('icons/effects/effects.dmi',"cultfloor",0,0,MOB_LAYER-1)
	return

/turf/unsimulated/floor/grass
	icon_state = "grass1"

/turf/unsimulated/floor/grass/New()
	..()
	icon_state = "grass[rand(1,4)]"

/turf/unsimulated/floor/snow
	..()
	temperature = 233.15 // -40C in K
	oxygen = MOLES_O2STANDARD*1.25 // 100kpa
	nitrogen = MOLES_N2STANDARD*1.25 // 100kpa
	name = "snow"
	icon = 'icons/turf/newsnow.dmi'
	icon_state = "snow0"
	var/snowballs = 0
	var/global/list/snowlayers = list()
	var/global/list/dirtlayers = list()
	light_color = "#e5ffff"
	can_border_transition = 1
	dynamic_lighting = 0
	luminosity = 1

/turf/unsimulated/floor/snow/New()
	..()
	icon_state = "snow[rand(0,6)]"
	relativewall_neighbours()
	snowballs = rand(30,50)
	src.update_icon()
	if(prob(5) && !(src.contents.len))
		new/obj/structure/flora/tree/pine(src)

/turf/unsimulated/floor/snow/relativewall_neighbours()
	for(var/direction in alldirs)
		var/turf/adj_tile = get_step(src, direction)
		if(istype(adj_tile,/turf/unsimulated/floor/snow))
			adj_tile.update_icon()

/turf/unsimulated/floor/snow/undersnow/New()
	..()
	snowballs = 0

/turf/unsimulated/floor/snow/undersnow/update_icon()
	..()
	var/junction = findSmoothingNeighbors()
	var/dircount = 0
	for(var/direction in diagonal)
		if (istype(get_step(src, direction),/turf/unsimulated/floor/snow/undersnow))
			if((direction & junction) == direction)
				overlays += dirtlayers["diag[direction]"]
				dircount += 1
	if(dircount == 4)
		overlays.Cut()
		icon_state = "snowpath-Full"
		overlays += snowlayers["1"]
		overlays += snowlayers["2"]
	else if(junction)
		overlays += dirtlayers["snow[junction]"]
	else overlays += dirtlayers["snow0"]


/turf/unsimulated/floor/snow/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(snowballs >= 0)
		if(istype(W,/obj/item/weapon/pickaxe/shovel))
			user.delayNextAttack(15)
			if(do_after(user,src,25))
				for(var/i = 0; i < min(snowballs,10), i++)
					var/obj/item/stack/sheet/snow/snowball = new /obj/item/stack/sheet/snow(user.loc)
					snowball.pixel_x = rand(-16,16)
					snowball.pixel_y = rand(-16,16)
				snowballs = min(snowballs-10,0)
			if(snowballs <= 0)
				src.ChangeTurf(/turf/unsimulated/floor/snow/undersnow)

/turf/unsimulated/floor/snow/undersnow/canBuildCatwalk()
	return BUILD_FAILURE

/turf/unsimulated/floor/snow/undersnow/canBuildLattice()
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/snow/undersnow/canBuildPlating()
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/snow/attack_hand(mob/user as mob)
	if(snowballs > 0)
		user.delayNextAttack(15)
		if(do_after(user,src,15))
			snowballs -= 1
			var/obj/item/stack/sheet/snow/snowball = new /obj/item/stack/sheet/snow
			user.put_in_hands(snowball)
			if(snowballs <= 0)
				src.ChangeTurf(/turf/unsimulated/floor/snow/undersnow)
				src.relativewall_neighbours()
	..()

/turf/unsimulated/floor/snow/Entered(mob/user)
	..()
	if(istype(user,/mob/living/carbon)&&!(user.stat))
		var/list/snowsound = list('sound/misc/snow1.ogg','sound/misc/snow2.ogg','sound/misc/snow3.ogg','sound/misc/snow4.ogg','sound/misc/snow5.ogg','sound/misc/snow6.ogg')
		playsound(get_turf(src), pick(snowsound), 10, 1, -1,channel = 123)

/turf/unsimulated/floor/snow/update_icon()
	if (overlays.len > 2)
		overlays.Cut()
	if(!(snowlayers.len))
		snowlayers["1"] = image('icons/turf/snowfx.dmi',"snowlayer1",17)
		snowlayers["2"] = image('icons/turf/snowfx.dmi',"snowlayer2",17)
	if(!(dirtlayers.len))
		for(var/dirtdir in alldirs)
			dirtlayers["side[dirtdir]"] = image('icons/turf/newsnow.dmi',"snowpath-Side",dir = dirtdir)
		for(var/diagdir in diagonal)
			dirtlayers["diag[diagdir]"] = image('icons/turf/newsnow.dmi',"dirtquarter",dir = diagdir,layer=2.1)
			dirtlayers["snow[diagdir]"] = image('icons/turf/newsnow.dmi',"snowpath",dir = diagdir)
		for(var/dirtdir in cardinal)
			dirtlayers["snow[dirtdir]"] = image('icons/turf/newsnow.dmi',"snowpath-half",dir = dirtdir)
			var/realdir = null
			switch(dirtdir)
				if(NORTH)
					realdir = EAST|SOUTH|WEST
				if(SOUTH)
					realdir = WEST|NORTH|EAST
				if(EAST)
					realdir = SOUTH|WEST|NORTH
				if(WEST)
					realdir = NORTH|EAST|SOUTH
			dirtlayers["snow[realdir]"] = image('icons/turf/newsnow.dmi',"snowpath-TJunction",dir = dirtdir)
		dirtlayers["snow15"] = image('icons/turf/newsnow.dmi',"snowpath-Crossroads")
		dirtlayers["snow0"] = image('icons/turf/newsnow.dmi',"snowpath-circle")
		dirtlayers["snow3"] = image('icons/turf/newsnow.dmi',"snowpath",dir = 1)
		dirtlayers["snow12"] = image('icons/turf/newsnow.dmi',"snowpath",dir = 8)
	var/lightson = 0
	for(var/direction in alldirs)
		if(!istype(get_step(src, direction),/turf/unsimulated/floor/snow))
			if(istype(get_step(src, direction),/turf/simulated/floor))
				lightson = 1
		//	var/turf/tilebehind = get_step(tile, tile_dir)
		//	if(tilebehind.temperature > 273.15)
			src.overlays += dirtlayers["side[direction]"]
			var/image/snow1 = snowlayers["1"]
			var/image/snow2 = snowlayers["2"]
			snow1.alpha = 255
			snow2.alpha = 255
			switch(direction)
				if(1)
					snow1.pixel_y = 32
					overlays += snow1
					snow2.pixel_y = 32
					overlays += snow2
				if(2)
					snow1.pixel_y = -32
					overlays += snow1
					snow2.pixel_y = -32
					overlays += snow2
				if(4)
					snow1.pixel_x = 32
					overlays += snow1
					snow2.pixel_x = 32
					overlays += snow2
				if(8)
					snow1.pixel_x = -32
					overlays += snow1
					snow2.pixel_x = -32
					overlays += snow2
			snow1.alpha = 64
			snow2.alpha = 64
			snow1.pixel_x = 0
			snow2.pixel_x = 0
			snow1.pixel_y = 0
			snow2.pixel_y = 0
	if(lightson)
		set_light(5, 0.5)
	else
		set_light(0,0)
	overlays += snowlayers["1"]
	overlays += snowlayers["2"]

/turf/unsimulated/floor/snow/undersnow
	..()
	name = "dirt"
	canSmoothWith = "/turf/unsimulated/floor/snow/undersnow"