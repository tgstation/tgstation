#define PET_PLAYTIME_COOLDOWN (2 MINUTES)
#define MESSAGE_EXPIRY_TIME (30 SECONDS)

/datum/ai_controller/basic_controller/orbie
	behavior_tree_json = "code/modules/mob/living/basic/pets/orbie/orbie.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TRICK_NAME = "Trick",
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

/datum/ai_controller/basic_controller/orbie/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(. & AI_CONTROLLER_INCOMPATIBLE)
		return
	RegisterSignal(new_pawn, COMSIG_AI_BLACKBOARD_KEY_SET(BB_LAST_RECEIVED_MESSAGE), PROC_REF(on_set_message))

/datum/ai_controller/basic_controller/orbie/proc/on_set_message(datum/source)
	SIGNAL_HANDLER

	addtimer(CALLBACK(src, PROC_REF(clear_blackboard_key), BB_LAST_RECEIVED_MESSAGE), MESSAGE_EXPIRY_TIME)

/// Finds a nearby free orbie to play with and mutually registers as playmates.
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/find_playmate
	target_key = BB_NEARBY_PLAYMATE
	target_source = /datum/target_source/oview_single_type/orbie
	targeting_strategy = /datum/targeting_strategy/playmate

/datum/bt_node/ai_behavior/acquire_target/update_interaction_target/find_playmate/on_target_found(datum/ai_controller/controller, atom/target, datum/targeting_strategy/strategy)
	var/mob/living/basic/orbie/playmate = target
	playmate.ai_controller.set_blackboard_key(BB_NEARBY_PLAYMATE, controller.pawn)

/// Accepts an orbie that is free to play (no current playmate and not on playdate cooldown).
/datum/targeting_strategy/playmate

/datum/targeting_strategy/playmate/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	if(!istype(target, /mob/living/basic/orbie))
		return FALSE
	var/mob/living/basic/orbie/orbie_target = target
	if(orbie_target == living_mob || orbie_target.stat == DEAD || isnull(orbie_target.ai_controller))
		return FALSE
	if(orbie_target.ai_controller.blackboard[BB_NEARBY_PLAYMATE])
		return FALSE
	if(orbie_target.ai_controller.blackboard[BB_NEXT_PLAYDATE] > world.time)
		return FALSE
	return TRUE

///plays with a nearby orbie
/datum/bt_node/ai_behavior/interact_with_playmate
	var/target_key = "BB_NEARBY_PLAYMATE"

/datum/bt_node/ai_behavior/interact_with_playmate/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	living_pawn.manual_emote("plays with [target]!")
	living_pawn.spin(spintime = 4, speed = 1)
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/mob, ClickOn), target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/interact_with_playmate/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.clear_blackboard_key(target_key)
	controller.set_blackboard_key(BB_NEXT_PLAYDATE, world.time + PET_PLAYTIME_COOLDOWN)

///relays a pda message if orbie is level 2+
/datum/bt_node/ai_behavior/relay_pda_message
	var/target_key = "BB_LAST_RECEIVED_MESSAGE"

/datum/bt_node/ai_behavior/relay_pda_message/perform(seconds_per_tick, datum/ai_controller/controller)
	if(controller.blackboard[BB_VIRTUAL_PET_LEVEL] < 2)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/basic/living_pawn = controller.pawn
	var/text_to_say = controller.blackboard[target_key]
	if(isnull(text_to_say))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/atom/movable, say), text_to_say, forced = "AI controller")
	living_pawn.spin(spintime = 4, speed = 1)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/relay_pda_message/finish_action(datum/ai_controller/controller, success)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/pet_command/follow/orbie

/datum/pet_command/follow/orbie/New(mob/living/parent)
	. = ..()
	RegisterSignal(parent, COMSIG_VIRTUAL_PET_SUMMONED, PROC_REF(on_summon))

/datum/pet_command/follow/orbie/proc/on_summon(datum/source, mob/living/friend)
	SIGNAL_HANDLER
	set_command_active(source, friend)

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
