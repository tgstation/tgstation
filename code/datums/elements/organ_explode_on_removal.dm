/**
 * ## DANGEROUS ORGAN REMOVAL ELEMENT
 *
 * Makes the organ explode when removed fromm the mob through any means
 */
/datum/element/dangerous_organ_removal

/datum/element/dangerous_organ_removal/Attach(datum/target)
	. = ..()
	if(!isorgan(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_removal))

/datum/element/dangerous_organ_removal/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ORGAN_REMOVED)

/datum/element/dangerous_organ_removal/proc/on_removal(obj/item/organ/source)
	SIGNAL_HANDLER

	source.audible_message("[source] explodes violenty!")
	explosion(source, light_impact_range = 1, explosion_cause = source)
	qdel(source)
