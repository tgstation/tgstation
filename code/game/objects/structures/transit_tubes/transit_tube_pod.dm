/obj/structure/transit_tube_pod
	icon = 'icons/obj/pipes/transit_tube_pod.dmi'
	icon_state = "pod"
	animate_movement = FORWARD_STEPS
	anchored = 1.0
	density = 1
	var/moving = 0
	var/datum/gas_mixture/air_contents = new()


/obj/structure/transit_tube_pod/New(loc)
	..(loc)

	air_contents.oxygen = MOLES_O2STANDARD * 2
	air_contents.nitrogen = MOLES_N2STANDARD
	air_contents.temperature = T20C

	// Give auto tubes time to align before trying to start moving
	spawn(5)
		follow_tube()

/obj/structure/transit_tube_pod/Destroy()
	for(var/atom/movable/AM in contents)
		AM.loc = loc

	..()

/obj/structure/transit_tube_pod/proc/follow_tube(var/reverse_launch)
	if(moving)
		return

	moving = 1

	spawn()
		var/obj/structure/transit_tube/current_tube = null
		var/next_dir
		var/next_loc
		var/last_delay = 0
		var/exit_delay

		if(reverse_launch)
			dir = turn(dir, 180) // Back it up

		for(var/obj/structure/transit_tube/tube in loc)
			if(tube.has_exit(dir))
				current_tube = tube
				break

		while(current_tube)
			next_dir = current_tube.get_exit(dir)

			if(!next_dir)
				break

			exit_delay = current_tube.exit_delay(src, dir)
			last_delay += exit_delay

			sleep(exit_delay)

			next_loc = get_step(loc, next_dir)

			current_tube = null
			for(var/obj/structure/transit_tube/tube in next_loc)
				if(tube.has_entrance(next_dir))
					current_tube = tube
					break

			if(current_tube == null)
				dir = next_dir
				Move(get_step(loc, dir)) // Allow collisions when leaving the tubes.
				break

			last_delay = current_tube.enter_delay(src, next_dir)
			sleep(last_delay)
			dir = next_dir
			loc = next_loc // When moving from one tube to another, skip collision and such.
			density = current_tube.density

			if(current_tube && current_tube.should_stop_pod(src, next_dir))
				current_tube.pod_stopped(src, dir)
				break

		density = 1

		// If the pod is no longer in a tube, move in a line until stopped or slowed to a halt.
		//  /turf/inertial_drift appears to only work on mobs, and re-implementing some of the
		//  logic allows a gradual slowdown and eventual stop when passing over non-space turfs.
		if(!current_tube && last_delay <= 10)
			do
				sleep(last_delay)

				if(!istype(loc, /turf/space))
					last_delay++

				if(last_delay > 10)
					break

			while(isturf(loc) && Move(get_step(loc, dir)))

		moving = 0


// Should I return a copy here? If the caller edits or del()s the returned
//  datum, there might be problems if I don't...
/obj/structure/transit_tube_pod/return_air()
	var/datum/gas_mixture/GM = new()
	GM.oxygen			= air_contents.oxygen
	GM.carbon_dioxide	= air_contents.carbon_dioxide
	GM.nitrogen			= air_contents.nitrogen
	GM.toxins			= air_contents.toxins
	GM.temperature		= air_contents.temperature
	return GM

// For now, copying what I found in an unused FEA file (and almost identical in a
//  used ZAS file). Means that assume_air and remove_air don't actually alter the
//  air contents.
/obj/structure/transit_tube_pod/assume_air(datum/gas_mixture/giver)
	return air_contents.merge(giver)

/obj/structure/transit_tube_pod/remove_air(amount)
	return air_contents.remove(amount)



// Called when a pod arrives at, and before a pod departs from a station,
//  giving it a chance to mix its internal air supply with the turf it is
//  currently on.
/obj/structure/transit_tube_pod/proc/mix_air()
	var/datum/gas_mixture/environment = loc.return_air()
	var/env_pressure = environment.return_pressure()
	var/int_pressure = air_contents.return_pressure()
	var/total_pressure = env_pressure + int_pressure

	if(total_pressure == 0)
		return

	// Math here: Completely made up, not based on realistic equasions.
	//  Goal is to balance towards equal pressure, but ensure some gas
	//  transfer in both directions regardless.
	// Feel free to rip this out and replace it with something better,
	//  I don't really know muhch about how gas transfer rates work in
	//  SS13.
	var/transfer_in = max(0.1, 0.5 * (env_pressure - int_pressure) / total_pressure)
	var/transfer_out = max(0.1, 0.3 * (int_pressure - env_pressure) / total_pressure)

	var/datum/gas_mixture/from_env = loc.remove_air(environment.total_moles() * transfer_in)
	var/datum/gas_mixture/from_int = air_contents.remove(air_contents.total_moles() * transfer_out)

	loc.assume_air(from_int)
	air_contents.merge(from_env)



// When the player moves, check if the pos is currently stopped at a station.
//  if it is, check the direction. If the direction matches the direction of
//  the station, try to exit. If the direction matches one of the station's
//  tube directions, launch the pod in that direction.
/obj/structure/transit_tube_pod/relaymove(mob/mob, direction)
	if(istype(mob, /mob) && mob.client)
		// If the pod is not in a tube at all, you can get out at any time.
		if(!(locate(/obj/structure/transit_tube) in loc))
			mob.loc = loc
			mob.client.Move(get_step(loc, direction), direction)
			mob.reset_view(null)

			//if(moving && istype(loc, /turf/space))
				// Todo: If you get out of a moving pod in space, you should move as well.
				//  Same direction as pod? Direcion you moved? Halfway between?

		if(!moving)
			for(var/obj/structure/transit_tube/station/station in loc)
				if(dir in station.directions())
					if(!station.pod_moving)
						if(direction == station.dir)
							if(station.icon_state == "open")
								mob.loc = loc
								mob.client.Move(get_step(loc, direction), direction)
								mob.reset_view(null)

							else
								station.open_animation()

						else if(direction in station.directions())
							dir = direction
							station.launch_pod()
					return

			for(var/obj/structure/transit_tube/tube in loc)
				if(dir in tube.directions())
					if(tube.has_exit(direction))
						dir = direction
						return