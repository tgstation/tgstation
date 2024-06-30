/datum/quirk/easily_disembowelable
	name = "Weak Body"
	desc = "You can be disembowled/suffer cranial fissures without being in hardcrit."
	icon = FA_ICON_HEART_BROKEN
	value = -2 // relatively low, since this is actually fairly uncommon to proc
	mob_trait = TRAIT_EASILY_DISEMBOWELABLE
	gain_text = span_danger("Your feel your organs moving around...")
	lose_text = span_notice("Your abdominal organs and your brain feel secure again.")
	medical_record_text = "The patient's abdominal wall/skull is abnormally weak."
	quirk_flags = QUIRK_HUMAN_ONLY
	hardcore_value = 2

