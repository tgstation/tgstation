// Prevents a basic mob from hitting themselves by accident.
// This is useful if you don't want self-harm as a balancing factor.
// There are a lot of basic mobs that never benefit from hitting themselves.
// Properly implementing this for carbons would require a more complex setup.

/datum/element/anti_self_harm

/datum/element/anti_self_harm/Attach(datum/target)
	. = ..()
	if (!isbasicmob(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_hostile_pre_attackingtarget))

/datum/element/anti_self_harm/Detach(datum/target, ...)
	UnregisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
	return ..()

/datum/element/anti_self_harm/proc/on_hostile_pre_attackingtarget(mob/living/basic/parent_mob, atom/target, is_adjacent, modifiers)
	SIGNAL_HANDLER
	if (parent_mob != target)
		return
	if (modifiers[RIGHT_CLICK])
		return

	// A balloon alert would be too distracting mid-combat.
	to_chat(parent_mob, span_warning("You decide against attacking yourself. <b>You can still do so with right-click.</b>"))
	return COMPONENT_HOSTILE_NO_ATTACK
