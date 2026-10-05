/datum/quirk/death_mimicry
	name = "Death Mimicry"
	desc = "You've mastered the art of faking your demise. Performing a death gasp knocks you unconscious and tricks anyone examining you into believing you've succumbed to your injuries for a short time."
	icon = FA_ICON_GHOST
	value = 16
	gain_text = span_notice("You know how to put on a convincing death scene.")
	lose_text = span_danger("You've lost your flair for dramatic deaths.")
	medical_record_text = "Patient routinely fakes cardiac arrest to get out of fights."
	mail_goodies = list(/obj/item/bodybag)
