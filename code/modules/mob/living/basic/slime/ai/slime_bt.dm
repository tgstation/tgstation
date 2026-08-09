/// Slime pet command attack: loops feed_on_slime_target toward BB_CURRENT_PET_TARGET.
/datum/bt_node/subtree/pet_command/attack/slime
	behavior_tree_json = "code/modules/mob/living/basic/slime/ai/pet_command_attack_slime.bt.json"

///give them the chud face if they dont feed us, basically select a nice face
/datum/bt_node/ai_behavior/change_slime_face

/datum/bt_node/ai_behavior/change_slime_face/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!prob(5))
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
	else if(controller.blackboard[BB_CURRENT_TARGET])
		new_mood = SLIME_MOOD_MISCHIEVOUS
	else
		new_mood = pick(SLIME_MOOD_SAD, SLIME_MOOD_SMILE, SLIME_MOOD_POUT)

	if(current_mood != new_mood)
		slime_pawn.current_mood = new_mood
		slime_pawn.regenerate_icons()

	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/**
 * Gate for slime food searching: passes only when the slime is unbuckled and is
 * hungryor rabid.
 */
/datum/bt_node/decorator/slime_wants_to_eat

/datum/bt_node/decorator/slime_wants_to_eat/check_condition(datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn) || slime_pawn.buckled)
		return FALSE
	if(controller.blackboard[BB_SLIME_HUNGER_LEVEL] != SLIME_HUNGER_NONE)
		return TRUE
	if(controller.blackboard[BB_SLIME_RABID])
		return TRUE
	return TRUE


///im about to eat this guy up
/datum/bt_node/ai_behavior/feed_on_slime_target
	var/target_key

/datum/bt_node/ai_behavior/feed_on_slime_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn)) //bro lmao comeon
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(slime_pawn.buckled)
		if(slime_pawn.buckled == target) //we got em boys
			return AI_BEHAVIOR_DELAY
		else
			slime_pawn.stop_feeding()
			return AI_BEHAVIOR_FAILED //epic fail; try again

	if(!slime_pawn.can_feed_on(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if((target.body_position != STANDING_UP) || prob(20))
		slime_pawn.start_feeding(target)
		return AI_BEHAVIOR_DELAY

	if(target.client && target.health >= 20)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	slime_pawn.start_feeding(target)
	return AI_BEHAVIOR_DELAY


/datum/bt_node/ai_behavior/feed_on_slime_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	slime_pawn.stop_feeding()
