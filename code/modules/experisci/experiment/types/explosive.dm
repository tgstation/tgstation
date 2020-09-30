/datum/experiment/explosion
	name = "Explosive Experiment"
	description = "An experiment requiring an explosion to progress"
	exp_tag = "Explosion"
	/// The required devastation range to complete the experiment
	var/required_devastation = 0
	/// The required heavy impact range to complete the experiment
	var/required_heavy = 0
	/// The required light impact range to complete the experiment
	var/required_light = 0
	/// The max ranges measured by this experiment
	var/measured = list("devastation" = 0, "heavy" = 0, "light" = 0)

/datum/experiment/explosion/is_complete()
	return required_devastation <= measured["devastation"] \
		&& required_heavy <= measured["heavy"] \
		&& required_light <= measured["light"]

/datum/experiment/explosion/check_progress()
	return "The maximum witnessed explosion had ranges of [measured["devastation"]] \
	 devestation, [measured["heavy"]] heavy, and [measured["light"]] light. You must \
	 reach an explosion of at least [required_devastation]D/[required_heavy]H/[required_light]L."

/datum/experiment/explosion/perform_experiment_actions(datum/component/experiment_handler/experiment_handler, devastation, heavy, light)
	measured["devastation"] = max(measured["devastation"], devastation)
	measured["heavy"] = max(measured["heavy"], heavy)
	measured["light"] = max(measured["light"], light)
	return is_complete()

/datum/experiment/explosion/actionable(devastation, heavy, light)
	return !is_complete()

