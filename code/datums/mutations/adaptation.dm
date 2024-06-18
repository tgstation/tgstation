/datum/mutation/human/adaptation
	name = "Adaptation"
	desc = "A strange mutation that adapts or something."
	desc = "A strange mutation that renders the host immune to damage from extreme temperatures. Does not protect from vacuums."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your body feels gay!</span>"
	instability = NEGATIVE_STABILITY_MAJOR
	locked = TRUE // fake parent
	conflicts = list(/datum/mutation/human/adaptation)
	mutation_traits = list(TRAIT_WADDLING)
	var/adapt_icon = "meow"

/datum/mutation/human/adaptation/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/mob/effects/genetics.dmi', adapt_icon, -MUTATIONS_LAYER))

/datum/mutation/human/adaptation/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/human/adaptation/cold
	name = "Cold Adaptation"
	desc = "A strange mutation that renders the host immune to damage from low temperature environments. It also prevents the host from slipping on water or ice."
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your body feels refreshingly cold.</span>"
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_traits = list(TRAIT_RESISTCOLD, TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE)
	adapt_icon = "cold"
	locked = FALSE

/datum/mutation/human/adaptation/heat
	name = "Heat Adaptation"
	desc = "A strange mutation that renders the host immune to damage from high temperature or ignition, though the flame itself still appears. It also seems to make the host resist ash storms."
	text_gain_indication = "<span class='notice'>Your body feels refreshingly warm.</span>"
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_traits = list(TRAIT_RESISTHEAT, TRAIT_ASHSTORM_IMMUNE)
	adapt_icon = "fire"
	locked = FALSE

/datum/mutation/human/adaptation/thermal
	name = "Thermal Adaptation"
	desc = "A strange mutation that renders the host immune to damage from both low and high temperature environments."
	difficulty = 32
	text_gain_indication = "<span class='notice'>Your body feels refreshingly room temperature.</span>"
	instability = POSITIVE_INSTABILITY_MAJOR
	mutation_traits = list(TRAIT_RESISTHEAT, TRAIT_RESISTCOLD)
	adapt_icon = "thermal"
	locked = TRUE // recipe

/datum/mutation/human/adaptation/pressure
	name = "Pressure Adaptation"
	desc = "A strange mutation that renders the host immune to damage from both low and high pressure environments. Does not protect from temperature, including the cold of space."
	text_gain_indication = "<span class='notice'>Your body feels numb!</span>"
	instability = POSITIVE_INSTABILITY_MODERATE
	adapt_icon = "pressure"
	mutation_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE)
	locked = FALSE
