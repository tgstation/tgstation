/datum/mutation/human/radioactive
	name = "Radioactivity"
	desc = "A volatile mutation that causes the host to sent out deadly beta radiation. This affects both the hosts and their surroundings."
	quality = NEGATIVE
	text_gain_indication = "<span class='warning'>You can feel it in your bones!</span>"
	instability = 5
	difficulty = 8
	power_coeff = 1

/datum/mutation/human/radioactive/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	. = ..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "radiation", -MUTATIONS_LAYER))

/datum/mutation/human/radioactive/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/human/radioactive/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	make_radioactive(acquirer)

/datum/mutation/human/radioactive/modify()
	. = ..()
	make_radioactive(owner)

/**
 * Makes the passed mob radioactive, or if they're already radioactive,
 * update their radioactivity to the newly set values
 */
/datum/mutation/human/radioactive/proc/make_radioactive(mob/living/carbon/human/who)
	who.AddComponent(/datum/component/radioactive_emitter, \
		cooldown_time = 5 SECONDS, \
		range = 1 * (GET_MUTATION_POWER(src) * 2), \
		threshold = RAD_MEDIUM_INSULATION, \
	)

/datum/mutation/human/radioactive/on_losing(mob/living/carbon/human/owner)
	qdel(owner.GetComponent(/datum/component/radioactive_emitter))
	return ..()
