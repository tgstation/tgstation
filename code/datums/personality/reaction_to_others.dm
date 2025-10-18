/datum/personality/callous
	savefile_key = "callous"
	name = "Callous"
	desc = "I don't care much about what happens to other people."
	pos_gameplay_desc = "Does not mind seeing death"
	neg_gameplay_desc = "Prefers not to help people"
	groups = list(PERSONALITY_GROUP_DEATH)

/datum/personality/compassionate
	savefile_key = "compassionate"
	name = "Compassionate"
	desc = "I like giving a hand to those in need."
	pos_gameplay_desc = "Likes helping people"
	neg_gameplay_desc = "Seeing death affects your mood more"
	groups = list(PERSONALITY_GROUP_DEATH, PERSONALITY_GROUP_MISANTHROPY)

/datum/personality/empathetic
	savefile_key = "empathetic"
	name = "Empathetic" // according to google "empathic" means you understand other people, while "empathetic" means you feel what they feel
	desc = "Other people's feelings are important to me."
	pos_gameplay_desc = "Likes seeing other people happy"
	neg_gameplay_desc = "Dislikes seeing other people sad"
	groups = list(PERSONALITY_GROUP_OTHERS)

/datum/personality/misanthropic
	savefile_key = "misanthropic"
	name = "Misanthropic"
	desc = "We should have never entered the stars."
	pos_gameplay_desc = "Likes seeing other people sad"
	neg_gameplay_desc = "Dislikes seeing other people happy"
	groups = list(PERSONALITY_GROUP_OTHERS, PERSONALITY_GROUP_MISANTHROPY)

/datum/personality/aloof
	savefile_key = "aloof"
	name = "Aloof"
	desc = "Why is everyone so touchy? I'd rather be left alone."
	neg_gameplay_desc = "Dislikes being grabbed, touched, or hugged"
	personality_trait = TRAIT_BADTOUCH

/datum/personality/aloof/apply_to_mob(mob/living/who)
	. = ..()
	RegisterSignals(who, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT), PROC_REF(uncomfortable_touch))

/datum/personality/aloof/remove_from_mob(mob/living/who)
	. = ..()
	UnregisterSignal(who, list(COMSIG_LIVING_GET_PULLED, COMSIG_CARBON_HELP_ACT))

/// Causes a negative moodlet to our quirk holder on signal
/datum/personality/aloof/proc/uncomfortable_touch(mob/living/source)
	SIGNAL_HANDLER

	if(source.stat == DEAD)
		return

	new /obj/effect/temp_visual/annoyed(source.loc)
	if(source.mob_mood.sanity <= SANITY_NEUTRAL)
		source.add_mood_event("bad_touch", /datum/mood_event/very_bad_touch)
	else
		source.add_mood_event("bad_touch", /datum/mood_event/bad_touch)

/datum/personality/aromantic
	savefile_key = "aromantic"
	name = "Aromantic"
	desc = "Romance has no place on the station."
	neg_gameplay_desc = "Dislikes kisses and hugs"
	personality_trait = TRAIT_BADTOUCH
