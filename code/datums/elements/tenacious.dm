/**
 * tenacious element; which makes the parent move faster while crawling
 *
 * Used by sparring sect!
 */
/datum/element/tenacious

/datum/element/tenacious/Attach(datum/target)
	. = ..()

	if(!ishuman(target))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/carbon/human/valid_target = target
	on_stat_change(valid_target, new_stat = valid_target.stat) //immediately try adding movement bonus if they're in soft crit
	RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	ADD_TRAIT(target, TRAIT_TENACIOUS, ELEMENT_TRAIT(type))

/datum/element/tenacious/Detach(datum/target)
	UnregisterSignal(target, COMSIG_MOB_STATCHANGE)
	REMOVE_TRAIT(target, TRAIT_TENACIOUS, ELEMENT_TRAIT(type))
	return ..()

///signal called by the stat of the target changing
/datum/element/tenacious/proc/on_stat_change(mob/living/carbon/human/target, new_stat)
	SIGNAL_HANDLER

	if(new_stat == SOFT_CRIT)
		target.balloon_alert(target, "your tenacity kicks in")
		target.add_movespeed_modifier(/datum/movespeed_modifier/tenacious)
	else
		target.balloon_alert(target, "your tenacity wears off")
		target.remove_movespeed_modifier(/datum/movespeed_modifier/tenacious)
