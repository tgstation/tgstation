/datum/quirk/friendly
	name = "Friendly"
	desc = "You give the best hugs, especially when you're in the right mood."
	icon = FA_ICON_HANDS_HELPING
	value = 2
	mob_trait = TRAIT_FRIENDLY
	gain_text = span_notice("You want to hug someone.")
	lose_text = span_danger("You no longer feel compelled to hug others.")
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	medical_record_text = "Patient demonstrates low-inhibitions for physical contact and well-developed arms. Requesting another doctor take over this case."
	mail_goodies = list(/obj/item/storage/box/hug)
