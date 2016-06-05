
//////////////////////////////////////////////////////////////////////////////////////////
					// MEDICINE REAGENTS
//////////////////////////////////////////////////////////////////////////////////////

// where all the reagents related to medicine go.

/datum/reagent/medicine
	name = "Medicine"
	id = "medicine"

/datum/reagent/medicine/on_mob_life(mob/living/M)
	current_cycle++
	holder.remove_reagent(src.id, metabolization_rate / M.metabolism_efficiency) //medicine reagents stay longer if you have a better metabolism

/datum/reagent/medicine/leporazine
	name = "Leporazine"
	id = "leporazine"
	description = "Leporazine will effectively regulate a patient's body temperature, ensuring it never leaves safe levels."
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/medicine/leporazine/on_mob_life(mob/living/M)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()

/datum/reagent/medicine/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/medicine/adminordrazine/on_mob_life(mob/living/carbon/M)
	M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
	M.setCloneLoss(0, 0)
	M.setOxyLoss(0, 0)
	M.radiation = 0
	M.heal_organ_damage(5,5, 0)
	M.adjustToxLoss(-5, 0)
	M.hallucination = 0
	M.setBrainLoss(0)
	M.disabilities = 0
	M.set_blurriness(0)
	M.set_blindness(0)
	M.SetWeakened(0, 0)
	M.SetStunned(0, 0)
	M.SetParalysis(0, 0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.slurring = 0
	M.confused = 0
	M.SetSleeping(0, 0)
	M.jitteriness = 0
	for(var/datum/disease/D in M.viruses)
		if(D.severity == NONTHREAT)
			continue
		D.spread_text = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()
	..()
	. = 1

/datum/reagent/medicine/adminordrazine/nanites
	name = "Nanites"
	id = "nanites"
	description = "Tiny nanomachines capable of rapid cellular regeneration."

/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Increases resistance to stuns as well as reducing drowsiness and hallucinations."
	color = "#FF00FF"

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	M.AdjustParalysis(-1, 0)
	M.AdjustStunned(-1, 0)
	M.AdjustWeakened(-1, 0)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
		. = 1
	..()

/datum/reagent/medicine/synaphydramine
	name = "Diphen-Synaptizine"
	id = "synaphydramine"
	description = "Reduces drowsiness, hallucinations, and Histamine from body."
	color = "#EC536D" // rgb: 236, 83, 109

/datum/reagent/medicine/synaphydramine/on_mob_life(mob/living/M)
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

/datum/reagent/medicine/inacusiate
	name = "Inacusiate"
	id = "inacusiate"
	description = "Instantly restores all hearing to the patient, but does not cure deafness."
	color = "#6600FF" // rgb: 100, 165, 255

/datum/reagent/medicine/inacusiate/on_mob_life(mob/living/M)
	M.setEarDamage(0,0)
	..()

/datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the patient's body temperature must be under 270K for it to metabolise correctly."
	color = "#0000C8"

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/M)
	switch(M.bodytemperature) // Low temperatures are required to take effect.
		if(0 to 100) // At extreme temperatures (upgraded cryo) the effect is greatly increased.
			M.status_flags &= ~DISFIGURED
			M.adjustCloneLoss(-7, 0)
			M.adjustOxyLoss(-9, 0)
			M.adjustBruteLoss(-5, 0)
			M.adjustFireLoss(-5, 0)
			M.adjustToxLoss(-5, 0)
			. = 1
		if(100 to 225) // At lower temperatures (cryo) the full effect is boosted
			M.status_flags &= ~DISFIGURED
			M.adjustCloneLoss(-2, 0)
			M.adjustOxyLoss(-7, 0)
			M.adjustBruteLoss(-3, 0)
			M.adjustFireLoss(-3, 0)
			M.adjustToxLoss(-3, 0)
			. = 1
		if(225 to T0C)
			M.status_flags &= ~DISFIGURED
			M.adjustCloneLoss(-1, 0)
			M.adjustOxyLoss(-5, 0)
			M.adjustBruteLoss(-1, 0)
			M.adjustFireLoss(-1, 0)
			M.adjustToxLoss(-1, 0)
			. = 1
	..()


/datum/reagent/medicine/rezadone
	name = "Rezadone"
	id = "rezadone"
	description = "A powder derived from fish toxin, Rezadone can effectively treat genetic damage as well as restoring minor wounds. Overdose will cause intense nausea and minor toxin damage."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = 30

/datum/reagent/medicine/rezadone/on_mob_life(mob/living/M)
	M.setCloneLoss(0) //Rezadone is almost never used in favor of cryoxadone. Hopefully this will change that.
	M.heal_organ_damage(1,1, 0)
	M.status_flags &= ~DISFIGURED
	..()
	. = 1

/datum/reagent/medicine/rezadone/overdose_process(mob/living/M)
	M.adjustToxLoss(1, 0)
	M.Dizzy(5)
	M.Jitter(5)
	..()
	. = 1

/datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	description = "Spaceacillin will prevent a patient from conventionally spreading any diseases they are currently infected with."
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

//Trek Chems, used primarily by medibots. Only heals a specific damage type, but is very efficient.
datum/reagent/medicine/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	description = "Restores bruising. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/medicine/bicaridine/on_mob_life(mob/living/M)
	M.adjustBruteLoss(-2*REM, 0)
	..()
	. = 1

datum/reagent/medicine/dexalin
	name = "Dexalin"
	id = "dexalin"
	description = "Restores oxygen loss. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/medicine/dexalin/on_mob_life(mob/living/M)
	M.adjustOxyLoss(-2*REM, 0)
	..()
	. = 1

datum/reagent/medicine/dexalinplus
	name = "Dexalin Plus"
	id = "dexalinplus"
	description = "Restores oxygen loss. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/medicine/dexalinplus/on_mob_life(mob/living/M)
	M.adjustOxyLoss(-M.oxyloss, 0)
	..()
	. = 1

datum/reagent/medicine/kelotane
	name = "Kelotane"
	id = "kelotane"
	description = "Restores fire damage. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/medicine/kelotane/on_mob_life(mob/living/M)
	M.adjustFireLoss(-2*REM, 0)
	..()
	. = 1

datum/reagent/medicine/antitoxin
	name = "Anti-Toxin"
	id = "antitoxin"
	description = "Heals toxin damage and removes toxins in the bloodstream. Overdose causes toxin damage."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/medicine/antitoxin/on_mob_life(mob/living/M)
	M.adjustToxLoss(-2*REM, 0)
	for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,1)
	..()
	. = 1

datum/reagent/medicine/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	description = "Stabilizes the breathing of patients. Good for those in critical condition."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/medicine/inaprovaline/on_mob_life(mob/living/M)
	if(M.losebreath >= 5)
		M.losebreath -= 5
	..()

datum/reagent/medicine/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	description = "Has a high chance to heal all types of damage. Overdose instead causes it."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/medicine/tricordrazine/on_mob_life(mob/living/M)
	if(prob(80))
		M.adjustBruteLoss(-1*REM, 0)
		M.adjustFireLoss(-1*REM, 0)
		M.adjustOxyLoss(-1*REM, 0)
		M.adjustToxLoss(-1*REM, 0)
		. = 1
	..()

datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Restorative Nanites"
	id = "syndicate_nanites"
	description = "Miniature medical robots that swiftly restore bodily damage."
	reagent_state = SOLID
	color = "#555555"

datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/M)
	M.adjustBruteLoss(-5*REM, 0) //A ton of healing - this is a 50 telecrystal investment.
	M.adjustFireLoss(-5*REM, 0)
	M.adjustOxyLoss(-15, 0)
	M.adjustToxLoss(-5*REM, 0)
	M.adjustBrainLoss(-15*REM)
	M.adjustCloneLoss(-3*REM, 0)
	..()
	. = 1

//used for changeling's adrenaline power
/datum/reagent/medicine/changelingAdrenaline
	name = "Adrenaline"
	id = "changelingAdrenaline"
	description = "Reduces stun times. Also deals toxin damage at high amounts."
	color = "#C8A5DC"
	overdose_threshold = 30

/datum/reagent/medicine/changelingAdrenaline/on_mob_life(mob/living/M as mob)
	M.AdjustParalysis(-1, 0)
	M.AdjustStunned(-1, 0)
	M.AdjustWeakened(-1, 0)
	M.adjustStaminaLoss(-1, 0)
	. = 1
	..()

/datum/reagent/medicine/changelingAdrenaline/overdose_process(mob/living/M as mob)
	M.adjustToxLoss(1, 0)
	. = 1
	..()

/datum/reagent/medicine/changelingAdrenaline2
	name = "Adrenaline"
	id = "changelingAdrenaline2"
	description = "Drastically increases movement speed."
	color = "#C8A5DC"
	metabolization_rate = 1

/datum/reagent/medicine/changelingAdrenaline2/on_mob_life(mob/living/M as mob)
	M.status_flags |= GOTTAGOREALLYFAST
	M.adjustToxLoss(2, 0)
	. = 1
	..()
