/datum/ai_controller/basic_controller/minebot
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
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/launch_missiles,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/befriend_miners,
		/datum/ai_planning_subtree/defend_node,
		/datum/ai_planning_subtree/minebot_maintain_distance,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/minebot,
		/datum/ai_planning_subtree/find_and_hunt_target/hunt_ores/minebot,
		/datum/ai_planning_subtree/minebot_mining,
		/datum/ai_planning_subtree/locate_dead_humans,
	)
	ai_traits = PAUSE_DURING_DO_AFTER

/datum/ai_planning_subtree/launch_missiles

/datum/ai_planning_subtree/launch_missiles/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/missile_ability = controller.blackboard[BB_MINEBOT_MISSILE_ABILITY]
	if(!missile_ability?.IsAvailable())
		return
	if(!controller.blackboard_key_exists(BB_MINEBOT_MISSILE_TARGET))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/clear_bombing_zone, BB_MINEBOT_MISSILE_TARGET, /obj/effect/temp_visual/minebot_target, 7)
		return
	controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_clear_target, BB_MINEBOT_MISSILE_ABILITY, BB_MINEBOT_MISSILE_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/find_and_set/clear_bombing_zone

/datum/ai_behavior/find_and_set/clear_bombing_zone/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/obj/effect/temp_visual/minebot_target/target in oview(search_range, controller.pawn))
		if(isclosedturf(get_turf(target)))
			continue
		return target
	return null

/datum/ai_planning_subtree/befriend_miners/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_MINER_FRIEND))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/miner_to_befriend, BB_MINER_FRIEND)
		return
	controller.queue_behavior(/datum/ai_behavior/befriend_target, BB_MINER_FRIEND)

/datum/ai_behavior/find_and_set/miner_to_befriend

/datum/ai_behavior/find_and_set/miner_to_befriend/search_tactic(datum/ai_controller/controller, locate_path, search_range)
	for(var/mob/living/carbon/human/target in oview(search_range, controller.pawn))
		if(HAS_TRAIT(target, TRAIT_ROCK_STONER))
			return target
	return null

/datum/ai_planning_subtree/defend_node/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[BB_DRONE_DEFEND]
	if(QDELETED(target))
		controller.queue_behavior(/datum/ai_behavior/find_and_set, BB_DRONE_DEFEND, /mob/living/basic/node_drone)
		return
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.faction.Find(REF(target)))
		controller.queue_behavior(/datum/ai_behavior/befriend_target, BB_DRONE_DEFEND)
		return
	if(target.health < (target.maxHealth * 0.75) && controller.blackboard[BB_MINEBOT_REPAIR_DRONE])
		controller.queue_behavior(/datum/ai_behavior/repair_drone, BB_DRONE_DEFEND)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/repair_drone
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/repair_drone/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target = controller.blackboard[target_key]
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/repair_drone/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/living_pawn = controller.pawn
	living_pawn.say("REPAIRING [target]!")
	living_pawn.UnarmedAttack(target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/repair_drone/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	if(!success)
		controller.clear_blackboard_key(target_key)

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
	return null

/datum/ai_behavior/send_sos_message
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	action_cooldown = 2 MINUTES

/datum/ai_behavior/send_sos_message/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
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

/datum/ai_behavior/send_sos_message/finish_action(datum/ai_controller/controller, success, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

///operational datums is null because we dont use a ranged component, we use a gun in our contents
/datum/ai_planning_subtree/basic_ranged_attack_subtree/minebot
	operational_datums = null
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/minebot

/datum/ai_planning_subtree/basic_ranged_attack_subtree/minebot/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return
	var/mob/living/living_pawn = controller.pawn
	if(!living_pawn.combat_mode) //we are not on attack mode
		return
	controller.queue_behavior(ranged_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/minebot_maintain_distance/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return
	var/mob/living/living_pawn = controller.pawn
	if(get_dist(living_pawn, target) <= controller.blackboard[BB_MINIMUM_SHOOTING_DISTANCE])
		controller.queue_behavior(/datum/ai_behavior/run_away_from_target/run_and_shoot/minebot, BB_BASIC_MOB_CURRENT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/run_away_from_target/run_and_shoot/minebot

/datum/ai_behavior/run_away_from_target/run_and_shoot/minebot/perform(seconds_per_tick, datum/ai_controller/controller, target_key, hiding_location_key)
	if(!controller.blackboard[BB_MINEBOT_PLANT_MINES])
		return ..()
	var/datum/action/cooldown/mine_ability = controller.blackboard[BB_MINEBOT_LANDMINE_ABILITY]
	mine_ability?.Trigger()
	return ..()

/datum/ai_behavior/basic_ranged_attack/minebot
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	avoid_friendly_fire = TRUE
	///if our target is closer than this distance, finish action
	var/minimum_distance = 3

/datum/ai_behavior/basic_ranged_attack/minebot/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	minimum_distance = controller.blackboard[BB_MINIMUM_SHOOTING_DISTANCE] ?  controller.blackboard[BB_MINIMUM_SHOOTING_DISTANCE] : initial(minimum_distance)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	var/mob/living/living_pawn = controller.pawn
	if(get_dist(living_pawn, target) <= minimum_distance)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

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
	callout_type = /datum/callout_option/mine

/datum/pet_command/automate_mining/valid_callout_target(mob/living/caller, datum/callout_option/callout, atom/target)
	return ismineralturf(target)

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

/datum/pet_command/point_targeting/attack/minebot
	attack_behaviour = /datum/ai_behavior/basic_ranged_attack/minebot

/datum/pet_command/point_targeting/attack/minebot/execute_action(datum/ai_controller/controller)
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
		return
	if(!parent.ai_controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET) && !QDELETED(target)) //we are already dealing with something,
		parent.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)

/datum/pet_command/protect_owner/minebot/execute_action(datum/ai_controller/controller)
	if(controller.blackboard[BB_MINEBOT_AUTO_DEFEND])
		var/mob/living/living_pawn = controller.pawn
		living_pawn.set_combat_mode(TRUE)
	controller.clear_blackboard_key(BB_ACTIVE_PET_COMMAND)


