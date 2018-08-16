
////////////////////////////
///    shrinking serum   ///
////////////////////////////

/datum/reagent/medicine/macrocillin
	name = "Macrocillin"
	id = "macrocillin"
	description = "Glowing yellow liquid."
	reagent_state = LIQUID
	color = "#FFFF00" // rgb: 255, 255, 0
	overdose_threshold = 20

/datum/reagent/medicine/macrocillin/on_mob_life(mob/living/M, method=INGEST)
	for(var/size in list(SIZESCALE_SMALL, SIZESCALE_NORMAL, SIZESCALE_BIG, SIZESCALE_HUGE))
		if(M.size_multiplier < size)
			M.sizescale(size)
			M << "<font color='green'>You grow!</font>"
			break
	if(M.reagents.has_reagent("macrocillin"))
		M.reagents.remove_reagent("macrocillin", 20)
	..()

/datum/reagent/medicine/microcillin
	name = "Microcillin"
	id = "microcillin"
	description = "Murky purple liquid."
	reagent_state = LIQUID
	color = "#800080"
	overdose_threshold = 20

/datum/reagent/microcillin/on_mob_life(mob/living/M, method=INGEST)
	for(var/size in list(SIZESCALE_BIG, SIZESCALE_NORMAL, SIZESCALE_SMALL, SIZESCALE_TINY))
		if(M.size_multiplier > size)
			M.sizescale(size)
			M << "<span class='alert'>You shrink!</span>"
			break;
	if(M.reagents.has_reagent("microcillin"))
		M.reagents.remove_reagent("microcillin", 20)

	..()

/datum/reagent/medicine/normalcillin
	name = "Normalcillin"
	id = "normalcillin"
	description = "Translucent cyan liquid."
	reagent_state = LIQUID
	color = "#00FFFF"
	overdose_threshold = 20

/datum/reagent/medicine/normalcillin/on_mob_life(mob/living/M, method=INGEST)
	if(M.size_multiplier > SIZESCALE_BIG)
		M.sizescale(SIZESCALE_BIG)
		M << "<span class='alert'>You shrink!</span>"
	else if(M.size_multiplier > SIZESCALE_NORMAL)
		M.sizescale(SIZESCALE_NORMAL)
		M << "<span class='alert'>You shrink!</span>"
	else if(M.size_multiplier < SIZESCALE_NORMAL)
		M.sizescale(SIZESCALE_NORMAL)
		M << "<font color='green'>You grow!</font>"
	else if(M.size_multiplier < SIZESCALE_SMALL)
		M.sizescale(SIZESCALE_SMALL)
		M << "<font color='green'>You grow!</font>"

	if(M.reagents.has_reagent("normalcillin"))
		M.reagents.remove_reagent("normalcillin", 20)
	..()


/datum/reagent/medicine/sizeoxadone
	name = "Sizeoxadone"
	id = "sizeoxadone"
	description = "A volatile liquid used as a precursor to size-altering chemicals. Causes dizziness if taken unprocessed."
	reagent_state = LIQUID
	color = "#1E90FF"
	overdose_threshold = 30
	metabolization_rate = 0.8 * REAGENTS_METABOLISM

/datum/reagent/sizeoxadone/on_mob_life(var/mob/living/carbon/M, var/removed)
	if(M.hallucination < volume && prob(20))
		M.hallucination += 5
	if(!M.confused) M.confused = 1
	M.confused = max(M.confused, 20)
	return

/datum/reagent/medicine/sizeoxadone/overdose_process(mob/living/M)
	M.adjustBrainLoss(1)
	M.adjustToxLoss(1)
	..()
	. = 1

////////////////////////// Anti-Noms Drugs //////////////////////////

/datum/reagent/medicine/ickypak
	name = "Ickypak"
	id = "ickypak"
	description = "A foul-smelling green liquid, for inducing muscle contractions to expel accidentally ingested things."
	reagent_state = LIQUID
	color = "#0E900E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/medicine/ickypak/on_mob_life(var/mob/living/M, method=INGEST)
	..()
	if(M.hallucination < volume && prob(20))
		M.hallucination += 5
	M.adjustToxLoss(-5)

	for(var/I in M.vore_organs)
		var/datum/belly/B = M.vore_organs[I]
		for(var/atom/movable/A in B.internal_contents)
			if(prob(55))
				playsound(M, 'sound/effects/splat.ogg', 50, 1)
				B.release_vore_contents(A)
	..()
	. = 1