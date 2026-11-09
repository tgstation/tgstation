/datum/element/clever_girl

/datum/element/clever_girl/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignals(target, list(COMSIG_MOB_OPENED_AIRLOCK, COMSIG_MOB_OPENED_DOOR), PROC_REF(on_open_door))

/datum/element/cleaning/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_MOB_OPENED_AIRLOCK, COMSIG_MOB_OPENED_DOOR))

/datum/element/clever_girl/proc/on_open_door(mob/living/source, forced)
	SIGNAL_HANDLER
	if (forced != DEFAULT_DOOR_CHECKS)
		return
	source.client?.give_award(/datum/award/achievement/misc/clever_girl, src)
