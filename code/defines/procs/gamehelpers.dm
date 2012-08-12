//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

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

/proc/in_range(source, user)
	if(get_dist(source, user) <= 1)
		return 1

	return 0 //not in range and not telekinetic


//Magic constants obtained by using linear regression on right-angled triangles of sides 0<x<1, 0<y<1
//They should approximate pythagoras theorem well enough for our needs.
//In fact, less accuracy is kinda better for explosions anyway :P Maybe k1=1, k2=0.5?
#define k1 0.934
#define k2 0.427
/proc/approx_dist(center=usr, T) // T is just the second atom to check distance to center with
	var/turf/centerturf = get_turf(center)
	var/turf/targetturf = get_turf(T)

	var/a = abs(targetturf.x - centerturf.x)	//sides of right-angled triangle
	var/b = abs(targetturf.y - centerturf.y)

	if(a>=b)
		return (k1*a) + (k2*b)	//No sqrt or powers :)
	else
		return (k1*b) + (k2*a)
#undef k1
#undef k2

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
	var/list/atoms = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/A in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			atoms += A

	//turfs += centerturf
	return atoms

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

/proc/circleviewturfs(center=usr,radius=3)		//Is there even a diffrence between this proc and circlerangeturfs()?

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs



//var/debug_mob = 0

// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
// being unable to hear people due to being in a box within a bag.

/proc/recursive_mob_check(var/atom/O,  var/list/L = list(), var/client_check = 1, var/sight_check = 1, var/include_radio = 1)

	//debug_mob += O.contents.len
	for(var/A as mob|obj in O)
		if(ismob(A))
			var/mob/M = A
			if(client_check && !M.client)
				L = recursive_mob_check(A, L)
				continue
			if(sight_check && !isInSight(A, O))
				continue
			L += M

		else if(include_radio && istype(A, /obj/item/device/radio))
			if(sight_check && isInSight(A, O))
				L += A
		L = recursive_mob_check(A, L)
	return L

// The old system would loop through lists for a total of 5000 per function call, in an empty server.
// This new system will loop at around 1000 in an empty server.

/proc/get_mobs_in_view(var/R, var/atom/source)
	// Returns a list of mobs in range of R from source. Used in radio and say code.

	var/turf/T = get_turf(source)
	var/list/hear = list()
	var/list/range = range(R, T)

	//debug_mob += range.len
	for(var/A as mob|obj in range)
		if(ismob(A))
			var/mob/M = A
			if(M.client && isInSight(M, source))
				hear += M
		else if(istype(A, /obj/item/device/radio))
			if(isInSight(A, source))
				hear += A
		hear += recursive_mob_check(A)
	//world.log << "NEW: [debug_mob]"
	//debug_mob = 0

	return hear


/proc/get_mobs_in_radio_ranges(var/list/obj/item/device/radio/radios, var/level = 0)
	. = list()

	// Returns a list of mobs who can hear any of the radios given in @radios
	var/list/speaker_coverage = list()
	for(var/obj/item/device/radio/R in radios)
		var/turf/speaker = get_turf(R)
		if(speaker)
			for(var/turf/T in view(R.canhear_range,speaker))
				speaker_coverage += T

	// Try to find all the players who can hear the message
	for(var/mob/M in player_list)
		var/turf/ear = get_turf(M)
		if(ear && (isnull(level) || level == ear.z))
			if(ear in speaker_coverage)
				. += M

	return .

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
#undef SIGN

proc/isInSight(var/atom/A, var/atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return 0

	if(inLineOfSight(Aturf.x,Aturf.y, Bturf.x,Bturf.y,Aturf.z))
		return 1

	else
		return 0