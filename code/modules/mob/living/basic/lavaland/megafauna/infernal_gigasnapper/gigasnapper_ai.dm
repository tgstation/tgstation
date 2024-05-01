/datum/ai_controller/basic_controller/gigasnapper
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		// excluding /datum/ai_planning_subtree/find_food on purpose despite having liked foods,
		// it would need to move and attack it to eat and the movement restrictions aren't worth working around.
		/datum/ai_planning_subtree/gigasnapper_set_arena,
		/datum/ai_planning_subtree/gigasnapper_attack,
	)

///subtree focuses on attacks while the arena is raised
/datum/ai_planning_subtree/gigasnapper_attack

/datum/ai_planning_subtree/gigasnapper_attack/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if (!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return

	//always move towards target to try lining up an attack, restricted movement will naturally keep movement vertical
	controller.queue_behavior(/datum/ai_behavior/travel_towards, BB_BASIC_MOB_CURRENT_TARGET)

	var/datum/action/cooldown/mob_cooldown/projectile_attack/smallsnipper_bubble/bubble = controller.blackboard[BB_SMALLSNIPPER_BUBBLE]

	//always try to do this attack if off cooldown, just always be spamming that to pollute the arena with projectiles
	if(bubble?.IsAvailable())
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_plan_execute, BB_SMALLSNIPPER_BUBBLE, BB_BASIC_MOB_CURRENT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

///subtree focuses on trapping the target in an arena
/datum/ai_planning_subtree/gigasnapper_set_arena

/datum/ai_planning_subtree/gigasnapper_set_arena/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if (!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return
	///TODO, use movement and jump ability religiously to try and get target within a distance where the arena will trap them
	// fight cannot start without arena raised
