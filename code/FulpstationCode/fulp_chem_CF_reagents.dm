#define REM REAGENTS_EFFECT_MULTIPLIER

//FulpChem rework/addition of old chems to fix the potatofarm that is tg development -Love, Saliferous
/datum/reagent/medicine/CF
	harmful = FALSE

//Trekkie Chems :  Uses discarded recipes with new lock-reagent to keep it T4/5
//Bicaridine (Brute Heal)
/datum/reagent/medicine/CF/bicaridine
	name = "Bicaridine"
	description = "Advanced Brute Healing. Injection only, Scotty."
	reagent_state = LIQUID
	color = "#FF1744"
	metabolization_rate = 0.4
	overdose_threshold = 30 * REAGENTS_METABOLISM

/datum/reagent/medicine/CF/bicaridine/reaction_mob(mob/living/M, method=INJECT, reac_volume, show_message = 1)
	if(iscarbon(M))
		if(M.stat == DEAD)
			show_message = 0
		if(method in list(SYRINGE_INJECT, INJECT))
			M.adjustBruteLoss(-2.0*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/CF/bicaridine/overdose_process(mob/living/M)	
	M.adjustBruteLoss(2*REM, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1

//Kelotane (Burn Heal)
/datum/reagent/medicine/CF/Kelotane
	name = "Kelotane"
	description = "Advanced Burn Healing. Injection only, Scotty."
	reagent_state = LIQUID
	color = "C7fB34"
	metabolization_rate = 0.4
	overdose_threshold = 30 * REAGENTS_METABOLISM

/datum/reagent/medicine/CF/kelotane/reaction_mob(mob/living/M, method=INJECT, reac_volume, show_message = 1)
	if(iscarbon(M))
		if(M.stat == DEAD)
			show_message = 0
		if(method in list(SYRINGE_INJECT, INJECT))
			M.adjustBurnLoss(-2.0*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/CF/kelotane/overdose_process(mob/living/M)	
	M.adjustBurnLoss(2*REM, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1
		
//Anti-Toxin (Toxin Heal)
/datum/reagent/medicine/CF/antitoxin
	name = "Anti-Toxin"
	description = "Advanced Toxin Healing. Injection only, Scotty."
	reagent_state = LIQUID
	color = "33B20C"
	metabolization_rate = 0.4
	overdose_threshold = 30 * REAGENTS_METABOLISM

/datum/reagent/medicine/CF/antitoxin/reaction_mob(mob/living/M, method=INJECT, reac_volume, show_message = 1)
	if(iscarbon(M))
		if(M.stat == DEAD)
			show_message = 0
		if(method in list(SYRINGE_INJECT, INJECT))
			M.adjustToxLoss(-2.0*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/CF/antitoxin/overdose_process(mob/living/M)	
	M.adjustToxLoss(2*REM, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1

//Tricordrazine (All-Heal)
/datum/reagent/medicine/CF/tricordrazine
	name = "Tricordrazine"
	description = "Advanced All-Heal. Injection only, Scotty."
	reagent_state = LIQUID
	color = "FDDA08"
	metabolization_rate = 0.4
	overdose_threshold = 40 * REAGENTS_METABOLISM

/datum/reagent/medicine/CF/tricordrazine/reaction_mob(mob/living/M, method=INJECT, reac_volume, show_message = 1)
	if(iscarbon(M))
		if(M.stat == DEAD)
			show_message = 0
		if(method in list(SYRINGE_INJECT, INJECT))
			M.adjustBruteLoss(-2.0*REM, 0)
			M.adjustBurnLoss(-2.0*REM, 0)
			M.adjustToxLoss(-2.0*REM, 0)
			M.adjustOxyLoss(-2.0*REM, 0)
	..()
	. = 1

/datum/reagent/medicine/CF/antitoxin/overdose_process(mob/living/M)	
	M.adjustBruteLoss(2.5*REM, FALSE, FALSE, BODYPART_ORGANIC)
	M.adjustBurnLoss(2.5*REM, FALSE, FALSE, BODYPART_ORGANIC)
	M.adjustToxLoss(2.5*REM, FALSE, FALSE, BODYPART_ORGANIC)
	M.adjustOxyLoss(2.5*REM, FALSE, FALSE, BODYPART_ORGANIC)
	..()
	. = 1

//End Trek Chems

//Charcoal (Toxin Heal / Chem Purge)
/datum/reagent/medicine/CF/charcoal
	name = "Charcoal"
	description = "Reduces toxin damage and purges the body of all chemical reagents, both good and bad."
	reagent_state = SOLID
	metabolization_rate = 0.2

/datum/reagent/medicine/CF/charcoal/reaction_mob(mob/living/M, method=INGEST, reac_volume, show_message = 1)
	if(iscarbon(M))
		if(M.stat == DEAD)
			show_message = 0
		if(method in list(PILL, INGEST))
			M.adjustToxLoss(-2.0*REM, 0)
			for(var/datum/reagent/R in M.reagents.reagent_list)
				M.reagents.remove_reagent(R.type, 0.5)
	..()
	return TRUE

//Synthflesh Re-add, combo brute/burn. Retains old recipe.
/datum/reagent/medicine/CF/instabitaluri
	name = "Synthflesh (Instabitaluri)"
	description = "Has a 100% chance of instantly healing brute and burn damage at the cost of toxicity (75% of damage healed). Touch application only."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/medicine/CF/instabitaluri/reaction_mob(mob/living/M, method=TOUCH, reac_volume,show_message = 1)
	if(iscarbon(M))
		var/mob/living/carbon/Carbies = M
		if (Carbies.stat == DEAD)
			show_message = 0
		if(method in list(PATCH, TOUCH))
			var/harmies = min(Carbies.getBruteLoss(),Carbies.adjustBruteLoss(-1.25 * reac_volume)*-1)
			var/burnies = min(Carbies.getFireLoss(),Carbies.adjustFireLoss(-1.25 * reac_volume)*-1)
			Carbies.adjustToxLoss((harmies+burnies)*0.75)
			if(show_message)
				to_chat(Carbies, "<span class='danger'>You feel your burns and bruises healing! It stings like hell!</span>")
			SEND_SIGNAL(Carbies, COMSIG_ADD_MOOD_EVENT, "painful_medicine", /datum/mood_event/painful_medicine)
	..()
	return TRUE

//Perfluorodecalin Re-add (Oxy Heal) Retains old recipe
//**Commented-out as Convermol is just Perfluorodecalin with a new name**
/*/datum/reagent/medicine/CF/perfluorodecalin
	name = "Perfuorodecalin"
	description = "Converts 5u of Suffocation damage to 2u of Toxin damage per tick, also gives 0.2u of Toxin damage per tick."
	reagent_state = LIQUID
	color = "9A1000"
	metabolization_rate = 0.1
	overdose_threshold = 35

/datum/reagent/medicine/CF/perfluorodecalin/on_mob_life(mob/living/carbon/human/M)
	if(iscarbon(M))
		for(OXYLOSS >= 5)
			M.adjustOxyLoss(-5.0*REM, 0)
			M.adjustToxLoss(2.0*REM, 0)
			M.adjustToxLoss(0.2*REM, 0)
		for(OXYLOSS < 5)
			M.adjustOxyLoss(-5.0*REM, 0)
			M.adjustToxLoss((OXYLOSS/2.5)*REM, 0)
			M.adjustToxLoss(0.2*REM, 0)
	..()
	return TRUE

/datum/reagent/medicine/CF/perfluorodecalin/overdose_process(mob/living/M)
	if(iscarbon(M))
		for(OXYLOSS >= 5)
			M.adjustOxyLoss(-5.0*REM, 0)
			M.adjustToxLoss(2.0*REM, 0)
			M.adjustToxLoss(1*REM, 0)
		for(OXYLOSS < 5)
			M.adjustOxyLoss(-5.0*REM, 0)
			M.adjustToxLoss((OXYLOSS/2.5)*REM, 0)
			M.adjustToxLoss(1*REM, 0)
	..()
	return TRUE
*/

/datum/reagent/medicine/CF/trekamol
	name = "Trekamol"
	description = "A space-worthy activator for advanced chemicals."
