/**
 * Mobs and items with this element will knock movable targets they hit away from them.
 * Guns and turrets will instead fire projectiles with similar effects.
 */
/datum/element/knockback
	/// distance the atom will be thrown
	var/throw_distance
	/// whether this can throw anchored targets (tables, etc)
	var/throw_anchored
	/// whether this is a gentle throw (default false means people thrown into walls are stunned / take damage)
	var/throw_gentle

/datum/element/knockback/Attach(datum/target, throw_distance = 1, throw_anchored = FALSE, throw_gentle = FALSE)
	. = ..()
	if(ismachinery(target) || isstructure(target) || isgun(target) || isprojectilespell(target)) // turrets, etc
		RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, PROC_REF(projectile_hit))
	else if(isitem(target))
		RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	else if(ishostile(target))
		RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(hostile_attackingtarget))
	else
		return ELEMENT_INCOMPATIBLE

	src.throw_distance = throw_distance
	src.throw_anchored = throw_anchored
	src.throw_gentle = throw_gentle

/datum/element/knockback/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_POST_ATTACKINGTARGET, COMSIG_PROJECTILE_ON_HIT))
	return ..()

/// triggered after an item attacks something
/datum/element/knockback/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	do_knockback(target, user, get_dir(source, target))
	return COMPONENT_AFTERATTACK_PROCESSED_ITEM

/// triggered after a hostile simplemob attacks something
/datum/element/knockback/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER
	if(!success)
		return
	do_knockback(target, attacker, get_dir(attacker, target))

/// triggered after a projectile hits something
/datum/element/knockback/proc/projectile_hit(datum/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	do_knockback(target, null, angle2dir(Angle))


/**
 * Throw a target in a direction
 *
 * Arguments:
 * * target - Target atom to throw
 * * thrower - Thing that caused this atom to be thrown
 * * throw_dir - Direction to throw the atom
 */
/datum/element/knockback/proc/do_knockback(atom/target, mob/thrower, throw_dir)
	if(!ismovable(target) || throw_dir == null)
		return
	var/atom/movable/throwee = target
	if(throwee.anchored && !throw_anchored)
		return
	if(throw_distance < 0)
		throw_dir = turn(throw_dir, 180)
		throw_distance *= -1
	var/atom/throw_target = get_edge_target_turf(throwee, throw_dir)
	throwee.safe_throw_at(throw_target, throw_distance, 1, thrower, gentle = throw_gentle)
