/datum/element/revenant_receptacle

/datum/element/revenant_receptacle/Attach(obj/target)
	. = ..()
	if(!istype(target) || (. == ELEMENT_INCOMPATIBLE))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_REVENANT_PRISON_DESTROYED, PROC_REF(grab_that_ghost))

/datum/element/proc/grab_that_ghost(obj/source, mob/living/basic/revenant)
	SIGNAL_HANDLER
	source.AddComponent(/datum/component/revenant_prison, revenant, create_on_release = FALSE)
	source.RemoveElement(/datum/element/revenant_receptacle)
	return TRUE
