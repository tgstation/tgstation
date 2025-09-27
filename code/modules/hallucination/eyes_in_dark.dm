/datum/hallucination/eyes_in_dark
	random_hallucination_weight = 2
	hallucination_tier = HALLUCINATION_TIER_COMMON
	/// The floating eye effect, somewhere in the world
	var/obj/effect/abstract/floating_eyes/eyes

/datum/hallucination/eyes_in_dark/Destroy()
	if(QDELETED(eyes))
		eyes = null
	else
		QDEL_NULL(eyes)
	return ..()

/datum/hallucination/eyes_in_dark/start()
	if(!hallucinator.client)
		return FALSE

	if(hallucinator.lighting_cutoff >= 2.5)
		return FALSE

	var/list/valid = list()
	for(var/turf/open/nearby in view(hallucinator))
		if(nearby.get_lumcount() > LIGHTING_TILE_IS_DARK)
			continue
		valid += nearby

	if(!length(valid))
		return FALSE

	if(prob(5))
		to_chat(hallucinator, span_warning("You feel like you're being watched..."))

	var/turf/selected = pick(valid)
	feedback_details += "Eye coords: [selected.x], [selected.y], [selected.z]"
	eyes = new(selected, hallucinator)
	RegisterSignal(eyes, COMSIG_QDELETING, PROC_REF(end_hallucination))
	addtimer(CALLBACK(src, PROC_REF(end_hallucination_gracefully)), rand(60 SECONDS, 180 SECONDS))
	return TRUE

/datum/hallucination/eyes_in_dark/proc/end_hallucination_gracefully()
	animate(eyes, alpha = 0, time = 1 SECONDS)
	QDEL_IN(src, 1.2 SECONDS)

/datum/hallucination/eyes_in_dark/proc/end_hallucination()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/obj/effect/abstract/floating_eyes
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// Who sees the eyes?
	var/datum/weakref/seer_ref

/obj/effect/abstract/floating_eyes/Initialize(mapload, mob/seer)
	. = ..()
	if(isnull(seer))
		return INITIALIZE_HINT_QDEL

	seer_ref = WEAKREF(seer)
	var/image/make_invis = image(icon = null, icon_state = null, loc = src)
	make_invis.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/one_person/reversed, "hallucination", make_invis, null, seer)
	START_PROCESSING(SSfastprocess, src)
	update_appearance()

/obj/effect/abstract/floating_eyes/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/abstract/floating_eyes/update_overlays()
	. = ..()
	var/mutable_appearance/r_eye = mutable_appearance(icon = 'icons/mob/human/human_face.dmi', icon_state = "eyes_glow_r")
	r_eye.color = COLOR_DARK_RED
	. += r_eye
	var/mutable_appearance/l_eye = mutable_appearance(icon = 'icons/mob/human/human_face.dmi', icon_state = "eyes_glow_l")
	l_eye.color = COLOR_DARK_RED
	. += l_eye

	. += emissive_appearance('icons/mob/human/human_face.dmi', "eyes_glow_l", src)
	. += emissive_appearance('icons/mob/human/human_face.dmi', "eyes_glow_r", src)

/obj/effect/abstract/floating_eyes/process(seconds_per_tick)
	var/turf/below_us = get_turf(src)
	var/mob/seer = seer_ref?.resolve()
	if(below_us.get_lumcount() > LIGHTING_TILE_IS_DARK || seer?.lighting_cutoff >= 2.5 || get_dist(seer, src) <= 1)
		graceful_delete()

/obj/effect/abstract/floating_eyes/proc/graceful_delete()
	STOP_PROCESSING(SSfastprocess, src)
	animate(src, alpha = 0, time = 0.5 SECONDS)
	QDEL_IN(src, 0.75 SECONDS)
