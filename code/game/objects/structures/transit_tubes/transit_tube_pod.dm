#define MOVE_ANIMATION_STAGE_ONE 1
#define MOVE_ANIMATION_STAGE_TWO 2

/obj/structure/transit_tube_pod
	icon = 'icons/obj/pipes_n_cables/transit_tube.dmi'
	icon_state = "pod"
	animate_movement = FORWARD_STEPS
	anchored = TRUE
	density = TRUE
	var/moving = FALSE
	var/datum/gas_mixture/air_contents = new()
	var/occupied_icon_state = "pod_occupied"
	var/obj/structure/transit_tube/current_tube = null

/obj/structure/transit_tube_pod/Initialize(mapload)
	. = ..()
	air_contents.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	air_contents.gases[/datum/gas/oxygen][MOLES] = MOLES_O2STANDARD
	air_contents.gases[/datum/gas/nitrogen][MOLES] = MOLES_N2STANDARD
	air_contents.temperature = T20C

/obj/structure/transit_tube_pod/Destroy()
	empty_pod()
	return ..()

/obj/structure/transit_tube_pod/update_icon_state()
	icon_state = contents.len ? occupied_icon_state : initial(icon_state)
	return ..()

/obj/structure/transit_tube_pod/attackby(obj/item/I, mob/user, list/modifiers)
	if(I.tool_behaviour == TOOL_CROWBAR)
		if(!moving)
			I.play_tool_sound(src)
			if(contents.len)
				user.visible_message(span_notice("[user] empties \the [src]."), span_notice("You empty \the [src]."))
				empty_pod()
			else
				deconstruct(TRUE)
	else
		return ..()

/obj/structure/transit_tube_pod/atom_deconstruct(disassembled = TRUE)
	var/atom/location = get_turf(src)
	var/obj/structure/c_transit_tube_pod/tube_pod = new/obj/structure/c_transit_tube_pod(location)
	transfer_fingerprints_to(tube_pod)
	tube_pod.setDir(dir)
	empty_pod(location)

/obj/structure/transit_tube_pod/ex_act(severity, target)
	. = ..()
	if(QDELETED(src))
		return TRUE

	empty_pod()
	return TRUE

/obj/structure/transit_tube_pod/contents_explosion(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += contents
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += contents
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += contents

/obj/structure/transit_tube_pod/singularity_pull(atom/singularity, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/transit_tube_pod/container_resist_act(mob/living/user)
	if(!user.incapacitated)
		empty_pod()
		return
	if(!moving)
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		to_chat(user, span_notice("You start trying to escape from the pod..."))
		if(do_after(user, 1 MINUTES, target = src))
			to_chat(user, span_notice("You manage to open the pod."))
			empty_pod()

/obj/structure/transit_tube_pod/proc/empty_pod(atom/location)
	if(!location)
		location = get_turf(src)
	for(var/atom/movable/M in contents)
		M.forceMove(location)
	update_appearance()

/obj/structure/transit_tube_pod/proc/follow_tube(obj/structure/transit_tube/tube)
	if(moving || !tube.has_exit(dir))
		return

	moving = TRUE
	current_tube = tube

	var/datum/move_loop/engine = GLOB.move_manager.force_move_dir(src, dir, 0, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(engine, COMSIG_MOVELOOP_PREPROCESS_CHECK, PROC_REF(before_pipe_transfer))
	RegisterSignal(engine, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(after_pipe_transfer))
	RegisterSignal(engine, COMSIG_QDELETING, PROC_REF(engine_finish))
	calibrate_engine(engine)

/obj/structure/transit_tube_pod/proc/before_pipe_transfer(datum/move_loop/move/source)
	SIGNAL_HANDLER
	setDir(source.direction)

/obj/structure/transit_tube_pod/proc/after_pipe_transfer(datum/move_loop/move/source)
	SIGNAL_HANDLER

	set_density(current_tube.density)
	if(current_tube.should_stop_pod(src, source.direction))
		current_tube.pod_stopped(src, dir)
		qdel(source)
		return

	calibrate_engine(source)

/obj/structure/transit_tube_pod/proc/calibrate_engine(datum/move_loop/move/engine)
	var/next_dir = current_tube.get_exit(dir)

	if(!next_dir)
		qdel(engine)
		return

	var/exit_delay = current_tube.exit_delay(src, dir)
	var/atom/next_loc = get_step(loc, next_dir)

	current_tube = null
	for(var/obj/structure/transit_tube/tube in next_loc)
		if(tube.has_entrance(next_dir))
			current_tube = tube
			break

	if(!current_tube)
		setDir(next_dir)
		// Allow collisions when leaving the tubes.
		Move(get_step(loc, dir), dir, DELAY_TO_GLIDE_SIZE(exit_delay))
		qdel(src)
		return

	var/enter_delay = current_tube.enter_delay(src, next_dir)
	engine.direction = next_dir
	engine.set_delay(enter_delay + exit_delay)

/obj/structure/transit_tube_pod/proc/engine_finish()
	set_density(TRUE)
	moving = FALSE

	var/obj/structure/transit_tube/TT = locate(/obj/structure/transit_tube) in loc
	//landed on a turf without transit tube or not in our direction
	if(!TT || (!(dir in TT.tube_dirs) && !(REVERSE_DIR(dir) in TT.tube_dirs)))
		outside_tube()

/obj/structure/transit_tube_pod/proc/outside_tube()
	var/list/savedcontents = contents.Copy()
	var/saveddir = dir
	var/turf/destination = get_edge_target_turf(src,saveddir)
	visible_message(span_warning("[src] ejects its insides out!"))
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
		if(direction == REVERSE_DIR(station.boarding_dir))
			if(station.open_status == STATION_TUBE_OPEN)
				user.forceMove(loc)
				update_appearance()
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
	if(!QDELETED(src))
		qdel(src)

#undef MOVE_ANIMATION_STAGE_ONE
#undef MOVE_ANIMATION_STAGE_TWO
