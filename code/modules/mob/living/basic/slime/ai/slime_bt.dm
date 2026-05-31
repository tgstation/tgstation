/// Slime pet command attack: loops feed_on_slime_target toward BB_CURRENT_PET_TARGET.
/datum/bt_node/subtree/pet_command/attack/slime
	behavior_tree_json = "pet_command_attack_slime.bt.json"

// =============================================================================
// Slime BT-native behaviors
// =============================================================================

/**
 * Updates the slime's facial overlay based on current mood (hunger, rabid, retaliate, hunting).
 * 5% chance per tick. Returns FAILURE if not triggered so the selector passes through.
 */
/datum/bt_node/ai_behavior/change_slime_face

/datum/bt_node/ai_behavior/change_slime_face/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!SPT_PROB(5, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn) || slime_pawn.stat)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/current_mood = slime_pawn.current_mood
	var/new_mood

	if(controller.blackboard[BB_SLIME_RABID] || LAZYLEN(controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]) > 0)
		new_mood = SLIME_MOOD_ANGRY
	else if(controller.blackboard[BB_SLIME_HUNGER_DISABLED])
		new_mood = SLIME_MOOD_SMILE
	else if(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		new_mood = SLIME_MOOD_MISCHIEVOUS
	else
		new_mood = pick(SLIME_MOOD_SAD, SLIME_MOOD_SMILE, SLIME_MOOD_POUT)

	if(current_mood != new_mood)
		slime_pawn.current_mood = new_mood
		slime_pawn.regenerate_icons()

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/**
 * Searches for a living mob the slime can feed on and sets BB_BASIC_MOB_CURRENT_TARGET.
 * Only runs when the slime is hungry, rabid, or already has a combat target.
 */
/datum/bt_node/ai_behavior/find_slime_food
	action_cooldown = 7.5 SECONDS

/datum/bt_node/ai_behavior/find_slime_food/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn) || slime_pawn.buckled)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(controller.blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_NONE && !controller.blackboard[BB_SLIME_RABID] && isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/static/list/slime_faction
	if(isnull(slime_faction))
		slime_faction = string_list(list(FACTION_SLIME))

	for(var/mob/living/candidate in oview(7, slime_pawn))
		if(FAST_FACTION_CHECK(slime_faction, candidate.get_faction(), slime_pawn.allies, candidate.allies, FALSE))
			continue
		if(!slime_pawn.can_feed_on(candidate, check_adjacent = FALSE))
			continue
		if(!valid_slime_target(slime_pawn, candidate, controller, seconds_per_tick))
			continue
		controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, candidate)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/find_slime_food/proc/valid_slime_target(mob/living/basic/slime/slime_pawn, mob/living/candidate, datum/ai_controller/controller, seconds_per_tick)
	if(candidate == controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return can_see(slime_pawn, candidate, 7)
	if(controller.blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_STARVING && controller.blackboard[BB_SLIME_RABID])
		return can_see(slime_pawn, candidate, 7)
	if(islarva(candidate) || ismonkey(candidate) || ishuman(candidate) || (isalienadult(candidate) && SPT_PROB(2.5, seconds_per_tick)))
		return can_see(slime_pawn, candidate, 7)
	return FALSE

// =============================================================================

/**
 * Attempt to feed on the target at BB_BASIC_MOB_CURRENT_TARGET.
 * If the target is feedable, calls start_feeding. Otherwise attacks.
 * Returns FAILURE if the target is gone, buckled (slime), or not feedable in context.
 */
/datum/bt_node/ai_behavior/feed_on_slime_target

/datum/bt_node/ai_behavior/feed_on_slime_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn) || slime_pawn.buckled)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(!slime_pawn.can_feed_on(target))
		slime_pawn.UnarmedAttack(target, TRUE)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if((target.body_position != STANDING_UP) || prob(20))
		slime_pawn.start_feeding(target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if(target.client && target.health >= 20)
		slime_pawn.UnarmedAttack(target, TRUE)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	slime_pawn.start_feeding(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
