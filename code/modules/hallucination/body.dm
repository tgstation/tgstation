/// Makes a random body appear and disappear quickly.
/datum/hallucination/body
	abstract_hallucination_parent = /datum/hallucination/body
	/// The file to make the body image from.
	var/body_image_file
	/// The icon state to make the body image form.
	var/body_image_state
	/// The actual image we made and showed show.
	var/image/shown_body

/datum/hallucination/body/start()
	// This hallucination is purely visual, so we don't need to bother for clientless mobs
	if(!hallucinator.client)
		return FALSE

	var/list/possible_points = list()
	for(var/turf/open/floor/open_floor in view(hallucinator))
		possible_points += open_floor

	if(!length(possible_points))
		return FALSE

	shown_body = make_body_image(pick(possible_points))

	hallucinator.client?.images |= shown_body
	QDEL_IN(src, rand(3 SECONDS, 5 SECONDS)) //Only seen for a brief moment.
	return TRUE

/datum/hallucination/body/Destroy()
	hallucinator.client?.images -= shown_body
	shown_body = null
	return ..()

/// Makes the image of the body to show at the location passed.
/datum/hallucination/body/proc/make_body_image(turf/location)
	return image(body_image_file, location, body_image_state, TURF_LAYER)

/datum/hallucination/body/husk
	random_hallucination_weight = 4
	body_image_file = 'icons/mob/human.dmi'
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
	body_image_file = 'icons/mob/alien.dmi'
	body_image_state = "alienother"
