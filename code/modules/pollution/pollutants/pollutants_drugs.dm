///minimum amount of pollutant to get high
#define HOTBOX_MINIMUM 180

///From smoking weed
/datum/pollutant/smoke/cannabis
	name = "Cannabis"
	smell_intensity = 2 //Stronger than the normal smoke
	scent = "cannabis"

/datum/pollutant/smoke/cannabis/BreatheAct(mob/living/carbon/victim, amount)
	if(amount < HOTBOX_MINIMUM)
		return
	//HOTBOX_MINIMUM pollution = 1u
	victim.reagents.add_reagent(/datum/reagent/drug/cannabis, amount / HOTBOX_MINIMUM)

#undef HOTBOX_MINIMUM

/datum/pollutant/smoke/vape
	name = "Vape Cloud"
	thickness = 2
	scent = "pleasant and soft vapour"
