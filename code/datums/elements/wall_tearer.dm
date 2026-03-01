/// Returned if we can rip up this target
#define WALL_TEAR_ALLOWED TRUE
/// Returned if we can't rip up this target
#define WALL_TEAR_INVALID FALSE
/// Returned if we can't rip up the target but still don't want to attack it
#define WALL_TEAR_FAIL_CANCEL_CHAIN -1

/**
 * Allows attached mobs to destroy walls over time, a little less unreasonable than the instant wall deletion of wall_smasher
 */
/datum/element/wall_tearer
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Whether we can break reinforced walls
	var/allow_reinforced
	/// How long it takes for us to destroy a wall completely (its a 3 step process so this will be divided by three)
	var/tear_time
	/// How much longer it takes to break reinforced walls
	var/reinforced_multiplier
	/// What interaction key do we use for our interaction
	var/do_after_key

/datum/element/wall_tearer/Attach(datum/target, allow_reinforced = TRUE, tear_time = 2 SECONDS, reinforced_multiplier = 2, do_after_key = null)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.allow_reinforced = allow_reinforced
	src.tear_time = tear_time
	src.reinforced_multiplier = reinforced_multiplier
	src.do_after_key = do_after_key
	RegisterSignals(target, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_UNARMED_ATTACK), PROC_REF(on_attacked_wall))

/datum/element/wall_tearer/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_UNARMED_ATTACK))

/// Try to tear up a wall
/datum/element/wall_tearer/proc/on_attacked_wall(mob/living/tearer, atom/target, proximity_flag)
	SIGNAL_HANDLER
	if (DOING_INTERACTION_WITH_TARGET(tearer, target) || (!isnull(do_after_key) && DOING_INTERACTION(tearer, do_after_key)))
		tearer.balloon_alert(tearer, "busy!")
		return COMPONENT_HOSTILE_NO_ATTACK
	var/is_valid = validate_target(target, tearer)
	if (is_valid != WALL_TEAR_ALLOWED)
		return is_valid == WALL_TEAR_FAIL_CANCEL_CHAIN ? COMPONENT_HOSTILE_NO_ATTACK : NONE
	INVOKE_ASYNC(src, PROC_REF(rip_and_tear), tearer, target)
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/element/wall_tearer/proc/rip_and_tear(mob/living/tearer, atom/target)
	// We need to do this three times to actually destroy it
	var/rip_time = (istype(target, /turf/closed/wall/r_wall) ? tear_time * reinforced_multiplier : tear_time) / 3
	if (rip_time > 0)
		tearer.visible_message(span_warning("[tearer] begins tearing through [target]!"))
		playsound(tearer, 'sound/machines/airlock/airlock_alien_prying.ogg', vol = 100, vary = TRUE)
		target.balloon_alert(tearer, "tearing...")
		if (!do_after(tearer, delay = rip_time, target = target, interaction_key = do_after_key))
			tearer.balloon_alert(tearer, "interrupted!")
			return
	// Might have been replaced, removed, or reinforced during our do_after
	var/is_valid = validate_target(target, tearer)
	if (is_valid != WALL_TEAR_ALLOWED)
		return
	tearer.do_attack_animation(target)
	target.AddComponent(/datum/component/torn_wall)
	is_valid = validate_target(target, tearer) // And now we might have just destroyed it
	if (is_valid == WALL_TEAR_ALLOWED)
		tearer.UnarmedAttack(target, proximity_flag = TRUE)

/// Check if the target atom is a wall we can actually rip up
/datum/element/wall_tearer/proc/validate_target(atom/target, mob/living/tearer)
	if (!isclosedturf(target) || isindestructiblewall(target))
		return WALL_TEAR_INVALID

	var/reinforced = istype(target, /turf/closed/wall/r_wall)
	if (!allow_reinforced && reinforced)
		target.balloon_alert(tearer, "it's too strong!")
		return WALL_TEAR_FAIL_CANCEL_CHAIN
	return WALL_TEAR_ALLOWED

#undef WALL_TEAR_ALLOWED
#undef WALL_TEAR_INVALID
#undef WALL_TEAR_FAIL_CANCEL_CHAIN
