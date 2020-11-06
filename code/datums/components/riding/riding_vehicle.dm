/datum/component/riding/vehicle/Initialize(mob/living/riding_mob, force = FALSE, riding_flags = NONE)
	. = ..()

/datum/component/riding/vehicle/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_RIDDEN_DRIVER_MOVE, .proc/driver_move)


/datum/component/riding/vehicle/proc/handle_ride(mob/user, direction)
	var/atom/movable/AM = parent
	if(user.incapacitated())
		Unbuckle(user)
		return

	if(world.time < last_vehicle_move + ((last_move_diagonal? 2 : 1) * vehicle_move_delay))
		return
	last_vehicle_move = world.time

	if(!keycheck(user))
		to_chat(user, "<span class='warning'>You'll need a special item in one of your hands to operate [AM].</span>")
		return

	var/turf/next = get_step(AM, direction)
	var/turf/current = get_turf(AM)
	if(!istype(next) || !istype(current))
		return	//not happening.
	if(!turf_check(next, current))
		to_chat(user, "<span class='warning'>Your \the [AM] can not go onto [next]!</span>")
		return
	if(!Process_Spacemove(direction) || !isturf(AM.loc))
		return
	if(isliving(AM) && respect_mob_mobility)
		var/mob/living/M = AM
		if(!(M.mobility_flags & MOBILITY_MOVE))
			return
	step(AM, direction)

	if((direction & (direction - 1)) && (AM.loc == next))		//moved diagonally
		last_move_diagonal = TRUE
	else
		last_move_diagonal = FALSE

	if(QDELETED(src))
		return
	handle_vehicle_layer(AM.dir)
	handle_vehicle_offsets(AM.dir)

	moved_successfully()

/datum/component/riding/vehicle/proc/driver_move(obj/vehicle/vehicle_parent, mob/living/user, direction)
	if(!keycheck(user))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>[vehicle_parent] has no key inserted!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(HAS_TRAIT(user, TRAIT_INCAPACITATED))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You cannot operate \the [vehicle_parent] right now!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(rider_check_flags & REQUIRES_LEGS && HAS_TRAIT(user, TRAIT_FLOORED))
		if(rider_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [vehicle_parent].</span>",\
			"<span class='danger'>You fall off \the [vehicle_parent] while trying to operate it while unable to stand!</span>")
			user.Stun(3 SECONDS)
			return COMPONENT_DRIVER_BLOCK_MOVE
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to manage that while unable to stand up enough to move \the [vehicle_parent]...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(rider_check_flags & REQUIRES_ARMS && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(rider_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [vehicle_parent].</span>",\
			"<span class='danger'>You fall off \the [vehicle_parent] while trying to operate it without being able to hold on!</span>")
			user.Stun(3 SECONDS)
			return COMPONENT_DRIVER_BLOCK_MOVE

		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to manage that unable to hold onto \the [vehicle_parent] to move it...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	handle_ride(user, direction)







/datum/component/riding/vehicle/atv
	keytype = /obj/item/key
	rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 1.5

/datum/component/riding/vehicle/atv/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/vehicle/bicycle
	rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 0

/datum/component/riding/vehicle/bicycle/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))



/datum/component/riding/vehicle/lavaboat
	rider_check_flags = NONE // not sure
	keytype = /obj/item/oar
	var/allowed_turf = /turf/open/lava

/datum/component/riding/vehicle/lavaboat/handle_specials()
	. = ..()
	allowed_turf_typecache = typecacheof(allowed_turf)

/datum/component/riding/vehicle/lavaboat/dragonboat
	vehicle_move_delay = 1

/datum/component/riding/vehicle/lavaboat/dragonboat/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(1, 2), TEXT_SOUTH = list(1, 2), TEXT_EAST = list(1, 2), TEXT_WEST = list( 1, 2)))

/datum/component/riding/vehicle/lavaboat/dragonboat
	vehicle_move_delay = 1
	keytype = null


/datum/component/riding/vehicle/janicart
	keytype = /obj/item/key/janitor

/datum/component/riding/vehicle/janicart/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 7), TEXT_EAST = list(-12, 7), TEXT_WEST = list( 12, 7)))

/datum/component/riding/vehicle/scooter
	rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/scooter/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0), TEXT_SOUTH = list(-2), TEXT_EAST = list(0), TEXT_WEST = list( 2)))

/datum/component/riding/vehicle/scooter/skateboard
	vehicle_move_delay = 1.5
	rider_check_flags = REQUIRES_LEGS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/scooter/skateboard/handle_specials()
	. = ..()
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/vehicle/scooter/skateboard/wheelys
	vehicle_move_delay = 0

/datum/component/riding/vehicle/scooter/skateboard/wheelys/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0), TEXT_SOUTH = list(0), TEXT_EAST = list(0), TEXT_WEST = list(0)))

/datum/component/riding/vehicle/scooter/skateboard/wheelys/rollerskates
	vehicle_move_delay = 1.5

/datum/component/riding/vehicle/scooter/skateboard/wheelys/skishoes
	vehicle_move_delay = 1

/datum/component/riding/vehicle/scooter/skateboard/wheelys/skishoes/handle_specials()
	. = ..()
	allowed_turf_typecache = typecacheof(/turf/open/floor/plating/asteroid/snow/icemoon)

/datum/component/riding/vehicle/secway
	keytype = /obj/item/key/security
	vehicle_move_delay = 1.75
	rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/secway/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))

/datum/component/riding/vehicle/secway/driver_move(mob/living/user, direction)
	var/obj/vehicle/ridden/secway/the_secway = parent

	if(keycheck(user) && the_secway.eddie_murphy)
		if(COOLDOWN_FINISHED(src, message_cooldown))
			the_secway.visible_message("<span class='warning'>[src] sputters and refuses to move!</span>")
			playsound(get_turf(the_secway), 'sound/effects/stall.ogg', 70)
			COOLDOWN_START(src, message_cooldown, 0.75 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE
	return ..()

/datum/component/riding/vehicle/speedbike
	vehicle_move_delay = 0
	override_allow_spacemove = TRUE
	rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/speedbike/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, -8), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(-10, 5), TEXT_WEST = list( 10, 5)))
	set_vehicle_dir_offsets(NORTH, -16, -16)
	set_vehicle_dir_offsets(SOUTH, -16, -16)
	set_vehicle_dir_offsets(EAST, -18, 0)
	set_vehicle_dir_offsets(WEST, -18, 0)


/datum/component/riding/vehicle/wheelchair
	vehicle_move_delay = 0
	rider_check_flags = REQUIRES_ARMS

/datum/component/riding/vehicle/wheelchair/handle_specials()
	. = ..()
	set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)


/datum/component/riding/vehicle/car
	//vehicle_move_delay = movedelay
	vehicle_move_delay = 1
	slowvalue = 0
	COOLDOWN_DECLARE(enginesound_cooldown)

/datum/component/riding/vehicle/car/moved_successfully()
	. = ..()
	var/obj/vehicle/sealed/car/car_parent = parent
	if(!COOLDOWN_FINISHED(src, enginesound_cooldown))
		return FALSE
	COOLDOWN_START(src, enginesound_cooldown, car_parent.engine_sound_length)
	playsound(car_parent, car_parent.engine_sound, 100, TRUE)
	return TRUE

/datum/component/riding/vehicle/car/clowncar
	keytype = /obj/item/bikehorn

/datum/component/riding/vehicle/car/speedwagon
	vehicle_move_delay = 0

/datum/component/riding/vehicle/car/speedwagon/handle_specials()
	. = ..()
	set_riding_offsets(1, list(TEXT_NORTH = list(-10, -4), TEXT_SOUTH = list(16, 3), TEXT_EAST = list(-4, 30), TEXT_WEST = list(4, -3)))
	set_riding_offsets(2, list(TEXT_NORTH = list(19, -5, 4), TEXT_SOUTH = list(-13, 3, 4), TEXT_EAST = list(-4, -3, 4.1), TEXT_WEST = list(4, 28, 3.9)))
	set_riding_offsets(3, list(TEXT_NORTH = list(-10, -18, 4.2), TEXT_SOUTH = list(16, 25, 3.9), TEXT_EAST = list(-22, 30), TEXT_WEST = list(22, -3, 4.1)))
	set_riding_offsets(4, list(TEXT_NORTH = list(19, -18, 4.2), TEXT_SOUTH = list(-13, 25, 3.9), TEXT_EAST = list(-22, 3, 3.9), TEXT_WEST = list(22, 28)))
	set_vehicle_dir_offsets(NORTH, -48, -48)
	set_vehicle_dir_offsets(SOUTH, -48, -48)
	set_vehicle_dir_offsets(EAST, -48, -48)
	set_vehicle_dir_offsets(WEST, -48, -48)
	for(var/i in GLOB.cardinals)
		set_vehicle_dir_layer(i, BELOW_MOB_LAYER)
