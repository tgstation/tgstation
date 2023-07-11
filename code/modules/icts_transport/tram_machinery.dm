#define AIRLOCK_CLOSED 1
#define AIRLOCK_CLOSING 2
#define AIRLOCK_OPEN 3
#define AIRLOCK_OPENING 4
#define AIRLOCK_DENY 5
#define AIRLOCK_EMAG 6
#define AIRLOCK_SECURITY_TRAM 5

#define AIRLOCK_FRAME_CLOSED "closed"
#define AIRLOCK_FRAME_CLOSING "closing"
#define AIRLOCK_FRAME_OPEN "open"
#define AIRLOCK_FRAME_OPENING "opening"

#define TRAM_DOOR_WARNING_TIME (1.4 SECONDS)
#define TRAM_DOOR_RECYCLE_TIME	(3 SECONDS)

/obj/machinery/door/airlock/tram
	name = "tram door"
	icon = 'icons/obj/doors/airlocks/tram/tram.dmi'
	overlays_file = 'icons/obj/doors/airlocks/tram/tram-overlays.dmi'
	opacity = FALSE
	assemblytype = null
	glass = TRUE
	airlock_material = "glass"
	air_tight = TRUE
	// req_access = list("tcomms")
	transport_linked_id = TRAMSTATION_LINE_1
	doorOpen = 'sound/machines/tramopen.ogg'
	doorClose = 'sound/machines/tramclose.ogg'
	autoclose = FALSE
	security_level = AIRLOCK_SECURITY_TRAM
	aiControlDisabled = AI_WIRE_DISABLED
	hackProof = TRUE
	/// Weakref to the tram we're attached
	var/datum/weakref/tram_ref
	/// Are the doors in a malfunctioning state (dangerous)
	var/malfunctioning = FALSE
	var/attempt = 0

/obj/machinery/door/airlock/tram/proc/cycle_tram_doors(command, rapid)
	switch(command)
		if(OPEN_DOORS)
			if( operating || welded || locked || seal )
				return FALSE
			if(!density)
				return TRUE
			SEND_SIGNAL(src, COMSIG_AIRLOCK_OPEN, FALSE)
			operating = TRUE
			playsound(src, doorOpen, vol = 40, vary = FALSE)
			update_icon(ALL, AIRLOCK_OPENING, TRUE)
			update_freelook_sight()
			sleep(0.7 SECONDS)
			set_density(FALSE)
			flags_1 &= ~PREVENT_CLICK_UNDER_1
			air_update_turf(TRUE, FALSE)
			layer = OPEN_DOOR_LAYER
			update_icon(ALL, AIRLOCK_OPEN, TRUE)
			operating = FALSE
			return TRUE

		if(CLOSE_DOORS)
			attempt++

			message_admins("TRAM: Door close attempt [attempt]")
			if(attempt >= 4 || rapid)
				attempt_cycle(rapid = TRUE)
				attempt = 0
				return

			if(attempt == 1)
				playsound(src, 'sound/machines/chime.ogg', 40, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

			addtimer(CALLBACK(src, PROC_REF(verify_status)), 3 SECONDS)
			attempt_cycle(rapid = FALSE)

/obj/machinery/door/airlock/tram/proc/verify_status()
	if(airlock_state != 1)
		if(attempt == 3)
			playsound(src, 'sound/machines/buzz-two.ogg', 60, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
			say("YOU'RE HOLDING UP THE TRAM, ASSHOLE!")
			cycle_tram_doors(CLOSE_DOORS, rapid = TRUE)
		else
			cycle_tram_doors(CLOSE_DOORS, rapid = FALSE)


/obj/machinery/door/airlock/tram/proc/attempt_cycle(rapid = FALSE)
	if(operating || welded || locked || seal)
		return FALSE
	if(density)
		return TRUE
	var/hungry_door = rapid || malfunctioning
	if((obj_flags & EMAGGED) || malfunctioning)
		do_sparks(6, TRUE, src)
		playsound(src, SFX_SPARKS, vol = 75, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		sleep(0.6 SECONDS)
	use_power(50)
	playsound(src, doorClose, vol = 40, vary = FALSE)
	SEND_SIGNAL(src, COMSIG_AIRLOCK_CLOSE)
	operating = TRUE
	layer = CLOSED_DOOR_LAYER
	update_icon(ALL, AIRLOCK_CLOSING, 1)
	sleep(1.4 SECONDS)
	if(!hungry_door)
		for(var/atom/movable/blocker in get_turf(src))
			if(blocker.density && blocker != src) //something is blocking the door
				say("Please stand clear of the doors!")
				playsound(src, 'sound/machines/buzz-sigh.ogg', 60, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
				layer = OPEN_DOOR_LAYER
				update_icon(ALL, AIRLOCK_OPEN, 1)
				operating = FALSE
				return FALSE
	sleep(0.6 SECONDS)
	set_density(TRUE)
	flags_1 |= PREVENT_CLICK_UNDER_1
	air_update_turf(TRUE, TRUE)
	crush()
	sleep(0.7 SECONDS)
	update_icon(ALL, AIRLOCK_CLOSED, 1)
	update_freelook_sight()
	operating = FALSE
	attempt = 0
	return TRUE

/obj/machinery/door/airlock/tram/proc/find_tram()
	for(var/datum/lift_master/lift as anything in GLOB.active_lifts_by_type[ICTS_TYPE_TRAM])
		if(lift.specific_lift_id == transport_linked_id)
			tram_ref = WEAKREF(lift)

/obj/machinery/door/airlock/tram/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)
	INVOKE_ASYNC(src, PROC_REF(open))
	GLOB.tram_doors += src
	// find_tram()

/obj/machinery/door/window/tram/Destroy()
	GLOB.tram_doors -= src
	return ..()

/obj/machinery/door/window/tram/examine(mob/user)
	. = ..()
	. += span_notice("It has labels indicating that it has an emergency mechanism to open using <b>just your hands</b> in the event of an emergency.")

/obj/machinery/door/window/tram/try_safety_unlock(mob/user)
	if(!hasPower()  && density)
		balloon_alert(user, "pulling emergency exit...")
		if(do_after(user, 7 SECONDS, target = src))
			try_to_crowbar(null, user, TRUE)
			return TRUE

/obj/machinery/door/window/tram/bumpopen(mob/user)
	if(operating || !density)
		return
	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	add_fingerprint(user)
	if(tram_part.travel_distance < XING_DEFAULT_TRAM_LENGTH || tram_part.travel_distance > tram_part.travel_trip_length - XING_DEFAULT_TRAM_LENGTH)
		return // we're already animating, don't reset that
	open(forced = BYPASS_DOOR_CHECKS) //making a daring exit midtravel? make sure the doors don't go in the wrong state on arrival.
	return

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/tram/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/tram/right, 0)

#undef AIRLOCK_CLOSED
#undef AIRLOCK_CLOSING
#undef AIRLOCK_OPENING
#undef AIRLOCK_DENY
#undef AIRLOCK_EMAG
#undef AIRLOCK_SECURITY_TRAM
