/datum/quirk/pushover
	name = "Pushover"
	desc = "Your first instinct is always to let people push you around. Resisting out of grabs is noticeably more difficult."
	icon = FA_ICON_HANDSHAKE
	value = -8
	mob_trait = TRAIT_GRABWEAKNESS
	gain_text = span_danger("You feel like a pushover.")
	lose_text = span_notice("You feel like standing up for yourself.")
	medical_record_text = "Patient presents a notably unassertive personality and is easy to manipulate."
	hardcore_value = 4
	mail_goodies = list(/obj/item/clothing/gloves/cargo_gauntlet)
