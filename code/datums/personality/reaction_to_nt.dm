/datum/personality/nt
	groups = list(PERSONALITY_GROUP_NT)
	processes = TRUE
	/// What mood event to apply when seeing NT propaganda
	var/mood_event_type

/datum/personality/nt/proc/can_see_nt_propaganda(mob/living/subject)
	for(var/obj/structure/sign/nearby in view(subject, 5))
		if(istype(nearby, /obj/structure/sign/nanotrasen))
			return TRUE
		if(istype(nearby, /obj/structure/sign/poster/official/nanotrasen_logo))
			return TRUE

	return FALSE

/datum/personality/nt/on_tick(mob/living/subject, seconds_per_tick)
	if(can_see_nt_propaganda(subject))
		subject.add_mood_event("nt_personality", mood_event_type)
	else
		subject.clear_mood_event("nt_personality")

/datum/personality/nt/remove_from_mob(mob/living/who)
	. = ..()
	who.clear_mood_event("nt_personality")

/datum/personality/nt/loyalist
	savefile_key = "loyalist"
	name = "Loyal"
	desc = "I believe in the station and in Central Command, till the very end!"
	pos_gameplay_desc = "Likes company posters and signs"
	mood_event_type = /datum/mood_event/nt_loyalist

/datum/personality/nt/disillusioned
	savefile_key = "disillusioned"
	name = "Disillusioned"
	desc = "Nanotrasen isn't what it used to be. This isn't what I signed up for."
	neg_gameplay_desc = "Dislikes company posters and signs"
	mood_event_type = /datum/mood_event/nt_disillusioned
