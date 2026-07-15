/**For items automatically offered to a player when they pull a borg.*/

/datum/component/borg_item_offered_when_pulled
	var/mob/living/silicon/robot

/datum/component/borg_item_offered_when_pulled/Initialize(mob/living/silicon/robot/borg)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(!istype(borg))
		stack_trace("Component assigned to [parent], but was not assigned a ref for type /mob/living/silicon/robot to attach COMSIG_LIVING_GET_PULLED")
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(borg, COMSIG_LIVING_GET_PULLED, PROC_REF(on_pulled))
	ADD_TRAIT(parent, TRAIT_OFFERED_WHEN_PULLED, TRAIT_OFFERED_WHEN_PULLED)
	robot = borg

/datum/component/borg_item_offered_when_pulled/Destroy(datum/source, ...)
	UnregisterSignal(robot, COMSIG_LIVING_GET_PULLED)
	robot = null
	return ..()

/datum/component/borg_item_offered_when_pulled/proc/on_pulled(mob/living/holder, mob/living/puller)
	SIGNAL_HANDLER
	holder.give(puller, parent)
