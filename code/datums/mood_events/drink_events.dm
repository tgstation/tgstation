/datum/mood_event/drunk
	mood_change = 3
	description = "Everything just feels better after a drink or two."
	/// The blush overlay to display when the owner is drunk
	var/datum/bodypart_overlay/simple/emote/blush_visual = new /datum/bodypart_overlay/simple/emote/blush()
	/// The bodypart that the blush_visual was applied to
	var/obj/item/bodypart/attached_bodypart

/datum/mood_event/drunk/add_effects(param)
	// Display blush visual
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		attached_bodypart = human_owner.get_bodypart(blush_visual.attached_body_zone)
		if(attached_bodypart)
			attached_bodypart.add_bodypart_overlay(blush_visual)
			human_owner.update_body()

/datum/mood_event/drunk/remove_effects()
	// Stop displaying blush visual
	if(attached_bodypart)
		attached_bodypart.remove_bodypart_overlay(blush_visual)
		if(attached_bodypart.owner) // Keep in mind that the user might have lost the attached bodypart by now
			attached_bodypart.owner.update_body()
		else
			attached_bodypart.update_icon_dropped()
		attached_bodypart = null

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
