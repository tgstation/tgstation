/**
  * # Experiment
  *
  * This is the base datum for experiments, storing the base definition.
  *
  * This class should be subclassed for producing actual experiments. The
  * proc stubs should be implemented in whole.
  */
/datum/experiment
	/// Name that distinguishes the experiment
	var/name = "Experiment"
	/// A brief description of the experiment to be shown as details
	var/description = "Base experiment"
	/// A list of types that are allowed to experiment with this datum
	var/allowed_experimentors = list()

/**
  * Checks if the experiment is complete
  *
  * This proc should be overridden such that it returns TRUE/FALSE to
  * state if the experiment is complete or not.sound
  */
/datum/experiment/proc/is_complete()
	return
/**
  * Gets the current progress towards the goal of the experiment
  *
  * This proc should be overridden such that the return value is a
  * string describing the current status of the experiment.
  */
/datum/experiment/proc/check_progress()
	return

/**
  * Checks if the experiment can be sabotaged
  *
  * This proc should be overridden such that it returns TRUE/FALSE to
  * state if the experiment can be sabotaged, having its progress
  * in some way impeded or reverted
  */
/datum/experiment/proc/can_sabotage()
	return

/**
  * Sabotages the experiment
  *
  * This proc should be overridden such that if the experiment supports
  * it the experiment is sabotaged.
  */
/datum/experiment/proc/sabotage()
	return
