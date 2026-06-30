///Checks the health status of our rider, if any. returns false if we dont have a rider to begin with
/datum/bt_node/decorator/check_rider_stat
	///stat we're interested in
	var/target_stat = UNCONSCIOUS

/datum/bt_node/decorator/check_rider_stat/check_condition(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	if(!length(living_pawn.buckled_mobs))
		return FALSE
	var/mob/living/buckled_to = living_pawn.buckled_mobs[1]
	return buckled_to.stat == target_stat
