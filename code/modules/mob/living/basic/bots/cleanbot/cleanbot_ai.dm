/datum/ai_controller/basic_controller/bot/clean
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/cleanbot(),
		BB_HYGIENE_BOT_TARGET = null,
		BB_HYGIENE_BOT_ANGRY  = FALSE,
		BB_HYGIENE_BOT_PATIENCE = 0,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/chase_filthy_person,
		/datum/ai_planning_subtree/core_bot_behaviors/watch_for_filthy_person,
		/datum/ai_planning_subtree/watch_for_filthy_person_idle
		)


///Updates the blackboard with the current targets that can be targetted by the AI based on the specified janitor mode flags
/datum/ai_controller/basic_controller/bot/clean/proc/set_valid_targets(valid_targets)
	blackboard[BB_CLEAN_BOT_VALID_TARGETS] = valid_targets

///Also look for filthy people while patrolling!
/datum/ai_planning_subtree/core_bot_behaviors/watch_for_filthy_person/PatrolBehavior(datum/ai_controller/controller, delta_time)
	controller.queue_behavior(/datum/ai_behavior/move_to_next_patrol_point)
	controller.queue_behavior(/datum/ai_behavior/find_filthy_person, BB_HYGIENE_BOT_TARGET, BB_TARGETTING_DATUM)

