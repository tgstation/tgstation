#define MAXIMUM_GUTLUNCH_POP 20
/datum/ai_controller/basic_controller/gutlunch
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

/datum/ai_controller/basic_controller/gutlunch/gutlunch_warrior
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_BABIES_PARTNER_TYPES = list(/mob/living/basic/mining/gutlunch/milk),
		BB_BABIES_CHILD_TYPES = list(/mob/living/basic/mining/gutlunch/grub),
		BB_MAX_CHILDREN = 5,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/befriend_ashwalkers,
		/datum/ai_planning_subtree/make_babies/gutlunch,
	)

/datum/ai_planning_subtree/make_babies/gutlunch/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(GLOB.gutlunch_count >= MAXIMUM_GUTLUNCH_POP)
		return
	return ..()

///find ashwalkers and add them to the list of masters
/datum/ai_planning_subtree/befriend_ashwalkers

/datum/ai_planning_subtree/befriend_ashwalkers/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/befriend_ashwalkers)

/datum/ai_behavior/befriend_ashwalkers
	action_cooldown = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/befriend_ashwalkers/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/mob/living/living_pawn = controller.pawn

	for(var/mob/living/potential_friend in oview(9, living_pawn))
		if(!isashwalker(potential_friend))
			continue
		if((living_pawn.faction.Find(REF(potential_friend))))
			continue
		living_pawn.befriend(potential_friend)
		to_chat(potential_friend, span_nicegreen("[living_pawn] looks at you with endearing eyes!"))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED


/datum/ai_controller/basic_controller/gutlunch/gutlunch_baby
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_FIND_MOM_TYPES = list(/mob/living/basic/mining/gutlunch/milk),
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/look_for_adult,
	)

/datum/ai_controller/basic_controller/gutlunch/gutlunch_milk
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_and_hunt_target/food_trough
	)

///consume food!
/datum/ai_planning_subtree/find_and_hunt_target/food_trough
	target_key = BB_TROUGH_TARGET
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/food_trough
	finding_behavior = /datum/ai_behavior/find_hunt_target/food_trough
	hunt_targets = list(/obj/structure/ore_container/food_trough/gutlunch_trough)
	hunt_chance = 75
	hunt_range = 9


/datum/ai_planning_subtree/find_and_hunt_target/food_trough/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard[BB_CHECK_HUNGRY])
		return
	return ..()

/datum/ai_behavior/find_hunt_target/food_trough

/datum/ai_behavior/find_hunt_target/food_trough/valid_dinner(mob/living/basic/source, obj/target, radius)
	if(isnull(target))
		return FALSE

	if(isnull(locate(/obj/item/stack/ore) in target))
		return FALSE

	return can_see(source, target, radius)

/datum/ai_behavior/hunt_target/unarmed_attack_target/food_trough
	always_reset_target = TRUE
	switch_combat_mode = TRUE

/datum/pet_command/mine_walls
	command_name = "Mine"
	command_desc = "Command your pet to mine down walls."
	speech_commands = list("mine", "smash")

/datum/pet_command/mine_walls/try_activate_command(mob/living/commander)
	var/mob/living/parent = weak_parent.resolve()
	if(isnull(parent))
		return
	//no walls for us to mine
	var/target_in_vicinity = locate(/turf/closed/mineral) in oview(9, parent)
	if(isnull(target_in_vicinity))
		return
	return ..()

/datum/pet_command/mine_walls/execute_action(datum/ai_controller/controller)
	if(controller.blackboard_key_exists(BB_CURRENT_PET_TARGET))
		controller.queue_behavior(/datum/ai_behavior/mine_wall, BB_CURRENT_PET_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING
	controller.queue_behavior(/datum/ai_behavior/find_mineral_wall, BB_CURRENT_PET_TARGET)

//pet commands
/datum/pet_command/point_targeting/breed/gutlunch

/datum/pet_command/point_targeting/breed/gutlunch/set_command_target(mob/living/parent, atom/target)
	if(GLOB.gutlunch_count >= MAXIMUM_GUTLUNCH_POP)
		parent.balloon_alert_to_viewers("can't reproduce anymore!")
		return
	return ..()

#undef MAXIMUM_GUTLUNCH_POP
