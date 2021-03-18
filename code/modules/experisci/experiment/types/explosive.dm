/datum/experiment/explosion
	name = "Explosive Experiment"
	description = "An experiment requiring an explosion to progress"
	exp_tag = "Explosion"
	performance_hint = "Perform explosive experiments using the research doppler array in the toxins lab."
	/// The required devastation range to complete the experiment
	var/required_devastation = 0
	/// The required heavy impact range to complete the experiment
	var/required_heavy = 0
	/// The required light impact range to complete the experiment
	var/required_light = 0
	/// The last measured devastation range
	var/last_devastation
	/// The last measured heavy range
	var/last_heavy
	/// The last measured light range
	var/last_light

/datum/experiment/explosion/is_complete()
	return required_devastation <= last_devastation \
		&& required_heavy <= last_heavy \
		&& required_light <= last_light

/datum/experiment/explosion/check_progress()
	var/status_message = "You must record an explosion with ranges of at least \
		[required_devastation] devastation, [required_heavy] heavy, and [required_light] light."
	if (last_devastation || last_heavy || last_light)
		status_message += " The last attempt had ranges of [last_devastation]D/[last_heavy]H/[last_light]L."
	. += EXPERIMENT_PROG_BOOL(status_message, is_complete())

/datum/experiment/explosion/perform_experiment_actions(datum/component/experiment_handler/experiment_handler, devastation, heavy, light)
	last_devastation = devastation
	last_heavy = heavy
	last_light = light
	return is_complete()

/datum/experiment/explosion/actionable(datum/component/experiment_handler/experiment_handler, devastation, heavy, light)
	return !is_complete()

