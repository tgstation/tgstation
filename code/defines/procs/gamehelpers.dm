/proc/dopage(src,target)
	var/href_list
	var/href
	href_list = params2list("src=\ref[src]&[target]=1")
	href = "src=\ref[src];[target]=1"
	src:temphtml = null
	src:Topic(href, href_list)
	return null

/proc/get_area(O)
	var/atom/location = O
	var/i
	for(i=1, i<=20, i++)
		if(isarea(location))
			return location
		else if (istype(location))
			location = location.loc
		else
			return null
	return 0

/proc/get_area_name(N) //get area by it's name
	for(var/area/A in world)
		if(A.name == N)
			return A
	return 0

/proc/get_random_turf(var/atom/A, var/list/L)
	while(L.len > 0)
		var/dir = pick(L)
		L -= dir
		var/turf/T = get_step(A,dir)
		var/possible = 1

		if(T.density == 0)
			for(var/obj/I in T)
				if(I.density == 1)
					possible = 0
					break

			if(possible)
				return T

	return

/proc/in_range(source, user, telepathy=1)
	if(get_dist(source, user) <= 1)
		return 1
	else
		if (istype(user, /mob/living/carbon))
			if (user:mutations & telepathy)
				var/X = source:x
				var/Y = source:y
				var/Z = source:z
				spawn(0)
					//I really shouldnt put this here but i dont have a better idea
					var/obj/effect/overlay/O = new /obj/effect/overlay( locate(X,Y,Z) )
					O.name = "sparkles"
					O.anchored = 1
					O.density = 0
					O.layer = FLY_LAYER
					O.dir = pick(cardinal)
					O.icon = 'effects.dmi'
					O.icon_state = "nothing"
					flick("empdisable",O)
					spawn(5)
						del(O)


				return 1

	return 0 //not in range and not telekinetic

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs


/proc/get_mobs_in_view(var/R, var/atom/source)
	// Returns a list of mobs in range of R from source. Used in radio and say code.

	var/turf/T = get_turf(source)
	var/list/hear = hearers(R, T)
	var/list/V = view(R, T)

	// Search for closets:
	for(var/obj/structure/closet/C in V)
		for(var/mob/M in C.contents)
			if(M.client)
				hear += M

	// Cryos:
	for(var/obj/machinery/atmospherics/unary/cryo_cell/C in V)
		if(C.occupant)
			if(C.occupant.client)
				hear += C.occupant

	// Intelicards
	for(var/obj/item/device/aicard/C in V)
		for(var/mob/living/silicon/ai/M in C)
			if(M.client)
				hear += M

	// Brains/MMIs/pAIs
	for(var/mob/living/carbon/brain/C in world)
		if(get_turf(C) in V)
			hear += C
	for(var/mob/living/silicon/pai/C in world)
		if(get_turf(C) in V)
			hear += C

	// Personal AIs
	for(var/obj/item/device/paicard/C in V)
		if(C.pai)
			if(C.pai.client)
				hear += C.pai

	// Exosuits
	for(var/obj/mecha/C in V)
		if(C.occupant)
			if(C.occupant.client)
				hear += C.occupant

	// Disposal Machines
	for(var/obj/machinery/disposal/C in V)
		for(var/mob/M in C.contents)
			if(M.client)
				hear += M

	return hear

/proc/get_dist_euclidian(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	var/dist = sqrt(dx**2 + dy**2)

	return dist

/proc/circlerangeturfs(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/proc/circleviewturfs(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

proc/check_can_reach(atom/user, atom/target)
	var/direct = get_dir(user, target)
	var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( user.loc )
	var/ok = 0
	if ( (direct - 1) & direct)

		// ------- CLICKED OBJECT IS LOCATED IN A DIAGONAL POSITION FROM THE PERSON -------

		var/turf/Step_1
		var/turf/Step_2
		switch(direct)
			if(5.0)
				Step_1 = get_step(user, NORTH)
				Step_2 = get_step(user, EAST)

			if(6.0)
				Step_1 = get_step(user, SOUTH)
				Step_2 = get_step(user, EAST)

			if(9.0)
				Step_1 = get_step(user, NORTH)
				Step_2 = get_step(user, WEST)

			if(10.0)
				Step_1 = get_step(user, SOUTH)
				Step_2 = get_step(user, WEST)

			else
		if(Step_1 && Step_2)

			// ------- BOTH CARDINAL DIRECTIONS OF THE DIAGONAL EXIST IN THE GAME WORLD -------

			var/check_1 = 0
			var/check_2 = 0
			if(step_to(D, Step_1))
				check_1 = 1
				for(var/obj/border_obstacle in Step_1)
					if(border_obstacle.flags & ON_BORDER)
						if(!border_obstacle.CheckExit(D, target))
							check_1 = 0
							// ------- YOU TRIED TO CLICK ON AN ITEM THROUGH A WINDOW (OR SIMILAR THING THAT LIMITS ON BORDERS) ON ONE OF THE DIRECITON TILES -------
				for(var/obj/border_obstacle in get_turf(target))
					if((border_obstacle.flags & ON_BORDER) && (target != border_obstacle))
						if(!border_obstacle.CanPass(D, D.loc, 1, 0))
							// ------- YOU TRIED TO CLICK ON AN ITEM THROUGH A WINDOW (OR SIMILAR THING THAT LIMITS ON BORDERS) ON THE TILE YOU'RE ON -------
							check_1 = 0

			D.loc = user.loc
			if(step_to(D, Step_2))
				check_2 = 1

				for(var/obj/border_obstacle in Step_2)
					if(border_obstacle.flags & ON_BORDER)
						if(!border_obstacle.CheckExit(D, target))
							check_2 = 0
				for(var/obj/border_obstacle in get_turf(target))
					if((border_obstacle.flags & ON_BORDER) && (target != border_obstacle))
						if(!border_obstacle.CanPass(D, D.loc, 1, 0))
							check_2 = 0


			if(check_1 || check_2)
				ok = 1
				// ------- YOU CAN REACH THE ITEM THROUGH AT LEAST ONE OF THE TWO DIRECTIONS. GOOD. -------

			/*
				More info:
					If you're trying to click an item in the north-east of your mob, the above section of code will first check if tehre's a tile to the north or you and to the east of you
					These two tiles are Step_1 and Step_2. After this, a new dummy object is created on your location. It then tries to move to Step_1, If it succeeds, objects on the turf you're on and
					the turf that Step_1 is are checked for items which have the ON_BORDER flag set. These are itmes which limit you on only one tile border. Windows, for the most part.
					CheckExit() and CanPass() are use to determine this. The dummy object is then moved back to your location and it tries to move to Step_2. Same checks are performed here.
					If at least one of the two checks succeeds, it means you can reach the item and ok is set to 1.
			*/
	else
		// ------- OBJECT IS ON A CARDINAL TILE (NORTH, SOUTH, EAST OR WEST OR THE TILE YOU'RE ON) -------
		if(target.loc == user.loc)
			ok = 1
			// ------- OBJECT IS ON THE SAME TILE AS YOU -------
		else
			ok = 1

			//Now, check objects to block exit that are on the border
			for(var/obj/border_obstacle in user.loc)
				if(border_obstacle.flags & ON_BORDER)
					if(!border_obstacle.CheckExit(D, target))
						ok = 0

			//Next, check objects to block entry that are on the border
			for(var/obj/border_obstacle in get_turf(target))
				if((border_obstacle.flags & ON_BORDER) && (target != border_obstacle))
					if(!border_obstacle.CanPass(D, D.loc, 1, 0))
						ok = 0
		/*
			See the previous More info, for... more info...
		*/

	if(get_dist(user, target) > 1)
		return 0

	del(D)
	// ------- DUMMY OBJECT'S SERVED IT'S PURPOSE, IT'S REWARDED WITH A SWIFT DELETE -------
	return ok

//cael - not sure if there's an equivalent proc, but if there is i couldn't find it
//searches to see if M contains O somewhere
proc/is_carrying(var/M as mob, var/O as obj)
	while(!istype(O,/area))
		if(O:loc == M)
			return 1
		O = O:loc
	return 0