/datum/ai_controller/basic_controller/gutlunch
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

/datum/ai_controller/basic_controller/gutlunch/gutlunch_warrior
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic/not_friends,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/mining/gutlunch/milk),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/mining/gutlunch/grub),
		BB_MAX_CHILDREN = 5,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/make_babies,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/mine_walls,
		/datum/ai_planning_subtree/befriend_ashwalkers,
	)

///find ashwalkers and add them to the list of masters
/datum/ai_planning_subtree/befriend_ashwalkers

/datum/ai_planning_subtree/befriend_ashwalkers/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/befriend_ashwalkers)

/datum/ai_behavior/befriend_ashwalkers
	action_cooldown = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/befriend_ashwalkers/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	var/mob/living/living_pawn = controller.pawn

	for(var/mob/living/potential_friend in oview(9, living_pawn))
		if(!isashwalker(potential_friend))
			continue
		if((living_pawn.faction.Find(REF(potential_friend))))
			continue
		living_pawn.befriend(potential_friend)
		to_chat(potential_friend, span_nicegreen("[living_pawn] looks at you with endearing eyes!"))
		finish_action(controller, TRUE)
		return

	finish_action(controller, FALSE)
	return



/datum/ai_controller/basic_controller/gutlunch/gutlunch_baby
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/mining/gutlunch/milk),
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/dig_away_from_danger,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
	)

/datum/ai_controller/basic_controller/gutlunch/gutlunch_milk
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/dig_away_from_danger,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
		/datum/ai_planning_subtree/find_and_hunt_target/food_trough
	)

///consume food!
/datum/ai_planning_subtree/find_and_hunt_target/food_trough
	target_key = BB_TROUGH_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/reset_target
	finding_behavior = /datum/ai_behavior/find_hunt_target/food_trough
	hunt_targets = list(/obj/structure/ore_container/gutlunch_trough)
	hunt_chance = 75
	hunt_range = 9


/datum/ai_planning_subtree/find_and_hunt_target/food_trough/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_CHECK_HUNGRY])
		return
	return ..()

/datum/ai_behavior/find_hunt_target/food_trough

/datum/ai_behavior/find_hunt_target/hunt_ores/valid_dinner(mob/living/basic/source, obj/target, radius)
	if(isnull(target))
		return FALSE

	if(isnull(locate(/obj/item/stack/ore) in target))
		return FALSE

	return can_see(source, target, radius)
