

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/update_pain_level()
	if(pain_numb)
		return 0

	pain_level = 					\
	1	* getOxyLoss() + 		\
	0.7	* getToxLoss() + 		\
	1.5	* getFireLoss() + 		\
	1.2	* getBruteLoss() + 		\
	1.7	* getCloneLoss()

	for(var/datum/reagent/R in reagents.reagent_list)
		pain_level -= R.pain_resistance

	if(slurring) //I'm not sure why this is here.
		pain_level -= 20

	return min(pain_level, 0)


/mob/living/carbon/proc/handle_shock() //Currently only used for humans
	update_pain_level()

/mob/living/carbon/proc/has_painkillers()
	return (reagents.has_reagent("oxycodone") || reagents.has_reagent("tramadol"))