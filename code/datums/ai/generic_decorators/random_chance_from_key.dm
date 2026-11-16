/// Passes with a probability taken from a blackboard key (0-100 integer).
/datum/bt_node/decorator/random_chance_from_key
	/// Blackboard key holding the integer probability (0-100)
	var/chance_key = null

/datum/bt_node/decorator/random_chance_from_key/check_condition(datum/ai_controller/controller)
	var/chance = controller.blackboard[chance_key]
	if(!chance)
		return FALSE
	return prob(chance)
