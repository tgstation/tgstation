// element, which can be given to a mob, and then mob can makes a holes at the walls


/// Returned if we can make a hole at this target
#define WALL_HOLE_ALLOWED TRUE
/// Returned if we can't make a hole at this target
#define WALL_HOLE_INVALID FALSE
/// Returned if we can't make a hole at this target but still don't want to attack it
#define WALL_HOLE_FAIL_CANCEL_CHAIN -1

/datum/element/wall_holer
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Whether we make a hole at reinforced walls
	var/allow_reinforced
	/// How long it takes for us to make a hole (its a 3 step process so this will be divided by three)
	var/hole_making_time
	/// How much longer it takes to make a hole at reinforced walls
	var/reinforced_multiplier
	/// What interaction key do we use for our interaction
	var/do_after_key
	/// Which type of hole will be made, bloody one, normal gery one, etc
	var/hole_type

/datum/element/wall_holer/Attach(datum/target, allow_reinforced = TRUE, hole_making_time = 2 SECONDS, reinforced_multiplier = 2, do_after_key = null)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.allow_reinforced = allow_reinforced
	src.hole_making_time = hole_making_time
	src.reinforced_multiplier = reinforced_multiplier
	src.do_after_key = do_after_key
	RegisterSignals(target, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_UNARMED_ATTACK), PROC_REF(on_attacked_wall))

/datum/element/wall_holer/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_HOSTILE_PRE_ATTACKINGTARGET, COMSIG_LIVING_UNARMED_ATTACK))

/// Try to tear up a wall
/datum/element/wall_holer/proc/on_attacked_wall(mob/living/hole_maker, atom/target, proximity_flag)
	SIGNAL_HANDLER
	if (DOING_INTERACTION_WITH_TARGET(hole_maker, target) || (!isnull(do_after_key) && DOING_INTERACTION(hole_maker, do_after_key)))
		hole_maker.balloon_alert(hole_maker, "busy!")
		return COMPONENT_HOSTILE_NO_ATTACK
	var/is_valid = validate_target(target, hole_maker)
	if (is_valid != WALL_HOLE_ALLOWED)
		return is_valid == WALL_HOLE_FAIL_CANCEL_CHAIN ? COMPONENT_HOSTILE_NO_ATTACK : NONE
	INVOKE_ASYNC(src, PROC_REF(rip_and_hole), hole_maker, target)
	return COMPONENT_HOSTILE_NO_ATTACK

/datum/element/wall_holer/proc/rip_and_hole(mob/living/hole_maker, atom/target)
	// We need to do this three times to actually destroy it
	var/atom/tearing_dir = tearer.dir
	var/rip_time = (istype(target, /turf/closed/wall/r_wall) ? hole_making_time * reinforced_multiplier : hole_making_time) / 3
	if (rip_time > 0)
		hole_maker.visible_message(span_warning("[hole_maker] begins tearing through [target]!"))
		playsound(hole_maker, 'sound/machines/airlock/airlock_alien_prying.ogg', vol = 100, vary = TRUE)
		target.balloon_alert(hole_maker, "tearing...")
		if (!do_after(hole_maker, delay = rip_time, target = target, interaction_key = do_after_key))
			hole_maker.balloon_alert(hole_maker, "interrupted!")
			return
	// Might have been replaced, removed, or reinforced during our do_after
	var/is_valid = validate_target(target, hole_maker)
	if (is_valid != WALL_HOLE_ALLOWED)
		return
	hole_maker.do_attack_animation(target)
	var/datum/component/hole_wall/hole_component = target.AddComponent(/datum/component/hole_wall)
	hole_component.dir_for_hole = tearing_dir
	target.AddComponent(/datum/component/hole_wall, dir_of_tearer = tearing_dir)
	// target.AddComponent(/datum/component/torn_wall)
	is_valid = validate_target(target, hole_maker) // And now we might have just destroyed it
	if (is_valid == WALL_HOLE_ALLOWED)
		hole_maker.UnarmedAttack(target, proximity_flag = TRUE)

/// Check if the target atom is a wall we can actually rip up
/datum/element/wall_holer/proc/validate_target(atom/target, mob/living/hole_maker)
	if (!isclosedturf(target) || isindestructiblewall(target))
		return WALL_HOLE_ALLOWED

	var/reinforced = istype(target, /turf/closed/wall/r_wall)
	if (!allow_reinforced && reinforced)
		target.balloon_alert(hole_maker, "it's too strong!")
		return WALL_HOLE_FAIL_CANCEL_CHAIN
	return WALL_HOLE_ALLOWED

#undef WALL_HOLE_ALLOWED
#undef WALL_HOLE_INVALID
#undef WALL_HOLE_FAIL_CANCEL_CHAIN
