/datum/mutation/human/radioactive
	name = "Radioactivity"
	desc = "A volatile mutation that causes the host to sent out deadly beta radiation. This affects both the hosts and their surroundings."
	quality = NEGATIVE
	text_gain_indication = span_warning("You can feel it in your bones!")
	instability = NEGATIVE_STABILITY_MAJOR
	difficulty = 8
	power_coeff = 1
	/// Weakref to our radiation emitter component
	var/datum/weakref/radioactivity_source_ref

/datum/mutation/human/radioactive/New(class_ = MUT_OTHER, timer, datum/mutation/human/copymut)
	. = ..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/mob/effects/genetics.dmi', "radiation", -MUTATIONS_LAYER))

/datum/mutation/human/radioactive/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/human/radioactive/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	var/datum/component/radioactive_emitter/radioactivity_source = make_radioactive(acquirer)
	radioactivity_source_ref = WEAKREF(radioactivity_source)

/datum/mutation/human/radioactive/modify()
	. = ..()
	if(!QDELETED(owner))
		make_radioactive(owner)

/**
 * Makes the passed mob radioactive, or if they're already radioactive,
 * update their radioactivity to the newly set values
 */
/datum/mutation/human/radioactive/proc/make_radioactive(mob/living/carbon/human/who)
	return who.AddComponent(
		/datum/component/radioactive_emitter, \
		cooldown_time = 5 SECONDS, \
		range = 1 * (GET_MUTATION_POWER(src) * 2), \
		threshold = RAD_MEDIUM_INSULATION, \
	)

/datum/mutation/human/radioactive/on_losing(mob/living/carbon/human/owner)
	QDEL_NULL(radioactivity_source_ref)
	return ..()
