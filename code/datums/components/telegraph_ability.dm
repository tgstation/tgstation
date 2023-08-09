/**
 * Component given to creatures to telegraph their abilities!
 */
/datum/component/telegraph_ability
	/// how long before we use our attack
	var/telegraph_time
	/// are we currently telegraphing
	var/currently_telegraphing = FALSE

/datum/component/telegraph_ability/Initialize(telegraph_time = 1 SECONDS)

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.telegraph_time = telegraph_time

/datum/component/telegraph_ability/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_ABILITY_STARTED, PROC_REF(start_telegraph))

/datum/component/telegraph_ability/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_ABILITY_STARTED)

/datum/component/telegraph_ability/proc/start_telegraph(mob/living/source, datum/action/cooldown/activated, atom/target)
	SIGNAL_HANDLER

	if(currently_telegraphing)
		return COMPONENT_BLOCK_ABILITY_START

	if(!activated.IsAvailable())
		return

	currently_telegraphing = !currently_telegraphing
	source.Shake(duration = telegraph_time)
	addtimer(CALLBACK(src, PROC_REF(use_ability), source, activated, target), telegraph_time)
	return COMPONENT_BLOCK_ABILITY_START

/datum/component/telegraph_ability/proc/use_ability(mob/living/source, datum/action/cooldown/activated, atom/target)
	if(!QDELETED(target)) //target is gone
		activated.Activate(target)
	currently_telegraphing = !currently_telegraphing
