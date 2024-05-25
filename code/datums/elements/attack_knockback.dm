/**
 * Knocks the target back one tile when melee hitting!
 *
 * Used in bats and maces
 */
/datum/element/attack_knockback
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Picks a number from this list, throws this far away
	var/list/throw_range = list(1)
	/// Picks a number from this list, throws at this speed
	var/list/throw_speed = list(1, 4)
	/// If the throw is violent or not
	var/gentle = TRUE
	/// Callback for a proc right before confirming the attack. If it returns FALSE, cancel
	var/datum/callback/pre_hit_callback

/datum/element/attack_knockback/Attach(datum/target, throw_range, throw_speed, datum/callback/pre_hit_callback)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	if(throw_range)
		src.throw_range = throw_range
	if(throw_speed)
		src.throw_speed = throw_speed
	src.pre_hit_callback = pre_hit_callback

	RegisterSignal(target, COMSIG_ITEM_POST_ATTACK, PROC_REF(on_item_attack))

/datum/element/attack_knockback/Detach(datum/source, ...)
	. = ..()

	QDEL_NULL(pre_hit_callback)
	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/datum/element/attack_knockback/proc/on_item_attack(obj/item/bat, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	// we obtain the relative direction from the bat itself to the target
	var/relative_direction = get_cardinal_dir(bat, target)
	var/atom/throw_target = get_edge_target_turf(target, relative_direction)
	if(QDELETED(target) || target.anchored)
		return

	if(pre_hit_callback && !pre_hit_callback.Invoke())
		return

	target.throw_at(throw_target, pick(throw_range), pick(throw_speed), user, gentle = src.gentle) // sorry friends, 7 speed batting caused wounds to absolutely delete whoever you knocked your target into (and said target)
