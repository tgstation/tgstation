#define MAX_CREW_RATIO 0.33
#define MIN_CREW_DEMORALISED 8
#define MAX_CREW_DEMORALISED 16

/datum/traitor_objective_category/demoralise
	name = "Demoralise Crew"
	objectives = list(
		/datum/traitor_objective/demoralise/poster = 2,
		/datum/traitor_objective/demoralise/graffiti = 1,
	)
	weight = OBJECTIVE_WEIGHT_TINY

/datum/traitor_objective/demoralise
	name = "Debug your code."
	description = "If you actually get this objective someone fucked up."

	progression_reward = list(2 MINUTES, 8 MINUTES)
	telecrystal_reward = list(0, 1)

	progression_maximum = 30 MINUTES

	abstract_type = /datum/traitor_objective/demoralise

	/// How many 'mood events' are required?
	var/demoralised_crew_required = 0
	/// How many 'mood events' have happened so far?
	var/demoralised_crew_events = 0

/datum/traitor_objective/demoralise/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	demoralised_crew_required = (clamp(rand(MIN_CREW_DEMORALISED, length(get_crewmember_minds()) * MAX_CREW_RATIO), MIN_CREW_DEMORALISED, MAX_CREW_DEMORALISED))
	replace_in_name("%VIEWS%", demoralised_crew_required)
	return TRUE

/**
 * Handles an event which increases your progress towards success.
 *
 * Arguments
 * * source - Source atom of the signal.
 * * victim - Mind of whoever it was you just triggered some kind of effect on.
 */
/datum/traitor_objective/demoralise/proc/on_mood_event(atom/source, datum/mind/victim)
	SIGNAL_HANDLER
	if (victim == handler.owner)
		return

	demoralised_crew_events++
	if (demoralised_crew_events >= demoralised_crew_required)
		to_chat(handler.owner, span_nicegreen("The crew look despondent. Mission accomplished."))
		succeed_objective()

#undef MAX_CREW_RATIO
#undef MIN_CREW_DEMORALISED
#undef MAX_CREW_DEMORALISED
