/obj/machinery/button/elevator
	name = "elevator button"
	desc = "Go back. Go back. Go back. Can you operate the elevator."
	base_icon_state = "tram"
	icon_state = "tram"
	can_alter_skin = FALSE
	light_color = COLOR_DISPLAY_BLUE
	device_type = /obj/item/assembly/control/elevator
	req_access = list()
	id = 1

/obj/machinery/button/elevator/Initialize(mapload, ndir, built)
	. = ..()
	// Kind of a cop-out
	AddElement(/datum/element/contextual_screentip_bare_hands, lmb_text = "Call Elevator")

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/elevator, 32)

/obj/item/assembly/control/elevator
	name = "elevator controller"
	desc = "A small device used to call elevators to the current floor."
	/// A weakref to the transport_controller datum we control
	var/datum/weakref/lift_weakref
	COOLDOWN_DECLARE(elevator_cooldown)

/obj/item/assembly/control/elevator/Initialize(mapload)
	. = ..()

	if(mapload)
		return INITIALIZE_HINT_LATELOAD

	var/datum/transport_controller/linear/lift = get_lift()
	if(!lift)
		return

	lift_weakref = WEAKREF(lift)

/obj/item/assembly/control/elevator/LateInitialize()
	var/datum/transport_controller/linear/lift = get_lift()
	if(!lift)
		log_mapping("Elevator call button at [AREACOORD(src)] found no associated elevator to link with, this may be a mapping error.")
		return

	lift_weakref = WEAKREF(lift)

// Emagging elevator buttons will disable safeties
/obj/item/assembly/control/elevator/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE

	obj_flags |= EMAGGED
	var/datum/transport_controller/linear/lift = lift_weakref?.resolve()
	if(!lift)
		return FALSE

	for(var/obj/structure/transport/linear/lift_platform as anything in lift.transport_modules)
		lift_platform.violent_landing = TRUE
		lift_platform.warns_on_down_movement = FALSE
		lift_platform.elevator_vertical_speed = initial(lift_platform.elevator_vertical_speed) * 0.5

	for(var/obj/machinery/door/elevator_door as anything in GLOB.elevator_doors)
		if(elevator_door.transport_linked_id != lift.specific_transport_id)
			continue
		if(elevator_door.obj_flags & EMAGGED)
			continue
		elevator_door.elevator_status = LIFT_PLATFORM_UNLOCKED
		INVOKE_ASYNC(elevator_door, TYPE_PROC_REF(/obj/machinery/door, open), BYPASS_DOOR_CHECKS)
		elevator_door.obj_flags |= EMAGGED

	// Note that we can either be emagged by having the button we are inside swiped,
	// or by someone emagging the assembly directly after removing it (to be cheeky)
	var/atom/balloon_alert_loc = get(src, /obj/machinery/button) || src
	balloon_alert_loc.balloon_alert(user, "safeties overridden")
	return TRUE

// Multitooling emagged elevator buttons will fix the safeties
/obj/item/assembly/control/elevator/multitool_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		return ..()

	var/datum/transport_controller/linear/lift = lift_weakref?.resolve()
	if(isnull(lift))
		return ..()

	for(var/obj/structure/transport/linear/lift_platform as anything in lift.transport_modules)
		lift_platform.violent_landing = initial(lift_platform.violent_landing)
		lift_platform.warns_on_down_movement = initial(lift_platform.warns_on_down_movement)
		lift_platform.elevator_vertical_speed = initial(lift_platform.elevator_vertical_speed)

	for(var/obj/machinery/door/elevator_door as anything in GLOB.elevator_doors)
		if(elevator_door.transport_linked_id != lift.specific_transport_id)
			continue
		if(!(elevator_door.obj_flags & EMAGGED))
			continue
		elevator_door.obj_flags &= ~EMAGGED
		INVOKE_ASYNC(elevator_door, TYPE_PROC_REF(/obj/machinery/door, close))

	// We can only be multitooled directly so just throw up the balloon alert
	balloon_alert(user, "safeties reset")
	obj_flags &= ~EMAGGED

/obj/item/assembly/control/elevator/activate(mob/activator)
	if(!COOLDOWN_FINISHED(src, elevator_cooldown))
		return

	// Actually try to call the elevator - this sleeps.
	// If we failed to call it, play a buzz sound.
	if(!call_elevator(activator))
		playsound(loc, 'sound/machines/buzz-two.ogg', 50, TRUE)

	// Finally, give people a chance to get off after it's done before going back off cooldown
	COOLDOWN_START(src, elevator_cooldown, 2 SECONDS)

/// Actually calls the elevator.
/// Returns FALSE if we failed to setup the move.
/// Returns TRUE if the move setup was a success, EVEN IF the move itself fails afterwards
/obj/item/assembly/control/elevator/proc/call_elevator(mob/activator)
	// We can't call an elevator that doesn't exist
	var/datum/transport_controller/linear/lift = lift_weakref?.resolve()
	if(!lift)
		loc.balloon_alert(activator, "no elevator connected!")
		return FALSE

	// We can't call an elevator that's moving. You may say "you totally can do that", but that's not modelled
	if(lift.controls_locked == LIFT_PLATFORM_LOCKED)
		loc.balloon_alert(activator, "elevator is moving!")
		return FALSE

	// If the elevator is already here, open the doors.
	var/obj/structure/transport/linear/prime_lift = lift.return_closest_platform_to_z(loc.z)
	if(prime_lift.z == loc.z)
		INVOKE_ASYNC(lift, TYPE_PROC_REF(/datum/transport_controller/linear, open_lift_doors_callback))
		loc.balloon_alert(activator, "elevator is here!")
		return TRUE

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
	if(!QDELETED(activator))
		loc.balloon_alert(activator, "elevator arrived")

	return TRUE

/// Callback for move_to_zlevel / general proc to check if we're still in a button
/obj/item/assembly/control/elevator/proc/check_button()
	if(QDELETED(src) || !istype(loc, /obj/machinery/button))
		return FALSE
	return TRUE

/// Gets the elevator associated with our assembly / button
/obj/item/assembly/control/elevator/proc/get_lift()
	for(var/datum/transport_controller/linear/possible_match as anything in SStransport.transports_by_type[TRANSPORT_TYPE_ELEVATOR])
		if(possible_match.specific_transport_id != id)
			continue

		return possible_match

	return null
