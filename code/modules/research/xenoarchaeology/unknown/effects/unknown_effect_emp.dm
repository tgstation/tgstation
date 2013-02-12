
/datum/artifact_effect/emp
	effecttype = "emp"

/datum/artifact_effect/emp/New()
	..()
	effect = EFFECT_PULSE

/datum/artifact_effect/emp/DoEffectPulse()
	if(holder)
		empulse(get_turf(holder), effectrange/2, effectrange)
		return 1
