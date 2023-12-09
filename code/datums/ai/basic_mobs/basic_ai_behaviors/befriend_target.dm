///behavior to befriend any targets
/datum/ai_behavior/befriend_target

/datum/ai_behavior/befriend_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, befriend_message)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		finish_action(controller, FALSE, target_key)
		return

	living_pawn.befriend(living_target)
	var/befriend_text = controller.blackboard[befriend_message]
	if(befriend_text)
		to_chat(living_target, span_nicegreen("[living_pawn] [befriend_text]"))

	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/befriend_target/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
