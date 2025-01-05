#define PET_PLAYTIME_COOLDOWN (2 MINUTES)
#define MESSAGE_EXPIRY_TIME (30 SECONDS)

/datum/ai_controller/basic_controller/orbie
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TRICK_NAME = "Trick",
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/find_playmates,
		/datum/ai_planning_subtree/relay_pda_message,
		/datum/ai_planning_subtree/pet_planning,
	)

/datum/ai_controller/basic_controller/orbie/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_SET(BB_LAST_RECEIVED_MESSAGE), PROC_REF(on_set_message))

/datum/ai_controller/basic_controller/orbie/proc/on_set_message(datum/source)
	SIGNAL_HANDLER

	addtimer(CALLBACK(src, PROC_REF(clear_blackboard_key), BB_LAST_RECEIVED_MESSAGE), MESSAGE_EXPIRY_TIME)

///ai behavior that lets us search for other orbies to play with
/datum/ai_planning_subtree/find_playmates

/datum/ai_planning_subtree/find_playmates/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_NEXT_PLAYDATE] > world.time)
		return
	if(controller.blackboard_key_exists(BB_NEARBY_PLAYMATE))
		controller.queue_behavior(/datum/ai_behavior/interact_with_playmate, BB_NEARBY_PLAYMATE)
		return SUBTREE_RETURN_FINISH_PLANNING

	controller.queue_behavior(/datum/ai_behavior/find_and_set/find_playmate, BB_NEARBY_PLAYMATE, /mob/living/basic/orbie)

/datum/ai_behavior/find_and_set/find_playmate

/datum/ai_behavior/find_and_set/find_playmate/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/mob/living/basic/orbie/playmate in oview(search_range, controller.pawn))
		if(playmate == controller.pawn || playmate.stat == DEAD || isnull(playmate.ai_controller))
			continue
		if(playmate.ai_controller.blackboard[BB_NEARBY_PLAYMATE] || playmate.ai_controller.blackboard[BB_NEXT_PLAYDATE] > world.time) //they already have a playmate...
			continue
		playmate.ai_controller.set_blackboard_key(BB_NEARBY_PLAYMATE, controller.pawn)
		return playmate
	return null


/datum/ai_behavior/interact_with_playmate
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/interact_with_playmate/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/interact_with_playmate/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	living_pawn.manual_emote("plays with [target]!")
	living_pawn.spin(spintime = 4, speed = 1)
	living_pawn.ClickOn(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/interact_with_playmate/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
	controller.set_blackboard_key(BB_NEXT_PLAYDATE, world.time + PET_PLAYTIME_COOLDOWN)

/datum/ai_planning_subtree/relay_pda_message

/datum/ai_planning_subtree/relay_pda_message/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard[BB_VIRTUAL_PET_LEVEL] < 2 || isnull(controller.blackboard[BB_LAST_RECEIVED_MESSAGE]))
		return

	controller.queue_behavior(/datum/ai_behavior/relay_pda_message, BB_LAST_RECEIVED_MESSAGE)

/datum/ai_behavior/relay_pda_message/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/text_to_say = controller.blackboard[target_key]
	if(isnull(text_to_say))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	living_pawn.say(text_to_say, forced = "AI controller")
	living_pawn.spin(spintime = 4, speed = 1)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/relay_pda_message/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/pet_command/follow/orbie
	follow_behavior = /datum/ai_behavior/pet_follow_friend/orbie

/datum/pet_command/follow/orbie/New(mob/living/parent)
	. = ..()
	RegisterSignal(parent, COMSIG_VIRTUAL_PET_SUMMONED, PROC_REF(on_summon))

/datum/pet_command/follow/orbie/proc/on_summon(datum/source, mob/living/friend)
	SIGNAL_HANDLER
	set_command_active(source, friend)

/datum/ai_behavior/pet_follow_friend/orbie
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

///command to make our pet turn its lights on, we need to be level 2 to activate this ability
/datum/pet_command/untargeted_ability/pet_lights
	command_name = "Lights"
	command_desc = "Toggle your pet's lights!"
	radial_icon = 'icons/mob/simple/pets.dmi'
	radial_icon_state = "orbie_lights_action"
	speech_commands = list("lights", "light", "toggle")
	ability_key = BB_LIGHTS_ABILITY

/datum/pet_command/untargeted_ability/pet_lights/execute_action(datum/ai_controller/controller)
	if(controller.blackboard[BB_VIRTUAL_PET_LEVEL] < 2)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return SUBTREE_RETURN_FINISH_PLANNING
	return ..()

/datum/pet_command/use_ability/pet_lights/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to toggle its lights!"

/datum/pet_command/use_ability/take_photo
	command_name = "Photo"
	command_desc = "Make your pet take a photo!"
	radial_icon = 'icons/obj/art/camera.dmi'
	radial_icon_state = "camera"
	speech_commands = list("photo", "picture", "image")
	command_feedback = "Readys camera mode"
	pet_ability_key = BB_PHOTO_ABILITY
	targeting_strategy_key = BB_TARGETING_STRATEGY

/datum/pet_command/use_ability/take_photo/retrieve_command_text(atom/living_pet, atom/target)
	return isnull(target) ? null : "signals [living_pet] to take a photo of [target]!"


/datum/pet_command/use_ability/take_photo/execute_action(datum/ai_controller/controller)
	if(controller.blackboard[BB_VIRTUAL_PET_LEVEL] < 3)
		controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
		return SUBTREE_RETURN_FINISH_PLANNING
	return ..()

/datum/pet_command/perform_trick_sequence
	command_name = "Trick Sequence"
	command_desc = "A trick sequence programmable through your PDA!"

/datum/pet_command/perform_trick_sequence/find_command_in_text(spoken_text, check_verbosity = FALSE)
	var/mob/living/living_pawn = weak_parent.resolve()
	if(isnull(living_pawn?.ai_controller))
		return FALSE
	var/text_command = living_pawn.ai_controller.blackboard[BB_TRICK_NAME]
	if(isnull(text_command))
		return FALSE
	return findtext(spoken_text, text_command)

/datum/pet_command/perform_trick_sequence/light/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to dance!"

/datum/pet_command/perform_trick_sequence/execute_action(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/list/trick_sequence = controller.blackboard[BB_TRICK_SEQUENCE]
	for(var/index in 1 to length(trick_sequence))
		addtimer(CALLBACK(living_pawn, TYPE_PROC_REF(/mob, emote), trick_sequence[index], index * 0.5 SECONDS))
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING

#undef PET_PLAYTIME_COOLDOWN
#undef MESSAGE_EXPIRY_TIME
