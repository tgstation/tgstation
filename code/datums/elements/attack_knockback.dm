/**
 * Knocks the target back one tile when melee hitting!
 *
 * Used in bats and maces
 */
/datum/element/attack_knockback

/datum/element/attack_knockback/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_POST_ATTACK, PROC_REF(on_item_attack))

/datum/element/attack_knockback/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/datum/element/attack_knockback/proc/on_item_attack(obj/item/bat, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	// we obtain the relative direction from the bat itself to the target
	var/relative_direction = get_cardinal_dir(bat, target)
	var/atom/throw_target = get_edge_target_turf(target, relative_direction)
	if(QDELETED(target) || target.anchored)
		return
	var/whack_speed = (prob(60) ? 1 : 4)
	target.throw_at(throw_target, rand(1, 2), whack_speed, user, gentle = TRUE) // sorry friends, 7 speed batting caused wounds to absolutely delete whoever you knocked your target into (and said target)
