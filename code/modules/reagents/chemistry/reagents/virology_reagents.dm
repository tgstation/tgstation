
//////////////////////////////////////////////////////////////////////////////////////////
					// VIROLOGY REAGENTS
//////////////////////////////////////////////////////////////////////////////////////

// where all the reagents related to medicine go.

/datum/reagent/virology/
	name = "Medicine"
	id = "medicine"

/datum/reagent/virology/on_mob_life(mob/living/M)
	current_cycle++
	holder.remove_reagent(src.id, metabolization_rate / M.metabolism_efficiency) //medicine reagents stay longer if you have a better metabolism

/datum/reagent/virology/dexalin
	name = "Dexalin"
	id = "virorespiration"
	description = "Rapidly restores oxygen deprivation as well as preventing more of it to an extent."
	reagent_state = LIQUID
	color = "#4169E1"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/virology/dexalin/on_mob_life(mob/living/M)
	M.adjustOxyLoss(-12*REM, 0)
	if(M.losebreath >= 4)
		M.losebreath -= 2
	..()
	. = 1

/datum/reagent/virology/Imidazoline
	name = "Imidazoline"
	id = "viroocular"
	description = "Quickly restores eye damage, cures nearsightedness, and has a chance to restore vision to the blind."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/virology/oculine/on_mob_life(mob/living/M)
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

/datum/reagent/virology/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = "viroantihol"
	description = "Purges alcoholic substance from the patient's body and eliminates its side effects."
	color = "#C8A5DC"

/datum/reagent/virology/ethylredoxrazine/on_mob_life(mob/living/M)
	M.dizziness = 0
	M.drowsyness = 0
	M.slurring = 0
	M.confused = 0
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3*REM, 0, 1)
	M.adjustToxLoss(-0.2*REM, 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.drunkenness = max(H.drunkenness - 10, 0)
	..()
	. = 1

/datum/reagent/virology/inacusiate
	name = "Inacusiate"
	id = "viroinacusiate"
	description = "Instantly restores all hearing to the patient, and cures deafness."
	color = "#6600FF" // rgb: 100, 165, 255

/datum/reagent/virology/inacusiate/on_mob_life(mob/living/M)
	if(M.disabilities & DEAF)
		if(prob(20))
			M << "<span class='warning'>Your hearing slowly returns...</span>"
			M.disabilities &= ~DEAF
			M.setEarDamage(0,0)
	else
		M.setEarDamage(0,0)
	..()

/datum/reagent/virology/synaphydramine
	name = "Diphen-Synaptizine"
	id = "synaphydramine"
	description = "Reduces drowsiness, hallucinations, and Histamine from body."
	color = "#EC536D" // rgb: 236, 83, 109

/datum/reagent/virology/synaphydramine/on_mob_life(mob/living/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	if(holder.has_reagent("histamine"))
		holder.remove_reagent("histamine", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
		. = 1
	..()

/datum/reagent/virology/alkysine
	name = "Alkysine"
	id = "viroalkysine"
	description = "Efficiently restores brain damage."
	color = "#C8A5DC"

/datum/reagent/medicine/mannitol/on_mob_life(mob/living/M)
	M.adjustBrainLoss(-3*REM)
	..()

/datum/reagent/virology/morphine
	name = "Opiates"
	id = "viromorphine"
	description = "A nerf blocker that causes drowsiness and eventually unconsciousness in high doses. Overdose will cause a variety of effects, ranging from minor to lethal."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	addiction_threshold = 25

/datum/reagent/virology/morphine/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(11)
			M << "<span class='warning'>You can't feel your legs</span>" //Warning when the victim is starting to pass out
		if(12 to 24)
			M.drowsyness += 1
		if(24 to INFINITY)
			M.Sleeping(2, 0)
			. = 1
	..()

/datum/reagent/virology/morphine/overdose_process(mob/living/M)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.Dizzy(2)
		M.Jitter(2)
	..()

/datum/reagent/virology/morphine/addiction_act_stage1(mob/living/M)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.Dizzy(2)
		M.Jitter(2)
	..()

/datum/reagent/virology/morphine/addiction_act_stage2(mob/living/M)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(1*REM, 0)
		. = 1
		M.Dizzy(3)
		M.Jitter(3)
	..()

/datum/reagent/virology/morphine/addiction_act_stage3(mob/living/M)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(2*REM, 0)
		. = 1
		M.Dizzy(4)
		M.Jitter(4)
	..()

/datum/reagent/virology/morphine/addiction_act_stage4(mob/living/M)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(3*REM, 0)
		. = 1
		M.Dizzy(5)
		M.Jitter(5)
	..()

/datum/reagent/virology/ethanol
	name = "Alcohol dehydrogenase"
	id = "viroethanol"
	description = "A natural alcohol produced by the body."
	color = "#404030" // rgb: 64, 64, 48
	var/boozepwr = 65 //Higher numbers equal higher hardness, higher hardness equals more intense alcohol poisoning

/datum/reagent/virology/ethanol/on_mob_life(mob/living/M)
	M.jitteriness = max(M.jitteriness-5,0)
	if(current_cycle >= boozepwr*0.5)
		var/drunk_value = sqrt(volume*1000/boozepwr)
		if(volume >= boozepwr*0.2)
			if(M.slurring < drunk_value)
				M.slurring += 4
			M.Dizzy(drunk_value)
		if(volume >= boozepwr*0.8)
			if(M.confused < drunk_value)
				M.confused += 3
		if(volume >= boozepwr*3.8)
			M.adjustToxLoss(1, 0)
			. = 1
	return ..() || .

/datum/reagent/virology/hallucigen
	name = "N,N-Dimethyltryptamine"
	id = "virohallucigen"
	description = "A potent natural hallucigen."
	color = "#B31008" // rgb: 139, 166, 233

/datum/reagent/virology/hallucigen/on_mob_life(mob/living/M)
	M.hallucination += 10
	return ..()

//datum/reagent/impedrezene
//	name = "Superoxide"
//	id = "impedrezene"
//	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
//	color = "#C8A5DC" // rgb: 200, 165, 220

//datum/reagent/impedrezene/on_mob_life(mob/living/M)
//	M.jitteriness = max(M.jitteriness-5,0)
//	if(prob(80))
//		M.adjustBrainLoss(1*REM)
//	if(prob(50))
//		M.drowsyness = max(M.drowsyness, 3)
//	if(prob(10))
//		M.emote("drool")
//	..()