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

/proc/flick_overlay_view(image/I, atom/target, duration) //wrapper for the above, flicks to everyone who can see the target atom
	var/list/viewing = list()
	for(var/m in viewers(target))
		var/mob/M = m
		if(M.client)
			viewing += M.client
	flick_overlay(I, viewing, duration)

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
			else if(human_check && !ishuman(M))
				continue
			else if(isnewplayer(M)) // exclude people in the lobby
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

/proc/pollCandidates(var/Question, var/jobbanType, var/datum/game_mode/gametypeCheck, var/be_special_flag = 0, var/poll_time = 300, var/ignore_category = null)
	var/list/mob/dead/observer/candidates = list()
	var/time_passed = world.time
	if (!Question)
		Question = "Would you like to be a special role?"

	for(var/mob/dead/observer/G in player_list)
		if(!G.key || !G.client || (ignore_category && poll_ignore[ignore_category] && G.ckey in poll_ignore[ignore_category]))
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
			switch(ignore_category ? askuser(G,Question,"Please answer in [poll_time/10] seconds!","Yes","No","Never for this round", StealFocus=0, Timeout=poll_time) : askuser(G,Question,"Please answer in [poll_time/10] seconds!","Yes","No", StealFocus=0, Timeout=poll_time))
				if(1)
					G << "<span class='notice'>Choice registered: Yes.</span>"
					if((world.time-time_passed)>poll_time)
						G << "<span class='danger'>Sorry, you were too late for the consideration!</span>"
						G << 'sound/machines/buzz-sigh.ogg'
					else
						candidates += G
				if(2)
					G << "<span class='danger'>Choice registered: No.</span>"
				if(3)
					var/list/L = poll_ignore[ignore_category]
					if(!L)
						poll_ignore[ignore_category] = list()
					poll_ignore[ignore_category] += G.ckey
					G << "<span class='danger'>Choice registered: Never for this round.</span>"
	sleep(poll_time)

	//Check all our candidates, to make sure they didn't log off during the wait period.
	for(var/mob/dead/observer/G in candidates)
		if(!G.key || !G.client)
			candidates.Remove(G)

	return candidates

/proc/pollCandidatesForMob(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, mob/M, ignore_category = null)
	var/list/L = pollCandidates(Question, jobbanType, gametypeCheck, be_special_flag, poll_time, ignore_category)
	if(!M || qdeleted(M) || !M.loc)
		return list()
	return L

/proc/pollCandidatesForMobs(Question, jobbanType, datum/game_mode/gametypeCheck, be_special_flag = 0, poll_time = 300, list/mobs, ignore_category = null)
	var/list/L = pollCandidates(Question, jobbanType, gametypeCheck, be_special_flag, poll_time, ignore_category)
	var/i=1
	for(var/v in mobs)
		var/atom/A = v
		if(!A || qdeleted(A) || !A.loc)
			mobs.Cut(i,i+1)
		else
			++i
	return L

/proc/makeBody(mob/dead/observer/G_found) // Uses stripped down and bastardized code from respawn character
	if(!G_found || !G_found.key)
		return

	//First we spawn a dude.
	var/mob/living/carbon/human/new_character = new(pick(latejoin))//The mob being spawned.

	G_found.client.prefs.copy_to(new_character)
	new_character.dna.update_dna_identity()
	new_character.key = G_found.key

	return new_character

/proc/send_to_playing_players(thing) //sends a whatever to all playing players; use instead of world << where needed
	for(var/M in player_list)
		if(M && !isnewplayer(M))
			M << thing

/proc/window_flash(var/client_or_usr)
	if (!client_or_usr)
		return
	winset(client_or_usr, "mainwindow", "flash=5")


/proc/GetRedPart(const/hexa)
	return hex2num(copytext(hexa, 2, 4))

/proc/GetGreenPart(const/hexa)
	return hex2num(copytext(hexa, 4, 6))

/proc/GetBluePart(const/hexa)
	return hex2num(copytext(hexa, 6, 8))
