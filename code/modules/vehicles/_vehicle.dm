/obj/vehicle
	name = "generic vehicle"
	desc = "Yell at coderbus."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "fuckyou"
	max_integrity = 300
	armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 60, ACID = 60)
	density = TRUE
	anchored = FALSE
	COOLDOWN_DECLARE(cooldown_vehicle_move)
	var/list/mob/occupants				//mob = bitflags of their control level.
	///Maximum amount of passengers plus drivers
	var/max_occupants = 1
	////Maximum amount of drivers
	var/max_drivers = 1
	var/movedelay = 2
	var/lastmove = 0
	/**
	  * If the driver needs a certain item in hand (or inserted, for vehicles) to drive this. For vehicles, this must be duplicated on their riding component subtype
	  * [/datum/component/riding/var/keytype] variable because only a few specific checks are handled here with this var, and the majority of it is on the riding component
	  * Eventually the remaining checks should be moved to the component and this var removed.
	  */
	var/key_type
	///The inserted key, needed on some vehicles to start the engine
	var/obj/item/key/inserted_key
	/// Whether the vehicle os currently able to move
	var/canmove = TRUE
	var/list/autogrant_actions_passenger	//plain list of typepaths
	var/list/autogrant_actions_controller	//assoc list "[bitflag]" = list(typepaths)
	var/list/mob/occupant_actions			//assoc list mob = list(type = action datum assigned to mob)
	///This vehicle will follow us when we move (like atrailer duh)
	var/obj/vehicle/trailer
	var/are_legs_exposed = FALSE

/obj/vehicle/Initialize(mapload)
	. = ..()
	occupants = list()
	autogrant_actions_passenger = list()
	autogrant_actions_controller = list()
	occupant_actions = list()
	generate_actions()

/obj/vehicle/examine(mob/user)
	. = ..()
	if(resistance_flags & ON_FIRE)
		. += "<span class='warning'>It's on fire!</span>"
	var/healthpercent = obj_integrity/max_integrity * 100
	switch(healthpercent)
		if(50 to 99)
			. += "It looks slightly damaged."
		if(25 to 50)
			. += "It appears heavily damaged."
		if(0 to 25)
			. += "<span class='warning'>It's falling apart!</span>"

/obj/vehicle/proc/is_key(obj/item/I)
	return istype(I, key_type)

/obj/vehicle/proc/return_occupants()
	return occupants

/obj/vehicle/proc/occupant_amount()
	return LAZYLEN(occupants)

/obj/vehicle/proc/return_amount_of_controllers_with_flag(flag)
	. = 0
	for(var/i in occupants)
		if(occupants[i] & flag)
			.++

/obj/vehicle/proc/return_controllers_with_flag(flag)
	RETURN_TYPE(/list/mob)
	. = list()
	for(var/i in occupants)
		if(occupants[i] & flag)
			. += i

/obj/vehicle/proc/return_drivers()
	return return_controllers_with_flag(VEHICLE_CONTROL_DRIVE)

/obj/vehicle/proc/driver_amount()
	return return_amount_of_controllers_with_flag(VEHICLE_CONTROL_DRIVE)

/obj/vehicle/proc/is_driver(mob/M)
	return is_occupant(M) && occupants[M] & VEHICLE_CONTROL_DRIVE

/obj/vehicle/proc/is_occupant(mob/M)
	return !isnull(LAZYACCESS(occupants, M))

/obj/vehicle/proc/add_occupant(mob/M, control_flags)
	if(!istype(M) || is_occupant(M))
		return FALSE

	LAZYSET(occupants, M, NONE)
	add_control_flags(M, control_flags)
	after_add_occupant(M)
	grant_passenger_actions(M)
	return TRUE

/obj/vehicle/proc/after_add_occupant(mob/M)
	auto_assign_occupant_flags(M)

/obj/vehicle/proc/auto_assign_occupant_flags(mob/M)	//override for each type that needs it. Default is assign driver if drivers is not at max.
	if(driver_amount() < max_drivers)
		add_control_flags(M, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_PERMISSION)

/obj/vehicle/proc/remove_occupant(mob/M)
	if(!istype(M))
		return FALSE
	remove_control_flags(M, ALL)
	remove_passenger_actions(M)
	LAZYREMOVE(occupants, M)
	cleanup_actions_for_mob(M)
	after_remove_occupant(M)
	return TRUE

/obj/vehicle/proc/after_remove_occupant(mob/M)

/obj/vehicle/relaymove(mob/living/user, direction)
	if(!canmove)
		return FALSE
	if(is_driver(user))
		return relaydrive(user, direction)
	return FALSE

/obj/vehicle/proc/after_move(direction)
	return

/obj/vehicle/proc/add_control_flags(mob/controller, flags)
	if(!is_occupant(controller) || !flags)
		return FALSE
	occupants[controller] |= flags
	for(var/i in GLOB.bitflags)
		if(flags & i)
			grant_controller_actions_by_flag(controller, i)
	return TRUE

/obj/vehicle/proc/remove_control_flags(mob/controller, flags)
	if(!is_occupant(controller) || !flags)
		return FALSE
	occupants[controller] &= ~flags
	for(var/i in GLOB.bitflags)
		if(flags & i)
			remove_controller_actions_by_flag(controller, i)
	return TRUE

/obj/vehicle/Move(newloc, dir)
	. = ..()
	if(trailer && .)
		var/dir_to_move = get_dir(trailer.loc, newloc)
		step(trailer, dir_to_move)
