/datum/status_effect/inebriated/drunk/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(on_cult_sacrificed))

/datum/status_effect/inebriated/drunk/clear_effects()
	. = ..()
	UnregisterSignal(owner, COMSIG_LIVING_CULT_SACRIFICED)

/datum/status_effect/inebriated/drunk/proc/on_cult_sacrificed(datum/source, list/mob/living/invokers)
	SIGNAL_HANDLER
	if(drunk_value < OLD_MAN_HENDERSON_DRUNKENNESS || owner.stat == DEAD)
		return NONE
	owner.visible_message(span_cultitalic("[owner] is unfazed by the rune, grumbling with incoherent drunken annoyance instead!"))
	return STOP_SACRIFICE
