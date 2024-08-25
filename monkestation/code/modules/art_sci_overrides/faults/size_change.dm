/datum/artifact_fault/shrink
	name = "Shrinking Fault"
	trigger_chance = 13
	visible_message = "starts to shrink."

	research_value = 200

/datum/artifact_fault/shrink/on_trigger(datum/component/artifact/component)
	component.holder.transform = matrix(component.holder.transform, 0.9, 0.9, MATRIX_SCALE)
	if(!isstructure(component.holder))
		return
	var/obj/structure/structure = component.holder
	structure.w_class--
	if(structure.w_class < WEIGHT_CLASS_TINY)
		component.holder.visible_message("[component.holder] vanishes into thin air!")
		qdel(component.holder)

/datum/artifact_fault/grow
	name = "Growing Fault"
	trigger_chance = 13
	visible_message = "starts to grow."

/datum/artifact_fault/grow/on_trigger(datum/component/artifact/component)
	if(!isitem(component.holder))
		return
	var/obj/item/item = component.holder
	if(item.w_class > WEIGHT_CLASS_HUGE)
		return

	component.holder.transform = matrix(component.holder.transform, 1.1, 1.1, MATRIX_SCALE)

	item.w_class++
	if(item.w_class > WEIGHT_CLASS_HUGE)
		component.holder.visible_message("[component.holder] becomes to cumbersome to carry!")
		component.holder.anchored = TRUE
