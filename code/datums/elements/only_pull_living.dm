/// Element for only letting a living pull other livings
/datum/element/only_pull_living

/datum/element/only_pull_living/Attach(datum/target)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_TRY_PULL, PROC_REF(try_pull))

/datum/element/only_pull_living/proc/try_pull(mob/living/owner, atom/movable/pulled)
	SIGNAL_HANDLER

	if(!isliving(pulled))
		return COMSIG_LIVING_CANCEL_PULL
