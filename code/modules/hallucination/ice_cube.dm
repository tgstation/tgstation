/// Causes the hallucinator to believe themselves frozen in ice. Man am I glad he's frozen in there etc etc
/datum/hallucination/ice
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_COMMON

	/// What icon file to use for our hallucinator
	var/ice_icon = 'icons/effects/freeze.dmi'
	/// What icon state to use for our hallucinator
	var/ice_icon_state = "ice_cube"
	/// Our ice overlay we generate
	var/image/ice_overlay
	/// How long will we be frozen today
	var/ice_duration
	/// Will we play the ice freeze sound?
	var/play_ice_sound

/datum/hallucination/ice/New(mob/living/hallucinator, duration = 6 SECONDS, play_freeze_sound = TRUE)
	src.ice_duration = duration
	src.play_ice_sound = play_freeze_sound
	return ..()

/datum/hallucination/ice/start()
	ice_overlay = image(ice_icon, hallucinator, ice_icon_state, ABOVE_MOB_LAYER)
	SET_PLANE_EXPLICIT(ice_overlay, ABOVE_GAME_PLANE, hallucinator)
	hallucinator.client?.images |= ice_overlay
	ADD_TRAIT(hallucinator, TRAIT_IMMOBILIZED, HALLUCINATION_TRAIT)
	to_chat(hallucinator, span_userdanger("You become frozen in a cube!"))
	hallucinator.cause_hallucination(/datum/hallucination/fake_alert/cold, "ice hallucination", duration = (ice_duration + 6 SECONDS))
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
