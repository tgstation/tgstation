/**
 * The point of this datum is to act as a means to group target player objectives
 * Not all 'target player' objectives have to be under this subtype, it's only used if you don't want duplicates among the current
 * children types under this type.
 */
/datum/traitor_objective/target_player
	abstract_type = /datum/traitor_objective/target_player

	progression_minimum = 30 MINUTES

	// The code below is for limiting how often you can get this objective. You will get this objective at a maximum of maximum_objectives_in_period every objective_period
	/// The objective period at which we consider if it is an 'objective'. Set to 0 to accept all objectives.
	var/objective_period = 15 MINUTES
	/// The maximum number of objectives we can get within this period.
	var/maximum_objectives_in_period = 4

	/// The target that we need to target.
	var/mob/living/target

/datum/traitor_objective/target_player/Destroy(force)
	set_target(null)
	return ..()

/datum/traitor_objective/target_player/proc/set_target(mob/living/new_target)
	if(target)
		UnregisterSignal(target, COMSIG_QDELETING)
	target = new_target
	if(target)
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(target_deleted))

/datum/traitor_objective/target_player/proc/target_deleted(datum/source)
	SIGNAL_HANDLER
	set_target(null)
