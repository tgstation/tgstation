///Decorator with a probability to pass, useful for things that sometimes happen. Slay queen
/datum/bt_node/decorator/random_chance
	/// 0.0–1.0 float; converted to percentage for prob(). Configure via BT_DECORATOR.
	var/chance = 0.5

/datum/bt_node/decorator/random_chance/check_condition(datum/ai_controller/controller)
	return prob(chance * 100)
