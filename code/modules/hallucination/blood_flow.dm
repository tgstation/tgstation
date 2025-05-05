/datum/hallucination/blood_flow
	random_hallucination_weight = 3
	hallucination_tier = HALLUCINATION_TIER_COMMON
	/// The bleeding hallucination's image
	var/image/bleeding

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

	feedback_details += "Bleeding: [picked]"

	RegisterSignals(picked, list(COMSIG_QDELETING, COMSIG_BODYPART_REMOVED), PROC_REF(stop_bleeding))
	RegisterSignal(hallucinator, SIGNAL_ADDTRAIT(TRAIT_NOBLOOD), PROC_REF(stop_bleeding))

	to_chat(hallucinator, span_warning("Your [picked.plaintext_zone] looses a spray of blood!"))
	var/bleed_duration = rand(16 SECONDS, 40 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(stop_bleeding), picked), bleed_duration)
	if(prob(25))
		addtimer(CALLBACK(src, PROC_REF(by_god), picked), bleed_duration * pick(0.5, 0.66))
	stamina_loop()

	hallucinator.playsound_local(get_turf(hallucinator), pick('sound/effects/wounds/blood1.ogg', 'sound/effects/wounds/blood2.ogg', 'sound/effects/wounds/blood3.ogg'), 50, TRUE)
	bleeding = image(
		icon = 'icons/mob/effects/bleed_overlays.dmi',
		icon_state = "[picked.body_zone]_[pick(2, 3)]",
		loc = hallucinator,
	)
	bleeding.color = carb_hallucinator.get_bloodtype()?.get_wound_color(carb_hallucinator) || BLOOD_COLOR_RED
	bleeding.layer = -WOUND_LAYER
	hallucinator.client?.images += bleeding
	return TRUE

/datum/hallucination/blood_flow/Destroy()
	hallucinator.client?.images -= bleeding
	return ..()

/datum/hallucination/blood_flow/proc/by_god(obj/item/bodypart/picked)
	if(QDELETED(src) || QDELETED(hallucinator) || QDELETED(picked))
		return

	to_chat(hallucinator, span_warning("The blood doesn't stop flowing, yet [picked.plaintext_zone] doesn't seem to hurt..."))

/datum/hallucination/blood_flow/proc/stop_bleeding(obj/item/bodypart/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_BODYPART_REMOVED))
	UnregisterSignal(hallucinator, SIGNAL_ADDTRAIT(TRAIT_NOBLOOD))
	if(!QDELETED(source))
		to_chat(hallucinator, span_warning("Your [source.plaintext_zone] stops bleeding."))
	if(!QDELETED(src))
		qdel(src)

/datum/hallucination/blood_flow/proc/stamina_loop()
	set waitfor = FALSE
	while(!QDELETED(src) && !QDELETED(hallucinator))
		hallucinator.adjustStaminaLoss(5)
		sleep(4 SECONDS)
