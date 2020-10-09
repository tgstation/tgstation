


/obj/effect/rollercoaster_hint
	name="rollercoaster hint"
	invisibility = INVISIBILITY_ABSTRACT //nope, can't see this
	anchored = TRUE

/obj/effect/rollercoaster_hint/proc/action()
	return

/obj/effect/rollercoaster_hint/stop/action(var/obj/vehicle/ridden/rollercoaster/coaster)
	if(coaster.front_coaster)
		coaster.disembark_all()

/obj/effect/rollercoaster_hint/slow_down/action(var/obj/vehicle/ridden/rollercoaster/coaster)
	if(coaster.front_coaster)
		coaster.change_speed_all(0.5)

/obj/effect/rollercoaster_hint/speed_up/action(var/obj/vehicle/ridden/rollercoaster/coaster)
	if(coaster.front_coaster)
		coaster.change_speed_all(-0.5)


//huge reason why i'm not using the trailer variable: coasters go up one at a time
/obj/effect/rollercoaster_hint/go_up/action(var/obj/vehicle/ridden/rollercoaster/coaster)
	coaster.z += 1

/obj/effect/rollercoaster_hint/go_down/action(var/obj/vehicle/ridden/rollercoaster/coaster)
	coaster.z -= 1

/obj/vehicle/ridden/rollercoaster
	name = "Terror of the tracks"
	desc = "The lord of the night has issues getting a job, so they're really gunning to keep this one."
	icon = 'icons/mob/eldritch_mobs.dmi'
	icon_state = "armsy_start"
	max_integrity = 6 YEARS //scared?
	armor = list(MELEE = 50, BULLET = 25, LASER = 20, ENERGY = 0, BOMB = 50, BIO = 0, RAD = 0, FIRE = 60, ACID = 60)
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	var/front_coaster = FALSE
	var/list/previous_coasters = list()
	var/in_progress = FALSE
	var/obj/structure/disposalpipe/current_pipe
	var/coaster_speed = 2 //how long in deciseconds the rollercoaster waits before moving

/obj/vehicle/ridden/rollercoaster/Initialize()
	. = ..()
	current_pipe = locate() in get_turf(src)
	previous_coasters = find_previous_coasters()

	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	D.set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
	D.set_vehicle_dir_layer(WEST, OBJ_LAYER)

/obj/vehicle/ridden/rollercoaster/has_gravity(turf/T)
	. = ..()
	return TRUE

/obj/vehicle/ridden/rollercoaster/driver_move(mob/living/user, direction)
	if(!in_progress)
		to_chat(user, "<span class='notice'>The coaster will start when it is full!</span>")
	else
		to_chat(user, "<span class='notice'>Just sit still and enjoy the ride, jesus christ.</span>")
	return TRUE


/obj/vehicle/ridden/rollercoaster/proc/find_previous_coasters(start_previous = TRUE)
	. = list()
	var/search_direction = turn(dir, 180)
	var/turf/trailerturf = get_step(src, search_direction)
	var/obj/vehicle/ridden/rollercoaster/trailercoaster = locate() in trailerturf
	if(trailercoaster)
		while(trailercoaster)
			. += trailercoaster
			trailerturf = get_step(trailercoaster, search_direction)
			trailercoaster = locate() in trailerturf

/obj/vehicle/ridden/rollercoaster/proc/start(start_previous = TRUE)
	current_pipe = locate() in get_turf(src)
	in_progress = TRUE
	INVOKE_ASYNC(current_pipe, /obj/structure/disposalpipe/proc/coaster_travel, src)
	if(start_previous)
		front_coaster = TRUE
		for(var/i in previous_coasters)
			var/obj/vehicle/ridden/rollercoaster/coaster = i
			INVOKE_ASYNC(coaster, .proc/start, FALSE)

/obj/vehicle/ridden/rollercoaster/proc/change_speed_all(amt)
	coaster_speed += amt
	for(var/i in previous_coasters)
		var/obj/vehicle/ridden/rollercoaster/coaster = i
		coaster.coaster_speed += amt

/obj/vehicle/ridden/rollercoaster/proc/disembark_all()
	var/search_direction = turn(dir, 180)//behind us
	var/turf/trailerturf = get_step(src, search_direction)//turf behind us
	in_progress = FALSE
	for(var/i in previous_coasters) //stops movement, and since some parts will not have reached the final terminus we need to move them there ourselves
		var/obj/vehicle/ridden/rollercoaster/coaster = i
		coaster.in_progress = FALSE
		coaster.forceMove(trailerturf)
		coaster.dir = dir
		trailerturf = get_step(coaster, search_direction)//turf behind now corrected coaster
	unbuckle_all_mobs()
	for(var/ii in previous_coasters) //now that everyone's in the correct spot, lets remove all the people riding.
		var/obj/vehicle/ridden/rollercoaster/disembark = ii
		disembark.unbuckle_all_mobs()

/obj/vehicle/ridden/rollercoaster/Move(newloc, dir)
	. = ..()
	var/turf/destination = get_turf(src)
	var/obj/effect/rollercoaster_hint/hint
	hint = locate() in destination
	if(hint)
		hint.action(src)
