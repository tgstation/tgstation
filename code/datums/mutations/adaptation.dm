/datum/mutation/human/temperature_adaptation
	name = "Temperature Adaptation"
	desc = "A strange mutation that renders the host immune to damage from extreme temperatures. Does not protect from vacuums."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your body feels warm!</span>"
	instability = 25
	conflicts = list(/datum/mutation/human/pressure_adaptation)

/datum/mutation/human/temperature_adaptation/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "fire", -MUTATIONS_LAYER))

/datum/mutation/human/temperature_adaptation/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/human/temperature_adaptation/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_RESISTCOLD, GENETIC_MUTATION)
	ADD_TRAIT(owner, TRAIT_RESISTHEAT, GENETIC_MUTATION)

/datum/mutation/human/temperature_adaptation/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_RESISTCOLD, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_RESISTHEAT, GENETIC_MUTATION)

/datum/mutation/human/pressure_adaptation
	name = "Pressure Adaptation"
	desc = "A strange mutation that renders the host immune to damage from both low and high pressure environments. Does not protect from temperature, including the cold of space."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your body feels numb!</span>"
	instability = 25
	conflicts = list(/datum/mutation/human/temperature_adaptation)

/datum/mutation/human/pressure_adaptation/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "pressure", -MUTATIONS_LAYER))

/datum/mutation/human/pressure_adaptation/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/human/pressure_adaptation/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, GENETIC_MUTATION)
	ADD_TRAIT(owner, TRAIT_RESISTHIGHPRESSURE, GENETIC_MUTATION)

/datum/mutation/human/pressure_adaptation/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_RESISTHIGHPRESSURE, GENETIC_MUTATION)
