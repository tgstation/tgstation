/datum/reagent/medicine/liquid_solder
	name = "Liquid Solder"
	description = "Repairs brain damage in synthetics."
	color = "#727272"
	taste_description = "metallic"
	process_flags = SYNTHETIC

/datum/reagent/medicine/liquid_solder/on_mob_life(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, (-3*REM))
	M.hallucination = max(0, M.hallucination - 10)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(prob(30) && C.has_trauma_type(BRAIN_TRAUMA_SPECIAL))
			C.cure_trauma_type(BRAIN_TRAUMA_SPECIAL)
		if(prob(10) && C.has_trauma_type(BRAIN_TRAUMA_MILD))
			C.cure_trauma_type(BRAIN_TRAUMA_MILD)
	..()
