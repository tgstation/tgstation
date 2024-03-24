/datum/ai_controller/basic_controller/slime
	blackboard = list(
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_SLIME_RABID = FALSE,
		BB_SLIME_HUNGER_DISABLED = FALSE,
		BB_CURRENT_HUNTING_TARGET = null, // people whose energy we want to drain
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/change_slime_face,
		/datum/ai_planning_subtree/use_mob_ability/evolve,
		/datum/ai_planning_subtree/use_mob_ability/reproduce,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/pet_planning/slime,
		/datum/ai_planning_subtree/find_and_hunt_target/find_slime_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/slime,
		/datum/ai_planning_subtree/random_speech/slime,
	)

/datum/ai_planning_subtree/use_mob_ability/evolve
	ability_key = BB_SLIME_EVOLVE

/datum/ai_planning_subtree/use_mob_ability/reproduce
	ability_key = BB_SLIME_REPRODUCE

///Most of the slime actions are not queued up if a slime is buckled. When commanded, they will unbuckle.
/datum/ai_planning_subtree/pet_planning/slime/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn))
		return

	var/datum/pet_command/command = controller.blackboard[BB_ACTIVE_PET_COMMAND]
	if (command)
		controller.queue_behavior(/datum/ai_behavior/interrupt_slime_feeding)

	return ..()

/datum/ai_behavior/interrupt_slime_feeding

/datum/ai_behavior/interrupt_slime_feeding/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn))
		return

	slime_pawn.stop_feeding()

	finish_action(controller, TRUE)

//Handles the slime changing their facial overlays
/datum/ai_planning_subtree/change_slime_face
	var/face_change_chance = 5

/datum/ai_planning_subtree/change_slime_face/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!SPT_PROB(face_change_chance, seconds_per_tick))
		return

	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn))
		return

	if(slime_pawn.stat) //dead slimes make no smiles
		return

	controller.queue_behavior(/datum/ai_behavior/perform_change_slime_face)

/datum/ai_behavior/perform_change_slime_face

/datum/ai_behavior/perform_change_slime_face/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/basic/slime/slime_pawn = controller.pawn
	if(!istype(slime_pawn))
		return

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

	finish_action(controller, TRUE)

// Slime subtree for hunting down people to drain
/datum/ai_planning_subtree/find_and_hunt_target/find_slime_food
	finding_behavior = /datum/ai_behavior/find_hunt_target/find_slime_food
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/slime
	hunt_targets = list(/mob/living)
	hunt_range = 7

/datum/ai_planning_subtree/find_and_hunt_target/find_slime_food/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.buckled)
		return FALSE

	//Slimes don't want to hunt if they are neither rabid, hungry or feeling attack right now
	if( (controller.blackboard[BB_SLIME_HUNGER_LEVEL] == SLIME_HUNGER_NONE) && !controller.blackboard[BB_SLIME_RABID] && isnull(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]))
		return FALSE

	return ..()

// Check if the slime can drain the target
/datum/ai_behavior/find_hunt_target/find_slime_food/valid_dinner(mob/living/basic/slime/hunter, mob/living/dinner, radius, datum/ai_controller/controller, seconds_per_tick)

	if(REF(dinner) in hunter.faction) //Don't eat our friends...
		return

	if(!hunter.can_feed_on(dinner, check_adjacenct = FALSE)) //Are they tasty to slimes?
		return

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
	if((hunted.body_position != STANDING_UP) || prob(20)) //Not standing, or we rolled well? Feed.
		hunter.start_feeding(hunted)
		return

	if(hunted.client && hunted.health >= 20) //If target has a client and is healthy, punch them a bit before feasting
		hunter.UnarmedAttack(hunted, TRUE)
		return

	hunter.start_feeding(hunted)

/datum/ai_behavior/hunt_target/unarmed_attack_target/slime/finish_action(datum/ai_controller/controller, succeeded, hunting_target_key, hunting_cooldown_key)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.buckled)
		controller.clear_blackboard_key(hunting_target_key)

/datum/ai_planning_subtree/basic_melee_attack_subtree/slime

/datum/ai_planning_subtree/basic_melee_attack_subtree/slime/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.buckled)
		return
	return ..()

/datum/ai_planning_subtree/random_speech/slime
	speech_chance = 1
	speak = list("Blorble...","Bzzt...","")
	emote_hear = list("blorbles.")
	emote_see = list("lights up for a bit, then stops.","bounces in place.", "jiggles!","vibrates!")
