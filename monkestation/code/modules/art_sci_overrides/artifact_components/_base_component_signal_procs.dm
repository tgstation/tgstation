/datum/component/artifact/proc/on_destroy(atom/source)
	SIGNAL_HANDLER
	UnregisterSignal(holder, COMSIG_IN_RANGE_OF_IRRADIATION)
	if(!QDELETED(holder))
		holder.loc.visible_message(span_warning("[holder] [artifact_origin.destroy_message]"))
	artifact_deactivate(TRUE)
	for(var/datum/artifact_effect/effect in artifact_effects)
		effect.on_destroy(source)
	if(!QDELETED(holder))
		qdel(holder)

/datum/component/artifact/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(explict_examine)
		examine_list += explict_examine
	for(var/datum/artifact_effect/effect in artifact_effects)
		if(discovered_effects.Find(effect.type))
			examine_list += effect.examine_discovered
		else
			examine_list += effect.examine_hint

	for(var/datum/artifact_activator/act in activators)
		if(discovered_activators.Find(act.type))
			examine_list += act.discovered_text
		else
			examine_list += pick(act.hint_texts)

	if(chosen_fault && chosen_fault.inspect_warning)
		examine_list += pick(chosen_fault.inspect_warning)

/datum/component/artifact/proc/on_sticker(atom/source, obj/item/sticker/sticker, mob/user)
	SIGNAL_HANDLER
	if(analysis)
		to_chat(user, "You peel off [analysis], to make room for [sticker].")
		sticker.peel()
	if(!istype(sticker, /obj/item/sticker/analysis_form))
		return
	analysis = sticker

/datum/component/artifact/proc/on_desticker(atom/source)
	SIGNAL_HANDLER
	analysis = null

/// Used to maintain the acid overlay on the parent [/atom].
/datum/component/artifact/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if(!extra_effect)
		return
	overlays += extra_effect

/datum/component/artifact/proc/on_unarmed(atom/source, mob/living/user)
	SIGNAL_HANDLER
	if(!user.Adjacent(holder))
		return
	if(isAI(user) || isobserver(user)) //sanity
		return

	if(user.pulling && isliving(user.pulling))
		if((user.istate & ISTATE_HARM) && user.pulling.Adjacent(holder) && user.grab_state > GRAB_PASSIVE)
			holder.visible_message(span_warning("[user] forcefully shoves [user.pulling] against the [holder]!"))
			on_unarmed(source, user.pulling)
		else if(!(user.istate & ISTATE_HARM))
			holder.visible_message(span_notice("[user] gently pushes [user.pulling] against the [holder]."))
			process_stimuli(STIMULUS_CARBON_TOUCH)
			logger.Log(LOG_CATEGORY_ARTIFACT, "[user] has pushed [user.pulling] into [parent]")
		return

	if(artifact_size == ARTIFACT_SIZE_LARGE) //only large artifacts since the average spessman wouldnt notice)
		user.visible_message(span_notice("[user] touches [holder]."))

	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		var/obj/item/bodypart/arm = human.get_active_hand()
		if(arm.bodytype & BODYTYPE_ROBOTIC)
			process_stimuli(STIMULUS_SILICON_TOUCH)
			logger.Log(LOG_CATEGORY_ARTIFACT, "[user] has touched [parent] with [arm]")
		else
			process_stimuli(STIMULUS_CARBON_TOUCH)
			logger.Log(LOG_CATEGORY_ARTIFACT, "[user] has touched [parent] with [arm]")
	else if(iscarbon(user))
		process_stimuli(STIMULUS_CARBON_TOUCH)
		logger.Log(LOG_CATEGORY_ARTIFACT, "[user] has touched [parent]")
	else if(issilicon(user))
		process_stimuli(STIMULUS_SILICON_TOUCH)
		logger.Log(LOG_CATEGORY_ARTIFACT, "[user] has touched [parent]")

	process_stimuli(STIMULUS_FORCE, 1)
	logger.Log(LOG_CATEGORY_ARTIFACT, "[user] has touched [parent]")

	if(active)
		for(var/datum/artifact_effect/effect in artifact_effects)
			effect.effect_touched(user)
		return
	if(LAZYLEN(artifact_origin.touch_descriptors))
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), user, span_notice("<i>[pick(artifact_origin.touch_descriptors)]</i>")), 0.5 SECONDS)

//just redirect to on_unarmed
/datum/component/artifact/proc/on_robot_attack(datum/source, mob/living/user)
	SIGNAL_HANDLER
	on_unarmed(source, user)

/datum/component/artifact/proc/ex_act(atom/source, severity)
	SIGNAL_HANDLER
	process_stimuli(STIMULUS_FORCE, 25 * severity)
	process_stimuli(STIMULUS_HEAT, 360 * severity)

/datum/component/artifact/proc/emp_act(atom/source, severity)
	SIGNAL_HANDLER
	process_stimuli(STIMULUS_SHOCK, 800 * severity)
	process_stimuli(STIMULUS_RADIATION, 2 * severity)

/datum/component/artifact/proc/on_attackby(atom/source, obj/item/I, mob/user)
	SIGNAL_HANDLER
	I.on_artifact_interact(src, user)

/datum/component/artifact/proc/log_pull(datum/source, atom/puller)
	SIGNAL_HANDLER
	logger.Log(LOG_CATEGORY_ARTIFACT, "[puller] has started pulling the [parent]")

/datum/component/artifact/proc/log_stop_pull(datum/source, atom/puller)
	SIGNAL_HANDLER
	logger.Log(LOG_CATEGORY_ARTIFACT, "[puller] has stopped pulling the [parent]")
