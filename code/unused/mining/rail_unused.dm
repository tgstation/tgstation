/**********************Rail track**************************/

/obj/machinery/rail_track
	name = "Rail track"
	icon = 'icons/obj/mining.dmi'
	icon_state = "rail"
	dir = 2
	var/id = null    //this is needed for switches to work Set to the same on the whole length of the track
	anchored = 1

/**********************Rail intersection**************************/

/obj/machinery/rail_track/intersections
	name = "Rail track intersection"
	icon_state = "rail_intersection"

/obj/machinery/rail_track/intersections/attack_hand(user as mob)
	switch (dir)
		if (1) dir = 5
		if (5) dir = 4
		if (4) dir = 9
		if (9) dir = 2
		if (2) dir = 10
		if (10) dir = 8
		if (8) dir = 6
		if (6) dir = 1
	return

/obj/machinery/rail_track/intersections/NSE
	name = "Rail track T intersection"
	icon_state = "rail_intersection_NSE"
	dir = 2

/obj/machinery/rail_track/intersections/NSE/attack_hand(user as mob)
	switch (dir)
		if (1) dir = 5
		if (2) dir = 5
		if (5) dir = 9
		if (9) dir = 2
	return

/obj/machinery/rail_track/intersections/SEW
	name = "Rail track T intersection"
	icon_state = "rail_intersection_SEW"
	dir = 8

/obj/machinery/rail_track/intersections/SEW/attack_hand(user as mob)
	switch (dir)
		if (8) dir = 6
		if (4) dir = 6
		if (6) dir = 5
		if (5) dir = 8
	return

/obj/machinery/rail_track/intersections/NSW
	name = "Rail track T intersection"
	icon_state = "rail_intersection_NSW"
	dir = 2

/obj/machinery/rail_track/intersections/NSW/attack_hand(user as mob)
	switch (dir)
		if (1) dir = 10
		if (2) dir = 10
		if (10) dir = 6
		if (6) dir = 2
	return

/obj/machinery/rail_track/intersections/NEW
	name = "Rail track T intersection"
	icon_state = "rail_intersection_NEW"
	dir = 8

/obj/machinery/rail_track/intersections/NEW/attack_hand(user as mob)
	switch (dir)
		if (4) dir = 9
		if (8) dir = 9
		if (9) dir = 10
		if (10) dir = 8
	return

/**********************Rail switch**************************/

/obj/machinery/rail_switch
	name = "Rail switch"
	icon = 'icons/obj/mining.dmi'
	icon_state = "rail"
	dir = 2
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	var/obj/machinery/rail_track/track = null
	var/id            //used for to change the track pieces

/obj/machinery/rail_switch/New()
	spawn(10)
		src.track = locate(/obj/machinery/rail_track, get_step(src, NORTH))
		if(track)
			id = track.id
	return

/obj/machinery/rail_switch/attack_hand(user as mob)
	user << "You switch the rail track's direction"
	for (var/obj/machinery/rail_track/T in world)
		if (T.id == src.id)
			var/obj/machinery/rail_car/C = locate(/obj/machinery/rail_car, T.loc)
			if (C)
				switch (T.dir)
					if(1)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "N"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(2)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "N"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(4)
						switch(C.direction)
							if("N") C.direction = "E"
							if("S") C.direction = "E"
							if("E") C.direction = "W"
							if("W") C.direction = "E"
					if(8)
						switch(C.direction)
							if("N") C.direction = "E"
							if("S") C.direction = "E"
							if("E") C.direction = "W"
							if("W") C.direction = "E"
					if(5)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "E"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(6)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "W"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(9)
						switch(C.direction)
							if("N") C.direction = "E"
							if("S") C.direction = "E"
							if("E") C.direction = "N"
							if("W") C.direction = "E"
					if(10)
						switch(C.direction)
							if("N") C.direction = "W"
							if("S") C.direction = "W"
							if("E") C.direction = "W"
							if("W") C.direction = "N"
	return

/**********************Rail car**************************/

/obj/machinery/rail_car
	name = "Rail car"
	icon = 'icons/obj/storage.dmi'
	icon_state = "miningcar"
	var/direction = "S"  //S = south, N = north, E = east, W = west. Determines whichw ay it'll look first
	var/moving = 0;
	anchored = 1
	density = 1
	var/speed = 0
	var/slowing = 0
	var/atom/movable/load = null //what it's carrying

/obj/machinery/rail_car/attack_hand(user as mob)
	if (moving == 0)
		processing_items.Add(src)
		moving = 1
	else
		processing_items.Remove(src)
		moving = 0
	return

/*
for (var/client/C)
	C << "Dela."
*/

/obj/machinery/rail_car/MouseDrop_T(var/atom/movable/C, mob/user)

	if(user.stat)
		return

	if (!istype(C) || C.anchored || get_dist(user, src) > 1 || get_dist(src,C) > 1 )
		return

	if(ismob(C))
		load(C)


/obj/machinery/rail_car/proc/load(var/atom/movable/C)

	if(get_dist(C, src) > 1)
		return
	//mode = 1

	C.loc = src.loc
	sleep(2)
	C.loc = src
	load = C

	C.pixel_y += 9
	if(C.layer < layer)
		C.layer = layer + 0.1
	overlays += C

	if(ismob(C))
		var/mob/M = C
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src

	//mode = 0
	//send_status()

/obj/machinery/rail_car/proc/unload(var/dirn = 0)
	if(!load)
		return

	overlays = null

	load.loc = src.loc
	load.pixel_y -= 9
	load.layer = initial(load.layer)
	if(ismob(load))
		var/mob/M = load
		if(M.client)
			M.client.perspective = MOB_PERSPECTIVE
			M.client.eye = src


	if(dirn)
		step(load, dirn)

	load = null

	// in case non-load items end up in contents, dump every else too
	// this seems to happen sometimes due to race conditions
	// with items dropping as mobs are loaded

	for(var/atom/movable/AM in src)
		AM.loc = src.loc
		AM.layer = initial(AM.layer)
		AM.pixel_y = initial(AM.pixel_y)
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)
				M.client.perspective = MOB_PERSPECTIVE
				M.client.eye = src

/obj/machinery/rail_car/relaymove(var/mob/user)
	if(user.stat)
		return
	if(load == user)
		unload(0)
	return

/obj/machinery/rail_car/process()
	if (moving == 1)
		if (slowing == 1)
			if (speed > 0)
				speed--;
				if (speed == 0)
					slowing = 0
		else
			if (speed < 10)
				speed++;
		var/i = 0
		for (i = 0; i < speed; i++)
			if (moving == 1)
				switch (direction)
					if ("S")
						for (var/obj/machinery/rail_track/R in locate(src.x,src.y-1,src.z))
							if (R.dir == 10)
								direction = "W"
							if (R.dir == 9)
								direction = "E"
							if (R.dir == 2 || R.dir == 1 || R.dir == 10 || R.dir == 9)
								for (var/mob/living/M in locate(src.x,src.y-1,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
					if ("N")
						for (var/obj/machinery/rail_track/R in locate(src.x,src.y+1,src.z))
							if (R.dir == 5)
								direction = "E"
							if (R.dir == 6)
								direction = "W"
							if (R.dir == 5 || R.dir == 1 || R.dir == 6 || R.dir == 2)
								for (var/mob/living/M in locate(src.x,src.y+1,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
					if ("E")
						for (var/obj/machinery/rail_track/R in locate(src.x+1,src.y,src.z))
							if (R.dir == 6)
								direction = "S"
							if (R.dir == 10)
								direction = "N"
							if (R.dir == 4 || R.dir == 8 || R.dir == 10 || R.dir == 6)
								for (var/mob/living/M in locate(src.x+1,src.y,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
					if ("W")
						for (var/obj/machinery/rail_track/R in locate(src.x-1,src.y,src.z))
							if (R.dir == 9)
								direction = "N"
							if (R.dir == 5)
								direction = "S"
							if (R.dir == 8 || R.dir == 9 || R.dir == 5 || R.dir == 4)
								for (var/mob/living/M in locate(src.x-1,src.y,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
				sleep(1)
	else
		processing_items.Remove(src)
		moving = 0
	return