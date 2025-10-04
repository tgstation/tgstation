/datum/personality/gambler
	savefile_key = "gambler"
	name = "Gambler"
	desc = "Throwing the dice is always worth it!"
	pos_gameplay_desc = "Likes gambling and card games, and content with losing when gambling"

/datum/personality/slacking
	/// Areas which are considered "slacking off"
	var/list/slacker_areas = list(
		/area/station/commons/fitness,
		/area/station/commons/lounge,
		/area/station/service/bar,
		/area/station/service/cafeteria,
		/area/station/service/library,
		/area/station/service/minibar,
		/area/station/service/theater,
	)
	/// Mood event applied when in a slacking area
	var/mood_event_type

/datum/personality/slacking/apply_to_mob(mob/living/who)
	. = ..()
	who.apply_status_effect(/datum/status_effect/moodlet_in_area, mood_event_type, slacker_areas, CALLBACK(src, PROC_REF(is_slacking)))

/datum/personality/slacking/remove_from_mob(mob/living/who)
	. = ..()
	who.remove_status_effect(/datum/status_effect/moodlet_in_area, mood_event_type)

/// Callback for the moodlet_in_area status effect to determine if we're slacking off
/datum/personality/slacking/proc/is_slacking(mob/living/who, area/new_area)
	if(!istype(new_area, /area/station/service))
		return TRUE
	// Service workers don't slack in service
	if(who.mind?.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_SERVICE)
		return FALSE

	return TRUE

/datum/personality/slacking/lazy
	savefile_key = "lazy"
	name = "Lazy"
	desc = "I don't really feel like working today."
	pos_gameplay_desc = "Happy in the bar or recreation areas"
	mood_event_type = /datum/mood_event/slacking_off_lazy
	groups = list(PERSONALITY_GROUP_RECREATION, PERSONALITY_GROUP_WORK, PERSONALITY_GROUP_ATHLETICS)

/datum/personality/slacking/diligent
	savefile_key = "diligent"
	name = "Diligent"
	desc = "Things need to get done around here!"
	pos_gameplay_desc = "Happy when in their department"
	neg_gameplay_desc = "Unhappy when slacking off in the bar or recreation areas"
	mood_event_type = /datum/mood_event/slacking_off_diligent
	groups = list(PERSONALITY_GROUP_RECREATION)

/datum/personality/slacking/diligent/apply_to_mob(mob/living/who)
	. = ..()
	RegisterSignals(who, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_SET_ROLE), PROC_REF(update_effect))
	// Unfortunate side effect here in that IC job changes, IE HoP are missed
	who.apply_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent, who.mind?.get_work_areas())

/datum/personality/slacking/diligent/remove_from_mob(mob/living/who)
	. = ..()
	UnregisterSignal(who, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_SET_ROLE))
	who.remove_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent)

/// Signal handler to update our status effect when our job changes
/datum/personality/slacking/diligent/proc/update_effect(mob/living/source, ...)
	SIGNAL_HANDLER

	source.remove_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent)
	source.apply_status_effect(/datum/status_effect/moodlet_in_area, /datum/mood_event/working_diligent, source.mind.get_work_areas())

/datum/personality/industrious
	savefile_key = "industrious"
	name = "Industrious"
	desc = "Everyone needs to be working - otherwise we're all wasting our time."
	neg_gameplay_desc = "Dislikes playing games"
	groups = list(PERSONALITY_GROUP_WORK)

/datum/personality/athletic
	savefile_key = "athletic"
	name = "Athletic"
	desc = "Can't just sit around all day! Have to keep moving."
	pos_gameplay_desc = "Likes exercising"
	neg_gameplay_desc = "Dislikes being lazy"
	groups = list(PERSONALITY_GROUP_ATHLETICS)

/datum/personality/erudite
	savefile_key = "erudite"
	name = "Erudite"
	desc = "Knowledge is power. Especially this deep in space."
	pos_gameplay_desc = "Likes reading books"
	groups = list(PERSONALITY_GROUP_READING)

/datum/personality/uneducated
	savefile_key = "uneducated"
	name = "Uneducated"
	desc = "I don't care much for books - I already know everything I need to know."
	neg_gameplay_desc = "Dislikes reading books"
	groups = list(PERSONALITY_GROUP_READING)

/datum/personality/spiritual
	savefile_key = "spiritual"
	name = "Spiritual"
	desc = "I believe in a higher power."
	pos_gameplay_desc = "Likes the Chapel and the Chaplain, and has special prayers"
	neg_gameplay_desc = "Dislikes unholy things"
	personality_trait = TRAIT_SPIRITUAL
