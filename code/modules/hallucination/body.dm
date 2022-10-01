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

/datum/hallucination/body/start()
	// This hallucination is purely visual, so we don't need to bother for clientless mobs
	if(!hallucinator.client)
		return FALSE

	var/list/possible_points = list()
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
	return queue_clean_up()

/datum/hallucination/body/proc/queue_clean_up()
	QDEL_IN(src, rand(3 SECONDS, 5 SECONDS)) //Only seen for a brief moment.
	return TRUE

/datum/hallucination/body/Destroy()
	hallucinator.client?.images -= shown_body
	shown_body = null
	return ..()

/// Makes the image of the body to show at the location passed.
/datum/hallucination/body/proc/make_body_image(turf/location)
	var/image/created_image = image(body_image_file, location, body_image_state, TURF_LAYER)
	if(body_floats)
		DO_FLOATING_ANIM(created_image)
	return created_image

/datum/hallucination/body/husk
	random_hallucination_weight = 8
	body_image_file = 'icons/mob/species/human/human.dmi'
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

/datum/hallucination/body/staticguy/queue_clean_up()
	RegisterSignal(hallucinator, COMSIG_MOVABLE_MOVED, .proc/on_move)
	del_timerid = QDEL_IN(src, rand(2 MINUTES, 3 MINUTES))
	return TRUE

/// Signal proc for [COMSIG_MOVABLE_MOVED] - if we move out of view of the hallucination, it disappears, how spooky
/datum/hallucination/body/staticguy/proc/on_move(datum/source)
	SIGNAL_HANDLER

	// Entering its turf will cause it to fade out then delete
	if(shown_body.loc == hallucinator.loc)
		animate(shown_body, alpha = 0, time = 0.5 SECONDS)
		deltimer(del_timerid)
		del_timerid = QDEL_IN(src, 0.6 SECONDS)
		return

	// Staying in view will do nothing
	if(shown_body.loc in view(hallucinator))
		return

	// Leaving view will delete it immediately
	deltimer(del_timerid)
	del_timerid = null
	qdel(src)

/datum/hallucination/body/weird
	random_hallucination_weight = 0.15 // These are very uncommon
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
	body_image_file = 'icons/mob/simple/simple_human.dmi'
	body_image_state = "faceless"

/datum/hallucination/body/weird/bones
	body_image_file = 'icons/mob/simple/simple_human.dmi'
	body_image_state = "mrbones"
