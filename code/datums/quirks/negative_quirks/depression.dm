/datum/quirk/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	icon = FA_ICON_FROWN
	mob_trait = TRAIT_DEPRESSION
	value = -3
	gain_text = span_danger("You start feeling depressed.")
	lose_text = span_notice("You no longer feel depressed.") //if only it were that easy!
	medical_record_text = "Patient has a mild mood disorder causing them to experience acute episodes of depression."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED
	hardcore_value = 2
	mail_goodies = list(/obj/item/storage/pill_bottle/happinesspsych)
