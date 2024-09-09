/datum/ai_behavior/perform_change_slime_face

/datum/ai_behavior/perform_change_slime_face/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn))
		return AI_BEHAVIOR_DELAY

	var/current_mood = slime_pawn.current_mood

	var/new_mood = SLIME_MOOD_NONE

	if (controller.blackboard[BB_SLIME_RABID] || LAZYLEN(controller.blackboard[BB_BASIC_MOB_RETALIATE_LIST]) > 0)
		new_mood = SLIME_MOOD_ANGRY
	else if (controller.blackboard[BB_SLIME_HUNGER_DISABLED])
		new_mood = SLIME_MOOD_SMILE
	else if (controller.blackboard[BB_CURRENT_HUNTING_TARGET])
		new_mood = SLIME_MOOD_MISCHIEVOUS
	else
		new_mood = pick(SLIME_MOOD_SAD, SLIME_MOOD_SMILE, SLIME_MOOD_POUT)

	if(current_mood != new_mood)
		slime_pawn.current_mood = new_mood
		slime_pawn.regenerate_icons()

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/find_hunt_target/find_slime_food

// Check if the slime can drain the target
/datum/ai_behavior/find_hunt_target/find_slime_food/valid_dinner(mob/living/basic/slime/hunter, mob/living/dinner, radius, datum/ai_controller/controller, seconds_per_tick)

	if(REF(dinner) in hunter.faction) //Don't eat our friends...
		return FALSE

	var/static/list/slime_faction = list(FACTION_SLIME)
	if(faction_check(slime_faction, dinner.faction)) //Don't try to eat slimy things, no matter how hungry we are. Anyone else can be betrayed.
		return FALSE

	if(!hunter.can_feed_on(dinner, check_adjacent = FALSE)) //Are they tasty to slimes?
		return FALSE

	//If we are retaliating on someone edible, lets eat them instead
	if(dinner == controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return can_see(hunter, dinner, radius)

	//We are so hungry, lets eat them
	if(controller.blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_STARVING && controller.blackboard[BB_SLIME_RABID])
		return can_see(hunter, dinner, radius)

	//A bit pickier
	if((islarva(dinner) || ismonkey(dinner)) || (ishuman(dinner) || isalienadult(dinner) && SPT_PROB(2.5, seconds_per_tick)))
		return can_see(hunter, dinner, radius)

	//We are not THAT hungry
	return FALSE

/datum/ai_behavior/hunt_target/unarmed_attack_target/slime

/datum/ai_behavior/hunt_target/unarmed_attack_target/slime/target_caught(mob/living/basic/slime/hunter, mob/living/hunted)
	if (!hunter.can_feed_on(hunted)) // Target is no longer edible
		hunter.UnarmedAttack(hunted, TRUE)
		return

	if((hunted.body_position != STANDING_UP) || prob(20)) //Not standing, or we rolled well? Feed.
		hunter.start_feeding(hunted)
		return

	if(hunted.client && hunted.health >= 20) //If target has a client and is healthy, punch them a bit before feasting
		hunter.UnarmedAttack(hunted, TRUE)
		return

	hunter.start_feeding(hunted)

/datum/ai_behavior/hunt_target/unarmed_attack_target/slime/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	var/atom/target = controller.blackboard[hunting_target_key]
	if(!slime_pawn.can_feed_on(target))
		controller.clear_blackboard_key(hunting_target_key)
