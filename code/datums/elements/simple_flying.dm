/**
 * # simple flying element!
 *
 * Non bespoke element (1 in existence) that makes animals fly while living and... not while dead!
 * Note: works for carbons and above, but please do something better. humans have wings got dangit!
 */
/datum/element/simple_flying

/datum/element/simple_flying/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/valid_target = target
	on_stat_change(valid_target, new_stat = valid_target.stat) //immediately try adding flight if they're conscious
	RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))

/datum/element/simple_flying/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOB_STATCHANGE)
	REMOVE_TRAIT(target, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(type))

///signal called by the stat of the target changing
/datum/element/simple_flying/proc/on_stat_change(mob/living/target, new_stat)
	SIGNAL_HANDLER

	if(new_stat == CONSCIOUS)
		ADD_TRAIT(target, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(type))
	else
		REMOVE_TRAIT(target, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(type))
