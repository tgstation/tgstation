/*
 * Applies a role-based mood if you can see the parent.
 *
 * - Applies a mood to people who are in visible range of the item.
 * - Does not re-apply mood to people who already have it.
 * - Sends a signal if a mood is successfully applied.
 */
/datum/proximity_monitor/advanced/demoraliser
	var/datum/demoralise_moods/moods

/datum/proximity_monitor/advanced/demoraliser/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, datum/demoralise_moods/moods)
	. = ..()
	src.moods = moods
	RegisterSignal(host, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/proximity_monitor/advanced/demoraliser/field_turf_crossed(atom/movable/crossed, turf/location)
	if (!isliving(crossed))
		return
	if (!can_see(crossed, host, current_range))
		return
	on_seen(crossed)

/*
 * Signal proc for [COMSIG_PARENT_EXAMINE].
 * Immediately tries to apply a mood to the examiner, ignoring the proximity check.
 * If someone wants to make themselves sad through a camera that's their choice I guess.
 */
/datum/proximity_monitor/advanced/demoraliser/proc/on_examine(datum/source, mob/examiner)
	SIGNAL_HANDLER
	if (isliving(examiner))
		on_seen(examiner)

/**
 * Called when someone is looking at a demoralising object.
 * Applies a mood if they are conscious and don't already have it.
 * Different moods are applied based on whether they are an antagonist, authority, or 'other' (presumed crew).
 *
 * Arguments
 * * viewer - Whoever is looking at this.
 */
/datum/proximity_monitor/advanced/demoraliser/proc/on_seen(mob/living/viewer)
	if (!viewer.mind)
		return
	// If you're not conscious you're too busy or dead to look at propaganda
	if (viewer.stat != CONSCIOUS)
		return
	if (was_demoralised(viewer))
		return

	if (is_special_character(viewer))
		to_chat(viewer, span_notice("[moods.antag_notification]"))
		SEND_SIGNAL(viewer, COMSIG_ADD_MOOD_EVENT, moods.mood_category, moods.antag_mood)
	else if (viewer.mind.assigned_role.departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY|DEPARTMENT_BITFLAG_COMMAND))
		to_chat(viewer, span_notice("[moods.authority_notification]"))
		SEND_SIGNAL(viewer, COMSIG_ADD_MOOD_EVENT, moods.mood_category, moods.authority_mood)
	else
		to_chat(viewer, span_notice("[moods.crew_notification]"))
		SEND_SIGNAL(viewer, COMSIG_ADD_MOOD_EVENT, moods.mood_category, moods.crew_mood)

	SEND_SIGNAL(host, COMSIG_DEMORALISING_EVENT, viewer.mind)

/**
 * Returns true if the viewer already has been given feelings, false if they haven't.
 *
 * Arguments
 * * viewer - Whoever just saw the parent.
 */
/datum/proximity_monitor/advanced/demoraliser/proc/was_demoralised(mob/living/viewer)
	var/datum/component/mood/mood = viewer.GetComponent(/datum/component/mood)
	if (!mood)
		return FALSE

	return mood.has_mood_of_category(moods.mood_category)

/// Mood application categories for this objective
/// Used to reduce duplicate code for applying moods to players based on their state
/datum/demoralise_moods
	/// Mood category to apply to moods
	var/mood_category
	/// Text to display to an antagonist upon receiving this mood
	var/antag_notification
	/// Mood datum to apply to an antagonist
	var/datum/mood_event/antag_mood
	/// Text to display to a crew member upon receiving this mood
	var/crew_notification
	/// Mood datum to apply to a crew member
	var/datum/mood_event/crew_mood
	/// Text to display to a head of staff upon receiving this mood
	var/authority_notification
	/// Mood datum to apply to a head of staff or security
	var/datum/mood_event/authority_mood

/datum/demoralise_moods/poster
	mood_category = "evil poster"
	antag_notification = "Nice poster."
	antag_mood = /datum/mood_event/traitor_poster_antag
	crew_notification = "Wait, is what that poster says true?"
	crew_mood = /datum/mood_event/traitor_poster_crew
	authority_notification = "Hey! Who put up that poster?"
	authority_mood = /datum/mood_event/traitor_poster_auth

/datum/mood_event/traitor_poster_antag
	description = "I am doing the right thing."
	mood_change = 2
	timeout = 2 MINUTES
	hidden = TRUE

/datum/mood_event/traitor_poster_crew
	description = "That poster made me feel bad about my job..."
	mood_change = -2
	timeout = 2 MINUTES
	hidden = TRUE

/datum/mood_event/traitor_poster_auth
	description = "That poster better not be giving the crew any funny ideas..."
	mood_change = -3
	timeout = 2 MINUTES
	hidden = TRUE

/datum/demoralise_moods/graffiti
	mood_category = "evil graffiti"
	antag_notification = "A three headed snake. Nice."
	antag_mood = /datum/mood_event/traitor_graffiti_antag
	crew_notification = "Is that... a three headed snake?"
	crew_mood = /datum/mood_event/traitor_graffiti_crew
	authority_notification = "A three headed snake only means trouble."
	authority_mood = /datum/mood_event/traitor_graffiti_auth

/datum/mood_event/traitor_graffiti_antag
	description = "The Syndicate logo? How delightfully bold."
	mood_change = 2
	timeout = 2 MINUTES
	hidden = TRUE

/datum/mood_event/traitor_graffiti_crew
	description = "The Syndicate logo? Am I safe here?"
	mood_change = -2
	timeout = 2 MINUTES
	hidden = TRUE

/datum/mood_event/traitor_graffiti_auth
	description = "Which of these layabouts drew that Syndicate logo?!"
	mood_change = -3
	timeout = 2 MINUTES
	hidden = TRUE
