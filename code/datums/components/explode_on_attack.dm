/**
 * Bombs the user after an attack
 */
/datum/component/explode_on_attack
	/// range of bomb impact
	var/impact_range
	/// should we be destroyed after the explosion?
	var/destroy_on_explode
	/// list of mobs we wont bomb on attack
	var/list/mob_type_dont_bomb

/datum/component/explode_on_attack/Initialize(impact_range = 1, destroy_on_explode = TRUE, list/mob_type_dont_bomb = list())
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.impact_range = impact_range
	src.destroy_on_explode = destroy_on_explode
	src.mob_type_dont_bomb = mob_type_dont_bomb

/datum/component/explode_on_attack/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(bomb_target))

/datum/component/explode_on_attack/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)


/datum/component/explode_on_attack/proc/bomb_target(mob/living/owner, atom/victim)
	SIGNAL_HANDLER

	if(!isliving(victim))
		return

	if(is_type_in_typecache(victim, mob_type_dont_bomb))
		return

	explosion(owner, light_impact_range = impact_range, explosion_cause = src)

	if(destroy_on_explode && owner)
		qdel(owner)
	return COMPONENT_HOSTILE_NO_ATTACK

