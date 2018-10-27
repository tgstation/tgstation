/datum/mutation/human/radioactive
	name = "Radioactivity"
	desc = "A volatile mutation that causes the host to sent out deadly beta radiation. This affects both the hosts and his surroundings."
	quality = NEGATIVE
	get_chance = 25
	text_gain_indication = "<span class='notice'>You can feel it in your bones!</span>"
	time_coeff = 5
	instability = 5

/datum/mutation/human/radioactive/on_life(mob/living/carbon/human/owner)
	radiation_pulse(owner, 20)

/datum/mutation/human/radioactive/New()
	..()
	visual_indicators |= mutable_appearance('icons/effects/genetics.dmi', "radiation", -MUTATIONS_LAYER)

/datum/mutation/human/radioactive/get_visual_indicator(mob/living/carbon/human/owner)
	return visual_indicators[1]