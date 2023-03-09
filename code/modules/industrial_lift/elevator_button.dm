/obj/item/assembly/control/elevator
	name = "elevator controller"
	desc = "A small device used to call elevators to the current floor."
	/// A weakref to the lift_master datum we control
	var/datum/weakref/lift_weakref

/obj/item/assembly/control/elevator/Initialize(mapload)
	. = ..()

	if(mapload)
		return INITIALIZE_HINT_LATELOAD

	var/datum/lift_master/lift = get_lift()
	if(!lift)
		return

	lift_weakref = WEAKREF(lift)

/obj/item/assembly/control/elevator/LateInitialize()
	var/datum/lift_master/lift = get_lift()
	if(!lift)
		log_mapping("Elevator call button at [AREACOORD(src)] found no associated lift to link with, this may be a mapping error.")
		return

	lift_weakref = WEAKREF(lift)

// Emagging elevator buttons will disable safeties
/obj/item/assembly/control/elevator/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return

	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(!lift)
		return

	for(var/obj/structure/industrial_lift/lift_platform as anything in lift.lift_platforms)
		lift_platform.violent_landing = TRUE
		lift_platform.warns_on_down_movement = FALSE
		lift_platform.elevator_vertical_speed = initial(lift_platform.elevator_vertical_speed) * 0.5

	// Note that we can either be emagged by having the button we are inside swiped,
	// or by someone emagging the assembly directly after removing it (to be cheeky)
	var/atom/balloon_alert_loc = get(src, /obj/machinery/button) || src
	balloon_alert_loc.balloon_alert(user, "safeties overridden")
	obj_flags |= EMAGGED
	return TRUE

// Multitooling emagged elevator buttons will fix the safeties
/obj/item/assembly/control/elevator/multitool_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		return ..()

	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(!lift)
		return ..()

	for(var/obj/structure/industrial_lift/lift_platform as anything in lift.lift_platforms)
		lift_platform.violent_landing = initial(lift_platform.violent_landing)
		lift_platform.warns_on_down_movement = initial(lift_platform.warns_on_down_movement)
		lift_platform.elevator_vertical_speed = initial(lift_platform.elevator_vertical_speed)

	// We can only be multitooled directly so just throw up the balloon alert
	balloon_alert(user, "safeties reset")
	obj_flags &= ~EMAGGED
	return TRUE

/obj/item/assembly/control/elevator/activate(mob/activator)
	if(cooldown)
		return

	cooldown = TRUE
	// Actually try to call the elevator - this sleeps.
	// If we failed to call it, play a buzz sound.
	if(!call_elevator(activator))
		playsound(loc, 'sound/machines/buzz-two.ogg', 50, TRUE)

	// Finally, give people a chance to get off after it's done before going back off cooldown
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 2 SECONDS)

/// Actually calls the elevator.
/// Returns FALSE if we failed to setup the move.
/// Returns TRUE if the move setup was a success, EVEN IF the move itself fails afterwards
/obj/item/assembly/control/elevator/proc/call_elevator(mob/activator)
	// We can't call an elevator that doesn't exist
	var/datum/lift_master/lift = lift_weakref?.resolve()
	if(!lift)
		loc.balloon_alert(activator, "no elevator connected!")
		return FALSE

	// We can't call an elevator that's moving. You may say "you totally can do that", but that's not modelled
	if(lift.controls_locked == LIFT_PLATFORM_LOCKED)
		loc.balloon_alert(activator, "elevator is moving!")
		return FALSE

	// We can't call an elevator if it's already at this destination
	var/obj/structure/industrial_lift/prime_lift = lift.return_closest_platform_to_z(loc.z)
	if(prime_lift.z == loc.z)
		loc.balloon_alert(activator, "elevator is here!")
		return FALSE

	// At this point, we can start moving.

	// Give the user, if supplied, a balloon alert.
	if(activator)
		loc.balloon_alert(activator, "elevator called")

	// Actually try to move the lift. This will sleep.
	if(!lift.move_to_zlevel(loc.z, CALLBACK(src, PROC_REF(check_button))))
		loc.balloon_alert(activator, "elevator out of service!")
		return FALSE

	// From here on all returns are TRUE, as we successfully moved the lift, even if we maybe didn't reach our floor

	// Our button was destroyed mid transit.
	if(!check_button())
		return TRUE

	// Our lift platform survived, but it didn't reach our landing z.
	if(!QDELETED(prime_lift) && prime_lift.z != loc.z)
		if(!QDELETED(activator))
			loc.balloon_alert(activator, "elevator out of service!")
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return TRUE

	// Everything went according to plan
	playsound(loc, 'sound/machines/ping.ogg', 50, TRUE)
	if(!QDELETED(activator))
		loc.balloon_alert(activator, "elevator arrived")

	return TRUE

/// Callback for move_to_zlevel / general proc to check if we're still in a button
/obj/item/assembly/control/elevator/proc/check_button()
	if(QDELETED(src))
		return FALSE
	if(!istype(loc, /obj/machinery/button))
		return FALSE
	return TRUE

/// Gets the lift associated with our assembly / button
/obj/item/assembly/control/elevator/proc/get_lift()
	for(var/datum/lift_master/possible_match as anything in GLOB.active_lifts_by_type[BASIC_LIFT_ID])
		if(possible_match.specific_lift_id != id)
			continue

		return possible_match

	return null

/obj/machinery/button/elevator
	name = "elevator button"
	desc = "Go back. Go back. Go back. Can you operate the elevator."
	icon_state = "hallctrl"
	skin = "hallctrl"
	device_type = /obj/item/assembly/control/elevator
	req_access = list()
	id = 1
	light_mask = "hall-light-mask"

/obj/machinery/button/elevator/Initialize(mapload, ndir, built)
	. = ..()
	// Kind of a cop-out
	AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Call Elevator")

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/elevator, 32)
