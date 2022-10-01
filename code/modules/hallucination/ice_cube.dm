/// Causes the hallucinator to believe themselves frozen in ice. Man am I glad he's frozen in there etc etc
/datum/hallucination/ice
	random_hallucination_weight = 3

	/// What icon file to use for our hallucinator
	var/ice_icon = 'icons/effects/freeze.dmi'
	/// What icon state to use for our hallucinator
	var/ice_icon_state = "ice_cube"
	/// Our ice overlay we generate
	var/image/ice_overlay
	/// How long will we be frozen today
	var/ice_duration = 6 SECONDS
	/// Will we play the ice freeze sound?
	var/play_ice_sound = TRUE

/datum/hallucination/ice/start()
	ice_overlay = image(ice_icon, hallucinator, ice_icon_state, ABOVE_MOB_LAYER)
	hallucinator.client?.images |= ice_overlay
	ADD_TRAIT(hallucinator, TRAIT_IMMOBILIZED, HALLUCINATION_TRAIT)
	to_chat(hallucinator, span_userdanger("You become frozen in a cube!"))
	hallucinator.cause_hallucination(/datum/hallucination/fake_alert/cold, "ice hallucination")
	/datum/hallucination/fake_alert/cold
	if(play_ice_sound)
		hallucinator.cause_hallucination(/datum/hallucination/fake_sound/weird/ice_crack, "ice hallucination")

	hallucinator.set_jitter_if_lower(ice_duration + 6 SECONDS)
	hallucinator.set_stutter_if_lower(ice_duration + 6 SECONDS)

	QDEL_IN(src, ice_duration)
	return TRUE

/datum/hallucination/ice/Destroy()
	unfreeze()
	return ..()

/datum/hallucination/ice/proc/unfreeze()
	REMOVE_TRAIT(hallucinator, TRAIT_IMMOBILIZED, HALLUCINATION_TRAIT)
	if(ice_overlay)
		hallucinator.client?.images -= ice_overlay
		ice_overlay = null

/datum/hallucination/ice/freezer
	random_hallucination_weight = 0
	ice_duration = 11 SECONDS
	play_ice_sound = FALSE
