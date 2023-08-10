/obj/machinery/door/window/tram
	name = "tram door"
	desc = "Probably won't crush you if you try to rush them as they close. But we know you live on that danger, try and beat the tram!"
	icon = 'icons/obj/doors/tramdoor.dmi'
	req_access = list("tcomms")
	multi_tile = TRUE
	var/associated_lift = MAIN_STATION_TRAM
	var/datum/weakref/tram_ref
	/// Are the doors in a malfunctioning state (dangerous)
	var/malfunctioning = FALSE

/obj/machinery/door/window/tram/left
	icon_state = "left"
	base_state = "left"

/obj/machinery/door/window/tram/left/directional/south
	plane = WALL_PLANE_UPPER

/obj/machinery/door/window/tram/right
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/tram/hilbert
	icon = 'icons/obj/mining_zones/survival_pod.dmi'
	associated_lift = HILBERT_TRAM
	icon_state = "windoor"
	base_state = "windoor"

/obj/machinery/door/window/tram/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "disabled motion sensors")
	obj_flags |= EMAGGED
	return TRUE

/// Random event called by code\modules\events\tram_malfunction.dm
/// Makes the doors malfunction
/obj/machinery/door/window/tram/proc/start_malfunction()
	if(obj_flags & EMAGGED)
		return

	malfunctioning = TRUE
	process()

/// Random event called by code\modules\events\tram_malfunction.dm
/// Returns doors to their original status
/obj/machinery/door/window/tram/proc/end_malfunction()
	if(obj_flags & EMAGGED)
		return

	malfunctioning = FALSE
	process()

/obj/machinery/door/window/tram/proc/cycle_doors(command, forced=FALSE)
	if(command == "open" && icon_state == "[base_state]open")
		if(!forced && !hasPower())
			return FALSE
		return TRUE
	if(command == "close" && icon_state == base_state)
		return TRUE
	switch(command)
		if("open")
			playsound(src, 'sound/machines/tramopen.ogg', vol = 75, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
			do_animate("opening")
			icon_state ="[base_state]open"
			sleep(7 DECISECONDS)
			set_density(FALSE)
			air_update_turf(TRUE, FALSE)
		if("close")
			if((obj_flags & EMAGGED) || malfunctioning)
				flick("[base_state]spark", src)
				playsound(src, SFX_SPARKS, vol = 75, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
				sleep(6 DECISECONDS)
			playsound(src, 'sound/machines/tramclose.ogg', vol = 75, vary = FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
			do_animate("closing")
			icon_state = base_state
			sleep(19 DECISECONDS)
			if((obj_flags & EMAGGED) || malfunctioning)
				if(malfunctioning && prob(85))
					return
				for(var/i in 1 to 3)
					for(var/mob/living/crushee in get_turf(src))
						crush()
					sleep(2 DECISECONDS)
			air_update_turf(TRUE, TRUE)
			operating = FALSE
			set_density(TRUE)

	update_freelook_sight()
	return TRUE

/obj/machinery/door/window/tram/right/directional/south
	plane = WALL_PLANE_UPPER

/obj/machinery/door/window/tram/proc/find_tram()
	for(var/datum/lift_master/lift as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(lift.specific_lift_id == associated_lift)
			tram_ref = WEAKREF(lift)

/obj/machinery/door/window/tram/Initialize(mapload, set_dir, unres_sides)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive, mapload)
	if(filler)
		filler.set_density(FALSE) // tram doors allow you to stand on the tile
	INVOKE_ASYNC(src, PROC_REF(open))
	GLOB.tram_doors += src
	find_tram()

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
	cycle_doors(OPEN_DOORS, TRUE) //making a daring exit midtravel? make sure the doors don't go in the wrong state on arrival.
	return

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/tram/left, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/tram/right, 0)
