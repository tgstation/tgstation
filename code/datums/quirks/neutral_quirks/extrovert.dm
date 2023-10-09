/datum/quirk/extrovert
	name = "Extrovert"
	desc = "You are energized by talking to others, and enjoy spending your free time in the bar."
	icon = FA_ICON_USERS
	value = 0
	mob_trait = TRAIT_EXTROVERT
	gain_text = span_notice("You feel like hanging out with other people.")
	lose_text = span_danger("You feel like you're over the bar scene.")
	medical_record_text = "Patient will not shut the hell up."
	mail_goodies = list(/obj/item/reagent_containers/cup/glass/flask)
