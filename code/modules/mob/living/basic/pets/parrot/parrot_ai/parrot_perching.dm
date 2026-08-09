/// Reads the parrot's desired-perch typecache so it can scan for somewhere to sit.
/datum/target_source/oview_typed/from_bb_key/parrot_perch_types
	typecache_key = BB_PARROT_PERCH_TYPES

/// Parrot behavior that perches them on their current perch target.
/datum/bt_node/ai_behavior/perch_on_target
	/// Blackboard key holding the atom to perch on.
	var/target_key

/datum/bt_node/ai_behavior/perch_on_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/basic/parrot/living_pawn = controller.pawn

	if(ishuman(target) && !check_human_conditions(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	living_pawn.start_perching(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/perch_on_target/proc/check_human_conditions(mob/living/living_human)
	if(living_human.stat == DEAD || LAZYLEN(living_human.buckled_mobs) >= living_human.max_buckled_mobs)
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/perch_on_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// Variant for the ghost parrot, which can haunt any living human.
/datum/bt_node/ai_behavior/perch_on_target/haunt

/datum/bt_node/ai_behavior/perch_on_target/haunt/check_human_conditions(mob/living/living_human)
	return (living_human.stat != DEAD)

/// Parrot idle wander; sits much more still while perched.
/datum/bt_node/ai_behavior/idle_random_walk/parrot
	/// Chance of us moving while perched.
	var/walk_chance_when_perched = 5

/datum/bt_node/ai_behavior/idle_random_walk/parrot/perform(seconds_per_tick, datum/ai_controller/controller)
	walk_chance = HAS_TRAIT(controller.pawn, TRAIT_PARROT_PERCHED) ? walk_chance_when_perched : initial(walk_chance)
	return ..()
