/datum/quirk/vegetarian
	name = "Vegetarian"
	desc = "You find the idea of eating meat morally and physically repulsive."
	icon = FA_ICON_CARROT
	value = 0
	gain_text = span_notice("You feel repulsion at the idea of eating meat.")
	lose_text = span_notice("You feel like eating meat isn't that bad.")
	medical_record_text = "Patient reports a vegetarian diet."
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/salad)
	mob_trait = TRAIT_VEGETARIAN
