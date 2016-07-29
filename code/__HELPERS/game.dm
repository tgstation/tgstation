<<<<<<< HEAD
//supposedly the fastest way to do this according to https://gist.github.com/Giacom/be635398926bb463b42a
#define RANGE_TURFS(RADIUS, CENTER) \
  block( \
    locate(max(CENTER.x-(RADIUS),1),          max(CENTER.y-(RADIUS),1),          CENTER.z), \
    locate(min(CENTER.x+(RADIUS),world.maxx), min(CENTER.y+(RADIUS),world.maxy), CENTER.z) \
  )

#define Z_TURFS(ZLEVEL) block(locate(1,1,ZLEVEL), locate(world.maxx, world.maxy, ZLEVEL))

/proc/get_area(atom/A)
	if (!istype(A))
		return
	for(A, A && !isarea(A), A=A.loc); //semicolon is for the empty statement
	return A

/proc/get_area_name(atom/X)
	var/area/Y = get_area(X)
	return Y.name

/proc/get_area_master(O)
	var/area/A = get_area(O)
	if(A && A.master)
		A = A.master
	return A

/proc/get_area_by_name(N) //get area by its name
	for(var/area/A in world)
		if(A.name == N)
			return A
	return 0

/proc/get_areas_in_range(dist=0, atom/center=usr)
	if(!dist)
		var/turf/T = get_turf(center)
		return T ? list(T.loc) : list()
	if(!center)
		return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	var/list/areas = list()
	for(var/V in turfs)
		var/turf/T = V
		areas |= T.loc
	return areas

// Like view but bypasses luminosity check

/proc/get_hear(range, atom/source)

	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard

/proc/alone_in_area(area/the_area, mob/must_be_alone, check_type = /mob/living/carbon)
	var/area/our_area = get_area_master(the_area)
	for(var/C in living_mob_list)
		if(!istype(C, check_type))
			continue
		if(C == must_be_alone)
			continue
		if(our_area == get_area_master(C))
			return 0
	return 1

//We used to use linear regression to approximate the answer, but Mloc realized this was actually faster.
//And lo and behold, it is, and it's more accurate to boot.
/proc/cheap_hypotenuse(Ax,Ay,Bx,By)
	return sqrt(abs(Ax - Bx)**2 + abs(Ay - By)**2) //A squared + B squared = C squared

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


//This is the new version of recursive_mob_check, used for say().
//The other proc was left intact because morgue trays use it.
//Sped this up again for real this time
/proc/recursive_hear_check(O)
	var/list/processing_list = list(O)
	. = list()
	while(processing_list.len)
		var/atom/A = processing_list[1]
		if(A.flags & HEAR)
			. += A
		processing_list.Cut(1, 2)
		processing_list += A.contents

// Better recursive loop, technically sort of not actually recursive cause that shit is retarded, enjoy.
//No need for a recursive limit either
/proc/recursive_mob_check(atom/O,client_check=1,sight_check=1,include_radio=1)

	var/list/processing_list = list(O)
	var/list/processed_list = list()
	var/list/found_mobs = list()

	while(processing_list.len)

		var/atom/A = processing_list[1]
		var/passed = 0

		if(ismob(A))
			var/mob/A_tmp = A
			passed=1

			if(client_check && !A_tmp.client)
				passed=0

			if(sight_check && !isInSight(A_tmp, O))
				passed=0

		else if(include_radio && istype(A, /obj/item/device/radio))
			passed=1

			if(sight_check && !isInSight(A, O))
				passed=0

		if(passed)
			found_mobs |= A

		for(var/atom/B in A)
			if(!processed_list[B])
				processing_list |= B

		processing_list.Cut(1, 2)
		processed_list[A] = A

	return found_mobs


/proc/get_hearers_in_view(R, atom/source)
	// Returns a list of hearers in view(R) from source (ignoring luminosity). Used in saycode.
	var/turf/T = get_turf(source)
	var/list/hear = list()

	if(!T)
		return hear

	var/list/range = get_hear(R, T)
	for(var/atom/movable/A in range)
		hear |= recursive_hear_check(A)

	return hear


/proc/get_mobs_in_radio_ranges(list/obj/item/device/radio/radios)

	set background = BACKGROUND_ENABLED

	. = list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	for(var/obj/item/device/radio/R in radios)
		if(R)
			. |= get_hearers_in_view(R.canhear_range, R)


#define SIGN(X) ((X<0)?-1:1)

/proc/inLineOfSight(X1,Y1,X2,Y2,Z=1,PX1=16.5,PY1=16.5,PX2=16.5,PY2=16.5)
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


/proc/isInSight(atom/A, atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return 0

	if(inLineOfSight(Aturf.x,Aturf.y, Bturf.x,Bturf.y,Aturf.z))
		return 1

	else
		return 0


/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/try_move_adjacent(atom/movable/AM)
	var/turf/T = get_turf(AM)
	for(var/direction in cardinal)
		if(AM.Move(get_step(T, direction)))
			break

/proc/get_mob_by_key(key)
	for(var/mob/M in mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null

// Will return a list of active candidates. It increases the buffer 5 times until it finds a candidate which is active within the buffer.

/proc/get_candidates(be_special_type, afk_bracket=3000, var/jobbanType)
	var/list/candidates = list()
	// Keep looping until we find a non-afk candidate within the time bracket (we limit the bracket to 10 minutes (6000))
	while(!candidates.len && afk_bracket < 6000)
		for(var/mob/dead/observer/G in player_list)
			if(G.client != null)
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					if(!G.client.is_afk(afk_bracket) && (be_special_type in G.client.prefs.be_special))
						if (jobbanType)
							if(!(jobban_isbanned(G, jobbanType) || jobban_isbanned(G, "Syndicate")))
								candidates += G.client
						else
							candidates += G.client
		afk_bracket += 600 // Add a minute to the bracket, for every attempt
	return candidates

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))
		O = new /obj/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay=0)
	if(!isobj(O))
		return
	if(!group)
		group = clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O

/proc/flick_overlay(image/I, list/show_to, duration)
	for(var/client/C in show_to)
		C.images += I
	spawn(duration)
		for(var/client/C in show_to)
			C.images -= I

/proc/get_active_player_count(var/alive_check = 0, var/afk_check = 0, var/human_check = 0)
	// Get active players who are playing in the round
	var/active_players = 0
	for(var/i = 1; i <= player_list.len; i++)
		var/mob/M = player_list[i]
		if(M && M.client)
			if(alive_check && M.stat)
				continue
			else if(afk_check && M.client.is_afk())
				continue
			else if(human_check && !istype(M, /mob/living/carbon/human))
				continue
			else if(istype(M, /mob/new_player)) // exclude people in the lobby
				continue
			else if(isobserver(M)) // Ghosts are fine if they were playing once (didn't start as observers)
				var/mob/dead/observer/O = M
				if(O.started_as_observer) // Exclude people who started as observers
					continue
			active_players++
	return active_players

/datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(var/src_x, var/src_y, var/time, var/distance, \
						   var/power_x, var/power_y, var/dest_x, var/dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/proc/projectile_trajectory(src_x, src_y, rotation, angle, power)

	// returns the destination (Vx,y) that a projectile shot at [src_x], [src_y], with an angle of [angle],
	// rotated at [rotation] and with the power of [power]
	// Thanks to VistaPOWA for this function

	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = 2* power_y / 10 //10 = g

	var/distance = time * power_x

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)

/proc/pollCandidates(var/Question, var/jobbanType, var/datum/game_mode/gametypeCheck, var/be_special_flag = 0, var/poll_time = 300)
	var/list/mob/dead/observer/candidates = list()
	var/time_passed = world.time
	if (!Question)
		Question = "Would you like to be a special role?"

	for(var/mob/dead/observer/G in player_list)
		if(!G.key || !G.client)
			continue
		if(be_special_flag)
			if(!(G.client.prefs) || !(be_special_flag in G.client.prefs.be_special))
				continue
		if (gametypeCheck)
			if(!gametypeCheck.age_check(G.client))
				continue
		if (jobbanType)
			if(jobban_isbanned(G, jobbanType) || jobban_isbanned(G, "Syndicate"))
				continue
		spawn(0)
			G << 'sound/misc/notice2.ogg' //Alerting them to their consideration
			switch(askuser(G,Question,"Please answer in [poll_time/10] seconds!","Yes","No", StealFocus=0, Timeout=poll_time))
				if(1)
					G << "<span class='notice'>Choice registered: Yes.</span>"
					if((world.time-time_passed)>poll_time)
						G << "<span class='danger'>Sorry, you were too late for the consideration!</span>"
						G << 'sound/machines/buzz-sigh.ogg'
					else
						candidates += G
				if(2)
					G << "<span class='danger'>Choice registered: No.</span>"
	sleep(poll_time)

	//Check all our candidates, to make sure they didn't log off during the wait period.
	for(var/mob/dead/observer/G in candidates)
		if(!G.key || !G.client)
			candidates.Remove(G)

	return candidates

/proc/makeBody(mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)
		return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	G_found.client.prefs.copy_to(new_character)
	new_character.dna.update_dna_identity()
	new_character.key = G_found.key

	return new_character
=======
/proc/dopage(src,target)
	var/href_list
	var/href
	href_list = params2list("src=\ref[src]&[target]=1")
	href = "src=\ref[src];[target]=1"
	src:temphtml = null
	src:Topic(href, href_list)
	return null

/proc/get_area(const/atom/O)
	if (isnull(O))
		return

	var/atom/A = O

	for (var/i = 0, ++i <= 16)
		if (isarea(A))
			return A

		if (istype(A))
			A = A.loc
		else
			return

/proc/get_area_master(const/O)
	var/area/A = get_area(O)

	if(isarea(A))
		return A

/proc/get_area_name(N) //get area by its name
	for(var/area/A in areas)
		if(A.name == N)
			return A
	return 0

/proc/in_range(atom/source, mob/user)
	if(source.Adjacent(user))
		return 1
	else if(istype(user) && user.mutations && user.mutations.len)
		if((M_TK in user.mutations) && (get_dist(user,source) < tk_maxrange))
			return 1

	return 0 //not in range and not telekinetic

// Like view but bypasses luminosity check
/proc/get_hear(var/range, var/atom/source)


	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard


/proc/alone_in_area(var/area/the_area, var/mob/must_be_alone, var/check_type = /mob/living/carbon)
	var/area/our_area = get_area_master(the_area)
	for(var/C in living_mob_list)
		if(!istype(C, check_type))
			continue
		if(C == must_be_alone)
			continue
		if(our_area == get_area_master(C))
			return 0
	return 1

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
	if(!centerturf)
		to_chat(usr, "cant get a center turf?")
		return
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in range(radius, centerturf))
		if(!T) continue
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

/proc/recursive_type_check(atom/O, type = /atom)
	var/list/processing_list = list(O)
	var/list/processed_list = new/list()
	var/found_atoms = new/list()

	while (processing_list.len)
		var/atom/A = processing_list[1]

		if (istype(A, type))
			found_atoms |= A

		for (var/atom/B in A)
			if (!processed_list[B])
				processing_list |= B

		processing_list.Cut(1, 2)
		processed_list[A] = A

	return found_atoms

//var/debug_mob = 0

/proc/get_contents_in_object(atom/O, type_path = /atom/movable)
	if (O)
		return recursive_type_check(O, type_path) - O
	else
		return new/list()

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

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/try_move_adjacent(atom/movable/AM)
	var/turf/T = get_turf(AM)
	for(var/direction in cardinal)
		if(AM.Move(get_step(T, direction)))
			break

/proc/get_mob_by_key(var/key)
	for(var/mob/M in mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null

//i think this is used soley by verb/give(), cael
proc/check_can_reach(atom/user, atom/target)
	if(!in_range(target,user))
		return 0
	return CanReachThrough(get_turf(user), get_turf(target), target)

//dummy caching, used to speed up reach checks
var/list/DummyCache = list()

/proc/CanReachThrough(turf/srcturf, turf/targetturf, atom/target, var/pass_flags=0)


	var/obj/item/weapon/dummy/D = locate() in DummyCache
	if(!D)
		D = new /obj/item/weapon/dummy( srcturf )
	else
		DummyCache.Remove(D)
		D.loc = srcturf

	D.flags=initial(D.flags)
	D.pass_flags=initial(D.pass_flags)
	if(pass_flags&PASSTABLE)
		D.pass_flags |= PASSTABLE

	if(targetturf.density && targetturf != get_turf(target))
		return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in srcturf)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.Uncross(D, targetturf))
				D.loc = null
				DummyCache.Add(D)
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in targetturf)
		if((border_obstacle.flags & ON_BORDER) && (target != border_obstacle))
			if(!border_obstacle.Cross(D, srcturf, 1, 0))
				D.loc = null
				DummyCache.Add(D)
				return 0

	D.loc = null
	DummyCache.Add(D)
	return 1

// Comment out when done testing shit.
//#define DEBUG_ROLESELECT

#ifdef DEBUG_ROLESELECT
# define roleselect_debug(x) testing(x)
# warning DEBUG_ROLESELECT is defined!
#else
# define roleselect_debug(x)
#endif

// Will return a list of active candidates. It increases the buffer 5 times until it finds a candidate which is active within the buffer.
/proc/get_active_candidates(var/role_id=null, var/buffer=ROLE_SELECT_AFK_BUFFER, var/poll=0)
	var/list/candidates = list() //List of candidate mobs to assume control of the new larva ~fuck you
	var/i = 0
	while(candidates.len <= 0 && i < 5)
		roleselect_debug("get_active_candidates(role_id=[role_id], buffer=[buffer], poll=[poll]): Player list is [player_list.len] items long.")
		for(var/mob/dead/observer/G in player_list)
			if(G.mind && G.mind.current && G.mind.current.stat != DEAD)
				roleselect_debug("get_active_candidates(role_id=[role_id], buffer=[buffer], poll=[poll]): Skipping [G]  - Shitty candidate.")
				continue

			if(!G.client.desires_role(role_id,display_to_user=(poll!=0 && i==0) ? poll : 0)) // Only ask once.
				roleselect_debug("get_active_candidates(role_id=[role_id], buffer=[buffer], poll=[poll]): Skipping [G]  - Doesn't want role.")
				continue

			if(((G.client.inactivity/10)/60) > buffer + i) // the most active players are more likely to become an alien
				roleselect_debug("get_active_candidates(role_id=[role_id], buffer=[buffer], poll=[poll]): Skipping [G]  - Inactive.")
				continue

			roleselect_debug("get_active_candidates(role_id=[role_id], buffer=[buffer], poll=[poll]): Selected [G] as candidate.")
			candidates += G
		i++
	return candidates

/proc/get_candidates(var/role_id=null)
	. = list()
	for(var/mob/dead/observer/G in player_list)
		if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
			if(!G.client.is_afk() && (role_id==null || G.client.desires_role(role_id)))
				. += G.client

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))	O = new /obj/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay=0)
	if(!isobj(O))	return
	if(!group)	group = clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O

/proc/flick_overlay(image/I, list/show_to, duration)
	set waitfor = FALSE
	for(var/client/C in show_to)
		C.images += I
	sleep(duration)
	for(var/client/C in show_to)
		C.images -= I

/proc/get_active_player_count()
	// Get active players who are playing in the round
	var/active_players = 0
	for(var/i = 1; i <= player_list.len; i++)
		var/mob/M = player_list[i]
		if(M && M.client)
			if(istype(M, /mob/new_player)) // exclude people in the lobby
				continue
			else if(isobserver(M)) // Ghosts are fine if they were playing once (didn't start as observers)
				var/mob/dead/observer/O = M
				if(O.started_as_observer) // Exclude people who started as observers
					continue
			active_players++
	return active_players

/datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(var/src_x, var/src_y, var/time, var/distance, \
						   var/power_x, var/power_y, var/dest_x, var/dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/proc/projectile_trajectory(var/src_x, var/src_y, var/rotation, var/angle, var/power)


	// returns the destination (Vx,y) that a projectile shot at [src_x], [src_y], with an angle of [angle],
	// rotated at [rotation] and with the power of [power]
	// Thanks to VistaPOWA for this function

	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = 2* power_y / 10 //10 = g

	var/distance = time * power_x

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)


/proc/mobs_in_area(var/area/the_area, var/client_needed=0, var/moblist=mob_list)
	var/list/mobs_found[0]
	var/area/our_area = get_area_master(the_area)
	for(var/mob/M in moblist)
		if(client_needed && !M.client)
			continue
		if(our_area != get_area_master(M))
			continue
		mobs_found += M
	return mobs_found

/proc/GetRedPart(const/hexa)
	return hex2num(copytext(hexa, 2, 4))

/proc/GetGreenPart(const/hexa)
	return hex2num(copytext(hexa, 4, 6))

/proc/GetBluePart(const/hexa)
	return hex2num(copytext(hexa, 6, 8))

/proc/GetHexColors(const/hexa)
	return list(
		GetRedPart(hexa),
		GetGreenPart(hexa),
		GetBluePart(hexa),
		)

/proc/rgb2hsl(var/red, var/grn, var/blu)

	red /= 255
	grn /= 255
	blu /= 255

	var/lo = min(red, grn, blu)
	var/hi = max(red, grn, blu)
	var/hue = 0
	var/sat = 0
	var/lgh = (lo + hi)/2

	if(lo != hi)
		if(lgh < 0.5)
			sat = (hi - lo) / (hi + lo)
		else
			sat = (hi - lo) / (2 - hi - lo)
		if(red == hi)
			hue = (grn - blu) / (hi - lo)
		else if(grn == hi)
			hue = 2 + (blu - red) / (hi - lo)
		else
			hue = 4 + (red - grn) / (hi - lo)
		if(hue<0)
			hue += 6

	lgh = round(lgh * 255, 1)
	sat = round(sat * 255, 1)

	hue = round((hue / 6) * 255, 1)

	return list(
		hue,
		sat,
		lgh,
		)

/proc/hsl2rgb(var/hue, var/sat, var/lgh)

	hue /= 255
	sat /= 255
	lgh /= 255

	var/red = 0
	var/grn = 0
	var/blu = 0

	if(!sat)
		red = lgh
		grn = lgh
		blu = lgh
	else
		var/temp1 = 0
		var/temp2 = 0
		var/temp3 = 0
		if(lgh < 0.5)
			temp2 = lgh * (1 + sat)
		else
			temp2 = lgh + sat - lgh * sat
		temp1 = 2 * lgh - temp2

		temp3 = hue + 1/3
		if(temp3 > 1)
			temp3--
		if(6*temp3<1)
			red = temp1 + (temp2 - temp1) * 6 * temp3
		else if(2*temp3<1)
			red = temp2
		else if(3*temp3<2)
			red = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
		else
			red = temp1

		temp3 = hue
		if(6*temp3<1)
			grn = temp1 + (temp2 - temp1) * 6 * temp3
		else if(2*temp3<1)
			grn = temp2
		else if(3*temp3<2)
			grn = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
		else
			grn = temp1

		temp3 = hue - 1/3
		if(temp3 < 0)
			temp3++
		if(6*temp3<1)
			blu = temp1 + (temp2 - temp1) * 6 * temp3
		else if(2*temp3<1)
			blu = temp2
		else if(3*temp3<2)
			blu = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
		else
			blu = temp1

	red = round(red*255, 1)
	grn = round(grn*255, 1)
	blu = round(blu*255, 1)

	return list(
		red,
		grn,
		blu,
		)

/proc/MixColors(const/list/colors)
	var/list/reds = new
	var/list/blues = new
	var/list/greens = new
	var/list/weights = new

	for (var/i = 0, ++i <= colors.len)
		reds.Add(GetRedPart(colors[i]))
		blues.Add(GetBluePart(colors[i]))
		greens.Add(GetGreenPart(colors[i]))
		weights.Add(1)

	var/r = mixOneColor(weights, reds)
	var/g = mixOneColor(weights, greens)
	var/b = mixOneColor(weights, blues)
	return rgb(r,g,b)

/proc/mixOneColor(var/list/weight, var/list/color)
	if(!weight || !color || length(weight) != length(color))
		return 0

	var/contents = length(weight)

	// normalize weights
	var/listsum = 0

	for(var/i = 1, i <= contents, i++)
		listsum += weight[i]

	for(var/i = 1, i <= contents, i++)
		weight[i] /= listsum

	// mix them
	var/mixedcolor = 0

	for(var/i = 1, i <= contents, i++)
		mixedcolor += weight[i] * color[i]

	// until someone writes a formal proof for this algorithm, let's keep this in
	//if(mixedcolor<0x00 || mixedcolor>0xFF)
	//	return 0
	// that's not the kind of operation we are running here, nerd
	return Clamp(round(mixedcolor), 0, 255)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
