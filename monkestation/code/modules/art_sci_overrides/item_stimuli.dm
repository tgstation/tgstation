/obj/item/proc/on_artifact_interact(datum/component/artifact/interacted, mob/user)
	if(force)
		interacted.process_stimuli(STIMULUS_FORCE, force)


/obj/item/weldingtool/on_artifact_interact(datum/component/artifact/interacted, mob/user)
	interacted.holder.visible_message(span_warning("[user] burns the artifact with the [src]!"))
	interacted.process_stimuli(STIMULUS_HEAT, 1000)

/obj/item/assembly/igniter/on_artifact_interact(datum/component/artifact/interacted, mob/user)
	interacted.holder.visible_message(span_warning("[user] zaps the artifact with the [src]!"))
	interacted.process_stimuli(STIMULUS_HEAT, 700)
	interacted.process_stimuli(STIMULUS_SHOCK, 1200)

/obj/item/lighter/on_artifact_interact(datum/component/artifact/interacted, mob/user)
	interacted.holder.visible_message(span_warning("[user] burns the artifact with the [src]!"))
	interacted.process_stimuli(STIMULUS_HEAT, heat)


/obj/item/multitool/on_artifact_interact(datum/component/artifact/interacted, mob/user)
	interacted.holder.visible_message(span_warning("[user] zaps the artifact with the [src]!"))
	interacted.process_stimuli(STIMULUS_SHOCK, 1000)

/obj/item/shockpaddles/on_artifact_interact(datum/component/artifact/interacted, mob/user)
	if(defib.deductcharge(2000))
		interacted.holder.visible_message(span_warning("[user] zaps the artifact with the [src]!"))
		interacted.process_stimuli(STIMULUS_SHOCK, 2000)
		playsound(user,'sound/machines/defib_zap.ogg', 50, TRUE, -1)

/obj/item/circuitboard/on_artifact_interact(datum/component/artifact/interacted, mob/user)
	interacted.holder.visible_message(span_notice("[user] presses the [src] against the artifact."))
	interacted.process_stimuli(STIMULUS_DATA)

/obj/item/disk/data/on_artifact_interact(datum/component/artifact/interacted, mob/user)
	interacted.holder.visible_message(span_notice("[user] presses the [src] against the artifact."))
	interacted.process_stimuli(STIMULUS_DATA)

/obj/item/bodypart/arm/on_artifact_interact(datum/component/artifact/interacted, mob/user)
	interacted.holder.visible_message(span_notice("[user] presses the [src] against the artifact."))
	if(bodytype & BODYTYPE_ROBOTIC)
		interacted.process_stimuli(STIMULUS_SILICON_TOUCH)
	else
		interacted.process_stimuli(STIMULUS_CARBON_TOUCH)
