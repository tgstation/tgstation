//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
 * A large number of misc global procs.
 */

//Inverts the colour of an HTML string
/proc/invertHTML(HTMLstring)

	if (!( istext(HTMLstring) ))
		CRASH("Given non-text argument!")
		return
	else
		if (length(HTMLstring) != 7)
			CRASH("Given non-HTML argument!")
			return
	var/textr = copytext(HTMLstring, 2, 4)
	var/textg = copytext(HTMLstring, 4, 6)
	var/textb = copytext(HTMLstring, 6, 8)
	var/r = hex2num(textr)
	var/g = hex2num(textg)
	var/b = hex2num(textb)
	textr = num2hex(255 - r, 2)
	textg = num2hex(255 - g, 2)
	textb = num2hex(255 - b, 2)
	return text("#[][][]", textr, textg, textb)
	return

//Returns the middle-most value
/proc/dd_range(low, high, num)
	return max(low,min(high,num))


/proc/Get_Angle(atom/movable/start,atom/movable/end)//For beams.
	if(!start || !end) return 0
	var/dy
	var/dx
	dy=(32*end.y+end.pixel_y)-(32*start.y+start.pixel_y)
	dx=(32*end.x+end.pixel_x)-(32*start.x+start.pixel_x)
	if(!dy)
		return (dx>=0)?90:270
	.=arctan(dx/dy)
	if(dy<0)
		.+=180
	else if(dx<0)
		.+=360

//Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location,mob/target,distance = 1, density = 0, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
/*
Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
Random error in tile placement x, error in tile placement y, and block offset.
Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
Turf and target are seperate in case you want to teleport some distance from a turf the target is not standing on or something.
*/

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)
	//var/errorxy = round((errorx+errory)/2)//Used for diagonal boxes.

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry+=distance
			yoffset+=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(2)//South
			diry-=distance
			yoffset-=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(4)//East
			dirx+=distance
			yoffset+=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx
		if(8)//West
			dirx-=distance
			yoffset-=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx

	var/turf/destination=locate(location.x+dirx,location.y+diry,location.z)

	if(destination)//If there is a destination.
		if(errorx||errory)//If errorx or y were specified.
			var/destination_list[] = list()//To add turfs to list.
			//destination_list = new()
			/*This will draw a block around the target turf, given what the error is.
			Specifying the values above will basically draw a different sort of block.
			If the values are the same, it will be a square. If they are different, it will be a rectengle.
			In either case, it will center based on offset. Offset is position from center.
			Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
			the offset should remain positioned in relation to destination.*/

			var/turf/center = locate((destination.x+xoffset),(destination.y+yoffset),location.z)//So now, find the new center.

			//Now to find a box from center location and make that our destination.
			for(var/turf/T in block(locate(center.x+b1xerror,center.y+b1yerror,location.z), locate(center.x+b2xerror,center.y+b2yerror,location.z) ))
				if(density&&T.density)	continue//If density was specified.
				if(T.x>world.maxx || T.x<1)	continue//Don't want them to teleport off the map.
				if(T.y>world.maxy || T.y<1)	continue
				destination_list += T
			if(destination_list.len)
				destination = pick(destination_list)
			else	return

		else//Same deal here.
			if(density&&destination.density)	return
			if(destination.x>world.maxx || destination.x<1)	return
			if(destination.y>world.maxy || destination.y<1)	return
	else	return

	return destination

/proc/getline(atom/M,atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=sign(dx)	//Sign of x distance (+ or -)
	var/sdy=sign(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px,py,M.z)
	return line

//Returns whether or not a player is a guest using their ckey as an input
/proc/IsGuestKey(key)
	if (findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return 0

	var/i, ch, len = length(key)

	for (i = 7, i <= len, ++i)
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57)
			return 0
	return 1

//Ensure the frequency is within bounds of what it should be sending/recieving at
/proc/sanitize_frequency(f)
	f = round(f)
	f = max(1441, f) // 144.1
	f = min(1489, f) // 148.9
	if ((f % 2) == 0) //Ensure the last digit is an odd number
		f += 1
	return f

//Turns 1479 into 147.9
/proc/format_frequency(f)
	f = text2num(f)
	return "[round(f / 10)].[f % 10]"



//This will update a mob's name, real_name, mind.name, data_core records, pda, id and traitor text
//Calling this proc without an oldname will only update the mob and skip updating the pda, id and records ~Carn
/mob/proc/fully_replace_character_name(oldname,newname)
	if(!newname)	return 0
	real_name = newname
	name = newname
	if(mind)
		mind.name = newname
	if(istype(src, /mob/living/carbon))
		var/mob/living/carbon/C = src
		if(C.dna)
			C.dna.real_name = real_name

	if(isAI(src))
		var/mob/living/silicon/ai/AI = src
		if(oldname != real_name)
			if(AI.eyeobj)
				AI.eyeobj.name = "[newname] (AI Eye)"

			// Set ai pda name
			if(AI.aiPDA)
				AI.aiPDA.owner = newname
				AI.aiPDA.name = newname + " (" + AI.aiPDA.ownjob + ")"

			// Notify Cyborgs
			for(var/mob/living/silicon/robot/Slave in AI.connected_robots)
				Slave.show_laws()

	if(isrobot(src))
		var/mob/living/silicon/robot/R = src
		if(oldname != real_name)
			R.notify_ai(3, oldname, newname)
		if(R.camera)
			R.camera.c_tag = real_name

	if(oldname)
		//update the datacore records! This is goig to be a bit costly.
		for(var/list/L in list(data_core.general,data_core.medical,data_core.security,data_core.locked))
			var/datum/data/record/R = find_record("name", oldname, L)
			if(R)	R.fields["name"] = newname

		//update our pda and id if we have them on our person
		var/list/searching = GetAllContents()
		var/search_id = 1
		var/search_pda = 1

		for(var/A in searching)
			if( search_id && istype(A,/obj/item/weapon/card/id) )
				var/obj/item/weapon/card/id/ID = A
				if(ID.registered_name == oldname)
					ID.registered_name = newname
					ID.update_label()
					if(!search_pda)	break
					search_id = 0

			else if( search_pda && istype(A,/obj/item/device/pda) )
				var/obj/item/device/pda/PDA = A
				if(PDA.owner == oldname)
					PDA.owner = newname
					PDA.update_label()
					if(!search_id)	break
					search_pda = 0

		for(var/datum/mind/T in ticker.minds)
			for(var/datum/objective/obj in T.objectives)
				// Only update if this player is a target
				if(obj.target && obj.target.current && obj.target.current.real_name == name)
					obj.update_explanation_text()

	return 1



//Generalised helper proc for letting mobs rename themselves. Used to be clname() and ainame()

/mob/proc/rename_self(role, allow_numbers=0)
	var/oldname = real_name
	var/newname
	var/loop = 1
	var/safety = 0

	while(loop && safety < 5)
		if(client && client.prefs.custom_names[role] && !safety)
			newname = client.prefs.custom_names[role]
		else
			switch(role)
				if("clown")
					newname = pick(clown_names)
				if("mime")
					newname = pick(mime_names)
				if("ai")
					newname = pick(ai_names)
				if("deity")
					newname = pick(clown_names|ai_names|mime_names) //pick any old name
				else
					return

		for(var/mob/living/M in player_list)
			if(M == src)
				continue
			if(!newname || M.real_name == newname)
				newname = null
				loop++ // name is already taken so we roll again
				break
		loop--
		safety++

	if(isAI(src))
		oldname = null//don't bother with the records update crap
	if(newname)
		fully_replace_character_name(oldname,newname)
		if(isrobot(src))
			var/mob/living/silicon/robot/A = src
			A.custom_name = newname


//Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

//Returns a list of unslaved cyborgs
/proc/active_free_borgs()
	. = list()
	for(var/mob/living/silicon/robot/R in living_mob_list)
		if(R.connected_ai)
			continue
		if(R.stat == DEAD)
			continue
		if(R.emagged || R.scrambledcodes || R.syndicate)
			continue
		. += R

//Returns a list of AI's
/proc/active_ais(check_mind=0)
	. = list()
	for(var/mob/living/silicon/ai/A in living_mob_list)
		if(A.stat == DEAD)
			continue
		if(A.control_disabled == 1)
			continue
		if(check_mind)
			if(!A.mind)
				continue
		. += A
	return .

//Find an active ai with the least borgs. VERBOSE PROCNAME HUH!
/proc/select_active_ai_with_fewest_borgs()
	var/mob/living/silicon/ai/selected
	var/list/active = active_ais()
	for(var/mob/living/silicon/ai/A in active)
		if(!selected || (selected.connected_robots.len > A.connected_robots.len))
			selected = A

	return selected

/proc/select_active_free_borg(mob/user)
	var/list/borgs = active_free_borgs()
	if(borgs.len)
		if(user)	. = input(user,"Unshackled cyborg signals detected:", "Cyborg Selection", borgs[1]) in borgs
		else		. = pick(borgs)
	return .

/proc/select_active_ai(mob/user)
	var/list/ais = active_ais()
	if(ais.len)
		if(user)	. = input(user,"AI signals detected:", "AI Selection", ais[1]) in ais
		else		. = pick(ais)
	return .

//Returns a list of all items of interest with their name
/proc/getpois(mobs_only=0)
	var/list/mobs = sortmobs()
	var/list/names = list()
	var/list/pois = list()
	var/list/namecounts = list()

	for(var/mob/M in mobs)
		var/name = M.name
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if (M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if (M.stat == 2)
			if(istype(M, /mob/dead/observer/))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		pois[name] = M

	if(!mobs_only)
		for(var/atom/A in poi_list)
			if(!A || !A.loc)
				continue
			var/name = A.name
			if (names.Find(name))
				namecounts[name]++
				name = "[name] ([namecounts[name]])"
			else
				names.Add(name)
				namecounts[name] = 1
			pois[name] = A

	return pois
//Orders mobs by type then by name
/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sortNames(mob_list)
	for(var/mob/living/silicon/ai/M in sortmob)
		moblist.Add(M)
	for(var/mob/camera/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/pai/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/robot/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/human/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/brain/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/alien/M in sortmob)
		moblist.Add(M)
	for(var/mob/dead/observer/M in sortmob)
		moblist.Add(M)
	for(var/mob/new_player/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/monkey/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/slime/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/M in sortmob)
		moblist.Add(M)
//	for(var/mob/living/silicon/hivebot/M in world)
//		mob_list.Add(M)
//	for(var/mob/living/silicon/hive_mainframe/M in world)
//		mob_list.Add(M)
	return moblist

//E = MC^2
/proc/convert2energy(M)
	var/E = M*(SPEED_OF_LIGHT_SQ)
	return E

//M = E/C^2
/proc/convert2mass(E)
	var/M = E/(SPEED_OF_LIGHT_SQ)
	return M

/proc/key_name(whom, include_link = null, include_name = 1)
	var/mob/M
	var/client/C
	var/key
	var/ckey

	if(!whom)	return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = directory[ckey]
		if(C)
			M = C.mob
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = 0

	if(key)
		if(C && C.holder && C.holder.fakekey && !include_name)
			if(include_link)
				. += "<a href='?priv_msg=[C.findStealthKey()]'>"
			. += "Administrator"
		else
			if(include_link)
				. += "<a href='?priv_msg=[ckey]'>"
			. += key
		if(!C)
			. += "\[DC\]"

		if(include_link)
			. += "</a>"
	else
		. += "*no key*"

	if(include_name && M)
		if(M.real_name)
			. += "/([M.real_name])"
		else if(M.name)
			. += "/([M.name])"

	return .

/proc/key_name_admin(whom, include_name = 1)
	return key_name(whom, 1, include_name)

/proc/get_mob_by_ckey(key)
	if(!key)
		return
	var/list/mobs = sortmobs()
	for(var/mob/M in mobs)
		if(M.ckey == key)
			return M

// Returns the atom sitting on the turf.
// For example, using this on a disk, which is in a bag, on a mob, will return the mob because it's on the turf.
/proc/get_atom_on_turf(atom/movable/M)
	var/atom/loc = M
	while(loc && loc.loc && !istype(loc.loc, /turf/))
		loc = loc.loc
	return loc

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(atom/A, direction)
	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return 0
		//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

		// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)
	return target

// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(atom/A, direction, range)

	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	if(direction & WEST)
		x = max(1, x - range)

	return locate(x,y,A.z)


// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/get_offset_target_turf(atom/A, dx, dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x,y,A.z)

/proc/arctan(x)
	var/y=arcsin(x/sqrt(1+x*x))
	return y


/proc/anim(turf/location,target as mob|obj,a_icon,a_icon_state as text,flick_anim as text,sleeptime = 0,direction as num)
//This proc throws up either an icon or an animation for a specified amount of time.
//The variables should be apparent enough.
	var/atom/movable/overlay/animation = new(location)
	if(direction)
		animation.dir = direction
	animation.icon = a_icon
	animation.layer = target:layer+1
	if(a_icon_state)
		animation.icon_state = a_icon_state
	else
		animation.icon_state = "blank"
		animation.master = target
		flick(flick_anim, animation)
	sleep(max(sleeptime, 15))
	qdel(animation)


/atom/proc/GetAllContents()
	var/list/processing_list = list(src)
	var/list/assembled = list()

	while(processing_list.len)
		var/atom/A = processing_list[1]
		processing_list -= A

		for(var/atom/a in A)
			if(!(a in assembled))
				processing_list |= a

		assembled |= A

	return assembled

//Step-towards method of determining whether one atom can see another. Similar to viewers()
/proc/can_see(atom/source, atom/target, length=5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 0

	while(current != target_turf)
		if(steps > length) return 0
		if(current.opacity) return 0
		for(var/atom/A in current)
			if(A.opacity) return 0
		current = get_step_towards(current, target_turf)
		steps++

	return 1

/proc/is_blocked_turf(turf/T)
	var/cant_pass = 0
	if(T.density) cant_pass = 1
	for(var/atom/A in T)
		if(A.density)//&&A.anchored
			cant_pass = 1
	return cant_pass

/proc/get_step_towards2(atom/ref , atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref,trg))
	var/turf/temp = get_step_towards(ref,trg)

	if(is_blocked_turf(temp))
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile = null
		var/breakpoint = 0

		while(!free_tile && breakpoint < 10)
			if(!is_blocked_turf(turf_last1))
				free_tile = turf_last1
				break
			if(!is_blocked_turf(turf_last2))
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1,dir_alt1)
			turf_last2 = get_step(turf_last2,dir_alt2)
			breakpoint++

		if(!free_tile) return get_step(ref, base_dir)
		else return get_step_towards(ref,free_tile)

	else return get_step(ref, base_dir)

/proc/do_mob(mob/user , mob/target, time = 30, numticks = 5, uninterruptible = 0, progress = 1)
	//This is quite an ugly solution but i refuse to use the old request system.
	if(!user || !target)
		return 0
	if(numticks == 0)
		return 0
	var/user_loc = user.loc
	var/target_loc = target.loc
	var/holding = user.get_active_hand()
	var/timefraction = round(time/numticks)
	var/image/progbar
	var/continue_looping = 1
	for(var/i = 1 to numticks)
		if(user.client && progress)
			progbar = make_progress_bar(i, numticks, target)
			assign_progress_bar(user, progbar)
		sleep(timefraction)
		if(!user || !target)
			continue_looping = 0

		if (continue_looping && !uninterruptible && (user.loc != user_loc || target.loc != target_loc || user.get_active_hand() != holding || user.incapacitated() || user.lying ))
			continue_looping = 0

		cancel_progress_bar(user, progbar)//Clear the way for the next progbar image
		if(!continue_looping)
			return 0

	cancel_progress_bar(user, progbar)
	return 1

/proc/make_progress_bar(current_number, goal_number, atom/target)
	if(current_number && goal_number && target)
		var/image/progbar
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = target, "icon_state" = "prog_bar_0")
		progbar.icon_state = "prog_bar_[round(((current_number / goal_number) * 100), 10)]"
		progbar.pixel_y = 32
		return progbar

/proc/cancel_progress_bar(mob/user, image/progbar)
	if(user && user.client && progbar)
		user.client.images -= progbar

/proc/assign_progress_bar(mob/user, image/progbar)
	if(user && user.client && progbar)
		user.client.images |= progbar

/proc/do_after(mob/user, delay, numticks = 5, needhand = 1, atom/target = null, progress = 1)
	if(!user)
		return 0

	if(numticks == 0)
		return 0

	var/atom/Tloc = null
	if(target)
		Tloc = target.loc

	var/delayfraction = round(delay/numticks)

	var/atom/Uloc = user.loc

	var/holding = user.get_active_hand()
	var/holdingnull = 1 //User is not holding anything
	if(holding)
		holdingnull = 0 //User is holding a tool of some kind

	var/image/progbar

	var/continue_looping = 1
	for (var/i = 1 to numticks)
		if(user.client && progress)
			progbar = make_progress_bar(i, numticks, target)
			assign_progress_bar(user, progbar)

		sleep(delayfraction)
		if(!user || user.stat || user.weakened || user.stunned  || !(user.loc == Uloc))
			continue_looping = 0

		if(continue_looping && Tloc && (!target || Tloc != target.loc)) //Tloc not set when we don't want to track target
			continue_looping = 0

		if(continue_looping && needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to insert some item/tool into the construction
			if(!holdingnull)
				if(!holding)
					continue_looping = 0
			if(continue_looping && user.get_active_hand() != holding)
				continue_looping = 0

		cancel_progress_bar(user, progbar)//Clear the way for the next progbar image
		if(!continue_looping)
			return 0

	cancel_progress_bar(user,progbar)
	return 1

//Takes: Anything that could possibly have variables and a varname to check.
//Returns: 1 if found, 0 if not.
/proc/hasvar(datum/A, varname)
	if(A.vars.Find(lowertext(varname))) return 1
	else return 0

//Returns sortedAreas list if populated
//else populates the list first before returning it
/proc/SortAreas()
	for(var/area/A in world)
		sortedAreas.Add(A)

	sortTim(sortedAreas, /proc/cmp_name_asc)

/area/proc/addSorted()
	sortedAreas.Add(src)
	sortTim(sortedAreas, /proc/cmp_name_asc)

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/areas = new/list()
	for(var/area/N in world)
		if(istype(N, areatype)) areas += N
	return areas

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/turfs = new/list()
	for(var/area/N in world)
		if(istype(N, areatype))
			for(var/turf/T in N) turfs += T
	return turfs

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all atoms	(objs, turfs, mobs) in areas of that type of that type in the world.
/proc/get_area_all_atoms(areatype)
	if(!areatype) return null
	if(istext(areatype)) areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/atoms = new/list()
	for(var/area/N in world)
		if(istype(N, areatype))
			for(var/atom/A in N)
				atoms += A
	return atoms



/proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)

//chances are 1:value. anyprob(1) will always return true
/proc/anyprob(value)
	return (rand(1,value)==value)

/proc/view_or_range(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = view(distance,center)
		if("range")
			. = range(distance,center)
	return

/proc/oview_or_orange(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = oview(distance,center)
		if("range")
			. = orange(distance,center)
	return

/proc/parse_zone(zone)
	if(zone == "r_hand") return "right hand"
	else if (zone == "l_hand") return "left hand"
	else if (zone == "l_arm") return "left arm"
	else if (zone == "r_arm") return "right arm"
	else if (zone == "l_leg") return "left leg"
	else if (zone == "r_leg") return "right leg"
	else if (zone == "l_foot") return "left foot"
	else if (zone == "r_foot") return "right foot"
	else return zone


//Gets the turf this atom inhabits

/proc/get_turf(atom/A)
	if (!istype(A))
		return
	for(A, A && !isturf(A), A=A.loc); //semicolon is for the empty statement
	return A


//Gets the turf this atom's *ICON* appears to inhabit
//Uses half the width/height respectively to work out
//A minimum pixel amt this icon needs to be pixel'd by
//to be considered to be in another turf

//division = world.icon_size - icon-width/2; DX = pixel_x/division
//division = world.icon_size - icon-height/2; DY = pixel_y/division

//Eg: Humans
//32 - 16; 16/16 = 1, DX = 1
//32 - 16; 15/16 = 0.9375 = 0 when round()'d, DX = 0

//NOTE: if your atom has non-standard bounds then this proc
//will handle it, but it'll be a bit slower.

/proc/get_turf_pixel(atom/movable/AM)
	if(istype(AM))
		var/rough_x = 0
		var/rough_y = 0
		var/final_x = 0
		var/final_y = 0
		var/final_z = 0

		//Assume standards
		var/i_width = world.icon_size
		var/i_height = world.icon_size

		//Handle snowflake objects only if necessary
		if(AM.bound_height != world.icon_size || AM.bound_width != world.icon_size)
			var/icon/AMicon = icon(AM.icon, AM.icon_state)
			i_width = AMicon.Width()
			i_height = AMicon.Height()
			qdel(AMicon)

		//Find a value to divide pixel_ by
		var/n_width = (world.icon_size - (i_width/2))
		var/n_height = (world.icon_size - (i_height/2))

		//DY and DX
		if(n_width)
			rough_x = round(AM.pixel_x/n_width)
		if(n_height)
			rough_y = round(AM.pixel_y/n_height)

		//Find coordinates
		if(!isturf(AM.loc))
			var/turf/T = get_turf(AM)
			final_x = T.x + rough_x
			final_y = T.y + rough_y
			final_z = T.z
		else
			final_x = AM.x + rough_x
			final_y = AM.y + rough_y
			final_z = AM.z

		if(final_x || final_y)
			return locate(final_x, final_y, final_z)

//Finds the distance between two atoms, in pixels
//centered = 0 counts from turf edge to edge
//centered = 1 counts from turf center to turf center
//of course mathematically this is just adding world.icon_size on again
/proc/getPixelDistance(atom/A, atom/B, centered = 1)
	if(!istype(A)||!istype(B))
		return 0
	. = bounds_dist(A, B) + sqrt((((A.pixel_x+B.pixel_x)**2) + ((A.pixel_y+B.pixel_y)**2)))
	if(centered)
		. += world.icon_size

/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null

//Quick type checks for some tools
var/global/list/common_tools = list(
/obj/item/stack/cable_coil,
/obj/item/weapon/wrench,
/obj/item/weapon/weldingtool,
/obj/item/weapon/screwdriver,
/obj/item/weapon/wirecutters,
/obj/item/device/multitool,
/obj/item/weapon/crowbar)

/proc/istool(O)
	if(O && is_type_in_list(O, common_tools))
		return 1
	return 0

/proc/is_pointed(obj/item/W)
	if(istype(W, /obj/item/weapon/pen))
		return 1
	if(istype(W, /obj/item/weapon/screwdriver))
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/syringe))
		return 1
	if(istype(W, /obj/item/weapon/kitchen/fork))
		return 1
	else
		return 0

//For objects that should embed, but make no sense being is_sharp or is_pointed()
//e.g: rods
/proc/can_embed(obj/item/W)
	if(W.is_sharp())
		return 1
	if(is_pointed(W))
		return 1

	var/list/embed_items = list(\
	/obj/item/stack/rods,\
	)

	if(is_type_in_list(W, embed_items))
		return 1


/*
Checks if that loc and dir has a item on the wall
*/
var/list/WALLITEMS = list(
	/obj/machinery/power/apc, /obj/machinery/alarm, /obj/item/device/radio/intercom,
	/obj/structure/extinguisher_cabinet, /obj/structure/reagent_dispensers/peppertank,
	/obj/machinery/status_display, /obj/machinery/requests_console, /obj/machinery/light_switch, /obj/structure/sign,
	/obj/machinery/newscaster, /obj/machinery/firealarm, /obj/structure/noticeboard, /obj/machinery/button,
	/obj/machinery/computer/security/telescreen, /obj/machinery/embedded_controller/radio/simple_vent_controller,
	/obj/item/weapon/storage/secure/safe, /obj/machinery/door_timer, /obj/machinery/flasher, /obj/machinery/keycard_auth,
	/obj/structure/mirror, /obj/structure/fireaxecabinet, /obj/machinery/computer/security/telescreen/entertainment
	)

var/list/WALLITEMS_EXTERNAL = list(
	/obj/machinery/camera, /obj/machinery/camera_assembly,
	/obj/machinery/light_construct, /obj/machinery/light)

var/list/WALLITEMS_INVERSE = list(
	/obj/machinery/light_construct, /obj/machinery/light)


/proc/gotwallitem(loc, dir, var/check_external = 0)
	var/locdir = get_step(loc, dir)
	for(var/obj/O in loc)
		if(is_type_in_list(O, WALLITEMS) && check_external != 2)
			//Direction works sometimes
			if(is_type_in_list(O, WALLITEMS_INVERSE))
				if(O.dir == turn(dir, 180))
					return 1
			else if(O.dir == dir)
				return 1

			//Some stuff doesn't use dir properly, so we need to check pixel instead
			//That's exactly what get_turf_pixel() does
			if(get_turf_pixel(O) == locdir)
				return 1

		if(is_type_in_list(O, WALLITEMS_EXTERNAL) && check_external)
			if(is_type_in_list(O, WALLITEMS_INVERSE))
				if(O.dir == turn(dir, 180))
					return 1
			else if(O.dir == dir)
				return 1

	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in locdir)
		if(is_type_in_list(O, WALLITEMS) && check_external != 2)
			if(O.pixel_x == 0 && O.pixel_y == 0)
				return 1
	return 0

/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")

/obj/proc/atmosanalyzer_scan(datum/gas_mixture/air_contents, mob/user, obj/target = src)
	var/obj/icon = target
	user.visible_message("[user] has used the analyzer on \icon[icon] [target].", "<span class='notice'>You use the analyzer on \icon[icon] [target].</span>")
	var/pressure = air_contents.return_pressure()
	var/total_moles = air_contents.total_moles()

	user << "<span class='notice'>Results of analysis of \icon[icon] [target].</span>"
	if(total_moles>0)
		var/o2_concentration = air_contents.oxygen/total_moles
		var/n2_concentration = air_contents.nitrogen/total_moles
		var/co2_concentration = air_contents.carbon_dioxide/total_moles
		var/plasma_concentration = air_contents.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

		user << "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>"
		user << "<span class='notice'>Nitrogen: [round(n2_concentration*100)] %</span>"
		user << "<span class='notice'>Oxygen: [round(o2_concentration*100)] %</span>"
		user << "<span class='notice'>CO2: [round(co2_concentration*100)] %</span>"
		user << "<span class='notice'>Plasma: [round(plasma_concentration*100)] %</span>"
		if(unknown_concentration>0.01)
			user << "<span class='danger'>Unknown: [round(unknown_concentration*100)] %</span>"
		user << "<span class='notice'>Temperature: [round(air_contents.temperature-T0C)] &deg;C</span>"
	else
		user << "<span class='notice'>[target] is empty!</span>"
	return

/proc/check_target_facings(mob/living/initator, mob/living/target)
	/*This can be used to add additional effects on interactions between mobs depending on how the mobs are facing each other, such as adding a crit damage to blows to the back of a guy's head.
	Given how click code currently works (Nov '13), the initiating mob will be facing the target mob most of the time
	That said, this proc should not be used if the change facing proc of the click code is overriden at the same time*/
	if(!ismob(target) || target.lying)
	//Make sure we are not doing this for things that can't have a logical direction to the players given that the target would be on their side
		return FACING_FAILED
	if(initator.dir == target.dir) //mobs are facing the same direction
		return FACING_SAME_DIR
	if(is_A_facing_B(initator,target) && is_A_facing_B(target,initator)) //mobs are facing each other
		return FACING_EACHOTHER
	if(initator.dir + 2 == target.dir || initator.dir - 2 == target.dir || initator.dir + 6 == target.dir || initator.dir - 6 == target.dir) //Initating mob is looking at the target, while the target mob is looking in a direction perpendicular to the 1st
		return FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR

/proc/random_step(atom/movable/AM, steps, chance)
	var/initial_chance = chance
	while(steps > 0)
		if(prob(chance))
			step(AM, pick(alldirs))
		chance = max(chance - (initial_chance / steps), 0)
		steps--

/proc/living_player_count()
	var/living_player_count = 0
	for(var/mob in player_list)
		if(mob in living_mob_list)
			living_player_count += 1
	return living_player_count

/proc/randomColor(mode = 0)	//if 1 it doesn't pick white, black or gray
	switch(mode)
		if(0)
			return pick("white","black","gray","red","green","blue","brown","yellow","orange","darkred",
						"crimson","lime","darkgreen","cyan","navy","teal","purple","indigo")
		if(1)
			return pick("red","green","blue","brown","yellow","orange","darkred","crimson",
						"lime","darkgreen","cyan","navy","teal","purple","indigo")
		else
			return "white"


/proc/screen_loc2turf(scr_loc, turf/origin)
	var/tX = text2list(scr_loc, ",")
	var/tY = text2list(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = text2list(tX[1], ":")
	tX = tX[1]
	tX = max(1, min(world.maxx, origin.x + (text2num(tX) - (world.view + 1))))
	tY = max(1, min(world.maxy, origin.y + (text2num(tY) - (world.view + 1))))
	return locate(tX, tY, tZ)

/proc/IsValidSrc(A)
	if(istype(A, /datum))
		var/datum/B = A
		return !B.gc_destroyed
	if(istype(A, /client))
		return 1
	return 0



//Get the dir to the RIGHT of dir if they were on a clock
//NORTH --> NORTHEAST
/proc/get_clockwise_dir(dir)
	. = angle2dir(dir2angle(dir)+45)

//Get the dir to the LEFT of dir if they were on a clock
//NORTH --> NORTHWEST
/proc/get_anticlockwise_dir(dir)
	. = angle2dir(dir2angle(dir)-45)


//Compare A's dir, the clockwise dir of A and the anticlockwise dir of A
//To the opposite dir of the dir returned by get_dir(B,A)
//If one of them is a match, then A is facing B
/proc/is_A_facing_B(atom/A,atom/B)
	if(!istype(A) || !istype(B))
		return 0
	if(istype(A, /mob/living))
		var/mob/living/LA = A
		if(LA.lying)
			return 0
	var/goal_dir = angle2dir(dir2angle(get_dir(B,A)+180))
	var/clockwise_A_dir = get_clockwise_dir(A.dir)
	var/anticlockwise_A_dir = get_anticlockwise_dir(B.dir)

	if(A.dir == goal_dir || clockwise_A_dir == goal_dir || anticlockwise_A_dir == goal_dir)
		return 1
	return 0


/*
rough example of the "cone" made by the 3 dirs checked

 B
  \
   \
    >
      <
       \
        \
B --><-- A
        /
       /
      <
     >
    /
   /
 B

*/


//This is just so you can stop an orbit.
//orbit() can run without it (swap orbiting for A)
//but then you can never stop it and that's just silly.
/atom/movable/var/atom/orbiting = null
//we raise this each time orbit is called to prevent mutiple calls in a short time frame from breaking things
/atom/movable/var/orbitid = 0

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = 1, angle_increment = 15, lockinorbit = 0)
	if(!istype(A))
		return
	orbitid++
	var/myid = orbitid
	if (orbiting)
		stop_orbit()
		//sadly this is the only way to ensure the original orbit proc stops
		//and resets the atom's transform before we continue.
		//time is based on the sleep in the loop and the time for the final animation of initial_transform.
		sleep(2.6+world.tick_lag)
		if (orbiting || !istype(A) || orbitid != myid) //post sleep re-check
			return
	orbiting = A
	var/lastloc = loc
	var/angle = 0
	var/matrix/initial_transform = matrix(transform)

	while(orbiting && orbiting.loc && orbitid == myid)
		var/targetloc = get_turf(orbiting)
		if (!lockinorbit && loc != lastloc && loc != targetloc)
			break
		loc = targetloc
		lastloc = loc
		angle += angle_increment

		var/matrix/shift = matrix(initial_transform)
		shift.Translate(radius,0)
		if(clockwise)
			shift.Turn(angle)
		else
			shift.Turn(-angle)
		animate(src, transform = shift, 2)
		sleep(0.6) //the effect breaks above 0.6 delay
	animate(src, transform = initial_transform, 2)
	orbiting = null


/atom/movable/proc/stop_orbit()
	if(orbiting)
		loc = get_turf(orbiting)
		orbiting = null


//Center's an image.
//Requires:
//The Image
//The x dimension of the icon file used in the image
//The y dimension of the icon file used in the image
// eg: center_image(I, 32,32)
// eg2: center_image(I, 96,96)

/proc/center_image(var/image/I, x_dimension = 0, y_dimension = 0)
	if(!I)
		return

	if(!x_dimension || !y_dimension)
		return

	if((x_dimension == world.icon_size) && (y_dimension == world.icon_size))
		return I

	//Offset the image so that it's bottom left corner is shifted this many pixels
	//This makes it infinitely easier to draw larger inhands/images larger than world.iconsize
	//but still use them in game
	var/x_offset = -((x_dimension/world.icon_size)-1)*(world.icon_size*0.5)
	var/y_offset = -((y_dimension/world.icon_size)-1)*(world.icon_size*0.5)

	//Correct values under world.icon_size
	if(x_dimension < world.icon_size)
		x_offset *= -1
	if(y_dimension < world.icon_size)
		y_offset *= -1

	I.pixel_x = x_offset
	I.pixel_y = y_offset

	return I

//similar function to range(), but with no limitations on the distance; will search spiralling outwards from the center
/proc/ultra_range(dist=0, center=usr, orange=0)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return list()

	var/list/L = list()
	var/turf/T
	var/y
	var/x
	var/c_dist = 1

	if(!orange)
		L += t_center
		L += t_center.contents

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents
		c_dist++

	return L

/atom/proc/contains(var/atom/location)
        if(!location)
                return 0
        for(location, location && location != src, location=location.loc); //semicolon is for the empty statement
        if(location == src)
                return 1
        return 0