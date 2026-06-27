/datum/mutation/adaptation
	name = "Adaptation"
	desc = "The subject gains immunity to damage from extreme temperatures. Does not protect from vacuums."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = span_notice("Your body feels normal!")
	instability = NEGATIVE_STABILITY_MAJOR
	locked = TRUE // fake parent
	conflicts = list(/datum/mutation/adaptation)
	mutation_traits = list(TRAIT_WADDLING)
	mutation_icon = 'icons/mob/effects/genetics.dmi'

/datum/mutation/adaptation/New(datum/mutation/copymut)
	. = ..()
	conflicts = typesof(/datum/mutation/adaptation)

/datum/mutation/adaptation/cold
	name = "Cold Adaptation"
	desc = "The subject gains immunity to damage from low temperature environments, as well as stability when navigating on ice."
	text_gain_indication = span_notice("Your body feels refreshingly cold.")
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_traits = list(TRAIT_RESISTCOLD, TRAIT_NO_SLIP_ICE)
	mutation_icon_state = "cold"
	locked = FALSE

/datum/mutation/adaptation/heat
	name = "Heat Adaptation"
	desc = "The subject gains immunity to damage from high temperatures (including fire), as well as resistance to ash storms."
	text_gain_indication = span_notice("Your body feels invigoratingly warm.")
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_traits = list(TRAIT_RESISTHEAT, TRAIT_ASHSTORM_IMMUNE)
	mutation_icon_state = "fire"
	locked = FALSE

/datum/mutation/adaptation/thermal
	name = "Thermal Adaptation"
	desc = "The subject gains immunity to damage from both low and high temperature environments. \
		Does not protect from high or low pressure environments, nor does it provide stability on ice or resistance to ash storms."
	difficulty = 32
	text_gain_indication = span_notice("Your body feels pleasantly room temperature.")
	instability = POSITIVE_INSTABILITY_MAJOR
	mutation_traits = list(TRAIT_RESISTHEAT, TRAIT_RESISTCOLD)
	mutation_icon_state = "thermal"
	locked = TRUE // recipe

/datum/mutation/adaptation/pressure
	name = "Pressure Adaptation"
	desc = "The subject gains immunity to damage from both low and high pressure environments. \
		Does not protect from temperature, including the cold of space."
	text_gain_indication = span_notice("Your body feels impressively pressurized.")
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_icon_state = "pressure"
	mutation_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE)
	locked = FALSE
