/**For items automatically offered to a player when they pull a borg.*/

/datum/element/borg_item_offered_when_pulled
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/mob/living/silicon/robot
	var/obj/item/borg_item

/datum/element/borg_item_offered_when_pulled/Attach(datum/target, mob/living/silicon/robot/borg)
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	if(!istype(borg))
		CRASH("Element assigned to [target], but was not assigned a ref for type /mob/living/silicon/robot to attach COMSIG_LIVING_GET_PULLED")
	RegisterSignal(borg, COMSIG_LIVING_GET_PULLED, PROC_REF(on_pulled))
	robot = borg
	borg_item = target
	return ..()

/datum/element/borg_item_offered_when_pulled/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(robot, COMSIG_LIVING_GET_PULLED)

/datum/element/borg_item_offered_when_pulled/proc/on_pulled(mob/living/holder, mob/living/puller)
	SIGNAL_HANDLER
	holder.give(puller, borg_item)
