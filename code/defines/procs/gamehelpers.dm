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

/proc/in_range(source, user)
	if(get_dist(source, user) <= 1)
		return 1
	else//TK TODO: remove this
		if(istype(user, /mob/living/carbon))
			if(user:mutations & PORTALS && get_dist(source, user) <= 7)
				if(user:equipped())	return 0
				var/X = source:x
				var/Y = source:y
				var/Z = source:z
				spawn(0)
					//I really shouldnt put this here but i dont have a better idea
					var/obj/effect/overlay/O = new /obj/effect/overlay ( locate(X,Y,Z) )
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