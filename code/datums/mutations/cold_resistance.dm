//Cold Resistance gives your entire body an orange halo, and makes you immune to the effects of vacuum and cold.
/datum/mutation/human/cold_resistance
	name = "Cold Resistance"
	desc = "A strange mutation that makes the holder completely immune to hostile temperatures."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your body feels warm!</span>"
	time_coeff = 5
	instability = 30

/datum/mutation/human/cold_resistance/New()
	..()
	visual_indicators |= mutable_appearance('icons/effects/genetics.dmi', "fire", -MUTATIONS_LAYER)

/datum/mutation/human/cold_resistance/get_visual_indicator(mob/living/carbon/human/owner)
	return visual_indicators[1]

/datum/mutation/human/cold_resistance/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.add_trait(TRAIT_RESISTCOLD, "cold_resistance")
	owner.add_trait(TRAIT_RESISTLOWPRESSURE, "cold_resistance")

/datum/mutation/human/cold_resistance/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.remove_trait(TRAIT_RESISTCOLD, "cold_resistance")
	owner.remove_trait(TRAIT_RESISTLOWPRESSURE, "cold_resistance")

