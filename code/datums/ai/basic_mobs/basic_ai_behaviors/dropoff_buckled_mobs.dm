/**
 * goes to a location and drops all buckled mobs, if any are there.
 */
/datum/ai_behavior/dropoff_buckled_mobs
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 1

/datum/ai_behavior/dropoff_buckled_mobs/setup(datum/ai_controller/controller, destination_key)
	. = ..()
	var/datum/weakref/weak_dropoff = controller.blackboard[destination_key]
	var/turf/dropoff = weak_dropoff?.resolve()
	if(!dropoff)
		return FALSE //we can't go somewhere that doesn't exist

	controller.current_movement_target = dropoff

/datum/ai_behavior/dropoff_buckled_mobs/perform(delta_time, datum/ai_controller/controller, destination_key)
	. = ..()
	//means we're in range of our destination
	var/mob/living/living_pawn = controller.pawn
	living_pawn.unbuckle_all_mobs(TRUE)
	finish_action(controller, TRUE, destination_key)

/datum/ai_behavior/dropoff_buckled_mobs/finish_action(datum/ai_controller/controller, succeeded, destination_key)
	. = ..()
	controller.blackboard[destination_key] = null
