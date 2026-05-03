/datum/component/temporary_synthpax_immunity
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/timer_id

/datum/component/temporary_synthpax_immunity/Initialize(initial_damage)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	timer_id = QDEL_IN_STOPPABLE(src, min(initial_damage SECONDS, 5 SECONDS))

/datum/component/temporary_synthpax_immunity/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(parent_damaged))
	ADD_TRAIT(parent, TRAIT_SYNTHPAX_IMMUNE, REF(src))
	REMOVE_TRAIT(parent, TRAIT_PACIFISM, METABOLIZATION_TRAIT(/datum/reagent/pax/peaceborg))

/datum/component/temporary_synthpax_immunity/UnregisterFromParent()
	var/mob/living/living_parent = parent
	REMOVE_TRAIT(parent, TRAIT_SYNTHPAX_IMMUNE, REF(src))
	if(living_parent.reagents.has_reagent(/datum/reagent/pax/peaceborg))
		ADD_TRAIT(parent, TRAIT_PACIFISM, METABOLIZATION_TRAIT(/datum/reagent/pax/peaceborg))
	UnregisterSignal(parent, COMSIG_MOB_AFTER_APPLY_DAMAGE)

/datum/component/temporary_synthpax_immunity/proc/parent_damaged(mob/living/source, amount)
	SIGNAL_HANDLER
	var/time_left = timeleft(timer_id)
	deltimer(timer_id)
	timer_id = QDEL_IN_STOPPABLE(src, min(time_left + amount SECONDS, 5 SECONDS))
