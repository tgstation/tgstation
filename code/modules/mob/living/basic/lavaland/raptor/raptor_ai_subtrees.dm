/datum/ai_planning_subtree/find_and_hunt_target/heal_raptors
	target_key = BB_INJURED_RAPTOR
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/heal_raptor
	finding_behavior = /datum/ai_behavior/find_hunt_target/injured_raptor
	hunt_targets = list(/mob/living/basic/raptor)
	hunt_chance = 70
	hunt_range = 9

/datum/ai_planning_subtree/find_and_hunt_target/heal_raptors/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_BASIC_MOB_HEALER])
		return
	return ..()

/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee/raptor
	target_key = BB_BASIC_MOB_FLEE_TARGET

/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee/raptor/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_RAPTOR_COWARD])
		return
	return ..()

/datum/ai_planning_subtree/find_and_hunt_target/care_for_young
	target_key = BB_RAPTOR_BABY
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/reset_target_combat_mode_off/care_for_young
	finding_behavior = /datum/ai_behavior/find_hunt_target/raptor_baby
	hunt_targets = list(/mob/living/basic/raptor/baby_raptor)
	hunt_chance = 75
	hunt_range = 9

/datum/ai_planning_subtree/find_and_hunt_target/care_for_young/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_RAPTOR_MOTHERLY])
		return
	return ..()

/datum/ai_planning_subtree/find_and_hunt_target/raptor_trough
	target_key = BB_RAPTOR_TROUGH_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/interact_with_target/reset_target_combat_mode_off
	finding_behavior = /datum/ai_behavior/find_hunt_target/raptor_trough
	hunt_targets = list(/obj/structure/ore_container/food_trough/raptor_trough)
	hunt_chance = 80
	hunt_range = 9

/datum/ai_planning_subtree/find_and_hunt_target/raptor_trough/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(world.time < controller.blackboard[BB_NEXT_FOOD_EAT])
		return
	return ..()

/datum/ai_planning_subtree/find_and_hunt_target/play_with_owner/raptor/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_RAPTOR_PLAYFUL])
		return
	return ..()
