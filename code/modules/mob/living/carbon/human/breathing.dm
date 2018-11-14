/mob/living/carbon/human/breathe()
	if(!dna.species.breathe(src))
		..()

/mob/living/carbon/human/check_breath(datum/gas_mixture/breath)

	var/L = getorganslot(ORGAN_SLOT_LUNGS)

	if(!L)
		if(health >= crit_threshold)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS + 1)
		else if(!has_trait(TRAIT_NOCRITDAMAGE))
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		failed_last_breath = 1

		var/datum/species/S = dna.species

		switch(S.breathid)				
			if("o2")
				throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
			if("tox")
				throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
			if("co2")
				throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
			if("n2")
				throw_alert("not_enough_nitro", /obj/screen/alert/not_enough_nitro)

		return FALSE
	else if(istype(L, /obj/item/organ/lungs))
		var/obj/item/organ/lungs/lun = L
		lun.check_breath(breath, src)
