/obj/structure/liquid_plasma_extraction_pipe
	name = "liquid plasma extraction pipe"
	desc = "Get that mork- liquid plasma, and return back to the base."
	icon = 'monkestation/code/modules/map_gen_expansions/icons/plasma_extractor.dmi'
	icon_state = "pipe_unbuilt"
	base_icon_state = "pipe"
	max_integrity = 900 //a lot more resistant than the average structure, we want focus on repairs instead.
	anchored = TRUE
	obj_flags = CAN_BE_HIT
	move_resist = MOVE_FORCE_STRONG
	dir = NONE // we will set the direction ourselves in placement.

	pixel_y = 8

	///The extraction hub pipenet we're connected to, which also has us in their own list.
	var/obj/structure/plasma_extraction_hub/part/pipe/connected_hub
	///The state of the pipe, in construction steps.
	var/pipe_state = PIPE_STATE_UNBUILT
	///The status of the pipe, basically if it's currently working on sucking up plasma or not.
	var/pipe_status = PIPE_STATUS_OFF

/obj/structure/liquid_plasma_extraction_pipe/Initialize(mapload, obj/structure/plasma_extraction_hub/part/pipe/connected_hub)
	. = ..()
	src.connected_hub = connected_hub

/obj/structure/liquid_plasma_extraction_pipe/Destroy()
	if(connected_hub)
		connected_hub.on_pipe_destroyed(src)
		connected_hub = null
	return ..()

/obj/structure/liquid_plasma_extraction_pipe/update_icon_state()
	. = ..()
	switch(pipe_state)
		if(PIPE_STATE_UNBUILT)
			icon_state = "[base_icon_state]_unbuilt"
		if(PIPE_STATE_DAMAGED)
			icon_state = "[base_icon_state]_damaged"
		else
			icon_state = base_icon_state

/obj/structure/liquid_plasma_extraction_pipe/update_overlays()
	. = ..()
	if(ISDIAGONALDIR(dir)) //overlays are only placed on straight pipes.
		return

	if(pipe_state == PIPE_STATE_FINE)
		var/mutable_appearance/pipe_connector = mutable_appearance(icon, "pipe-connector", src, plane)
		pipe_connector.pixel_y += 7
		. += pipe_connector

	switch(pipe_status)
		if(PIPE_STATUS_OFF)
			. += "[base_icon_state]_red"
		if(PIPE_STATUS_ON)
			. += "[base_icon_state]_green"

/obj/structure/liquid_plasma_extraction_pipe/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(pipe_state != PIPE_STATE_UNBUILT)
		balloon_alert(user, "already built!")
		return
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 40, interaction_key = DOAFTER_SOURCE_PIPE_CONSTRUCTION))
		return
	balloon_alert(user, "fastened")
	pipe_state = PIPE_STATE_FINE
	update_appearance(UPDATE_ICON)

/obj/structure/liquid_plasma_extraction_pipe/welder_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(pipe_state != PIPE_STATE_DAMAGED)
		balloon_alert(user, "not damaged!")
		return
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 40, interaction_key = DOAFTER_SOURCE_PIPE_CONSTRUCTION))
		return
	repair_damage(max_integrity) //repair all damage.
	balloon_alert(user, "repaired")
	pipe_state = PIPE_STATE_FINE
	var/obj/structure/plasma_extraction_hub/part/pipe/main/main_connected_hub = connected_hub
	if(istype(main_connected_hub) && main_connected_hub.drilling)
		main_connected_hub.start_drilling()
	else if(connected_hub.pipe_owner.drilling)
		connected_hub.start_drilling()
	else
		update_appearance(UPDATE_ICON)

/obj/structure/liquid_plasma_extraction_pipe/crowbar_act(mob/living/user, obj/item/tool)
	if(pipe_status == PIPE_STATUS_ON)
		balloon_alert(user, "currently working!")
		return
	balloon_alert(user, "destroying...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 40, interaction_key = DOAFTER_SOURCE_PIPE_CONSTRUCTION))
		return
	qdel(src)
	return

//this is called by basic animals, but not simple. Too bad, if you want to fix this then start making more basic mobs!
/obj/structure/liquid_plasma_extraction_pipe/attack_animal(mob/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(pipe_state == PIPE_STATE_DAMAGED)
		return
	balloon_alert_to_viewers("springs a leak!")
	pipe_state = PIPE_STATE_DAMAGED
	if(connected_hub.currently_functional)
		connected_hub.stop_drilling()
	else
		update_appearance(UPDATE_ICON)

/obj/structure/liquid_plasma_extraction_pipe/Move(atom/newloc, direct, glide_size_override, update_dir)
	. = ..()
	//you shouldn't be moving, now die.
	qdel(src)

/**
 * Ending pipe
 * This one starts off freely built (so no need to wrench in) and has a different sprite.
 * This basically has no functionality and only exists to tell pipes that they've successfully connected to a pipe.
 */
/obj/structure/liquid_plasma_ending
	name = "liquid plasma extractor"
	desc = "Extracts concentrated liquid plasma from the geyser for mining."
	icon = 'monkestation/code/modules/map_gen_expansions/icons/plasma_extractor.dmi'
	icon_state = "pipe_ending"
	base_icon_state = "pipe_ending"
	anchored = TRUE
	density = TRUE
	obj_flags = CAN_BE_HIT
	resistance_flags = LAVA_PROOF | FIRE_PROOF | INDESTRUCTIBLE
	move_resist = MOVE_FORCE_OVERPOWERING

/obj/structure/liquid_plasma_extraction_pipe/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(!CanReach(user))
		return
	var/obj/vehicle/ridden/sick_grinder/grinder = new(get_turf(src))
	if(!grinder.user_buckle_mob(M, user, check_loc = FALSE))
		qdel(grinder)

/obj/vehicle/ridden/sick_grinder
	name = ""
	icon = null
	icon_state = null
	var/obj/structure/liquid_plasma_extraction_pipe/last_pipe

/obj/vehicle/ridden/sick_grinder/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/sick_grinder)
	AddComponent(/datum/component/particle_spewer/movement/sparks)

/obj/vehicle/ridden/sick_grinder/Destroy(force)
	. = ..()
	last_pipe = null

/obj/vehicle/ridden/sick_grinder/post_unbuckle_mob(mob/living/M)
	. = ..()
	qdel(src)

/obj/vehicle/ridden/sick_grinder/relaymove(mob/living/user, direction)
	var/obj/structure/liquid_plasma_extraction_pipe/locate_pipe = locate() in get_step(src, direction)
	if(!canmove || !locate_pipe)
		return FALSE
	var/turf/turf = get_turf(src)
	for(var/obj/structure/liquid_plasma_extraction_pipe/pipe in turf.contents)
		if(is_driver(user) && check_pipe_move(pipe, direction))
			last_pipe = pipe
			return relaydrive(user, direction)
	return FALSE

/obj/vehicle/ridden/sick_grinder/proc/check_pipe_move(obj/structure/liquid_plasma_extraction_pipe/pipe, direction)
	var/pipe_dir = pipe.dir
	var/last_pipe_dir = last_pipe?.dir
	switch(pipe_dir)
		if(NORTH, SOUTH)
			if((direction == NORTH || direction == SOUTH ) && (last_pipe_dir != EAST && last_pipe_dir != WEST))
				return TRUE
		if(EAST, WEST)
			if((direction == EAST || direction == WEST) && (last_pipe_dir != NORTH && last_pipe_dir != SOUTH))
				return TRUE
		if(NORTHWEST)
			if(direction == EAST || direction == NORTH)
				return TRUE
		if(NORTHEAST)
			if(direction == WEST || direction == NORTH)
				return TRUE
		if(SOUTHEAST)
			if(direction == WEST || direction == SOUTH)
				return TRUE
		if(SOUTHWEST)
			if(direction == EAST || direction == SOUTH)
				return TRUE
	return FALSE

/datum/component/riding/vehicle/sick_grinder
	vehicle_move_delay = 0.5
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/sick_grinder/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 13), TEXT_SOUTH = list(0, 13), TEXT_EAST = list(0, 13), TEXT_WEST = list(0, 13)))
	set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)


/datum/component/particle_spewer/movement/sparks
	unusual_description = "flying sparks"
	particle_state = "white_square"
	burst_amount = 4
	duration = 2 SECONDS
	particle_blending = BLEND_ADD

/datum/component/particle_spewer/movement/sparks/adjust_animate_steps()
	animate_holder.add_animation_step(list(transform = matrix(0.5, 0.5, MATRIX_SCALE), time = 0))
	animate_holder.add_animation_step(list(transform = "RANDOM", time = 0.4 SECONDS, pixel_y = "RANDOM", color = COLOR_VERY_SOFT_YELLOW, pixel_x = "RANDOM", easing = LINEAR_EASING))

	animate_holder.set_random_var(2, "transform", list(-90, 90))
	animate_holder.set_random_var(2, "pixel_x", list(-0, 32))
	animate_holder.set_random_var(2, "pixel_y", list(-16, 16))
	animate_holder.set_parent_copy(2, "pixel_y")
	animate_holder.set_parent_copy(2, "pixel_x")


	animate_holder.set_transform_type(2, MATRIX_ROTATE)
	animate_holder.add_animation_step(list(transform = "RANDOM", time = 0.5 SECONDS, alpha = 0, pixel_y = "RANDOM", color = "ffffff", easing = LINEAR_EASING|EASE_OUT))

	animate_holder.set_random_var(3, "transform", list(-90, 90))
	animate_holder.set_random_var(3, "pixel_y", list(-13, -8))
	animate_holder.set_parent_copy(3, "pixel_y")

	animate_holder.set_transform_type(3, MATRIX_ROTATE)


/datum/component/particle_spewer/movement/sparks/animate_particle(obj/effect/abstract/particle/spawned)
	. = ..()
	spawned.color = COLOR_WHITE
	spawned.add_filter("bloom", 1, list(type = "bloom", threshold = rgb(255,128,255), size = 5, offset = 4, alpha = 255))

/datum/component/particle_spewer/movement/sparks/spawn_particles(atom/movable/mover, turf/target)
	var/burstees = burst_amount
	if(random_bursts)
		burstees = rand(1, burst_amount)

	var/offset = 0
	var/dir = get_dir(mover, target)
	for(var/i = 0 to burstees)
		//create and assign particle its stuff
		var/obj/effect/abstract/particle/spawned = new(get_turf(source_object))
		if(offsets)
			spawned.pixel_x = offset_x
			spawned.pixel_y = offset_y

		switch(dir)
			if(NORTH, SOUTH)
				spawned.pixel_y += offset
			if(EAST, WEST)
				spawned.pixel_x += offset

		offset += 2
		spawned.icon = icon_file
		spawned.icon_state = particle_state
		spawned.blend_mode = particle_blending

		living_particles |= spawned

		animate_particle(spawned)
