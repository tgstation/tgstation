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
	RegisterSignal(host, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/proximity_monitor/advanced/demoraliser/field_turf_crossed(atom/movable/crossed, turf/old_location, turf/new_location)
	if (!isliving(crossed))
		return
	if (!can_see(crossed, host, current_range))
		return
	on_seen(crossed)

/*
 * Signal proc for [COMSIG_ATOM_EXAMINE].
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
	if(viewer.is_blind())
		return
	if (!should_demoralise(viewer))
		return
	if(!viewer.can_read(host, moods.reading_requirements, TRUE)) //if it's a text based demoralization datum, make sure the mob has the capability to read. if it's only an image, make sure it's just bright enough for them to see it.
		return


	if (viewer.is_antag())
		to_chat(viewer, span_notice("[moods.antag_notification]"))
		viewer.add_mood_event(moods.mood_category, moods.antag_mood)
	else if (viewer.mind.assigned_role.departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY|DEPARTMENT_BITFLAG_COMMAND))
		to_chat(viewer, span_notice("[moods.authority_notification]"))
		viewer.add_mood_event(moods.mood_category, moods.authority_mood)
	else
		to_chat(viewer, span_notice("[moods.crew_notification]"))
		viewer.add_mood_event(moods.mood_category, moods.crew_mood)

	SEND_SIGNAL(host, COMSIG_DEMORALISING_EVENT, viewer.mind)

/**
 * Returns true if user is capable of experiencing moods and doesn't already have the one relevant to this datum, false otherwise.
 *
 * Arguments
 * * viewer - Whoever just saw the parent.
 */
/datum/proximity_monitor/advanced/demoraliser/proc/should_demoralise(mob/living/viewer)
	if (!viewer.mob_mood)
		return FALSE

	return !viewer.mob_mood.has_mood_of_category(moods.mood_category)

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
	/// For literacy checks
	var/reading_requirements = READING_CHECK_LIGHT
	/// Mood datum to apply to a head of staff or security
	var/datum/mood_event/authority_mood

/datum/demoralise_moods/poster
	mood_category = "evil poster"
	antag_notification = "Хороший плакат."
	antag_mood = /datum/mood_event/traitor_poster_antag
	crew_notification = "Подожди, а правда ли то, что написано на этом плакате?"
	crew_mood = /datum/mood_event/traitor_poster_crew
	authority_notification = "Э блять! Кто повесил этот плакат?"
	authority_mood = /datum/mood_event/traitor_poster_auth
	reading_requirements = (READING_CHECK_LITERACY | READING_CHECK_LIGHT)

/datum/mood_event/traitor_poster_antag
	description = "Я поступаю правильно."
	mood_change = 2
	timeout = 2 MINUTES
	hidden = TRUE

/datum/mood_event/traitor_poster_crew
	description = "Этот плакат заставил меня чувствовать себя плохо из-за своей работы..."
	mood_change = -2
	timeout = 2 MINUTES
	hidden = TRUE

/datum/mood_event/traitor_poster_auth
	description = "Надеюсь этот плакат не будет давать экипажу никаких забавных идей..."
	mood_change = -3
	timeout = 2 MINUTES
	hidden = TRUE

/datum/demoralise_moods/graffiti
	mood_category = "evil graffiti"
	antag_notification = "Трехглавая змея. Заебись."
	antag_mood = /datum/mood_event/traitor_graffiti_antag
	crew_notification = "Это... трёхголовая змея?"
	crew_mood = /datum/mood_event/traitor_graffiti_crew
	authority_notification = "Трехглавая змея означает только неприятности."
	authority_mood = /datum/mood_event/traitor_graffiti_auth

/datum/mood_event/traitor_graffiti_antag
	description = "Логотип Синдиката? Как восхитительно смело."
	mood_change = 2
	timeout = 2 MINUTES
	hidden = TRUE

/datum/mood_event/traitor_graffiti_crew
	description = "Логотип Синдиката? Я точно здесь в безопасности?"
	mood_change = -2
	timeout = 2 MINUTES
	hidden = TRUE

/datum/mood_event/traitor_graffiti_auth
	description = "Кто из этих бездельников нарисовал логотип Синдиката?!"
	mood_change = -3
	timeout = 2 MINUTES
	hidden = TRUE

/datum/demoralise_moods/module
	mood_category = "module"
	antag_notification = "Я чувствую себя странно отдохнувшим."
	antag_mood = /datum/mood_event/traitor_module_antag
	crew_notification = "Моя голова болит. Такое ощущение, будто что-то вбивает мне гвозди в мозг!"
	crew_mood = /datum/mood_event/traitor_module_crew
	authority_notification = "У меня начинает кружиться голова. Враг у ворот. Я одинок..."
	authority_mood = /datum/mood_event/traitor_module_auth
	reading_requirements = (READING_CHECK_LIGHT)

/datum/mood_event/traitor_module_antag
	description = "Думаю, я специально создам проблемы."
	mood_change = 1
	timeout = 2 MINUTES
	hidden = TRUE

/datum/mood_event/traitor_module_crew
	description = "Они на станции! Я знаю это! Они собираются схватить меня!"
	mood_change = -4
	timeout = 2 MINUTES
	hidden = TRUE

/datum/mood_event/traitor_module_auth
	description = "Никто на этой станции не на моей стороне, а врагом может быть кто угодно! Придётся принять более решительные меры..."
	mood_change = -5
	timeout = 2 MINUTES
	hidden = TRUE
