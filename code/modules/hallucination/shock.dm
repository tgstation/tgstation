/// Causes a fake "zap" to the hallucinator.
/datum/hallucination/shock
	random_hallucination_weight = 1

	var/electrocution_icon = 'icons/mob/human/human.dmi'
	var/electrocution_icon_state = "electrocuted_base"
	var/image/shock_image
	var/image/electrocution_skeleton_anim

/datum/hallucination/shock/New(mob/living/hallucinator)
	electrocution_icon_state = ishuman(hallucinator) ? "electrocuted_base" : "electrocuted_generic"
	return ..()

/datum/hallucination/shock/Destroy()
	if(shock_image)
		hallucinator.client?.images -= shock_image
		shock_image = null
	if(electrocution_skeleton_anim)
		hallucinator.client?.images -= electrocution_skeleton_anim
		electrocution_skeleton_anim = null

	return ..()

/datum/hallucination/shock/start()
	shock_image = image(hallucinator, hallucinator, dir = hallucinator.dir)
	shock_image.appearance_flags |= KEEP_APART
	shock_image.color = rgb(0, 0, 0)
	shock_image.override = TRUE

	electrocution_skeleton_anim = image(electrocution_icon, hallucinator, icon_state = electrocution_icon_state, layer = ABOVE_MOB_LAYER)
	electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART

	to_chat(hallucinator, span_userdanger("You feel a powerful shock course through your body!"))
	hallucinator.visible_message(span_warning("[hallucinator] falls to the ground, shaking!"), ignored_mobs = hallucinator)
	hallucinator.client?.images |= shock_image
	hallucinator.client?.images |= electrocution_skeleton_anim

	hallucinator.playsound_local(get_turf(src), SFX_SPARKS, 100, TRUE)
	hallucinator.adjustStaminaLoss(50)
	hallucinator.Stun(4 SECONDS)
	hallucinator.do_jitter_animation(300) // Maximum jitter
	hallucinator.adjust_jitter(20 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(reset_shock_animation)), 4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(shock_drop)), 2 SECONDS)
	QDEL_IN(src, 4 SECONDS)
	return TRUE

/datum/hallucination/shock/proc/reset_shock_animation()
	if(QDELETED(hallucinator))
		return

	hallucinator.client?.images -= shock_image
	shock_image = null

	hallucinator.client?.images -= electrocution_skeleton_anim
	electrocution_skeleton_anim = null

/datum/hallucination/shock/proc/shock_drop()
	if(QDELETED(hallucinator))
		return

	hallucinator.Paralyze(6 SECONDS)
