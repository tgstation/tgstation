/datum/ai_controller/basic_controller/minebot
	behavior_tree_json = "minebot.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_BASIC_MOB_FLEE_DISTANCE = 3,
		BB_MINIMUM_SHOOTING_DISTANCE = 3,
		BB_MINEBOT_PLANT_MINES = TRUE,
		BB_MINEBOT_REPAIR_DRONE = TRUE,
		BB_MINEBOT_AUTO_DEFEND = TRUE,
		BB_BLACKLIST_MINERAL_TURFS = list(/turf/closed/mineral/gibtonite),
		BB_AUTOMATED_MINING = FALSE,
		BB_OWNER_SELF_HARM_RESPONSES = list(
			"Please stop hurting yourself.",
			"There is no need to do that.",
			"Your actions are illogical.",
			"Please make better choices.",
			"Remember, you have beaten your worst days before."
		)
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/datum/bt_node/subtree/minebot_combat
	behavior_tree_json = "minebot_combat.bt.json"

/datum/bt_node/subtree/minebot_mining
	behavior_tree_json = "minebot_mining.bt.json"

/// Mineral wall finder that skips turfs in the blacklist and the previously unreachable wall.
/datum/bt_node/ai_behavior/find_mineral_wall/minebot

/datum/bt_node/ai_behavior/find_mineral_wall/minebot/check_if_mineable(datum/ai_controller/controller, turf/target_wall)
	var/list/forbidden = controller.blackboard[BB_BLACKLIST_MINERAL_TURFS]
	var/turf/previous_unreachable = controller.blackboard[BB_PREVIOUS_UNREACHABLE_WALL]
	if(is_type_in_list(target_wall, forbidden) || target_wall == previous_unreachable)
		return FALSE
	controller.clear_blackboard_key(BB_PREVIOUS_UNREACHABLE_WALL)
	return ..()

/// Mines a mineral turf at range using RangedAttack rather than ai_interact.
/datum/bt_node/ai_behavior/minebot_mine_turf
	time_between_perform = 3 SECONDS
	var/target_key = BB_TARGET_MINERAL_TURF

/datum/bt_node/ai_behavior/minebot_mine_turf/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/living_pawn = controller.pawn
	var/turf/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(check_obstacles_in_path(controller, target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!living_pawn.combat_mode)
		living_pawn.set_combat_mode(TRUE)
	living_pawn.RangedAttack(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/minebot_mine_turf/proc/check_obstacles_in_path(datum/ai_controller/controller, turf/target)
	var/mob/living/source = controller.pawn
	var/list/turfs_in_path = get_line(source, target) - target
	for(var/turf/turf in turfs_in_path)
		if(turf.is_blocked_turf(ignore_atoms = list(source)))
			controller.set_blackboard_key(BB_PREVIOUS_UNREACHABLE_WALL, target)
			return TRUE
	return FALSE

/datum/bt_node/ai_behavior/minebot_mine_turf/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// Sends a radio SOS message for a dead or unconscious miner. Clears the target key on finish.
/datum/bt_node/ai_behavior/send_sos_message
	time_between_perform = 2 MINUTES
	var/target_key = BB_NEARBY_DEAD_MINER

/datum/bt_node/ai_behavior/send_sos_message/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/carbon/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn
	if(QDELETED(target) || is_station_level(target.z))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/turf/target_turf = get_turf(target)
	var/obj/item/implant/radio/radio_implant = locate(/obj/item/implant/radio) in living_pawn.contents
	if(!radio_implant)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/message = "ALERT, [target] in need of help at coordinates: [target_turf.x], [target_turf.y], [target_turf.z]!"
	radio_implant.radio.talk_into(living_pawn, message, RADIO_CHANNEL_SUPPLY)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/send_sos_message/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// Moves adjacent to an allied node drone and repairs it if its health is below the threshold.
/// Fails if the drone is healthy, not allied, or repair is disabled.
/datum/bt_node/ai_behavior/repair_drone
	var/target_key = BB_DRONE_DEFEND
	var/repair_threshold = 0.75

/datum/bt_node/ai_behavior/repair_drone/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(!controller.blackboard[BB_MINEBOT_REPAIR_DRONE])
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.has_ally(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(target.health >= target.maxHealth * repair_threshold)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	INVOKE_ASYNC(living_pawn, TYPE_PROC_REF(/atom/movable, say), "REPAIRING [target]!")
	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Turns off combat mode then interacts with a nearby ore to collect it. Clears the target key on finish.
/datum/bt_node/ai_behavior/collect_ore/minebot
	var/target_key = BB_ORE_TARGET

/datum/bt_node/ai_behavior/collect_ore/minebot/perform(seconds_per_tick, datum/ai_controller/controller)
	var/obj/item/stack/ore/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.combat_mode)
		living_pawn.set_combat_mode(FALSE)
	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/collect_ore/minebot/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

/// befriend_target variant that fails immediately if the target is already an ally — used to gate the drone-defend block.
/datum/bt_node/ai_behavior/befriend_target/check_ally

/datum/bt_node/ai_behavior/befriend_target/check_ally/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target) || living_pawn.has_ally(living_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	return ..()

/// BT-native ranged attack for the minebot. Avoids friendly fire.
/datum/bt_node/ai_behavior/basic_ranged_attack/minebot
	avoid_friendly_fire = TRUE

/// Accepts humans with TRAIT_ROCK_STONER (miners).
/datum/targeting_strategy/rock_stoner

/datum/targeting_strategy/rock_stoner/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target, /mob/living/carbon/human))
		return FALSE
	return HAS_TRAIT(target, TRAIT_ROCK_STONER)

/// Accepts unconscious or dead humans that have a mind (i.e., real players/NPCs that need SOS).
/datum/targeting_strategy/unconscious_human

/datum/targeting_strategy/unconscious_human/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target, /mob/living/carbon/human))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	return human_target.stat >= UNCONSCIOUS && human_target.mind

///pet commands
/datum/pet_command/free/minebot

/datum/pet_command/free/minebot/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, FALSE)
	return ..()

/datum/pet_command/automate_mining
	command_name = "Automate mining"
	command_desc = "Make your minebot automatically mine!"
	radial_icon_state = "mine"
	speech_commands = list("mine")
	callout_type = /datum/callout_option/mine

/datum/pet_command/automate_mining/valid_callout_target(mob/living/speaker, datum/callout_option/callout, atom/target)
	return ismineralturf(target)

/datum/pet_command/automate_mining/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to start mining!"

/datum/pet_command/automate_mining/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, TRUE)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/minebot_ability
	command_name = "Minebot ability"
	command_desc = "Make your minebot use one of its abilities."
	radial_icon = 'icons/mob/actions/actions_mecha.dmi'
	///the ability we will use
	var/ability_key

/datum/pet_command/minebot_ability/execute_action(datum/ai_controller/controller)
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	if(!ability?.IsAvailable())
		return
	INVOKE_ASYNC(ability, TYPE_PROC_REF(/datum/action, Trigger))
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)

/datum/pet_command/minebot_ability/light
	command_name = "Toggle lights"
	command_desc = "Make your minebot toggle its lights."
	speech_commands = list("light")
	radial_icon_state = "mech_lights_off"
	ability_key = BB_MINEBOT_LIGHT_ABILITY

/datum/pet_command/minebot_ability/light/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to toggle its lights!"

/datum/pet_command/minebot_ability/dump
	command_name = "Dump ore"
	command_desc = "Make your minebot dump all its ore!"
	speech_commands = list("dump", "ore")
	radial_icon_state = "mech_eject"
	ability_key = BB_MINEBOT_DUMP_ABILITY

/datum/pet_command/minebot_ability/dump/retrieve_command_text(atom/living_pet, atom/target)
	return "signals [living_pet] to dump its ore!"

/datum/pet_command/minebot_ability/dump/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, FALSE) //else bro will just pick it up
	return ..()

/datum/pet_command/attack/minebot
	attack_subtree = /datum/bt_node/subtree/pet_command/attack/minebot

/datum/pet_command/attack/minebot/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, FALSE)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.combat_mode)
		living_pawn.set_combat_mode(TRUE)
	return ..()

/datum/pet_command/idle/minebot

/datum/pet_command/idle/minebot/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, FALSE)
	return ..()

/datum/pet_command/protect_owner/minebot

/datum/pet_command/protect_owner/minebot/set_command_target(mob/living/parent, atom/target)
	if(!parent.ai_controller.blackboard[BB_MINEBOT_AUTO_DEFEND])
		return FALSE
	if(!parent.ai_controller.blackboard_key_exists(BB_CURRENT_TARGET) && !QDELETED(target)) //we are already dealing with something,
		parent.ai_controller.set_blackboard_key(BB_CURRENT_TARGET, target)
	return TRUE

/datum/pet_command/protect_owner/minebot/execute_action(datum/ai_controller/controller)
	if(controller.blackboard[BB_MINEBOT_AUTO_DEFEND])
		var/mob/living/living_pawn = controller.pawn
		living_pawn.set_combat_mode(TRUE)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
