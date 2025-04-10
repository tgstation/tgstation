/datum/mood_event/drunk
	mood_change = 3
	description = "Everything just feels better after a drink or two."
	/// The blush overlay to display when the owner is drunk
	var/datum/bodypart_overlay/simple/emote/blush_overlay

/datum/mood_event/drunk/add_effects(drunkness)
	update_change(drunkness)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	blush_overlay = human_owner.give_emote_overlay(/datum/bodypart_overlay/simple/emote/blush)

/// Updates the description and value of the moodlet according to the passed drunkness value
/// (Does not add to or remove from the current level - it will sets it directly to the new value)
/datum/mood_event/drunk/proc/update_change(drunkness = 0)
	var/old_mood = mood_change
	switch(drunkness)
		if(0 to 30)
			mood_change = 3
			description = "Everything just feels better after a drink or two."
		if(30 to 45)
			mood_change = 4
			description = "Is it getting hotter, or is it just me? I need another drink to cool down."
		if(45 to 60)
			mood_change = 5
			description = "Who keeps moving the floor? I'm going to talk to them... after this drink."
		if(60 to 90)
			mood_change = 6
			description = "I'm noooot drunk, you're drunk! In fact... I need another drink!"
		if(90 to INFINITY)
			mood_change = 3 // crash out
			description = "You're my BESSST frien'... You and me agains' th' world, buddy. Le's get another drink."
	if(old_mood != mood_change)
		owner.mob_mood.update_mood()

/datum/mood_event/drunk/remove_effects()
	QDEL_NULL(blush_overlay)

/datum/mood_event/wrong_brandy
	description = "I hate that type of drink."
	mood_change = -2
	timeout = 6 MINUTES

/datum/mood_event/quality_revolting
	description = "That drink was the worst thing I've ever consumed."
	mood_change = -8
	timeout = 7 MINUTES

/datum/mood_event/quality_nice
	description = "That drink wasn't bad at all."
	mood_change = 2
	timeout = 7 MINUTES

/datum/mood_event/quality_good
	description = "That drink was pretty good."
	mood_change = 4
	timeout = 7 MINUTES

/datum/mood_event/quality_verygood
	description = "That drink was great!"
	mood_change = 6
	timeout = 7 MINUTES

/datum/mood_event/quality_fantastic
	description = "That drink was amazing!"
	mood_change = 8
	timeout = 7 MINUTES

/datum/mood_event/amazingtaste
	description = "Amazing taste!"
	mood_change = 50
	timeout = 10 MINUTES

/datum/mood_event/wellcheers
	description = "What a tasty can of Wellcheers! The salty grape flavor is a great pick-me-up."
	mood_change = 3
	timeout = 7 MINUTES
