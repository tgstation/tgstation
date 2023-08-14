#define TRAM_DOOR_WARNING_TIME (1.4 SECONDS)
#define TRAM_DOOR_CYCLE_TIME (0.4 SECONDS)
#define TRAM_DOOR_CRUSH_TIME (0.7 SECONDS)
#define TRAM_DOOR_RECYCLE_TIME	(3 SECONDS)

/obj/machinery/door/airlock/tram
	name = "tram door"
	icon = 'icons/obj/doors/airlocks/tram/tram.dmi'
	overlays_file = 'icons/obj/doors/airlocks/tram/tram-overlays.dmi'
	opacity = FALSE
	assemblytype = null
	airlock_material = "glass"
	air_tight = TRUE
	req_access = list(ACCESS_TCOMMS)
	transport_linked_id = TRAMSTATION_LINE_1
	doorOpen = 'sound/machines/tramopen.ogg'
	doorClose = 'sound/machines/tramclose.ogg'
	autoclose = FALSE
	/// Weakref to the tram we're attached
	var/datum/weakref/tram_ref
	var/retry_counter
	/// Are the doors in a malfunctioning state (dangerous)
	var/malfunctioning = FALSE
	bound_width = 64

/obj/machinery/door/airlock/tram/open(checks = DEFAULT_DOOR_CHECKS)
	if(operating || welded || locked || seal)
		return FALSE

	if(!density)
		return TRUE

	if(checks == DEFAULT_DOOR_CHECKS && (!hasPower() || wires.is_cut(WIRE_OPEN) || (obj_flags & EMAGGED)))
		return FALSE

	SEND_SIGNAL(src, COMSIG_AIRLOCK_OPEN, FALSE)
	operating = TRUE
	update_icon(ALL, AIRLOCK_OPENING, TRUE)

	if(checks >= BYPASS_DOOR_CHECKS)
		playsound(src, 'sound/machines/airlockforced.ogg', vol = 40, vary = FALSE)
		sleep(TRAM_DOOR_CYCLE_TIME)
	else
		playsound(src, doorOpen, vol = 40, vary = FALSE)
		sleep(TRAM_DOOR_WARNING_TIME)

	set_opacity(FALSE)
	set_density(FALSE)
	filler.set_opacity(FALSE)
	filler.set_density(FALSE)
	update_freelook_sight()
	flags_1 &= ~PREVENT_CLICK_UNDER_1
	air_update_turf(TRUE, FALSE)
	sleep(TRAM_DOOR_CYCLE_TIME)
	layer = OPEN_DOOR_LAYER
	update_icon(ALL, AIRLOCK_OPEN, TRUE)
	operating = FALSE

	return TRUE

/obj/machinery/door/airlock/tram/close(checks = DEFAULT_DOOR_CHECKS, force_crush = FALSE)
	retry_counter++
	if(retry_counter >= 4 || force_crush || checks == BYPASS_DOOR_CHECKS)
		try_to_close(checks = BYPASS_DOOR_CHECKS)
		return

	if(retry_counter == 1)
		playsound(src, 'sound/machines/chime.ogg', 40, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

	addtimer(CALLBACK(src, PROC_REF(verify_status)), TRAM_DOOR_RECYCLE_TIME)
	try_to_close()

/**
 * Perform a close attempt and report TRUE/FALSE if it worked
 *
 * Arguments:
 * * rapid - boolean: if TRUE will skip safety checks and crush whatever is in the way
 */
/obj/machinery/door/airlock/tram/proc/try_to_close(checks = DEFAULT_DOOR_CHECKS)
	if(operating || welded || locked || seal)
		return FALSE
	if(density)
		return TRUE
	var/hungry_door = (checks == BYPASS_DOOR_CHECKS || malfunctioning)
	if((obj_flags & EMAGGED) || malfunctioning)
		do_sparks(3, TRUE, src)
		playsound(src, SFX_SPARKS, vol = 75, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	use_power(50)
	playsound(src, doorClose, vol = 40, vary = FALSE)
	operating = TRUE
	layer = CLOSED_DOOR_LAYER
	update_icon(ALL, AIRLOCK_CLOSING, 1)
	sleep(TRAM_DOOR_WARNING_TIME)
	if(!hungry_door)
		for(var/atom/movable/blocker in get_turf(src))
			if(blocker.density && blocker != src) //something is blocking the door
				say("Please stand clear of the doors!")
				playsound(src, 'sound/machines/buzz-sigh.ogg', 60, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
				layer = OPEN_DOOR_LAYER
				update_icon(ALL, AIRLOCK_OPEN, 1)
				operating = FALSE
				return FALSE
	SEND_SIGNAL(src, COMSIG_AIRLOCK_CLOSE)
	sleep(TRAM_DOOR_CRUSH_TIME)
	set_density(TRUE)
	set_opacity(TRUE)
	filler.set_density(TRUE)
	filler.set_opacity(TRUE)
	update_freelook_sight()
	flags_1 |= PREVENT_CLICK_UNDER_1
	air_update_turf(TRUE, TRUE)
	crush()
	sleep(TRAM_DOOR_CYCLE_TIME)
	update_icon(ALL, AIRLOCK_CLOSED, 1)
	operating = FALSE
	retry_counter = 0
	return TRUE

/**
 * Checks if the door close action was successful. Retries if it failed
 *
 * If some jerk is blocking the doors, they've had enough warning by attempt 3,
 * take a chunk of skin, people have places to be!
 */
/obj/machinery/door/airlock/tram/proc/verify_status()
	if(airlock_state != 1)
		if(retry_counter == 3)
			playsound(src, 'sound/machines/buzz-two.ogg', 60, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
			say("YOU'RE HOLDING UP THE TRAM, ASSHOLE!")
			close(checks = BYPASS_DOOR_CHECKS)
		else
			close()

/**
 * Set the weakref for the tram we're attached to
 */
/obj/machinery/door/airlock/tram/proc/find_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in SSicts_transport.transports_by_type[ICTS_TYPE_TRAM])
		if(tram.specific_transport_id == transport_linked_id)
			tram_ref = WEAKREF(tram)

/obj/machinery/door/airlock/tram/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door/airlock/tram/LateInitialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(open))
	SSicts_transport.doors += src
	find_tram()

/obj/machinery/door/airlock/tram/Destroy()
	SSicts_transport.doors -= src
	return ..()

/**
 * Tram doors can be opened with hands when unpowered
 */
/obj/machinery/door/airlock/tram/examine(mob/user)
	. = ..()
	. += span_notice("It has an emergency mechanism to open using <b>just your hands</b> in the event of an emergency.")

/**
 * Tram doors can be opened with hands when unpowered
 */
/obj/machinery/door/window/tram/try_safety_unlock(mob/user)
	if(!hasPower()  && density)
		balloon_alert(user, "pulling emergency exit...")
		if(do_after(user, 7 SECONDS, target = src))
			try_to_crowbar(null, user, TRUE)
			return TRUE


/**
 * If you pry (bump) the doors open midtravel, open quickly so you can jump out and make a daring escape.
 */
/obj/machinery/door/airlock/tram/bumpopen(mob/user, checks = BYPASS_DOOR_CHECKS)
	if(operating || !density)
		return
	var/datum/transport_controller/linear/tram/tram_part = tram_ref?.resolve()
	add_fingerprint(user)
	if(tram_part.travel_remaining < DEFAULT_TRAM_LENGTH || tram_part.travel_remaining > tram_part.travel_trip_length - DEFAULT_TRAM_LENGTH)
		return // we're already animating, don't reset that
	open(checks = BYPASS_DOOR_CHECKS)
	return

#undef TRAM_DOOR_WARNING_TIME
#undef TRAM_DOOR_CYCLE_TIME
#undef TRAM_DOOR_CRUSH_TIME
#undef TRAM_DOOR_RECYCLE_TIME
