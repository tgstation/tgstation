/datum/ai_behavior/emote_on_target
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH


/datum/ai_behavior/emote_on_target/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/hunt_target = controller.blackboard[target_key]
	if (isnull(hunt_target))
		return FALSE
	set_movement_target(controller, hunt_target)


/datum/ai_behavior/emote_on_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, list/emote_list)
	var/atom/target = controller.blackboard[target_key]
	if(!length(emote_list) || isnull(target))
		return AI_BEHAVIOR_FAILED | AI_BEHAVIOR_DELAY
	run_emote(controller.pawn, target_key, emote_list)
	return AI_BEHAVIOR_SUCCEEDED | AI_BEHAVIOR_DELAY


/datum/ai_behavior/emote_on_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if(succeeded)
		controller.clear_blackboard_key(target_key)


/datum/ai_behavior/emote_on_target/proc/run_emote(mob/living/living_pawn, atom/target, list/emote_list)
	living_pawn.manual_emote("[pick(emote_list)] [target]")
