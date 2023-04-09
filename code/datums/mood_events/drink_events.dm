/datum/mood_event/drunk
	mood_change = 3
	description = "Everything just feels better after a drink or two."
	/// The blush overlay to display when the owner is drunk
	var/datum/bodypart_overlay/simple/emote/blush_overlay

/datum/mood_event/drunk/add_effects(param)
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	blush_overlay = human_owner.give_emote_overlay(/datum/bodypart_overlay/simple/emote/blush)

/datum/mood_event/drunk/remove_effects()
	QDEL_NULL(blush_overlay)

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
