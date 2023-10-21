/datum/ai_controller/basic_controller/minebot
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic/not_friends,
		BB_BLACKLIST_MINERAL_TURFS = list(/turf/closed/mineral/gibtonite),
		BB_AUTOMATED_MINING = FALSE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/minebot,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/minebot,
		/datum/ai_planning_subtree/minebot_mining,
		/datum/ai_planning_subtree/locate_dead_humans,
	)

///find dead humans and report their location on the radio
/datum/ai_planning_subtree/locate_dead_humans/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(controller.blackboard_key_exists(BB_NEARBY_DEAD_MINER))
		controller.queue_behavior(/datum/ai_behavior/send_sos_message, BB_NEARBY_DEAD_MINER)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_and_set/unconscious_human, BB_NEARBY_DEAD_MINER, /mob/living/carbon/human)

/datum/ai_behavior/find_and_set/unconscious_human/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/mob/living/carbon/human/target in oview(search_range, controller.pawn))
		if(target.stat >= UNCONSCIOUS && target.mind)
			return target

/datum/ai_behavior/send_sos_message
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 2 MINUTES

/datum/ai_behavior/send_sos_message/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/carbon/target = controller.blackboard[target_key]
	var/mob/living/living_pawn = controller.pawn
	if(QDELETED(target) || is_station_level(target.z))
		finish_action(controller, FALSE, target_key)
		return
	var/turf/target_turf = get_turf(target)
	var/obj/item/implant/radio/radio_implant = locate(/obj/item/implant/radio) in living_pawn.contents
	if(!radio_implant)
		finish_action(controller, FALSE, target_key)
		return
	var/message = "ALERT, [target] in need of help at coordinates: [target_turf.x], [target_turf.y], [target_turf.z]!"
	radio_implant.radio.talk_into(living_pawn, message, RADIO_CHANNEL_SUPPLY)
	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/send_sos_message/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

///operational datums is null because we dont use a ranged component, we use a gun in our contents
/datum/ai_planning_subtree/basic_ranged_attack_subtree/minebot
	operational_datums = null
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/minebot

/datum/ai_behavior/basic_ranged_attack/minebot
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	avoid_friendly_fire = TRUE

/datum/ai_planning_subtree/basic_ranged_attack_subtree/minebot/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.combat_mode) //we are not on attack mode
		return
	return ..()

///mine walls if we are on automated mining mode
/datum/ai_planning_subtree/minebot_mining/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_AUTOMATED_MINING])
		return
	if(controller.blackboard_key_exists(BB_TARGET_MINERAL_TURF))
		controller.queue_behavior(/datum/ai_behavior/minebot_mine_turf, BB_TARGET_MINERAL_TURF)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_mineral_wall/minebot, BB_TARGET_MINERAL_TURF)

/datum/ai_behavior/find_mineral_wall/minebot

/datum/ai_behavior/find_mineral_wall/minebot/check_if_mineable(datum/ai_controller/controller, turf/target_wall)
	var/list/forbidden_turfs = controller.blackboard[BB_BLACKLIST_MINERAL_TURFS]
	var/turf/previous_unreachable_wall = controller.blackboard[BB_PREVIOUS_UNREACHABLE_WALL]
	if(is_type_in_list(target_wall, forbidden_turfs) || target_wall == previous_unreachable_wall)
		return FALSE
	controller.clear_blackboard_key(BB_PREVIOUS_UNREACHABLE_WALL)
	return ..()

/datum/ai_behavior/minebot_mine_turf
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 2
	action_cooldown = 3 SECONDS

/datum/ai_behavior/minebot_mine_turf/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/minebot_mine_turf/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()
	var/mob/living/basic/living_pawn = controller.pawn
	var/turf/target = controller.blackboard[target_key]

	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return

	if(check_obstacles_in_path(controller, target))
		finish_action(controller, FALSE, target_key)
		return

	if(!living_pawn.combat_mode)
		living_pawn.set_combat_mode(TRUE)

	living_pawn.RangedAttack(target)
	finish_action(controller, TRUE, target_key)
	return

/datum/ai_behavior/minebot_mine_turf/proc/check_obstacles_in_path(datum/ai_controller/controller, turf/target)
	var/mob/living/source = controller.pawn
	var/list/turfs_in_path = get_line(source, target) - target
	for(var/turf/turf in turfs_in_path)
		if(turf.is_blocked_turf(ignore_atoms = list(source)))
			controller.set_blackboard_key(BB_PREVIOUS_UNREACHABLE_WALL, target)
			return TRUE
	return FALSE

/datum/ai_behavior/minebot_mine_turf/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

///store ores in our body
/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/minebot
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/consume_ores/minebot
	hunt_chance = 100

/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/minebot/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/automated_mining = controller.blackboard[BB_AUTOMATED_MINING]
	var/mob/living/living_pawn = controller.pawn

	if(!automated_mining && living_pawn.combat_mode) //are we not on automated mining or collect mode?
		return

	return ..()

/datum/ai_behavior/hunt_target/unarmed_attack_target/consume_ores/minebot
	hunt_cooldown = 2 SECONDS

/datum/ai_behavior/hunt_target/unarmed_attack_target/consume_ores/minebot/target_caught(mob/living/hunter, obj/item/stack/ore/hunted)
	if(hunter.combat_mode)
		hunter.set_combat_mode(FALSE)
	return ..()

///pet commands
/datum/pet_command/free/minebot

/datum/pet_command/free/minebot/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, FALSE)
	return ..()

/datum/pet_command/automate_mining
	command_name = "Automate mining"
	command_desc = "Make your minebot automatically mine!"
	radial_icon = 'icons/obj/mining.dmi'
	radial_icon_state = "pickaxe"
	speech_commands = list("mine")

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
	controller.queue_behavior(/datum/ai_behavior/use_mob_ability, ability_key)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/pet_command/minebot_ability/light
	command_name = "Toggle lights"
	command_desc = "Make your minebot toggle its lights."
	speech_commands = list("light")
	radial_icon_state = "mech_lights_off"
	ability_key = BB_MINEBOT_LIGHT_ABILITY

/datum/pet_command/minebot_ability/dump
	command_name = "Dump ore"
	command_desc = "Make your minebot dump all its ore!"
	speech_commands = list("dump", "ore")
	radial_icon_state = "mech_eject"
	ability_key = BB_MINEBOT_DUMP_ABILITY

/datum/pet_command/point_targetting/attack/minebot
	attack_behaviour = /datum/ai_behavior/basic_ranged_attack/minebot

/datum/pet_command/point_targetting/attack/minebot/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, FALSE)
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.combat_mode)
		living_pawn.set_combat_mode(TRUE)
	return ..()

/datum/pet_command/idle/minebot

/datum/pet_command/idle/minebot/execute_action(datum/ai_controller/controller)
	controller.set_blackboard_key(BB_AUTOMATED_MINING, FALSE)
	return ..()
