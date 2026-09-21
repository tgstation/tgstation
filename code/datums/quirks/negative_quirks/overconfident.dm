/datum/quirk/in_over_your_head
	name = "Overconfident"
	desc = "You've done this so many times before. What could possibly go wrong? You know you'll always come out \
		head and shoulders over the competition!"
	icon = FA_ICON_PERSON_BURST
	value = -8
	mob_trait = TRAIT_ALWAYS_ALLOW_DECAPITATION
	gain_text = span_danger("You feel like nothing can possibly beat you!")
	lose_text = span_notice("You feel like you have a firmer grasp of your own abilities.")
	medical_record_text = "Patient has an unrealistic understanding of their own capabilities."
	hardcore_value = 6
	mail_goodies = list(/obj/item/clothing/neck/large_scarf/red)
