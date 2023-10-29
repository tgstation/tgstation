//Seperate file because we will add more and more as more items that fit stimuli are added that require uniqueness aside from stimuli and value like shockpaddles

/datum/component/artifact/proc/on_attackby(atom/source, obj/item/I, mob/user)
	SIGNAL_HANDLER
	if(I.artifact_stimuli)
		if(I.artifact_stimuli & STIMULUS_HEAT)
			holder.visible_message(span_warning("[user] burns the artifact with the [I]!"))
		if(I.artifact_stimuli & STIMULUS_SHOCK)
			holder.visible_message(span_warning("[user] zaps the artifact with the [I]!"))
		if(STIMULUS_DATA)
			holder.visible_message(span_notice("[user] touches the artifact with the [I]"))
		if((I.artifact_stimuli & STIMULUS_CARBON_TOUCH )|| (I.artifact_stimuli & STIMULUS_SILICON_TOUCH))
			holder.visible_message(span_notice("[user] presses the [I] against the artifact."))
		if(I.artifact_stimuli & STIMULUS_RADIATION)
			holder.visible_message(span_notice("[user] irradiates the artifact with [I]!"))
		
		if(length(I.usesound))
			playsound(user, pick(I.usesound), 50, TRUE)

		process_stimuli(I.artifact_stimuli, I.stimuli_value)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(istype(I, /obj/item/bodypart/arm))
		var/obj/item/bodypart/arm/arm = I
		holder.visible_message(span_notice("[user] presses the [arm] against the artifact.")) //pressing stuff against stuff isnt very severe so
		if(arm.bodytype & BODYTYPE_ROBOTIC)
			process_stimuli(STIMULUS_SILICON_TOUCH)
		else
			process_stimuli(STIMULUS_CARBON_TOUCH)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(istype(I,/obj/item/shockpaddles))
		var/obj/item/shockpaddles/paddles = I
		if(paddles.defib.deductcharge(I.stimuli_value))
			holder.visible_message(span_warning("[user] zaps the artifact with the [I]!"))
			process_stimuli(STIMULUS_SHOCK, I.stimuli_value)
			playsound(user,'sound/machines/defib_zap.ogg', 50, TRUE, -1)
			return COMPONENT_CANCEL_ATTACK_CHAIN
	
	if(I.force)
		process_stimuli(STIMULUS_FORCE, I.force)
