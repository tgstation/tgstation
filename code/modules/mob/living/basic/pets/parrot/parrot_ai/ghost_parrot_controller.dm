/// Used for ghost poly.
/datum/ai_controller/basic_controller/parrot/ghost
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/parrot_as_in_repeat,
		/datum/ai_planning_subtree/possess_humans,
		/datum/ai_planning_subtree/hoard_items,
	)

///subtree to possess humans
/datum/ai_planning_subtree/possess_humans
	///chance we go possess humans
	var/possess_chance = 2

/datum/ai_planning_subtree/possess_humans/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/living_pawn = controller.pawn

	if(controller.blackboard_key_exists(BB_PERCH_TARGET))
		controller.queue_behavior(/datum/ai_behavior/perch_on_target/haunt, BB_PERCH_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING


	if(!SPT_PROB(possess_chance, seconds_per_tick))
		if(ishuman(living_pawn.loc))
			return SUBTREE_RETURN_FINISH_PLANNING
		return

	if(ishuman(living_pawn.loc))
		controller.set_blackboard_key(living_pawn.loc)
		return

	controller.queue_behavior(/datum/ai_behavior/find_and_set/conscious_person, BB_PERCH_TARGET)


/datum/ai_behavior/perch_on_target/haunt

/datum/ai_behavior/perch_on_target/haunt/check_human_conditions(mob/living/living_human)
	return (living_human.stat != DEAD)
