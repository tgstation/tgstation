/datum/ai_behavior/attempt_group_find
	var/group_to_find = /datum/group_planning

/datum/ai_behavior/attempt_group_find/perform(seconds_per_tick, datum/ai_controller/controller, ...)
	. = ..()
	for(var/mob/living/basic/found_basic in view(7, controller.pawn))
		if(BB_GROUP_DATUM in found_basic.ai_controller.blackboard)
			var/datum/group_planning/found_group = found_basic.ai_controller.blackboard[BB_GROUP_DATUM]
			if(!found_group)
				continue
			if(found_group.type != group_to_find)
				continue
			controller.blackboard[BB_GROUP_DATUM] = found_group
			found_group.group_mobs |= controller.pawn
			finish_action(controller, TRUE)
			break

	var/datum/group_planning/new_group = new group_to_find
	controller.blackboard[BB_GROUP_DATUM] = new_group
	new_group.group_mobs |= controller.pawn
	finish_action(controller, TRUE)

/datum/ai_behavior/attempt_group_find/fish
	group_to_find = /datum/group_planning/fish
