/datum/ai_controller/basic_controller/ice_demon
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_LIST_SCARY_ITEMS = list(
			/obj/item/weldingtool,
			/obj/item/flashlight/flare,
		),
		BB_BASIC_MOB_FLEEING = TRUE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/flee_target/ice_demon,
		/datum/ai_planning_subtree/find_and_hunt_target/teleport_destination,
		/datum/ai_planning_subtree/targeted_mob_ability/summon_afterimages,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/maintain_distance/cover_minimum_distance/ice_demon,
	)


/datum/ai_planning_subtree/maintain_distance/cover_minimum_distance/ice_demon
	minimum_distance = 5
	maximum_distance = 7

/datum/ai_planning_subtree/maintain_distance/cover_minimum_distance/ice_demon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/teleport_ability = controller.blackboard[BB_DEMON_TELEPORT_ABILITY]
	if(!teleport_ability?.IsAvailable())
		return ..()

	var/mob/living/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	var/distance_to_target = get_dist(living_pawn, target)
	if(distance_to_target >= minimum_distance)
		return ..()

	//instead of running away, we will teleport away! teleportation is handled by hunt_target behavior
	controller.queue_behavior(/datum/ai_behavior/find_furthest_turf_from_target, target_key, BB_TELEPORT_DESTINATION, minimum_distance - distance_to_target)

///find furtherst turf target so we may teleport to it
/datum/ai_behavior/find_furthest_turf_from_target

/datum/ai_behavior/find_furthest_turf_from_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, set_key, range)
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return

	var/distance = 0
	var/turf/chosen_turf
	for(var/turf/open/potential_destination in oview(controller.pawn, range))
		if(potential_destination.is_blocked_turf())
			continue
		var/new_distance_to_target = get_dist(potential_destination, living_target)
		if(new_distance_to_target > distance)
			chosen_turf = potential_destination
			distance = new_distance_to_target
		if(distance == range)
			break //we have already found the max distance

	if(isnull(chosen_turf))
		finish_action(controller, FALSE)
		return

	controller.set_blackboard_key(BB_TELEPORT_DESTINATION, chosen_turf)
	finish_action(controller, TRUE)


/datum/ai_planning_subtree/find_and_hunt_target/teleport_destination
	target_key = BB_TELEPORT_DESTINATION
	hunting_behavior = /datum/ai_behavior/hunt_target/use_ability_on_target/demon_teleport
	finding_behavior = /datum/ai_behavior/find_valid_teleport_location
	hunt_targets = list(/turf/open)
	hunt_chance = 100
	hunt_range = 3

/datum/ai_planning_subtree/find_and_hunt_target/teleport_destination/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return
	var/datum/action/cooldown/ability = controller.blackboard[BB_DEMON_TELEPORT_ABILITY]
	if(!ability?.IsAvailable())
		return
	return ..()

/datum/ai_behavior/find_valid_teleport_location

/datum/ai_behavior/find_valid_teleport_location/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, types_to_hunt, hunt_range)
	. = ..()
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/list/possible_turfs = list()

	if(QDELETED(target))
		finish_action(controller, FALSE)
		return

	for(var/turf/open/potential_turf in oview(target, hunt_range)) //we check for turfs around the target
		if(potential_turf.is_blocked_turf())
			continue
		if(!can_see(target, potential_turf, hunt_range))
			continue
		possible_turfs += potential_turf

	if(!length(possible_turfs))
		finish_action(controller, FALSE)
		return

	controller.set_blackboard_key(hunting_target_key, pick(possible_turfs))
	finish_action(controller, TRUE)

/datum/ai_behavior/hunt_target/use_ability_on_target/demon_teleport
	hunt_cooldown = 5 SECONDS
	ability_key = BB_DEMON_TELEPORT_ABILITY
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	always_reset_target = TRUE

/datum/ai_planning_subtree/targeted_mob_ability/summon_afterimages
	ability_key = BB_DEMON_CLONE_ABILITY

/datum/ai_planning_subtree/targeted_mob_ability/summon_afterimages/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn
	if(living_pawn.health / living_pawn.maxHealth > 0.5) //only use this ability when under half health
		return
	return ..()

/datum/ai_planning_subtree/flee_target/ice_demon

/datum/ai_planning_subtree/flee_target/ice_demon/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		return
	if(!iscarbon(target))
		return
	var/mob/living/carbon/human_target = target

	for(var/obj/held_item in human_target.held_items)
		if(!is_type_in_list(held_item, controller.blackboard[BB_LIST_SCARY_ITEMS]))
			continue
		if(!held_item.light_on)
			continue
		var/datum/action/cooldown/slip_ability = controller.blackboard[BB_DEMON_SLIP_ABILITY]
		if(!slip_ability?.IsAvailable())
			controller.queue_behavior(/datum/ai_behavior/use_mob_ability/burrow, BB_DEMON_SLIP_ABILITY)
		return ..()

/datum/ai_controller/basic_controller/ice_demon/afterimage
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/flee_target/ice_demon, //even the afterimages are afraid of flames!
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
