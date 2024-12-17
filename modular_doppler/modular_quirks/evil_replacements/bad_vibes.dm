/datum/quirk/bad_vibes
	name = "Bad Vibes"
	desc = "By a quirk of your personality or exposure to too many horrible sights, you give off a bad aura which affects \
			empaths and anyone else who looks too closely."
	icon = FA_ICON_HAND_MIDDLE_FINGER
	value = 0
	mob_trait = TRAIT_BAD_VIBES
	gain_text = span_notice("You give off a negative aura.")
	lose_text = span_notice("You try to be more approachable.")
	medical_record_text = "Patient scared away a nurse prior to physical examination."

/datum/mood_event/bad_vibes
	description = "Some people truly disturb me... What could happen to make someone like that?"
	mood_change = -4
	timeout = 1 MINUTES
