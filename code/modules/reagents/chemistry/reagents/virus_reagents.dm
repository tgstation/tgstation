
//This file contains replicas of ordinary reagents, so they can be tweaked without changing the original ones.

datum/reagent/virus
	name = "Virus Chemical"
	id = "viruschem"
	description = "A chemical produced by a virus."
	color = "#CCCCCC"


/datum/reagent/virus/inacusiate
	name = "Viral Inacusiate"
	id = "viral_inacusiate"
	description = "Instantly restores all hearing to the patient, but does not cure deafness."
	color = "#6600FF" // rgb: 100, 165, 255

/datum/reagent/virus/inacusiate/on_mob_life(mob/living/M)
	M.setEarDamage(0,0)
	..()

/datum/reagent/virus/antihol
	name = "Viral Antihol"
	id = "viral_antihol"
	description = "Purges alcoholic substance from the patient's body and eliminates its side effects."
	color = "#00B4C8"

/datum/reagent/virus/antihol/on_mob_life(mob/living/M)
	M.dizziness = 0
	M.drowsyness = 0
	M.slurring = 0
	M.confused = 0
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3*REM, 0, 1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.drunkenness = max(H.drunkenness - 10, 0)
	..()

/datum/reagent/virus/synaptizine
	name = "Diphen-Synaptizine"
	id = "viral_diphen"
	description = "Reduces drowsiness, hallucinations, and Histamine from body."
	color = "#EC536D" // rgb: 236, 83, 109

/datum/reagent/virus/sensory/stage3/on_mob_life(mob/living/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	if(holder.has_reagent("histamine"))
		holder.remove_reagent("histamine", 5)
	M.hallucination = max(0, M.hallucination - 10)
	..()

/datum/reagent/virus/mannitol
	name = "Viral Mannitol"
	id = "viral_mannitol"
	description = "Efficiently restores brain damage."
	color = "#DCDCFF"

/datum/reagent/virus/brainheal/on_mob_life(mob/living/M)
	M.adjustBrainLoss(-3*REM)
	..()

/datum/reagent/virus/morphine
	name = "Viral Morphine"
	id = "viral_morphine"
	description = "A painkiller that allows the patient to move at full speed even in bulky objects. Causes drowsiness and eventually unconsciousness in high doses."
	reagent_state = LIQUID
	color = "#A9FBFB"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/virus/morphine/on_mob_life(mob/living/M)
	M.status_flags |= IGNORESLOWDOWN
	switch(current_cycle)
		if(11)
			M << "<span class='warning'>You start to feel tired...</span>" //Warning when the victim is starting to pass out
		if(12 to 24)
			M.drowsyness += 1
		if(24 to INFINITY)
			M.Sleeping(2, 0)
			. = 1
	..()

/datum/reagent/virus/mindbreaker
	name = "Viral Mindbreaker"
	id = "viral_mindbreaker"
	description = "A powerful hallucinogen. Not a thing to be messed with."
	color = "#B31008" // rgb: 139, 166, 233

/datum/reagent/virus/mindbreaker/on_mob_life(mob/living/M)
	M.hallucination += 10
	return ..()

/datum/reagent/virus/impedrezene
	name = "Viral Impedrezene"
	id = "viral_impedrezene"
	description = "Narcotic that impedes one's ability by slowing down the higher brain cell functions."
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/virus/impedrezene/on_mob_life(mob/living/M)
	M.jitteriness = max(M.jitteriness-5,0)
	if(prob(80))
		M.adjustBrainLoss(1*REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(10))
		M.emote("drool")
	..()

/datum/reagent/virus/speed
	name = "Viral Ephedrine"
	id = "viral_ephedrine"
	description = "Increases movement speed."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/virus/speed/on_mob_life(mob/living/M)
	M.status_flags |= GOTTAGOFAST
	..()
	. = 1

/datum/reagent/virus/adrenaline
	name = "Viral Adrenaline"
	id = "viral_adrenaline"
	description = "Increases stun resistance."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/virus/antistun/on_mob_life(mob/living/M)
	M.AdjustParalysis(-1, 0)
	M.AdjustStunned(-1, 0)
	M.AdjustWeakened(-1, 0)
	M.AdjustSleeping(-1, 0)
	M.adjustStaminaLoss(-2*REM, 0)
	..()
	. = 1

/datum/reagent/virus/fleshdeath //heparin + lipolicide
	name = "Viral Necrotic Agent"
	id = "viral_fleshdeath"
	description = "Increases stun resistance."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/virus/fleshdeath/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.bleed_rate = min(H.bleed_rate + 2, 8)
		H.adjustBruteLoss(1, 0)
	if(M.nutrition <= NUTRITION_LEVEL_STARVING)
		M.adjustToxLoss(0.5*REM, 0)
	M.nutrition = max(M.nutrition - 3, 0)
	M.overeatduration = 0
	return ..()

/datum/reagent/virus/oculine
	name = "Viral Oculine"
	id = "viral_oculine"
	description = "Quickly restores eye damage, cures nearsightedness, and has a chance to restore vision to the blind."
	reagent_state = LIQUID
	color = "#FFFFFF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/virus/eyehealing/on_mob_life(mob/living/M)
	if(M.disabilities & BLIND)
		if(prob(20))
			M << "<span class='warning'>Your vision slowly returns...</span>"
			M.cure_blind()
			M.cure_nearsighted()
			M.blur_eyes(35)

	else if(M.disabilities & NEARSIGHT)
		M << "<span class='warning'>The blackness in your peripheral vision fades.</span>"
		M.cure_nearsighted()
		M.blur_eyes(10)

	else if(M.eye_blind || M.eye_blurry)
		M.set_blindness(0)
		M.set_blurriness(0)
	else if(M.eye_damage > 0)
		M.adjust_eye_damage(-1)
	..()

/datum/reagent/virus/salbutamol
	name = "Viral Salbutamol"
	id = "viral_salbutamol"
	description = "Rapidly restores oxygen deprivation as well as preventing more of it to an extent."
	reagent_state = LIQUID
	color = "#00FFFF"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/virus/salbutamol/on_mob_life(mob/living/M)
	M.adjustOxyLoss(-3*REM, 0)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	..()