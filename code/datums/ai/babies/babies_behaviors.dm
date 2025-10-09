#define FIND_PARTNER_COOLDOWN 1 MINUTES

/**
 * Find a compatible, living partner, if we're also alone.
 */
/datum/ai_behavior/find_partner
	action_cooldown = 5 SECONDS
	/// Range to look.
	var/range = 7
	/// Maximum number of nearby pop
	var/max_nearby_pop = 3

/datum/ai_behavior/find_partner/perform(seconds_per_tick, datum/ai_controller/controller, target_key, partner_types_key, child_types_key)
	var/maximum_pop = controller.blackboard[BB_MAX_CHILDREN] || max_nearby_pop
	var/mob/pawn_mob = controller.pawn
	var/list/similar_species_types = controller.blackboard[partner_types_key]
	var/list/children_types = controller.blackboard[child_types_key]
	var/mob/living/living_pawn = controller.pawn
	var/list/possible_partners = list()

	var/nearby_pop = 0
	for(var/mob/living/other in oview(range, pawn_mob))
		if(!pawn_mob.faction_check_atom(other))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

		// Don't breed with children please, thanks
		if(!is_type_in_list(other, similar_species_types) || is_type_in_list(other, children_types))
			continue

		if(++nearby_pop >= maximum_pop)
			controller.set_blackboard_key(BB_PARTNER_SEARCH_TIMEOUT, world.time + FIND_PARTNER_COOLDOWN)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

		if (valid_partner(other, living_pawn))
			possible_partners += other

	if(!length(possible_partners))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(target_key, pick(possible_partners))
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_partner/proc/valid_partner(mob/living/other, mob/living/living_pawn)
	if(!HAS_TRAIT(other, TRAIT_MOB_BREEDER) || other.ckey)
		return FALSE

	if(other.stat != CONSCIOUS) //Check if it's conscious FIRST.
		return FALSE

	if(other.gender != living_pawn.gender && !(other.flags_1 & HOLOGRAM_1)) //Better safe than sorry ;_;
		return TRUE
	return FALSE

/**
 * Reproduce.
 */
/datum/ai_behavior/make_babies
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/make_babies/setup(datum/ai_controller/controller, target_key, child_types_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(!target)
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/make_babies/perform(seconds_per_tick, datum/ai_controller/controller, target_key, child_types_key)
	var/mob/target = controller.blackboard[target_key]
	var/list/children_types = controller.blackboard[child_types_key]
	if(!valid_partner(target) || is_type_in_list(target, children_types))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.ai_interact(target = target, combat_mode = FALSE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/make_babies/proc/valid_partner(mob/target)
	return !QDELETED(target) && target.stat == CONSCIOUS

/datum/ai_behavior/make_babies/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/find_partner/raptor/valid_partner(mob/living/other, mob/living/living_pawn)
	. = ..()
	if (!. || !istype(other, /mob/living/basic/raptor))
		return FALSE
	var/mob/living/basic/raptor/raptor = other
	return raptor.growth_stage == RAPTOR_ADULT

/datum/ai_behavior/make_babies/raptor/valid_partner(mob/target)
	. = ..()
	if (!. || !istype(target, /mob/living/basic/raptor))
		return FALSE
	var/mob/living/basic/raptor/raptor = target
	return raptor.growth_stage == RAPTOR_ADULT

#undef FIND_PARTNER_COOLDOWN
