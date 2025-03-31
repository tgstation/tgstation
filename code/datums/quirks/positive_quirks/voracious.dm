/datum/quirk/voracious
	name = "Voracious"
	desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine."
	icon = FA_ICON_DRUMSTICK_BITE
	value = 4
	mob_trait = TRAIT_VORACIOUS
	gain_text = span_notice("You feel HONGRY.")
	lose_text = span_danger("You no longer feel HONGRY.")
	medical_record_text = "Patient has an above average appreciation for food and drink."
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/dinner)
