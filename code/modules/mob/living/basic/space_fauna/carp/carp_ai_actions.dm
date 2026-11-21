/// How far away the magicarp looks for a special spell target
#define MAGICARP_SPELL_TARGET_SEEK_RANGE 4
/// How far away the magicarp looks for a regular spell target
#define MAGICARP_SPELL_ENEMY_SEEK_RANGE 9

/datum/pet_command/use_ability/magicarp
	pet_ability_key = BB_MAGICARP_SPELL

/**
 * # Carp should flee
 * Gates the flee/panic-teleport block. A carp flees from its flee target if that target is a feared
 * fisherman, or if it is otherwise allowed to flee (i.e. it's injured, which clears BB_BASIC_MOB_STOP_FLEEING).
 */
/datum/bt_node/decorator/carp_should_flee
	/// Blackboard key holding the thing we'd run away from
	var/target_key = BB_BASIC_MOB_FLEE_TARGET

/datum/bt_node/decorator/carp_should_flee/check_condition(datum/ai_controller/controller)
	var/atom/flee_from = controller.blackboard[target_key]
	if(QDELETED(flee_from))
		return FALSE
	if(controller.blackboard[BB_CARPS_FEAR_FISHERMAN] && HAS_TRAIT(flee_from, TRAIT_SCARY_FISHERMAN))
		return TRUE
	return !controller.blackboard[BB_BASIC_MOB_STOP_FLEEING]

/datum/bt_node/decorator/carp_should_flee/register_observe_signals(atom/pawn)
	RegisterSignals(pawn, list(
		COMSIG_AI_BLACKBOARD_KEY_SET(target_key),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key),
		COMSIG_AI_BLACKBOARD_KEY_SET(BB_BASIC_MOB_STOP_FLEEING),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_BASIC_MOB_STOP_FLEEING),
	), PROC_REF(on_signal_changed))
	return TRUE

/datum/bt_node/decorator/carp_should_flee/unregister_observe_signals(atom/pawn)
	UnregisterSignal(pawn, list(
		COMSIG_AI_BLACKBOARD_KEY_SET(target_key),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key),
		COMSIG_AI_BLACKBOARD_KEY_SET(BB_BASIC_MOB_STOP_FLEEING),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(BB_BASIC_MOB_STOP_FLEEING),
	))

/**
 * # Find magicarp spell target
 * Finds a target for the magicarp's spell. Different spells want different targeting, so rather than make a
 * controller per spell we branch on BB_MAGICARP_SPELL_SPECIAL_TARGETING here. Only runs if the spell is ready.
 */
/datum/bt_node/ai_behavior/find_magicarp_spell_target
	/// Blackboard key holding the spell we're trying to target
	var/ability_key = BB_MAGICARP_SPELL
	/// Blackboard key we store the chosen spell target in
	var/target_key = BB_MAGICARP_SPELL_TARGET
	/// Blackboard key holding our targeting strategy for the default case
	var/targeting_strategy_key = BB_TARGETING_STRATEGY
	/// Blackboard key describing any special targeting this spell wants
	var/special_targeting_key = BB_MAGICARP_SPELL_SPECIAL_TARGETING

/datum/bt_node/ai_behavior/find_magicarp_spell_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/datum/action/cooldown/using_action = controller.blackboard[ability_key]
	if(!using_action?.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/atom/found
	switch(controller.blackboard[special_targeting_key])
		if(MAGICARP_SPELL_CORPSES)
			found = find_friendly_corpse(controller)
		if(MAGICARP_SPELL_OBJECTS)
			found = find_animatable(controller)
		if(MAGICARP_SPELL_WALLS)
			found = find_nearest_wall(controller)
		else
			found = find_nearest_enemy(controller)

	if(isnull(found))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(target_key, found)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Nearest valid combat target which isn't a scary fisherman (default spell targeting)
/datum/bt_node/ai_behavior/find_magicarp_spell_target/proc/find_nearest_enemy(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!strategy)
		return null
	var/list/candidates = list()
	for(var/mob/living/candidate in oview(MAGICARP_SPELL_ENEMY_SEEK_RANGE, living_pawn))
		if(HAS_TRAIT(candidate, TRAIT_SCARY_FISHERMAN))
			continue
		if(!strategy.is_valid_target(living_pawn, candidate, MAGICARP_SPELL_ENEMY_SEEK_RANGE, controller))
			continue
		candidates += candidate
	if(!length(candidates))
		return null
	return get_closest_atom(/mob/living, candidates, living_pawn)

/// An object or structure we could animate with a staff of change
/datum/bt_node/ai_behavior/find_magicarp_spell_target/proc/find_animatable(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/list/nearby_items = list()
	for(var/obj/new_friend in oview(MAGICARP_SPELL_TARGET_SEEK_RANGE, living_pawn))
		if(!isitem(new_friend) && !isstructure(new_friend))
			continue
		if(is_type_in_list(new_friend, GLOB.animatable_blacklist))
			continue
		if(living_pawn.see_invisible < new_friend.invisibility)
			continue
		nearby_items += new_friend
	if(length(nearby_items))
		return pick(nearby_items)
	return null

/// The nearest wall which isn't invulnerable
/datum/bt_node/ai_behavior/find_magicarp_spell_target/proc/find_nearest_wall(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/list/nearby_walls = list()
	for(var/turf/closed/new_wall in oview(MAGICARP_SPELL_TARGET_SEEK_RANGE, living_pawn))
		if(isindestructiblewall(new_wall))
			continue
		nearby_walls += new_wall
	if(length(nearby_walls))
		return get_closest_atom(/turf/closed, nearby_walls, living_pawn)
	return null

/// A corpse who shares our faction, for resurrection spells
/datum/bt_node/ai_behavior/find_magicarp_spell_target/proc/find_friendly_corpse(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/list/nearby_bodies = list()
	for(var/mob/living/dead_pal in oview(MAGICARP_SPELL_TARGET_SEEK_RANGE, living_pawn))
		if(!isturf(dead_pal.loc))
			continue
		if(!dead_pal.stat || dead_pal.health > 0)
			continue
		if(living_pawn.see_invisible < dead_pal.invisibility)
			continue
		if(!living_pawn.faction_check_atom(dead_pal))
			continue
		nearby_bodies += dead_pal
	if(length(nearby_bodies))
		return pick(nearby_bodies)
	return null

#undef MAGICARP_SPELL_TARGET_SEEK_RANGE
#undef MAGICARP_SPELL_ENEMY_SEEK_RANGE
