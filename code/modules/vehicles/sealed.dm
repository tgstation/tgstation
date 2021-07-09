/obj/vehicle/sealed
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	var/enter_delay = 2 SECONDS
	var/mouse_pointer
	var/headlights_toggle = FALSE

/obj/vehicle/sealed/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/climb_out)

/obj/vehicle/sealed/generate_action_type()
	var/datum/action/vehicle/sealed/E = ..()
	. = E
	if(istype(E))
		E.vehicle_entered_target = src

/obj/vehicle/sealed/MouseDrop_T(atom/dropping, mob/M)
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
		for(var/occupant in occupants)
			conditionalwall.bumpopen(occupant)

/obj/vehicle/sealed/after_add_occupant(mob/M)
	. = ..()
	ADD_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)


/obj/vehicle/sealed/after_remove_occupant(mob/M)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)


/obj/vehicle/sealed/proc/mob_try_enter(mob/M)
	if(!istype(M))
		return FALSE
	if(occupant_amount() >= max_occupants)
		return FALSE
	if(do_after(M, get_enter_delay(M), src, timed_action_flags = IGNORE_HELD_ITEM))
		mob_enter(M)
		return TRUE
	return FALSE

/obj/vehicle/sealed/proc/get_enter_delay(mob/M)
	return enter_delay

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
	SIGNAL_HANDLER
	if(!istype(M))
		return FALSE
	remove_occupant(M)
	if(!isAI(M))//This is the ONE mob we dont want to be moved to the vehicle that should be handeled when used
		M.forceMove(exit_location(M))
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
	inserted_key.forceMove(drop_location())
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
		mob_exit(i, null, randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/Carbon = i
			Carbon.Paralyze(40)

/obj/vehicle/sealed/proc/dump_specific_mobs(flag, randomstep = TRUE)
	for(var/i in occupants)
		if(!(occupants[i] & flag))
			continue
		mob_exit(i, null, randomstep)
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
