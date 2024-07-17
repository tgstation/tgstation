/// Component for only letting a living pull other livings
/datum/component/only_pull_people

/datum/component/only_pull_people/Initialize(...)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_LIVING_TRY_PULL, PROC_REF(try_pull))

/datum/component/only_pull_people/proc/try_pull(mob/living/parent, atom/movable/pulled)
	SIGNAL_HANDLER

	if(!isliving(pulled))
		return COMSIG_LIVING_CANCEL_PULL
