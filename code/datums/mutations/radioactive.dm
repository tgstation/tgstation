/datum/mutation/human/radioactive
	name = "Radioactivity"
	desc = "A volatile mutation that causes the host to sent out deadly beta radiation. This affects both the hosts and their surroundings."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>You can feel it in your bones!</span>"
	instability = 5
	difficulty = 8
	power_coeff = 1

	COOLDOWN_DECLARE(last_radioactive_pulse)

/datum/mutation/human/radioactive/on_life(delta_time, times_fired)
	if (!COOLDOWN_FINISHED(src, last_radioactive_pulse))
		return

	COOLDOWN_START(src, last_radioactive_pulse, 5 SECONDS)
	radiation_pulse(
		owner,
		max_range = 1 * (GET_MUTATION_POWER(src) * 2),
		threshold = RAD_MEDIUM_INSULATION,
	)

/datum/mutation/human/radioactive/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "radiation", -MUTATIONS_LAYER))

/datum/mutation/human/radioactive/get_visual_indicator()
	return visual_indicators[type][1]
