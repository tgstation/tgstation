// =============================================================================
// Dog BT-native behaviors
// =============================================================================

/**
 * BT version of basic_melee_attack/dog.
 * When adjacent and BB_DOG_HARASS_HARM = FALSE: paws harmlessly (animation, no damage).
 * When adjacent and BB_DOG_HARASS_HARM = TRUE: bites normally.
 * Returns FAILURE if targeting strategy rejects the target.
 */
/datum/bt_node/ai_behavior/basic_melee_attack/dog

/datum/bt_node/ai_behavior/basic_melee_attack/dog/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/living_pawn = controller.pawn
	if(!(isturf(living_pawn.loc) || HAS_TRAIT(living_pawn, TRAIT_AI_BAGATTACK)))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/target = controller.blackboard[target_key]
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(QDELETED(target) || !targeting_strategy?.can_attack(living_pawn, target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	if(!controller.blackboard[BB_DOG_HARASS_HARM])
		paw_harmlessly(living_pawn, target, seconds_per_tick)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return ..(seconds_per_tick, controller, target_key, targeting_strategy_key, hiding_location_key)

/// Swat at someone we don't like but won't hurt
/datum/bt_node/ai_behavior/basic_melee_attack/dog/proc/paw_harmlessly(mob/living/living_pawn, atom/target, seconds_per_tick)
	if(!SPT_PROB(20, seconds_per_tick))
		return
	living_pawn.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(target, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE, -1)
	target.visible_message(span_danger("[living_pawn] paws ineffectually at [target]!"), span_danger("[living_pawn] paws ineffectually at you!"))

// =============================================================================

/**
 * Searches for a target with TRAIT_HATED_BY_DOGS within 2 tiles. Sets BB_DOG_HARASS_TARGET and
 * BB_DOG_HARASS_HARM = FALSE if found. Returns FAILURE if no valid target is found.
 * Combine with a cooldown decorator or embed the SPT_PROB gate in the parent tree.
 */
/datum/bt_node/ai_behavior/find_hated_dog_target

/datum/bt_node/ai_behavior/find_hated_dog_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key)
	if(!SPT_PROB(10, seconds_per_tick))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/dog = controller.pawn
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	for(var/mob/living/iter_living in oview(2, dog))
		if(iter_living.stat != CONSCIOUS || !HAS_TRAIT(iter_living, TRAIT_HATED_BY_DOGS))
			continue
		if(!isnull(dog.buckled))
			dog.audible_message(span_notice("[dog] growls at [iter_living], yet [dog.p_they()] [dog.p_are()] much too comfy to move."), hearing_distance = COMBAT_MESSAGE_RANGE)
			continue
		if(!strategy?.can_attack(dog, iter_living))
			continue
		dog.audible_message(span_warning("[dog] growls at [iter_living], seemingly annoyed by [iter_living.p_their()] presence."), hearing_distance = COMBAT_MESSAGE_RANGE)
		controller.set_blackboard_key(target_key, iter_living)
		controller.set_blackboard_key(BB_DOG_HARASS_HARM, FALSE)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	controller.clear_blackboard_key(target_key)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

// =============================================================================

/**
 * Dog-specific idle: random walks at a dog-appropriate rate, and occasionally spins/tail-chases.
 * Reads BB_DOG_IS_SLOW to determine movement chance. Always returns BT_RUNNING.
 */
/datum/bt_node/ai_behavior/idle_dog

/datum/bt_node/ai_behavior/idle_dog/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn

	var/obj/item/carry_item = controller.blackboard[BB_SIMPLE_CARRY_ITEM]
	if(carry_item && SPT_PROB(5, seconds_per_tick))
		living_pawn.visible_message(span_notice("[living_pawn] gently teethes on \the [carry_item] in [living_pawn.p_their()] mouth."), vision_distance = COMBAT_MESSAGE_RANGE)

	var/move_chance = controller.blackboard[BB_DOG_IS_SLOW] ? 2.5 : 5
	if(isturf(living_pawn.loc) && !living_pawn.pulledby)
		if(SPT_PROB(move_chance, seconds_per_tick) && (living_pawn.mobility_flags & MOBILITY_MOVE))
			var/move_dir = pick(GLOB.alldirs)
			living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
		else if(SPT_PROB(2, seconds_per_tick))
			living_pawn.manual_emote(pick("dances around.", "chases [living_pawn.p_their()] tail!"))
			living_pawn.AddComponent(/datum/component/spinny)

	return AI_BEHAVIOR_DELAY

// =============================================================================

/**
 * Refreshes BB_BASIC_MOB_SPEAK_LINES from the dog pawn's current speech state, then speaks.
 * Dogs dynamically update their speech based on fashion accessories — this behavior
 * keeps the blackboard in sync before each roll.
 */
/datum/bt_node/ai_behavior/dog_random_speech

/datum/bt_node/ai_behavior/dog_random_speech/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/pet/dog/dog_pawn = controller.pawn
	if(!istype(dog_pawn))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	dog_pawn.update_dog_speak_blackboard(controller)

	var/list/speech_lines = controller.blackboard[BB_BASIC_MOB_SPEAK_LINES]
	if(isnull(speech_lines))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/speech_chance = speech_lines[BB_SPEAK_CHANCE] || 1
	if(!prob(speech_chance)) // Dont use SPT because this can tick on a different interval based on the plan
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/emote_hear = speech_lines[BB_EMOTE_HEAR] || list()
	var/list/emote_see  = speech_lines[BB_EMOTE_SEE]  || list()
	var/list/speak      = speech_lines[BB_EMOTE_SAY]  || list()
	var/list/sounds     = speech_lines[BB_EMOTE_SOUND] || list()

	var/total = length(emote_hear) + length(emote_see) + length(speak)
	if(!total)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/sound_to_play = length(sounds) ? pick(sounds) : null
	var/roll = rand(1, total)

	if(roll <= length(emote_hear))
		dog_pawn.manual_emote(pick(emote_hear))
		if(sound_to_play)
			playsound(dog_pawn, sound_to_play, 80, vary = TRUE, pressure_affected = TRUE, ignore_walls = FALSE)
	else if(roll <= length(emote_hear) + length(emote_see))
		dog_pawn.manual_emote(pick(emote_see))
	else
		dog_pawn.say(pick(speak), forced = "AI Controller")
		if(sound_to_play)
			playsound(dog_pawn, sound_to_play, 80, vary = TRUE)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

// =============================================================================

/// Dog harassment: find a TRAIT_HATED_BY_DOGS target nearby, then approach and paw/bite it.
/datum/bt_node/subtree/dog_harassment
	behavior_tree_json = "code/datums/ai/dog/dog_harassment.bt.json"
