
/obj/item/assembly/control/elevator
	name = "elevator controller"
	desc = "A small device used to call elevators to the current floor."

// Emagging elevator buttons will disable safeties
/obj/item/assembly/control/elevator/emag_act(mob/user, obj/item/card/emag/emag_card)
	// We should only emag this when installed in something, so we can be linked to a lift
	if(!istype(loc, /obj/machinery/button))
		return
	if(obj_flags & EMAGGED)
		return

	var/datum/lift_master/lift = get_lift()
	if(!lift)
		return

	for(var/obj/structure/industrial_lift/lift_platform as anything in lift.lift_platforms)
		lift_platform.violent_landing = TRUE
		lift_platform.warns_on_down_movement = FALSE
	loc.balloon_alert(user, "safeties overridden")
	obj_flags |= EMAGGED
	return TRUE

// Multitooling emagged elevator buttons will fix the safeties
/obj/item/assembly/control/elevator/multitool_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		return ..()

	var/datum/lift_master/lift = get_lift()
	if(!lift)
		return ..()

	for(var/obj/structure/industrial_lift/lift_platform as anything in lift.lift_platforms)
		lift_platform.violent_landing = initial(lift_platform.violent_landing)
		lift_platform.warns_on_down_movement = initial(lift_platform.warns_on_down_movement)
	balloon_alert(user, "safeties reset")
	obj_flags &= ~EMAGGED
	return TRUE

/obj/item/assembly/control/elevator/activate(mob/activator)
	if(cooldown)
		return FALSE

	cooldown = TRUE
	if(!call_elevator(activator))
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 2 SECONDS)
		playsound(loc, 'sound/machines/buzz-two.ogg', 50, TRUE)
		return FALSE

	return TRUE

/// Actually calls the elevator.
/// Returns FALSE if we failed to setup the move.
/// Returns TRUE if the move setup was a success, EVEN IF the move itself fails afterwards
/obj/item/assembly/control/elevator/proc/call_elevator(mob/activator)
	var/datum/lift_master/lift = get_lift()
	if(!lift)
		loc.balloon_alert(activator, "no elevator connected!")
		return FALSE

	var/obj/structure/industrial_lift/prime_lift = lift.lift_platforms[1]
	var/lift_z = prime_lift.z

	// The z level to which the elevator should travel
	// The target Z (where the elevator should move to) is not our z level (we are just some assembly in nullspace)
	// but actually the Z level of whatever we are contained in (e.g. elevator button)
	var/target_z = abs(loc.z)
	// The amount of z levels between the our and target_z
	var/difference = abs(target_z - lift_z)

	// We're already at the desired z-level!
	if(difference == 0)
		loc.balloon_alert(activator, "elevator is here!")
		return FALSE

	// Direction (up/down) needed to go to reach targetZ
	var/direction = lift_z < target_z ? UP : DOWN

	// We can't go that way anymore, or possibly ever
	if(!lift.Check_lift_move(direction))
		loc.balloon_alert(activator, "elevator out of service!")
		return FALSE

	// From here on we can call the move a "success"
	. = TRUE
	lift.set_controls(LIFT_PLATFORM_LOCKED)

	// How fast our lift moves up and down
	var/travel_speed = prime_lift.elevator_vertical_speed
	// How long it will/should take us to reach the target Z level
	// (100 / 2 floors up = 50 seconds on every floor, will always reach destination in the same time)
	var/travel_duration = travel_speed * difference
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), travel_duration)
	if(activator)
		loc.balloon_alert(activator, "elevator called")

	// Approach the desired z-level one step at a time
	for(var/i in 1 to difference)
		// move_after_delay will set up a timer and cause us to move after a time
		lift.move_after_delay(
			lift_move_duration = travel_speed,
			door_duration = travel_speed * 1.5,
			direction = direction,
			user = activator,
		)
		// and we don't want to send another request until the timer's done
		stoplag(travel_speed)
		// stop lifting if the lift, button, or assembly has disappeared
		if(QDELETED(lift) || QDELETED(src) || !istype(loc, /obj/machinery/button))
			break
		// we suddenly can no longer move that direction
		if(!lift.Check_lift_move(direction))
			break

	// Our lift survived, unlock it (even if we failed for some reason, so as to not brick it permanently)
	if(!QDELETED(lift))
		lift.set_controls(LIFT_PLATFORM_UNLOCKED)

	// Our lift platform survived, but it didn't reach our landing z.
	if(!QDELETED(prime_lift) && prime_lift.z == target_z)
		loc.balloon_alert(activator, "elevator out of service!")
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return .

	// Our button destroyed mid transit
	if(!istype(loc, /obj/machinery/button))
		return .

	// Everything went according to plan
	playsound(loc, 'sound/machines/ping.ogg', 50, TRUE)
	// And the activator is still around!
	if(!QDELETED(activator))
		loc.balloon_alert(activator, "elevator arrived")

	return .

/// Gets the lift associated with our assembly / button
/obj/item/assembly/control/elevator/proc/get_lift()
	for(var/datum/lift_master/possible_match as anything in GLOB.active_lifts_by_type[BASIC_LIFT_ID])
		if(possible_match.specific_lift_id != id || possible_match.controls_locked)
			continue

		return possible_match

	return null
