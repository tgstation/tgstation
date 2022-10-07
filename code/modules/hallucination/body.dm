/// Makes a random body appear and disappear quickly.
/datum/hallucination/body
	abstract_hallucination_parent = /datum/hallucination/body
	/// The file to make the body image from.
	var/body_image_file
	/// The icon state to make the body image form.
	var/body_image_state
	/// The actual image we made and showed show.
	var/image/shown_body
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
		for(var/turf/open/floor/open_floor in view(hallucinator))
			possible_points += open_floor

	if(!length(possible_points))
		return FALSE

	shown_body = make_body_image(pick(possible_points))

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
	return image(body_image_file, location, body_image_state, body_layer)

/datum/hallucination/body/husk
	random_hallucination_weight = 4
	body_image_file = 'icons/mob/species/human/human.dmi'
	body_image_state = "husk"

/datum/hallucination/body/husk/sideways
	random_hallucination_weight = 2

/datum/hallucination/body/husk/sideways/make_body_image(turf/location)
	var/image/body = ..()
	var/matrix/turn_matrix = matrix()
	turn_matrix.Turn(90)
	body.transform = turn_matrix
	return body

/datum/hallucination/body/alien
	random_hallucination_weight = 1
	body_image_file = 'icons/mob/nonhuman-player/alien.dmi'
	body_image_state = "alienother"

/datum/hallucination/body/freezer
	random_hallucination_weight = 1
	body_image_file = 'icons/effects/effects.dmi'
	body_image_state = "the_freezer"
	body_layer = ABOVE_ALL_MOB_LAYER
	spawn_under_hallucinator = TRUE

/datum/hallucination/body/freezer/make_body_image(turf/location)
	var/image/body = ..()
	body.pixel_x = pick(rand(-208,-48), rand(48, 208))
	body.pixel_y = pick(rand(-208,-48), rand(48, 208))
	body.alpha = 245
	SET_PLANE_EXPLICIT(body, ABOVE_HUD_PLANE, location)
	return body

/datum/hallucination/body/freezer/queue_cleanup()
	QDEL_IN(src, 12 SECONDS) //The freezer stays on screen while you're frozen
	addtimer(CALLBACK(src, .proc/freeze_player), 1 SECONDS) // You barely have a moment to react before you're frozen
	addtimer(CALLBACK(src, .proc/freeze_intimidate), 11.8 SECONDS)
	hallucinator.cause_hallucination(/datum/hallucination/fake_sound/weird/radio_static, "freezer hallucination")
	return TRUE

/datum/hallucination/body/freezer/proc/freeze_player()
	if(QDELETED(src))
		return
	hallucinator.cause_hallucination(/datum/hallucination/ice, "freezer hallucination", duration = 11 SECONDS, play_freeze_sound = FALSE)


/datum/hallucination/body/freezer/proc/freeze_intimidate()
	if(QDELETED(src))
		return
	// Spook 'em before we delete
	shown_body.pixel_x = (shown_body.pixel_x / 2)
	shown_body.pixel_y = (shown_body.pixel_y / 2)
