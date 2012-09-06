//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

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

/proc/get_area_name(N) //get area by its name
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

/proc/in_range(source, user)
	if(get_dist(source, user) <= 1)
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

// Like view but bypasses luminosity check
/proc/hear(var/range, var/atom/source)

	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard

//var/debug_mob = 0

// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
// being unable to hear people due to being in a box within a bag.

/proc/recursive_mob_check(var/atom/O,  var/list/L = list(), var/client_check = 1, var/sight_check = 1, var/include_radio = 1, var/max_depth = 3)

	//debug_mob += O.contents.len
	if(max_depth < 1)
		return L

	for(var/atom/A in O)
		if(ismob(A))
			var/mob/M = A
			if(client_check && !M.client)
				L = recursive_mob_check(A, L, 1, 1, max_depth - 1)
				continue
			if(sight_check && !isInSight(A, O))
				continue
			L += M

		else if(include_radio && istype(A, /obj/item/device/radio))
			if(sight_check && isInSight(A, O))
				L += A
		L = recursive_mob_check(A, L, 1, 1, max_depth - 1)
	return L

// The old system would loop through lists for a total of 5000 per function call, in an empty server.
// This new system will loop at around 1000 in an empty server.

/proc/get_mobs_in_view(var/R, var/atom/source)
	// Returns a list of mobs in range of R from source. Used in radio and say code.

	var/turf/T = get_turf(source)
	if(!istype(T))
		return
	var/list/hear = list()
	var/list/range = hear(R, T)

	//debug_mob += range.len
	for(var/turf/A in range)
		hear += recursive_mob_check(A)
	//world.log << "NEW: [debug_mob]"
	//debug_mob = 0

	return hear

#define SIGN(X) ((X<0)?-1:1)

proc
	inLineOfSight(X1,Y1,X2,Y2,Z=1,PX1=16.5,PY1=16.5,PX2=16.5,PY2=16.5)
		var/turf/T
		if(X1==X2)
			if(Y1==Y2)
				return 1 //Light cannot be blocked on same tile
			else
				var/s = SIGN(Y2-Y1)
				Y1+=s
				while(Y1!=Y2)
					T=locate(X1,Y1,Z)
					if(T.opacity)
						return 0
					Y1+=s
		else
			var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
			var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
			var/signX = SIGN(X2-X1)
			var/signY = SIGN(Y2-Y1)
			if(X1<X2)
				b+=m
			while(X1!=X2 || Y1!=Y2)
				if(round(m*X1+b-Y1))
					Y1+=signY //Line exits tile vertically
				else
					X1+=signX //Line exits tile horizontally
				T=locate(X1,Y1,Z)
				if(T.opacity)
					return 0
		return 1

proc/isInSight(var/atom/A, var/atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return 0

	if(inLineOfSight(Aturf.x,Aturf.y, Bturf.x,Bturf.y,Aturf.z))
		return 1

	else
		return 0


proc/doafterattack(obj/target , obj/source)

	if (istype(target, /obj/item/weapon/storage/ ))
		return 0

	else if (locate (/obj/structure/table, source.loc))
		return 0

	else if (!istype(target.loc, /turf/))
		return 0

	else
		return 1

proc/check_can_reach(atom/user, atom/target)
	if(!in_range(user,target))
		return 0
	return CanReachThrough(get_turf(user), get_turf(target), target)

//cael - not sure if there's an equivalent proc, but if there is i couldn't find it
//searches to see if M contains O somewhere
proc/is_carrying(var/M as mob, var/O as obj)
	while(!istype(O,/area))
		if(O:loc == M)
			return 1
		O = O:loc
	return 0

	//hackcopy from a ZAS function, first created for use with intertial_damper/new shielding
proc/CircleFloodFill(turf/start, var/radius = 3)
	if(!istype(start))
		return list()
	var
		list
			open = list(start)
			closed = list()
			possibles = circlerange(start,radius)

	while(open.len)
		for(var/turf/T in open)
			//Stop if there's a door, even if it's open. These are handled by indirect connection.
			if(!T.HasDoor())

				for(var/d in cardinal)
					var/turf/O = get_step(T,d)
					//Simple pass check.
					if(O.ZCanPass(T, 1) && !(O in open) && !(O in closed) && O in possibles)
						open += O

			open -= T
			closed += T

	return closed

//floods in a square area, flowing around any shielding but including all other turf types
//created initially for explosion / shield interaction
proc/ExplosionFloodFill(turf/start, var/radius = 3)
	if(!istype(start))
		return list()
	var
		list
			open = list(start)
			closed = list()
			possibles = range(start,radius)

	while(open.len)
		for(var/turf/T in open)
			for(var/turf/O in range(T,1))
				if( !(O in possibles) || O in open || O in closed )
					continue
				var/shield_here = 0
				for(var/obj/effect/energy_field/E in O)
					if(E.density)
						shield_here = 1
						break
				if(!shield_here)
					open += O

			open -= T
			closed += T

	return closed

/*

/obj/machinery/shield_gen/external/get_shielded_turfs()
	var
		list
			open = list(get_turf(src))
			closed = list()

	while(open.len)
		for(var/turf/T in open)
			for(var/turf/O in orange(1, T))
				if(get_dist(O,src) > field_radius)
					continue
				var/add_this_turf = 0
				if(istype(O,/turf/space))
					for(var/turf/simulated/G in orange(1, O))
						add_this_turf = 1
						break
					for(var/obj/structure/S in orange(1, O))
						add_this_turf = 1
						break
					for(var/obj/structure/S in O)
						add_this_turf = 0
						break

					if(add_this_turf && !(O in open) && !(O in closed))
						open += O
			open -= T
			closed += T

	return closed
*/

//floods in a circular area, flowing around any shielding but including all other turf types
//created initially for explosion / shield interaction
proc/ExplosionCircleFloodFill(turf/start, var/radius = 3)
	if(!istype(start))
		return list()
	var
		list
			open = list(start)
			closed = list()
			possibles = circlerange(start,radius)

	while(open.len)
		for(var/turf/T in open)
			for(var/turf/O in range(T,1))
				if(get_dist(O,start) > radius)
					continue

				if( !(O in possibles) || O in open || O in closed )
					continue
				var/shield_here = 0
				for(var/obj/effect/energy_field/E in O)
					if(E.density)
						shield_here = 1
						break
				if(!shield_here && (O in possibles) && !(O in open) && !(O in closed))
					open += O

			open -= T
			closed += T

	return closed