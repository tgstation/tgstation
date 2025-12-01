/datum/hallucination/blood_flow
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_COMMON
	/// The bleeding hallucination's image
	var/image/bleeding
	/// Ref to the bleeding bodypart, necessary to unregister signals
	var/obj/item/bodypart/bleeding_bodypart

/datum/hallucination/blood_flow/start()
	if(!hallucinator.client || !iscarbon(hallucinator))
		return FALSE

	var/mob/living/carbon/carb_hallucinator = hallucinator
	if(!length(carb_hallucinator.bodyparts) || !carb_hallucinator.can_bleed())
		return FALSE

	var/obj/item/bodypart/picked
	var/list/bodyparts = carb_hallucinator.bodyparts.Copy()
	while(isnull(picked) && length(bodyparts))
		picked = pick_n_take(bodyparts)
		if(!picked.can_bleed())
			picked = null

	if(isnull(picked))
		return FALSE

	bleeding_bodypart = picked

	feedback_details += "Bleeding: [bleeding_bodypart]"

	RegisterSignals(bleeding_bodypart, list(COMSIG_QDELETING, COMSIG_BODYPART_REMOVED), PROC_REF(stop_bleeding))
	RegisterSignal(hallucinator, COMSIG_LIVING_UPDATE_BLOOD_STATUS, PROC_REF(stop_bleeding))

	to_chat(hallucinator, span_warning("Your [bleeding_bodypart.plaintext_zone] looses a spray of blood!"))
	var/bleed_duration = rand(16 SECONDS, 40 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(stop_bleeding)), bleed_duration)
	if(prob(25))
		addtimer(CALLBACK(src, PROC_REF(by_god)), bleed_duration * pick(0.5, 0.66))
	stamina_loop()

	hallucinator.playsound_local(get_turf(hallucinator), pick('sound/effects/wounds/blood1.ogg', 'sound/effects/wounds/blood2.ogg', 'sound/effects/wounds/blood3.ogg'), 50, TRUE)
	bleeding = image(
		icon = 'icons/mob/effects/bleed_overlays.dmi',
		icon_state = "[bleeding_bodypart.body_zone]_[pick(2, 3)]",
		loc = hallucinator,
	)
	bleeding.color = carb_hallucinator.get_bloodtype()?.get_wound_color(carb_hallucinator) || BLOOD_COLOR_RED
	bleeding.layer = -WOUND_LAYER
	hallucinator.client?.images += bleeding
	return TRUE

/datum/hallucination/blood_flow/Destroy()
	hallucinator.client?.images -= bleeding
	return ..()

/datum/hallucination/blood_flow/proc/by_god()
	if(QDELETED(src) || QDELETED(hallucinator) || QDELETED(bleeding_bodypart))
		return

	to_chat(hallucinator, span_warning("The blood doesn't stop flowing, yet [bleeding_bodypart.plaintext_zone] doesn't seem to hurt..."))

/datum/hallucination/blood_flow/proc/on_update_blood_status(datum/source, had_blood, has_blood, old_blood_volume, new_blood_volume)
	SIGNAL_HANDLER
	if (!has_blood)
		stop_bleeding()

/datum/hallucination/blood_flow/proc/stop_bleeding()
	SIGNAL_HANDLER
	UnregisterSignal(bleeding_bodypart, list(COMSIG_QDELETING, COMSIG_BODYPART_REMOVED))
	UnregisterSignal(hallucinator, COMSIG_LIVING_UPDATE_BLOOD_STATUS)
	if(!QDELETED(bleeding_bodypart))
		to_chat(hallucinator, span_warning("Your [bleeding_bodypart.plaintext_zone] stops bleeding."))
	if(!QDELETED(src))
		qdel(src)

/datum/hallucination/blood_flow/proc/stamina_loop()
	set waitfor = FALSE
	while(!QDELETED(src) && !QDELETED(hallucinator))
		hallucinator.adjust_stamina_loss(5)
		sleep(4 SECONDS)
