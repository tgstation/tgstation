/obj/vehicle
	name = "generic vehicle"
	desc = "Yell at coderbus."
	icon = 'icons/mob/rideables/vehicles.dmi'
	icon_state = "error"
	max_integrity = 300
	armor_type = /datum/armor/obj_vehicle
	layer = VEHICLE_LAYER
	density = TRUE
	anchored = FALSE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	pass_flags_self = PASSVEHICLE
	COOLDOWN_DECLARE(cooldown_vehicle_move)
	var/list/mob/occupants //mob = bitflags of their control level.
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
	/// Whether the vehicle is currently able to move
	var/canmove = TRUE
	var/list/autogrant_actions_passenger //plain list of typepaths
	var/list/autogrant_actions_controller //assoc list "[bitflag]" = list(typepaths)
	var/list/list/datum/action/occupant_actions //assoc list mob = list(type = action datum assigned to mob)
	///This vehicle will follow us when we move (like atrailer duh)
	var/obj/vehicle/trailer
	var/are_legs_exposed = FALSE
	var/enter_sound
	var/exit_sound

/datum/armor/obj_vehicle
	melee = 30
	bullet = 30
	laser = 30
	bomb = 30
	fire = 60
	acid = 60

/obj/vehicle/Initialize(mapload)
	. = ..()
	occupants = list()
	autogrant_actions_passenger = list()
	autogrant_actions_controller = list()
	occupant_actions = list()
	generate_actions()
	ADD_TRAIT(src, TRAIT_CASTABLE_LOC, INNATE_TRAIT)

/obj/vehicle/Destroy(force)
	QDEL_NULL(trailer)
	inserted_key = null
	return ..()

/obj/vehicle/Exited(atom/movable/gone, direction)
	if(gone == inserted_key)
		inserted_key = null
	if(exit_sound)
		playsound(src, exit_sound, 70, TRUE, MEDIUM_RANGE_SOUND_EXTRARANGE)
	return ..()

/obj/vehicle/examine(mob/user)
	. = ..()
	. += generate_integrity_message()

/// Returns a readable string of the vehicle's health for examining. Overridden by subtypes who want to be more verbose with their health messages.
/obj/vehicle/proc/generate_integrity_message()
	var/examine_text = ""
	var/integrity = atom_integrity/max_integrity * 100
	switch(integrity)
		if(50 to 99)
			examine_text = "It looks slightly damaged."
		if(25 to 50)
			examine_text = "It appears heavily damaged."
		if(0 to 25)
			examine_text = span_warning("It's falling apart!")

	return examine_text

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

/obj/vehicle/proc/add_occupant(mob/M, control_flags, forced)
	if(!istype(M) || is_occupant(M))
		return FALSE
	if(enter_sound && !forced)
		playsound(src, enter_sound, 70, TRUE, MEDIUM_RANGE_SOUND_EXTRARANGE)
	LAZYSET(occupants, M, NONE)
	add_control_flags(M, control_flags)
	after_add_occupant(M)
	grant_passenger_actions(M)
	return TRUE

/obj/vehicle/proc/after_add_occupant(mob/M)
	auto_assign_occupant_flags(M)

/obj/vehicle/proc/auto_assign_occupant_flags(mob/M) //override for each type that needs it. Default is assign driver if drivers is not at max.
	if(driver_amount() < max_drivers)
		add_control_flags(M, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/proc/remove_occupant(mob/M)
	SHOULD_CALL_PARENT(TRUE)
	if(!istype(M))
		return FALSE
	remove_control_flags(M, ALL)
	remove_passenger_actions(M)
	LAZYREMOVE(occupants, M)
//	LAZYREMOVE(contents, M)
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

/// To add a trailer to the vehicle in a manner that allows safe qdels
/obj/vehicle/proc/add_trailer(obj/vehicle/added_vehicle)
	trailer = added_vehicle
	RegisterSignal(trailer, COMSIG_QDELETING, PROC_REF(remove_trailer))

/// To remove a trailer from the vehicle in a manner that allows safe qdels
/obj/vehicle/proc/remove_trailer()
	SIGNAL_HANDLER
	UnregisterSignal(trailer, COMSIG_QDELETING)
	trailer = null

/obj/vehicle/Move(newloc, dir)
	// It is unfortunate, but this is the way to make it not mess up
	var/atom/old_loc = loc
	// When we do this, it will set the loc to the new loc
	. = ..()
	if(trailer && .)
		var/dir_to_move = get_dir(trailer.loc, old_loc)
		step(trailer, dir_to_move)
