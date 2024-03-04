/// Deals bonus brute damage to smaller mobs
/datum/element/tiny_mob_hunter
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Will apply bonus to mobs this size or smaller
	var/target_size
	/// Additional damage to apply
	var/bonus_damage

/datum/element/tiny_mob_hunter/Attach(datum/target, target_size = MOB_SIZE_TINY, bonus_damage = 10)
	. = ..()
	if(!isanimal_or_basicmob(target)) // No post-attack signal for carbons, you can add one if you really want to put this on one
		return ELEMENT_INCOMPATIBLE

	src.target_size = target_size
	src.bonus_damage = bonus_damage
	RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(on_attacked_target))

/datum/element/tiny_mob_hunter/Detach(datum/target)
	UnregisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET)
	return ..()

/// Applies a bonus following the attack
/datum/element/tiny_mob_hunter/proc/on_attacked_target(mob/living/hunter, atom/target)
	SIGNAL_HANDLER
	if (!isliving(target))
		return
	var/mob/living/prey = target
	if (prey.mob_size > target_size)
		return
	prey.apply_damage(bonus_damage, BRUTE, hunter.zone_selected)
