/// Makes a random body appear and disappear quickly in view of the hallucinator.
/datum/hallucination/body
	abstract_hallucination_parent = /datum/hallucination/body
	/// The file to make the body image from.
	var/body_image_file
	/// The icon state to make the body image form.
	var/body_image_state
	/// The actual image we made and showed show.
	var/image/shown_body
	/// Whether we apply the floating anim to the body
	var/body_floats = FALSE
	/// The layer this body will be drawn on, in case we want to bypass lighting
	var/body_layer = TURF_LAYER
	/// if TRUE, spawns the body under the hallucinator instead of somewhere in view
	var/spawn_under_hallucinator = FALSE

/datum/hallucination/body/start()
	// This hallucination is purely visual, so we don't need to bother for clientless mobs
	if(!hallucinator.client)
		return FALSE

	var/list/possible_points = list()
	if(spawn_under_hallucinator)
		possible_points += get_turf(hallucinator)
	else
		for(var/turf/open/open_turf in view(hallucinator))
			if(open_turf.is_blocked_turf())
				continue
			possible_points += open_turf

	if(!length(possible_points))
		return FALSE

	var/turf/picked = pick(possible_points)
	if(isspaceturf(picked) || !picked.has_gravity())
		body_floats = TRUE

	shown_body = make_body_image(picked)

	hallucinator.client?.images |= shown_body
	return queue_cleanup()

/datum/hallucination/body/proc/queue_cleanup()
	QDEL_IN(src, rand(3 SECONDS, 5 SECONDS)) //Only seen for a brief moment.
	return TRUE

/datum/hallucination/body/Destroy()
	hallucinator.client?.images -= shown_body
	shown_body = null
	return ..()

/// Makes the image of the body to show at the location passed.
/datum/hallucination/body/proc/make_body_image(turf/location)
	var/image/created_image = image(body_image_file, location, body_image_state, body_layer)
	if(body_floats)
		DO_FLOATING_ANIM(created_image)
	return created_image

/datum/hallucination/body/husk
	random_hallucination_weight = 8
	body_image_file = 'icons/mob/human/human.dmi'
	body_image_state = "husk"

/datum/hallucination/body/husk/sideways
	random_hallucination_weight = 4

/datum/hallucination/body/husk/sideways/make_body_image(turf/location)
	var/image/body = ..()
	var/matrix/turn_matrix = matrix()
	turn_matrix.Turn(90)
	body.transform = turn_matrix
	return body

/datum/hallucination/body/ghost
	random_hallucination_weight = 2
	body_image_file = 'icons/mob/simple/mob.dmi'
	body_image_state = "ghost"
	body_floats = TRUE

/datum/hallucination/body/hole
	random_hallucination_weight = 1
	body_image_file = 'icons/effects/effects.dmi'
	body_image_state = "blank"

/datum/hallucination/body/staticguy
	random_hallucination_weight = 1
	body_image_file = 'icons/effects/effects.dmi'
	body_image_state = "static"
	/// Our QDEL_IN timer id, so we can cancel it
	var/del_timerid

/datum/hallucination/body/staticguy/Destroy()
	if(!QDELETED(hallucinator))
		UnregisterSignal(hallucinator, COMSIG_MOVABLE_MOVED)
	if(del_timerid)
		deltimer(del_timerid)
		del_timerid = null
	return ..()

/datum/hallucination/body/staticguy/queue_cleanup()
	RegisterSignal(hallucinator, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	del_timerid = QDEL_IN_STOPPABLE(src, rand(2 MINUTES, 3 MINUTES))
	return TRUE

/// Signal proc for [COMSIG_MOVABLE_MOVED] - if we move out of view of the hallucination, it disappears, how spooky
/datum/hallucination/body/staticguy/proc/on_move(datum/source)
	SIGNAL_HANDLER

	// Entering its turf will cause it to fade out then delete
	if(shown_body.loc == hallucinator.loc)
		animate(shown_body, alpha = 0, time = 0.5 SECONDS)
		deltimer(del_timerid)
		del_timerid = QDEL_IN_STOPPABLE(src, 0.6 SECONDS)
		return

	// Staying in view will do nothing
	if(shown_body.loc in view(hallucinator))
		return

	// Leaving view will delete it immediately
	deltimer(del_timerid)
	del_timerid = null
	qdel(src)

/datum/hallucination/body/weird
	random_hallucination_weight = 0.1 // These are very uncommon
	abstract_hallucination_parent = /datum/hallucination/body/weird

/datum/hallucination/body/weird/alien
	body_image_file = 'icons/mob/nonhuman-player/alien.dmi'
	body_image_state = "alienother"
	body_floats = TRUE

/datum/hallucination/body/weird/mini_bubblegum
	body_image_file = 'icons/mob/simple/mob.dmi'
	body_image_state = "horror"

/datum/hallucination/body/weird/chrono
	body_image_file = 'icons/mob/simple/mob.dmi'
	body_image_state = "chronostuck"
	body_floats = TRUE

/datum/hallucination/body/weird/god
	body_image_file = 'icons/mob/simple/mob.dmi'
	body_image_state = "god"
	body_floats = TRUE

/datum/hallucination/body/weird/sling
	body_image_file = 'icons/mob/simple/mob.dmi'
	body_image_state = "shadowling_ascended"
	body_floats = TRUE

/datum/hallucination/body/weird/faceless
	body_image_file = 'icons/mob/simple/traders.dmi'
	body_image_state = "faceless"

/datum/hallucination/body/weird/bones
	body_image_file = 'icons/mob/simple/traders.dmi'
	body_image_state = "mrbones"

/datum/hallucination/body/weird/freezer
	random_hallucination_weight = 0.3 // Slightly more common since it's cool (heh)
	body_image_file = 'icons/effects/effects.dmi'
	body_image_state = "the_freezer"
	body_layer = ABOVE_ALL_MOB_LAYER
	spawn_under_hallucinator = TRUE

/datum/hallucination/body/weird/freezer/make_body_image(turf/location)
	var/image/body = ..()
	body.pixel_x = pick(rand(-208,-48), rand(48, 208))
	body.pixel_y = pick(rand(-208,-48), rand(48, 208))
	body.alpha = 245
	SET_PLANE_EXPLICIT(body, ABOVE_HUD_PLANE, location)
	return body

/datum/hallucination/body/weird/freezer/queue_cleanup()
	QDEL_IN(src, 12 SECONDS) //The freezer stays on screen while you're frozen
	addtimer(CALLBACK(src, PROC_REF(freeze_player)), 1 SECONDS) // You barely have a moment to react before you're frozen
	addtimer(CALLBACK(src, PROC_REF(freeze_intimidate)), 11.8 SECONDS)
	hallucinator.cause_hallucination(/datum/hallucination/fake_sound/weird/radio_static, "freezer hallucination")
	return TRUE

/datum/hallucination/body/weird/freezer/proc/freeze_player()
	if(QDELETED(src))
		return
	hallucinator.cause_hallucination(/datum/hallucination/ice, "freezer hallucination", duration = 11 SECONDS, play_freeze_sound = FALSE)

/datum/hallucination/body/weird/freezer/proc/freeze_intimidate()
	if(QDELETED(src))
		return
	// Spook 'em before we delete
	shown_body.pixel_x = (shown_body.pixel_x / 2)
	shown_body.pixel_y = (shown_body.pixel_y / 2)
