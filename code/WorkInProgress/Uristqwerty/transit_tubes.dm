
// Basic transit tubes. Straight pieces, curved sections,
//  and basic splits/joins (no routing logic).
// Mappers: you can use "Generate Instances from Icon-states"
//  to get the different pieces.
/obj/structure/transit_tube
	icon = 'transit_tube.dmi'
	icon_state = "E-W"
	density = 1
	layer = 3.1
	anchored = 1.0
	var/list/tube_dirs = null
	var/exit_delay = 2
	var/enter_delay = 1


// A place where tube pods stop, and people can get in or out.
// Mappers: use "Generate Instances from Directions" for this
//  one.
/obj/structure/transit_tube/station
	icon = 'transit_tube_station.dmi'
	icon_state = "closed"
	exit_delay = 2
	enter_delay = 3
	var/pod_moving = 0
	var/automatic_launch_time = 100

	var/const/OPEN_DURATION = 6
	var/const/CLOSE_DURATION = 6



/obj/structure/transit_tube_pod
	icon = 'transit_tube_pod.dmi'
	icon_state = "pod"
	animate_movement = FORWARD_STEPS
	var/moving = 0
	var/datum/gas_mixture/air_contents



/obj/structure/transit_tube/station/New(loc)
	..(loc)

	spawn(automatic_launch_time)
		launch_pod()


/obj/structure/transit_tube/station/Bumped(mob/AM as mob|obj)
	if(!pod_moving && icon_state == "open" && istype(AM, /mob))
		for(var/obj/structure/transit_tube_pod/pod in loc)
			if(!pod.moving && pod.dir in directions())
				AM.loc = pod
				return



/obj/structure/transit_tube/station/attack_hand(mob/user as mob)
	if(!pod_moving)
		for(var/obj/structure/transit_tube_pod/pod in loc)
			if(!pod.moving && pod.dir in directions())
				if(icon_state == "closed")
					open_animation()

				else if(icon_state == "open")
					close_animation()



/obj/structure/transit_tube/station/proc/open_animation()
	if(icon_state == "closed")
		icon_state = "opening"
		spawn(OPEN_DURATION)
			if(icon_state == "opening")
				icon_state = "open"



/obj/structure/transit_tube/station/proc/close_animation()
	if(icon_state == "open")
		icon_state = "closing"
		spawn(CLOSE_DURATION)
			if(icon_state == "closing")
				icon_state = "closed"



/obj/structure/transit_tube/station/proc/launch_pod()
	for(var/obj/structure/transit_tube_pod/pod in loc)
		if(!pod.moving && pod.dir in directions())
			spawn(5)
				pod_moving = 1
				close_animation()
				sleep(CLOSE_DURATION + 2)
				if(icon_state == "closed" && pod)
					pod.follow_tube()

				pod_moving = 0

			return



/obj/structure/transit_tube/proc/should_stop_pod(pod, from_dir)
	return 0



/obj/structure/transit_tube/station/should_stop_pod(pod, from_dir)
	return 1



/obj/structure/transit_tube/proc/pod_stopped(pod, from_dir)
	return 0



/obj/structure/transit_tube/station/pod_stopped(obj/structure/transit_tube_pod/pod, from_dir)
	pod_moving = 1
	spawn(5)
		open_animation()
		sleep(OPEN_DURATION + 2)
		pod_moving = 0
		pod.mix_air()

		if(automatic_launch_time)
			var/const/wait_step = 5
			var/i = 0
			while(i < automatic_launch_time)
				sleep(wait_step)
				i += wait_step

				if(pod_moving || icon_state != "open")
					return

			launch_pod()



// Returns a /list of directions this tube section can
//  connect to.
/obj/structure/transit_tube/proc/directions()
	return tube_dirs



/obj/structure/transit_tube/proc/has_entrance(from_dir)
	from_dir = turn(from_dir, 180)

	for(var/direction in directions())
		if(direction == from_dir)
			return 1

	return 0



/obj/structure/transit_tube/proc/has_exit(in_dir)
	for(var/direction in directions())
		if(direction == in_dir)
			return 1

	return 0



// Searches for an exit direction within 45 degrees of the
//  specified dir. Returns that direction, or 0 if none match.
/obj/structure/transit_tube/proc/get_exit(in_dir)
	var/near_dir = 0
	var/in_dir_cw = turn(in_dir, -45)
	var/in_dir_ccw = turn(in_dir, 45)

	for(var/direction in directions())
		if(direction == in_dir)
			return direction

		else if(direction == in_dir_cw)
			near_dir = direction

		else if(direction == in_dir_ccw)
			near_dir = direction

	return near_dir



/obj/structure/transit_tube/proc/exit_delay(pod, to_dir)
	return exit_delay

/obj/structure/transit_tube/proc/enter_delay(pod, to_dir)
	return enter_delay



/obj/structure/transit_tube_pod/proc/follow_tube()
	if(moving)
		return

	moving = 1

	spawn()
		var/obj/structure/transit_tube/current_tube = null
		var/next_dir
		var/next_loc

		for(var/obj/structure/transit_tube/tube in loc)
			if(tube.has_exit(dir))
				current_tube = tube
				break

		while(current_tube)
			next_dir = current_tube.get_exit(dir)

			if(!next_dir)
				break

			sleep(current_tube.exit_delay(src, dir))
			next_loc = get_step(loc, next_dir)

			current_tube = null
			for(var/obj/structure/transit_tube/tube in next_loc)
				if(tube.has_entrance(next_dir))
					current_tube = tube
					break

			if(current_tube == null)
				dir = next_dir
				step(src, dir)
				break

			sleep(current_tube.enter_delay(src, next_dir))
			dir = next_dir
			loc = next_loc

			if(current_tube && current_tube.should_stop_pod(src, next_dir))
				current_tube.pod_stopped(src, dir)
				break

		moving = 0



// HUGE HACK: Because the pod isn't a mecha, travelling through tubes over space
//  won't protect people from space.
// This avoids editing an additional file, so that adding
//  tubes to a SS13 codebase is a simple as dropping this code file and the
//  required icon files somewhere where BYOND can find them.
/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	if(!istype(loc, /obj/structure/transit_tube_pod))
		return ..(environment)



/obj/structure/transit_tube_pod/return_air()
	var/datum/gas_mixture/GM = new()
	GM.oxygen = MOLES_O2STANDARD * 2
	GM.nitrogen = MOLES_N2STANDARD
	GM.temperature = T20C
	return GM

// For now, copying what I found in an unused FEA file (and almost identical in a
//  used ZAS file). Means that assume_air and remove_air don't actually alter the
//  air contents.
/obj/structure/transit_tube_pod/assume_air(datum/gas_mixture/giver)
	return 0

/obj/structure/transit_tube_pod/remove_air(amount)
	var/oxygen = MOLES_O2STANDARD
	var/carbon_dioxide = 0
	var/nitrogen = MOLES_N2STANDARD
	var/toxins = 0

	var/datum/gas_mixture/GM = new()

	var/sum = oxygen + carbon_dioxide + nitrogen + toxins
	if(sum>0)
		GM.oxygen = (oxygen/sum)*amount
		GM.carbon_dioxide = (carbon_dioxide/sum)*amount
		GM.nitrogen = (nitrogen/sum)*amount
		GM.toxins = (toxins/sum)*amount

	GM.temperature = T20C
	GM.update_values() //Needed in ZAS to prevent suffocation. Not present in FEA. Comment/uncomment as nessecary.

	return GM



// Called when a pod arrives at, and before a pod departs from a station,
//  giving it a chance to mix its internal air supply with the turf it is
//  currently on.
/obj/structure/transit_tube_pod/proc/mix_air()
	//Needs to be implemented at some point



// When the player moves, check if the pos is currently stopped at a station.
//  if it is, check the direction. If the direction matches the direction of
//  the station, try to exit. If the direction matches one of the station's
//  tube directions, launch the pod in that direction.
/obj/structure/transit_tube_pod/relaymove(mob/mob, direction)
	if(!moving && istype(mob, /mob) && mob.client)
		for(var/obj/structure/transit_tube/station/station in loc)
			if(!station.pod_moving && (dir in station.directions()))
				if(direction == station.dir)
					if(station.icon_state == "open")
						mob.loc = loc
						mob.client.Move(get_step(loc, direction), direction)

					else
						station.open_animation()

				else if(direction in station.directions())
					dir = direction
					station.launch_pod()



/obj/structure/transit_tube/New(loc)
	..(loc)

	if(tube_dirs == null)
		init_dirs()



// Parse the icon_state into a list of directions.
// This means that mappers can use Dream Maker's built in
//  "Generate Instances from Icon-states" option to get all
//  variations. Additionally, as a separate proc, sub-types
//  can handle it more intelligently.
/obj/structure/transit_tube/proc/init_dirs()
	tube_dirs = parse_dirs(icon_state)

	if(copytext(icon_state, 1, 3) == "D-")
		density = 0



// Tube station directions are simply 90 to either side of
//  the exit.
/obj/structure/transit_tube/station/init_dirs()
	tube_dirs = list(turn(dir, 90), turn(dir, -90))



// Uses a list() to cache return values. Since they should
//  never be edited directly, all tubes with a certain
//  icon_state can just reference the same list. In theory,
//  reduces memory usage, and improves CPU cache usage.
//  In reality, I don't know if that is quite how BYOND works,
//  but it is probably safer to assume the existence of, and
//  rely on, a sufficiently smart compiler/optimizer.
/obj/structure/transit_tube/proc/parse_dirs(text)
	var/global/list/direction_table = list()

	if(text in direction_table)
		return direction_table[text]

	var/list/split_text = stringsplit(text, "-")

	// If the first token is D, the icon_state represents
	//  a purely decorative tube, and doesn't actually
	//  connect to anything.
	if(split_text[1] == "D")
		direction_table[text] = list()
		return null

	var/list/directions = list()

	for(var/text_part in split_text)
		var/direction = text2dir_extended(text_part)

		if(direction > 0)
			directions += direction

	direction_table[text] = directions
	return directions



// A copy of text2dir, extended to accept one and two letter
//  directions, and to clearly return 0 otherwise.
/obj/structure/transit_tube/proc/text2dir_extended(direction)
	switch(uppertext(direction))
		if("NORTH", "N")
			return 1
		if("SOUTH", "S")
			return 2
		if("EAST", "E")
			return 4
		if("WEST", "W")
			return 8
		if("NORTHEAST", "NE")
			return 5
		if("NORTHWEST", "NW")
			return 9
		if("SOUTHEAST", "SE")
			return 6
		if("SOUTHWEST", "SW")
			return 10
		else
	return 0