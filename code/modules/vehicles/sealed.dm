/obj/vehicle/sealed
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	interaction_flags_mouse_drop = NEED_HANDS

	var/enter_delay = 2 SECONDS
	var/mouse_pointer
	var/headlights_toggle = FALSE
	///Determines which occupants provide access when bumping into doors
	var/access_provider_flags = VEHICLE_CONTROL_DRIVE

/obj/vehicle/sealed/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SUPERMATTER_CONSUMED, PROC_REF(on_entered_supermatter))

/obj/vehicle/sealed/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/climb_out)

/obj/vehicle/sealed/generate_action_type()
	var/datum/action/vehicle/sealed/E = ..()
	. = E
	if(istype(E))
		E.vehicle_entered_target = src

/obj/vehicle/sealed/mouse_drop_receive(atom/dropping, mob/M, params)
	if(!istype(dropping) || !istype(M))
		return ..()
	if(M == dropping)
		mob_try_enter(M)
	return ..()

/obj/vehicle/sealed/Exited(atom/movable/gone, direction)
	. = ..()
	if(ismob(gone))
		remove_occupant(gone)

// so that we can check the access of the vehicle's occupants. Ridden vehicles do this in the riding component, but these don't have that
/obj/vehicle/sealed/Bump(atom/A)
	. = ..()
	if(istype(A, /obj/machinery/door))
		var/obj/machinery/door/conditionalwall = A
		for(var/mob/occupant as anything in return_controllers_with_flag(access_provider_flags))
			if(conditionalwall.try_safety_unlock(occupant))
				return
			conditionalwall.bumpopen(occupant)

/obj/vehicle/sealed/after_add_occupant(mob/M)
	. = ..()
	ADD_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)


/obj/vehicle/sealed/after_remove_occupant(mob/M)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)


/obj/vehicle/sealed/proc/mob_try_enter(mob/rider)
	if(!istype(rider))
		return FALSE
	var/enter_delay = get_enter_delay(rider)
	if (enter_delay == 0)
		if (enter_checks(rider))
			mob_enter(rider)
			return TRUE
		return FALSE
	if (do_after(rider, enter_delay, src, timed_action_flags = IGNORE_HELD_ITEM, extra_checks = CALLBACK(src, PROC_REF(enter_checks), rider)))
		mob_enter(rider)
		return TRUE
	return FALSE

/// returns enter do_after delay for the given mob in ticks
/obj/vehicle/sealed/proc/get_enter_delay(mob/M)
	return enter_delay

///Extra checks to perform during the do_after to enter the vehicle
/obj/vehicle/sealed/proc/enter_checks(mob/M)
	return occupant_amount() < max_occupants

/obj/vehicle/sealed/proc/mob_enter(mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	if(!silent)
		M.visible_message(span_notice("[M] climbs into \the [src]!"))
	M.forceMove(src)
	add_occupant(M)
	return TRUE

/obj/vehicle/sealed/proc/mob_try_exit(mob/M, mob/user, silent = FALSE, randomstep = FALSE)
	mob_exit(M, silent, randomstep)

/obj/vehicle/sealed/proc/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	if(!istype(M))
		return FALSE
	remove_occupant(M)
	if(!isAI(M))//This is the ONE mob we don't want to be moved to the vehicle that should be handled when used
		M.forceMove(exit_location(M))
	else
		return TRUE
	if(randomstep)
		var/turf/target_turf = get_step(exit_location(M), pick(GLOB.cardinals))
		M.throw_at(target_turf, 5, 10)

	if(!silent)
		M.visible_message(span_notice("[M] drops out of \the [src]!"))
	return TRUE

/obj/vehicle/sealed/proc/exit_location(M)
	return drop_location()

/obj/vehicle/sealed/attackby(obj/item/I, mob/user, params)
	if(key_type && !is_key(inserted_key) && is_key(I))
		if(user.transferItemToLoc(I, src))
			to_chat(user, span_notice("You insert [I] into [src]."))
			if(inserted_key) //just in case there's an invalid key
				inserted_key.forceMove(drop_location())
			inserted_key = I
			inserted_key.forceMove(src)
		else
			to_chat(user, span_warning("[I] seems to be stuck to your hand!"))
		return
	return ..()

/obj/vehicle/sealed/proc/remove_key(mob/user)
	if(!inserted_key)
		to_chat(user, span_warning("There is no key in [src]!"))
		return
	if(!is_occupant(user) || !(occupants[user] & VEHICLE_CONTROL_DRIVE))
		to_chat(user, span_warning("You must be driving [src] to remove [src]'s key!"))
		return
	to_chat(user, span_notice("You remove [inserted_key] from [src]."))
	if(!HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		user.put_in_hands(inserted_key)
	else
		inserted_key.equip_to_best_slot(user)
	inserted_key = null

/obj/vehicle/sealed/Destroy()
	dump_mobs()
	return ..()

/obj/vehicle/sealed/proc/dump_mobs(randomstep = TRUE)
	for(var/i in occupants)
		mob_exit(i, randomstep = randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/Carbon = i
			Carbon.Paralyze(40)

/obj/vehicle/sealed/proc/dump_specific_mobs(flag, randomstep = TRUE)
	for(var/i in occupants)
		if(!(occupants[i] & flag))
			continue
		mob_exit(i, randomstep = randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/C = i
			C.Paralyze(40)


/obj/vehicle/sealed/AllowDrop()
	return FALSE

/obj/vehicle/sealed/relaymove(mob/living/user, direction)
	if(canmove)
		vehicle_move(direction)
	return TRUE

/// Sinced sealed vehicles (cars and mechs) don't have riding components, the actual movement is handled here from [/obj/vehicle/sealed/proc/relaymove]
/obj/vehicle/sealed/proc/vehicle_move(direction)
	return FALSE

/// When we touch a crystal, kill everything inside us
/obj/vehicle/sealed/proc/on_entered_supermatter(atom/movable/vehicle, atom/movable/supermatter)
	SIGNAL_HANDLER
	for (var/mob/passenger as anything in occupants)
		if(!isAI(passenger))
			passenger.Bump(supermatter)
