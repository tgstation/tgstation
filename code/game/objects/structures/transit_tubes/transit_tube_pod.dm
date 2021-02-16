#define MOVE_ANIMATION_STAGE_ONE 1
#define MOVE_ANIMATION_STAGE_TWO 2

/obj/structure/transit_tube_pod
	icon = 'icons/obj/atmospherics/pipes/transit_tube.dmi'
	icon_state = "pod"
	animate_movement = FORWARD_STEPS
	anchored = TRUE
	density = TRUE
	var/moving = FALSE
	var/datum/gas_mixture/air_contents = new()
	var/occupied_icon_state = "pod_occupied"
	var/obj/structure/transit_tube/current_tube = null
	var/next_dir
	var/next_loc
	var/enter_delay = 0
	var/exit_delay
	var/moving_time = 0


/obj/structure/transit_tube_pod/Initialize()
	. = ..()
	air_contents.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	air_contents.gases[/datum/gas/oxygen][MOLES] = MOLES_O2STANDARD
	air_contents.gases[/datum/gas/nitrogen][MOLES] = MOLES_N2STANDARD
	air_contents.temperature = T20C


/obj/structure/transit_tube_pod/Destroy()
	empty_pod()
	return ..()

/obj/structure/transit_tube_pod/update_icon_state()
	if(contents.len)
		icon_state = occupied_icon_state
	else
		icon_state = initial(icon_state)

/obj/structure/transit_tube_pod/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_CROWBAR)
		if(!moving)
			I.play_tool_sound(src)
			if(contents.len)
				user.visible_message("<span class='notice'>[user] empties \the [src].</span>", "<span class='notice'>You empty \the [src].</span>")
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
			user.visible_message("<span class='notice'>[user] removes [src].</span>", "<span class='notice'>You remove [src].</span>")
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
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

/obj/structure/transit_tube_pod/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/transit_tube_pod/container_resist_act(mob/living/user)
	if(!user.incapacitated())
		empty_pod()
		return
	if(!moving)
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		to_chat(user, "<span class='notice'>You start trying to escape from the pod...</span>")
		if(do_after(user, 1 MINUTES, target = src))
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
		return TRUE
	else
		return ..()

/obj/structure/transit_tube_pod/proc/follow_tube()
	set waitfor = FALSE
	if(moving)
		return

	moving = TRUE

	for(var/obj/structure/transit_tube/tube in loc)
		if(tube.has_exit(dir))
			current_tube = tube
			break

	move_animation(MOVE_ANIMATION_STAGE_ONE)

///timer loop that handles the pod moving from tube to tube
/obj/structure/transit_tube_pod/proc/move_animation(stage = MOVE_ANIMATION_STAGE_ONE)
	if(stage == MOVE_ANIMATION_STAGE_ONE)
		next_dir = current_tube.get_exit(dir)

		if(!next_dir)
			return

		exit_delay = current_tube.exit_delay(src, dir)
		next_loc = get_step(loc, next_dir)

		current_tube = null
		for(var/obj/structure/transit_tube/tube in next_loc)
			if(tube.has_entrance(next_dir))
				current_tube = tube
				break

		if(current_tube == null)
			setDir(next_dir)
			Move(get_step(loc, dir), dir, DELAY_TO_GLIDE_SIZE(exit_delay)) // Allow collisions when leaving the tubes.
			return

		enter_delay = current_tube.enter_delay(src, next_dir)
		if(enter_delay > 0)
			addtimer(CALLBACK(src, .proc/move_animation, MOVE_ANIMATION_STAGE_TWO), enter_delay)
			return
		else
			stage = MOVE_ANIMATION_STAGE_TWO
	if(stage == MOVE_ANIMATION_STAGE_TWO)
		setDir(next_dir)
		set_glide_size(DELAY_TO_GLIDE_SIZE(enter_delay + exit_delay))
		forceMove(next_loc) // When moving from one tube to another, skip collision and such.
		density = current_tube.density

		if(current_tube?.should_stop_pod(src, next_dir))
			current_tube.pod_stopped(src, dir)
		else
			addtimer(CALLBACK(src, .proc/move_animation, MOVE_ANIMATION_STAGE_ONE), exit_delay)
			return
	density = TRUE
	moving = FALSE

	var/obj/structure/transit_tube/TT = locate(/obj/structure/transit_tube) in loc
	if(!TT || (!(dir in TT.tube_dirs) && !(turn(dir,180) in TT.tube_dirs))) //landed on a turf without transit tube or not in our direction
		outside_tube()

/obj/structure/transit_tube_pod/proc/outside_tube()
	var/list/savedcontents = contents.Copy()
	var/saveddir = dir
	var/turf/destination = get_edge_target_turf(src,saveddir)
	visible_message("<span class='warning'>[src] ejects its insides out!</span>")
	deconstruct(FALSE)//we automatically deconstruct the pod
	for(var/i in savedcontents)
		var/atom/movable/AM = i
		AM.throw_at(destination,rand(1,3),5)

/obj/structure/transit_tube_pod/return_air()
	return air_contents

/obj/structure/transit_tube_pod/return_analyzable_air()
	return air_contents

/obj/structure/transit_tube_pod/assume_air(datum/gas_mixture/giver)
	return air_contents.merge(giver)

/obj/structure/transit_tube_pod/remove_air(amount)
	return air_contents.remove(amount)


/obj/structure/transit_tube_pod/relaymove(mob/living/user, direction)
	if(!user.client || moving)
		return

	for(var/obj/structure/transit_tube/station/station in loc)
		if(station.pod_moving)
			return
		if(direction == turn(station.boarding_dir,180))
			if(station.open_status == STATION_TUBE_OPEN)
				user.forceMove(loc)
				update_icon()
			else
				station.open_animation()
		else if(direction in station.tube_dirs)
			setDir(direction)
			station.launch_pod()
		return

	for(var/obj/structure/transit_tube/transit_tube in loc)
		if(!(dir in transit_tube.tube_dirs))
			continue
		if(!transit_tube.has_exit(direction))
			continue
		setDir(direction)
		return


/obj/structure/transit_tube_pod/return_temperature()
	return air_contents.temperature

//special pod made by the dispenser, it fizzles away when reaching a station.

/obj/structure/transit_tube_pod/dispensed
	name = "temporary transit tube pod"
	desc = "Hits the skrrrt (tube station), then hits the dirt (nonexistence). You know how it is."
	icon_state = "temppod"
	occupied_icon_state = "temppod_occupied"

/obj/structure/transit_tube_pod/dispensed/outside_tube()
	qdel(src)

#undef MOVE_ANIMATION_STAGE_ONE
#undef MOVE_ANIMATION_STAGE_TWO
