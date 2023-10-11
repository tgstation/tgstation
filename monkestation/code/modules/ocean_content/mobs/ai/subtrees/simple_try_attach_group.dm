/datum/ai_planning_subtree/simple_create_or_follow_commands
	var/group_finding_behaviour = /datum/ai_behavior/attempt_group_find

/datum/ai_planning_subtree/simple_create_or_follow_commands/fish
	group_finding_behaviour = /datum/ai_behavior/attempt_group_find/fish


/datum/ai_planning_subtree/simple_create_or_follow_commands/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/group_planning/attached = controller.blackboard[BB_GROUP_DATUM]
	if(!attached)
		controller.queue_behavior(group_finding_behaviour)
		return

	if(length(attached.in_progress_mobs) && !(controller.pawn in attached.in_progress_mobs) && !(controller.pawn in attached.finished_mobs))
		attached.add_to_current_action(controller)
		return

	if(!attached.next_action > world.time && !length(attached.in_progress_mobs))
		return

	if(!attached.fetched_behaviour)
		attached.decide_next_action()
	attached.bulk_queue()

