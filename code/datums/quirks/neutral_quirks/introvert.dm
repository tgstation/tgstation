/datum/quirk/introvert
	name = "Introvert"
	desc = "You are energized by having time to yourself, and enjoy spending your free time in the library."
	icon = FA_ICON_BOOK_READER
	value = 0
	mob_trait = TRAIT_INTROVERT
	gain_text = span_notice("You feel like reading a good book quietly.")
	lose_text = span_danger("You feel like libraries are boring.")
	medical_record_text = "Patient doesn't seem to say much."
	mail_goodies = list(/obj/item/book/random)
