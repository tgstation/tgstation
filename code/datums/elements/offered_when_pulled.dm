/**For items automatically offered to a player when they pull on another mob. Primarily used by the janitorial cleaning suite.*/

/datum/element/offered_when_pulled

/datum/element/offered_when_pulled/Attach(datum/target)
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_LIVING_GET_PULLED, PROC_REF(on_pulled))
	return ..()

/datum/element/offered_when_pulled/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_GET_PULLED)

/datum/element/offered_when_pulled/proc/on_pulled(mob/living/holder, mob/living/puller)
	SIGNAL_HANDLER
	for(var/obj/item/items in holder.get_all_contents())
		if(HAS_TRAIT(items, TRAIT_OFFERED_WHEN_PULLED))
			holder.give(puller, items)
