/// A spellcasting AI which does not move
/datum/ai_controller/basic_controller/meteor_heart
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/meteor_heart/meteor_heart.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_CURRENT_TARGET_HIDING_LOCATION = null,
	)

/// After enough time with no target, calls deaggro() on the meteor heart to shut down the AI and reset visuals.
/datum/bt_node/ai_behavior/meteor_heart_deaggro
	var/deaggro_delay = 10 SECONDS
	VAR_PRIVATE/timerid

/datum/bt_node/ai_behavior/meteor_heart_deaggro/setup(datum/ai_controller/controller)
	. = ..()
	timerid = addtimer(CALLBACK(src, PROC_REF(finish_action), controller, TRUE), deaggro_delay, TIMER_UNIQUE | TIMER_STOPPABLE)

/datum/bt_node/ai_behavior/meteor_heart_deaggro/perform(seconds_per_tick, datum/ai_controller/controller)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/meteor_heart_deaggro/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	deltimer(timerid)
	timerid = null
	if(!succeeded)
		return
	var/mob/living/basic/meteor_heart/heart = controller.pawn
	if(istype(heart))
		heart.deaggro()
