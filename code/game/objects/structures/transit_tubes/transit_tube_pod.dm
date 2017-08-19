/obj/structure/transit_tube_pod
	icon = 'icons/obj/atmospherics/pipes/transit_tube.dmi'
	icon_state = "pod"
	animate_movement = FORWARD_STEPS
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/moving = 0
	var/datum/gas_mixture/air_contents = new()


/obj/structure/transit_tube_pod/New(loc)
	..()
	air_contents.assert_gases("o2", "n2")
	air_contents.gases["o2"][MOLES] = MOLES_O2STANDARD * 2
	air_contents.gases["n2"][MOLES] = MOLES_N2STANDARD
	air_contents.temperature = T20C


/obj/structure/transit_tube_pod/Destroy()
	empty_pod()
	return ..()

/obj/structure/transit_tube_pod/update_icon()
	if(contents.len)
		icon_state = "pod_occupied"
	else
		icon_state = "pod"

/obj/structure/transit_tube_pod/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/crowbar))
		if(!moving)
			playsound(src.loc, I.usesound, 50, 1)
			if(contents.len)
				user.visible_message("[user] empties \the [src].", "<span class='notice'>You empty \the [src].</span>")
				empty_pod()
			else
				deconstruct(TRUE, user)
	else
		return ..()

/obj/structure/transit_tube_pod/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/atom/location = get_turf(src)
		if(user)
			location = user.loc
			add_fingerprint(user)
			user.visible_message("[user] removes [src].", "<span class='notice'>You remove [src].</span>")
		var/obj/structure/c_transit_tube_pod/R = new/obj/structure/c_transit_tube_pod(location)
		transfer_fingerprints_to(R)
		R.setDir(dir)
		empty_pod(location)
	qdel(src)

/obj/structure/transit_tube_pod/ex_act(severity, target)
	..()
	if(!QDELETED(src))
		empty_pod()

/obj/structure/transit_tube_pod/contents_explosion(severity, target)
	for(var/atom/movable/AM in contents)
		AM.ex_act(severity, target)

/obj/structure/transit_tube_pod/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/transit_tube_pod/container_resist(mob/living/user)
	if(!moving)
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		to_chat(user, "<span class='notice'>You start trying to escape from the pod...</span>")
		if(do_after(user, 600, target = src))
			to_chat(user, "<span class='notice'>You manage to open the pod.</span>")
			empty_pod()

/obj/structure/transit_tube_pod/proc/empty_pod(atom/location)
	if(!location)
		location = get_turf(src)
	for(var/atom/movable/M in contents)
		M.forceMove(location)
	update_icon()

/obj/structure/transit_tube_pod/Process_Spacemove()
	if(moving) //No drifting while moving in the tubes
		return 1
	else return ..()

/obj/structure/transit_tube_pod/proc/follow_tube()
	set waitfor = 0
	if(moving)
		return

	moving = 1

	var/obj/structure/transit_tube/current_tube = null
	var/next_dir
	var/next_loc
	var/last_delay = 0
	var/exit_delay

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
			setDir(next_dir)
			Move(get_step(loc, dir), dir) // Allow collisions when leaving the tubes.
			break

		last_delay = current_tube.enter_delay(src, next_dir)
		sleep(last_delay)
		setDir(next_dir)
		loc = next_loc // When moving from one tube to another, skip collision and such.
		density = current_tube.density

		if(current_tube && current_tube.should_stop_pod(src, next_dir))
			current_tube.pod_stopped(src, dir)
			break

	density = TRUE
	moving = 0

	var/obj/structure/transit_tube/TT = locate(/obj/structure/transit_tube) in loc
	if(!TT || (!(dir in TT.tube_dirs) && !(turn(dir,180) in TT.tube_dirs)))	//landed on a turf without transit tube or not in our direction
		deconstruct(FALSE)	//we automatically deconstruct the pod

/obj/structure/transit_tube_pod/return_air()
	return air_contents

/obj/structure/transit_tube_pod/assume_air(datum/gas_mixture/giver)
	return air_contents.merge(giver)

/obj/structure/transit_tube_pod/remove_air(amount)
	return air_contents.remove(amount)

/obj/structure/transit_tube_pod/relaymove(mob/mob, direction)
	if(istype(mob) && mob.client)
		if(!moving)
			for(var/obj/structure/transit_tube/station/station in loc)
				if(!station.pod_moving)
					if(direction == turn(station.boarding_dir,180))
						if(station.open_status == STATION_TUBE_OPEN)
							mob.forceMove(loc)
							update_icon()
						else
							station.open_animation()

					else if(direction in station.tube_dirs)
						setDir(direction)
						station.launch_pod()
				return

			for(var/obj/structure/transit_tube/TT in loc)
				if(dir in TT.tube_dirs)
					if(TT.has_exit(direction))
						setDir(direction)
						return
