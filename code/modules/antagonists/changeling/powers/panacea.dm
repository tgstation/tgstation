/datum/action/changeling/panacea
	name = "Anatomic Panacea"
	desc = "Expels impurifications from our form; curing negative diseases, removing parasites, sobering us, purging radiation and all reagents, curing brain traumas and brain damage, breaking addictions, healing toxin damage, and resetting our genetic code completely. This power doesn't heal our non-brain organs, cure blindness, cure deafness, or restore our blood volume; for that, we should use the Regenerate power. Costs 20 chemicals."
	helptext = "Can be used while unconscious."
	button_icon_state = "panacea"
	chemical_cost = 20
	dna_cost = 1
	req_stat = HARD_CRIT

//Heals the things that the other regenerative abilities don't.
/datum/action/changeling/panacea/sting_action(mob/user)
	to_chat(user, "<span class='notice'>We cleanse impurities from our form.</span>")
	..()
	var/list/bad_organs = list(
		user.getorgan(/obj/item/organ/body_egg),
		user.getorgan(/obj/item/organ/zombie_infection))

	for(var/o in bad_organs)
		var/obj/item/organ/O = o
		if(!istype(O))
			continue

		O.Remove(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.vomit(0, toxic = TRUE)
		O.forceMove(get_turf(user))

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
		C.adjustOrganLoss(ORGAN_SLOT_BRAIN, -200) //this is redundant with regenerate, but old!anatomic panacea gave you some mannitol and I want new!anatomic panacea to be consistent with that
		C.drunkenness = 0
		C.silent = 0
		var/obj/item/organ/stomach/belly = C.getorganslot(ORGAN_SLOT_STOMACH)
  		if(belly)
    		belly.clear_reagents()

    if(user.reagents)
		user.reagents.clear_reagents()
		user.reagents.add_reagent(/datum/reagent/medicine/mutadone, 10) //I hate hate hate HATE this "solution", but I fear that just copy+pasting the code from mutadone here could cause an issue if that causes a monkey changeling to turn back into a human mid-power execution...

	if(isliving(user))
		var/mob/living/L = user
		for(var/thing in L.diseases)
			var/datum/disease/D = thing
			if(D.severity == DISEASE_SEVERITY_POSITIVE)
				continue
			D.cure()
		L.radiation = 0
		L.clear_addictions()
		L.dizziness = 0
		L.drowsyness = 0
		L.stuttering = 0
		L.jitteriness = 0
		L.hallucination = 0
		L.slurring = 0
		L.cultslurring = 0
		L.derpspeech = 0
		L.set_confusion(0)
		L.set_drugginess(amount)
		L.set_disgust(amount)
		L.adjustToxLoss(-50, TRUE, TRUE) //works even on toxinlovers, so a slimeperson changeling with anatomic panacea won't accidentally kill themselves with it
	return TRUE
