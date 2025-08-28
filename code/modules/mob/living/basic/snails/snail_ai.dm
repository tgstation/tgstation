/datum/ai_controller/basic_controller/snail
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/use_mob_ability/snail_retreat,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/find_and_hunt_target/snail_people,
	)

/datum/ai_planning_subtree/find_and_hunt_target/snail_people
	target_key = BB_LOW_PRIORITY_HUNTING_TARGET
	finding_behavior = /datum/ai_behavior/find_hunt_target/snail_people
	hunting_behavior = /datum/ai_behavior/hunt_target/snail_people
	hunt_targets = list(
		/mob/living/carbon,
	)
	hunt_range = 5
	hunt_chance = 45

/datum/ai_behavior/find_hunt_target/snail_people
	action_cooldown = 1 MINUTES
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/find_hunt_target/snail_people/valid_dinner(mob/living/source, mob/living/carbon/potential_snail, radius, datum/ai_controller/controller, seconds_per_tick)
	if(!istype(potential_snail))
		return FALSE
	if(potential_snail.stat != CONSCIOUS)
		return FALSE
	if(!is_species(potential_snail, /datum/species/snail))
		return FALSE
	return can_see(source, potential_snail, radius)

/datum/ai_behavior/hunt_target/snail_people
	always_reset_target = TRUE

/datum/ai_behavior/hunt_target/snail_people/target_caught(mob/living/hunter, atom/hunted)
	hunter.manual_emote("Celebrates around [hunted]!")
	hunter.SpinAnimation(speed = 1, loops = 3)

/datum/ai_planning_subtree/use_mob_ability/snail_retreat
	ability_key = BB_SNAIL_RETREAT_ABILITY
	finish_planning = TRUE

/datum/ai_planning_subtree/use_mob_ability/snail_retreat/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/shell_retreated = HAS_TRAIT(controller.pawn, TRAIT_SHELL_RETREATED)
	var/has_target = controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET)
	if((has_target && shell_retreated) || (!has_target && !shell_retreated))
		return
	return ..()


/datum/ai_controller/basic_controller/snail/trash
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
