/datum/quirk/mute
	name = "Mute"
	desc = "For some reason you are completely unable to speak."
	icon = FA_ICON_VOLUME_XMARK
	value = -4
	mob_trait = TRAIT_MUTE
	gain_text = span_danger("You find yourself unable to speak!")
	lose_text = span_notice("You feel a growing strength in your vocal chords.")
	medical_record_text = "The patient is unable to use their voice in any capacity."
	hardcore_value = 4
