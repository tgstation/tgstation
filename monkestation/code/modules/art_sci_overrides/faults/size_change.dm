/datum/artifact_fault/shrink
	name = "Shrink"
	trigger_chance = 13
	visible_message = "starts to shrink."

/datum/artifact_fault/shrink/on_trigger(datum/component/artifact/component)
	component.holder.transform = matrix(component.holder.transform, 0.9, 0.9, MATRIX_SCALE)
	component.holder.w_class--
	if(component.holder.w_class < WEIGHT_CLASS_TINY)
		component.holder.visible_message("[component.holder] vanishes into thin air!")
		qdel(component.holder)

/datum/artifact_fault/grow
	name = "Grow"
	trigger_chance = 13
	visible_message = "starts to grow."

/datum/artifact_fault/grow/on_trigger(datum/component/artifact/component)
	component.holder.transform = matrix(component.holder.transform, 1.1, 1.1, MATRIX_SCALE)
	component.holder.w_class++
	if(component.holder.w_class > WEIGHT_CLASS_HUGE)
		component.holder.visible_message("[component.holder] becomes to cumbersome to carry!")
		component.holder.anchored = TRUE
