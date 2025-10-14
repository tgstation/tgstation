/datum/personality/introvert
	savefile_key = "introvert"
	name = "Introverted"
	desc = "I prefer to be alone, reading or painting in the library."
	pos_gameplay_desc = "Likes being in the library"
	// neg_gameplay_desc = "Dislikes large groups"
	personality_trait = TRAIT_INTROVERT
	groups = list(PERSONALITY_GROUP_INTERACTION)

/datum/personality/extrovert
	savefile_key = "extrovert"
	name = "Extroverted"
	desc = "I prefer to be surrounded by people, having a drink at the Bar."
	pos_gameplay_desc = "Likes being in the bar"
	// neg_gameplay_desc = "Dislikes being alone"
	personality_trait = TRAIT_EXTROVERT
	groups = list(PERSONALITY_GROUP_INTERACTION, PERSONALITY_GROUP_OTHERS)

/datum/personality/paranoid
	savefile_key = "paranoid"
	name = "Paranoid"
	desc = "Everyone and everything is out to get me! This place is a deathtrap!"
	pos_gameplay_desc = "Likes being alone or in moderately-sized groups"
	neg_gameplay_desc = "Stressed when with one other person, or in large groups"
	processes = TRUE
	groups = list(PERSONALITY_GROUP_PEOPLE_FEAR)

/datum/personality/paranoid/remove_from_mob(mob/living/who)
	. = ..()
	who.clear_mood_event("paranoia_personality")

/datum/personality/paranoid/on_tick(mob/living/subject, seconds_per_tick)
	var/list/nearby_people = list()
	for(var/mob/living/carbon/human/nearby in view(subject, 5))
		if(nearby == subject || !is_dangerous_mob(subject, nearby))
			continue
		nearby_people += nearby

	switch(length(nearby_people))
		if(0)
			subject.add_mood_event("paranoia_personality", /datum/mood_event/paranoid/alone)
		if(1)
			subject.add_mood_event("paranoia_personality", /datum/mood_event/paranoid/one_on_one)
		if(2 to 6) // 6 people is roughly the size of the larger jobs like meddoc or secoff
			subject.add_mood_event("paranoia_personality", /datum/mood_event/paranoid/small_group)
		else
			subject.add_mood_event("paranoia_personality", /datum/mood_event/paranoid/large_group)

/datum/personality/paranoid/proc/is_dangerous_mob(mob/living/subject, mob/living/carbon/human/target)
	if(target.stat >= UNCONSCIOUS)
		return FALSE
	if(target.invisibility > subject.see_invisible || target.alpha < 20)
		return FALSE
	// things that are threatening: other players
	// things that are also threatening: monkeys
	return TRUE
