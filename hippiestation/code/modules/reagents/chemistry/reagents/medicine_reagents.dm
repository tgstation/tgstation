/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/carbon/M)	//hippie cryo tweaks, fix trailing cold damage on exit
	var/power = 0.00003 * (-M.bodytemperature ** 2) + 3	//properly adjusted so lower temperature = faster healing
	if(M.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT + 10)	//if you're a bit cold you'll get healed a tiny bit still
		M.adjustOxyLoss(-3 * power, 0)
		M.adjustBruteLoss(-power, 0)
		M.adjustFireLoss(-power, 0)
		M.adjustToxLoss(-power, 0, TRUE) //heals TOXINLOVERs
		M.adjustCloneLoss(-power, 0)
		for(var/i in M.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_xadone(power)
		REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC) //fixes common causes for disfiguration
		. = 1
	metabolization_rate = REAGENTS_METABOLISM * (0.00001 * (M.bodytemperature ** 2) + 0.5)
	..()
