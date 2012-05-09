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
	else
		if (istype(user, /mob/living/carbon))
			if (usr.tkdisable != 0) //Remote Viewing + TK = oh god wat
				user << "\red Your mind is too strained right now!"
				return 0
			if (user:mutations & TK)
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


/proc/get_mobs_in_view(var/R, var/atom/source)
	// Returns a list of mobs in range of R from source. Used in radio and say code.

	var/turf/T = get_turf(source)
	var/list/hear = hearers(R, T)
	var/list/V = range(R, T)

	// Search for closets:
	for(var/obj/structure/closet/C in V)
		for(var/mob/M in C.contents)
			if(isInSight(source,C))
				if(M.client)
					hear += M

	// Cryos:
	for(var/obj/machinery/atmospherics/unary/cryo_cell/C in V)
		if(C.occupant)
			if(isInSight(source,C))
				if(C.occupant.client)
					hear += C.occupant

	// Intelicards
	for(var/obj/item/device/aicard/C in V)
		for(var/mob/living/silicon/ai/M in C)
			if(isInSight(source,C))
				if(M.client)
					hear += M

	// Kind of a hacky fix, but should fix most cases without undo issues.
	for(var/mob/M as mob in V)
		for(var/obj/item/device/aicard/C in M.contents)
			for(var/mob/living/silicon/ai/A in C)
				if(isInSight(source,A))
					if(A.client)
						hear += A

	// Soulstones
	for(var/obj/item/device/soulstone/C in V)
		for(var/mob/living/simple_animal/shade/M in C)
			if(isInSight(source,C))
				if(M.client)
					hear += M

	// Kind of a hacky fix, but should fix most cases without undo issues.
	for(var/mob/M as mob in V)
		for(var/obj/item/device/soulstone/C in M.contents)
			for(var/mob/living/simple_animal/shade/A in C)
				if(isInSight(source,A))
					if(A.client)
						hear += A



	// Brains/MMIs/pAIs
	for(var/mob/living/carbon/brain/C in world)
		if(get_turf(C) in V)
			if(isInSight(source,C))
				hear += C
	for(var/mob/living/silicon/pai/C in world)
		if(get_turf(C) in V)
			if(isInSight(source,C))
				hear += C

/*   -- Handled above.  WHY IS THIS HERE?  WHYYYYYYY
	// Personal AIs
	for(var/obj/item/device/paicard/C in V)
		if(C.pai)
			if(isInSight(source,C))
				if(C.pai.client)
					hear += C.pai
*/
	// Exosuits
	for(var/obj/mecha/C in V)
		if(C.occupant)
			if(isInSight(source,C))
				if(C.occupant.client)
					hear += C.occupant

	// Disposal Machines
	for(var/obj/machinery/disposal/C in V)
		for(var/mob/M in C.contents)
			if(isInSight(source,C))
				if(M.client)
					hear += M

	//Borg rechargers
	for(var/obj/machinery/recharge_station/C in V)
		if(C.occupant)
			if(isInSight(source,C))
				if(C.occupant.client)
					hear += C.occupant

	for(var/obj/item/device/radio/theradio in V)
		if(isInSight(source,theradio))
			hear += theradio



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
			var
				m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
				b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
				signX = SIGN(X2-X1)
				signY = SIGN(Y2-Y1)
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