// Category 2 medicines are medicines that have an ill effect regardless of volume/OD to dissuade doping. Mostly used as emergency chemicals OR to convert damage (and heal a bit in the process). The type is used to prompt borgs that the medicine is harmful.
/datum/reagent/medicine/C2
	harmful = TRUE

/******BRUTE******/
/*Suffix: -bital*/

/datum/reagent/medicine/C2/sanguibital
	name = "Sanguibital"
	description = "A unique medicine that heals bruises, scaling with the rate at which one is bleeding out. Dilates blood streams, increasing the amount of blood lost. Overdosing further increases blood loss."
	color = "#ECEC8D" // rgb: 236	236	141
	taste_description = "whatever vampires would eat"
	overdose_threshold = 35
	reagent_state = SOLID

/datum/reagent/medicine/C2/sanguibital/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.bleed_rate)
			H.adjustBruteLoss(-0.5*H.bleed_rate*REM)
			H.bleed_rate += 2
	..()
	return TRUE

/datum/reagent/medicine/C2/sanguibital/overdose_process(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.bleed_rate += 2
	..()
	return TRUE

/datum/reagent/medicine/C2/libital //messes with your liber
	name = "Libital"
	description = "A bruise reliever. Does minor liver damage."
	color = "#ECEC8D" // rgb: 236	236	141
	taste_description = "bitter with a hint of alcohol"
	reagent_state = SOLID

/datum/reagent/medicine/C2/libital/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1*REM)
	M.adjustBruteLoss(-1*REM)
	..()
	return TRUE

/******BURN******/
/*Suffix: -uri*/
/datum/reagent/medicine/C2/ichiyuri
	name = "Ichiyuri"
	description = "Used to treat serious burns. Prolonged exposure can cause burns to itch."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/resetting_probability = 0
	var/spammer = 0

/datum/reagent/medicine/C2/ichiyuri/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-2*REM)
	if(prob(resetting_probability) && !(M.restrained() || M.incapacitated()))
		if(spammer < world.time)
			to_chat(M,"<span class='warning'>You can't help but to itch the burn.</span>")
			spammer = world.time + (10 SECONDS)
		var/scab = rand(1,7)
		M.adjustBruteLoss(scab*REM)
		M.bleed(scab)
		resetting_probability = 0
	resetting_probability += (5*(current_cycle/10)) // 10 iterations = >51% to itch
	..()
	return TRUE

/datum/reagent/medicine/C2/aiuri
	name = "Aiuri"
	description = "Used to treat burns. Does minor eye damage."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/resetting_probability = 0
	var/message_cd = 0

/datum/reagent/medicine/C2/aiuri/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-0.5*REM)
	M.adjustOrganLoss(ORGAN_SLOT_EYES,1*REM)
	..()
	return TRUE

/******OXY******/
/*Suffix: -mol*/

/datum/reagent/medicine/C2/convermol
	name = "Convermol"
	description = "Restores oxygen deprivation while producing a lesser amount of toxic byproducts. Both scale with exposure to the drug and current amount of oxygen deprivation. Overdose causes toxic byproducts regardless of oxygen deprivation."
	reagent_state = LIQUID
	color = "#FF6464"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 35 // at least 2 full syringes +some, this stuff is nasty if left in for long

/datum/reagent/medicine/C2/convermol/on_mob_life(mob/living/carbon/human/M)
	var/oxycalc = 2.5*REM*current_cycle
	if(!overdosed)
		oxycalc = min(oxycalc,M.getOxyLoss()+(current_cycle*0.1)) //if NOT overdosing, we lower our toxdamage to only the damage we actually healed with a minimum of 0.1*current_cycle. IE if we only heal 10 oxygen damage but we COULD have healed 20, we will only take toxdamage for the 10. We would take the toxdamage for the extra 10 if we were overdosing.
	M.adjustOxyLoss(-oxycalc, 0)
	M.adjustToxLoss(oxycalc/2.5, 0)
	if(prob(current_cycle) && M.losebreath)
		M.losebreath--
	..()
	return TRUE

/datum/reagent/medicine/C2/convermol/overdose_process(mob/living/carbon/human/M)
	metabolization_rate += 1
	..()
	return TRUE

/datum/reagent/medicine/C2/tirimol
	name = "Tirimol"
	description = "An oxygen deprivation medication that causes fatigue. Prolonged exposure causes the patient to fall asleep once the medicine metabolizes."
	color = "#FF6464"
	var/drowsycd = 0

/datum/reagent/medicine/C2/tirimol/on_mob_life(mob/living/carbon/human/M)
	M.adjustOxyLoss(-1)
	M.adjustStaminaLoss(2)
	if(drowsycd && (world.time > drowsycd))
		M.drowsyness += 10
		drowsycd = world.time + (45 SECONDS)
	else if(!drowsycd)
		drowsycd = world.time + (15 SECONDS)
	..()
	return TRUE

/datum/reagent/medicine/C2/tirimol/on_mob_end_metabolize(mob/living/L)
	if(current_cycle > 20)
		L.Sleeping(200)
	..()

/******TOXIN******/
/*Suffix: -iver*/

#define FIZ_WEAKRATE	0.005

/datum/reagent/medicine/C2/fiziver //fiz = phys ok?
  name = "Fiziver"
  description = "An antitoxin that temporarily weakens the user, making them susceptible to other forms of damage. Weakness and toxin healing scales with exposure."
  overdose_threshold = 11 // Scales every damage so naturally quite abusable. Luckily the OD purges the chem which resets the damage mod *wink*
  var/reset_mods = 0 //amount, not bool

/datum/reagent/medicine/C2/fiziver/on_mob_life(mob/living/carbon/human/M)
	var/maths = FIZ_WEAKRATE * current_cycle
	reset_mods += maths
	var/datum/physiology/phis = M.physiology
	phis.brute_mod += maths
	phis.burn_mod += maths
	phis.oxy_mod += maths
	phis.stamina_mod += maths
	M.adjustToxLoss(round(reset_mods*-1000,0.01)) //Math is fun!
	..()
	return TRUE

/datum/reagent/medicine/C2/fiziver/on_mob_delete(mob/living/carbon/human/M)
	var/datum/physiology/phis = M.physiology
	phis.brute_mod = max(phis.brute_mod - reset_mods, 1)
	phis.burn_mod = max(phis.burn_mod - reset_mods, 1)
	phis.oxy_mod = max(phis.oxy_mod - reset_mods, 1)
	return ..()

/datum/reagent/medicine/C2/fiziver/overdose_process(mob/living/carbon/human/M)
	var/maths = reset_mods*3
	M.adjustBruteLoss(maths)
	M.adjustFireLoss(maths)
	M.adjustOxyLoss(maths)
	..()
	M.reagents.del_reagent(type)
	return TRUE

#undef FIZ_WEAKRATE

/datum/reagent/medicine/C2/multiver //made up chem, it's a PALLETTE cleanser hehe
	name = "Multiver"
	description = "An antitoxin that scales with the more unique medicines in the body as well as purges chems (including itself). Causes lung damage."

/datum/reagent/medicine/C2/multiver/on_mob_life(mob/living/carbon/human/M)
	var/medibonus = 0 //it will always have itself which makes it REALLY start @ 1
	for(var/r in M.reagents.reagent_list)
		var/datum/reagent/the_reagent = r
		if(istype(the_reagent, /datum/reagent/medicine))
			medibonus += 1
	M.adjustToxLoss(-0.5 * medibonus)
	M.adjustOrganLoss(ORGAN_SLOT_LUNGS, medibonus)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type, medibonus*0.5)
	..()
	return TRUE

/datum/reagent/medicine/C2/syriniver
	name = "Syriniver"
	description = "A potent antidote for intravenous use with a narrow therapeutic index, it is considered an active prodrug of musiver."
	reagent_state = LIQUID
	color = "#8CDF24" // heavy saturation to make the color blend better
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	overdose_threshold = 6
	var/conversion_amount

/datum/reagent/medicine/C2/syriniver/on_transfer(atom/A, method=INJECT, trans_volume)
	if(method != INJECT || !iscarbon(A))
		return
	var/mob/living/carbon/C = A
	if(trans_volume >= 0.6) //prevents cheesing with ultralow doses.
		C.adjustToxLoss(-1.5 * min(2, trans_volume) * REM, 0)	  //This is to promote iv pole use for that chemotherapy feel.
	var/obj/item/organ/liver/L = C.internal_organs_slot[ORGAN_SLOT_LIVER]
	if((L.organ_flags & ORGAN_FAILING) || !L)
		return
	conversion_amount = trans_volume * (min(100 -C.getOrganLoss(ORGAN_SLOT_LIVER), 80) / 100) //the more damaged the liver the worse we metabolize.
	C.reagents.remove_reagent(/datum/reagent/medicine/C2/syriniver, conversion_amount)
	C.reagents.add_reagent(/datum/reagent/medicine/C2/musiver, conversion_amount)
	..()

/datum/reagent/medicine/C2/syriniver/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.8)
	M.adjustToxLoss(-1*REM, 0)
	for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,1)

	..()
	. = 1

/datum/reagent/medicine/C2/syriniver/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5)
	M.adjust_disgust(3)
	M.reagents.add_reagent(/datum/reagent/medicine/C2/musiver, 0.225 * REM)
	..()
	. = 1

/datum/reagent/medicine/C2/musiver
	name = "Musiver"
	description = "The active metabolite of syriniver. Causes muscle weakness on overdose"
	reagent_state = LIQUID
	color = "#DFD54E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 25
	var/datum/brain_trauma/mild/muscle_weakness/U

/datum/reagent/medicine/C2/musiver/on_mob_life(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 0.1)
	M.adjustToxLoss(-1*REM, 0)
	for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,1)
	..()
	. = 1

/datum/reagent/medicine/C2/musiver/overdose_start(mob/living/carbon/M)
	U = new()
	M.gain_trauma(U, TRAUMA_RESILIENCE_ABSOLUTE)
	..()

/datum/reagent/medicine/C2/musiver/on_mob_delete(mob/living/carbon/M)
	if(U)
		QDEL_NULL(U)
	return ..()

/datum/reagent/medicine/C2/musiver/overdose_process(mob/living/carbon/M)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER, 1.5)
	M.adjust_disgust(3)
	..()
	. = 1

/******COMBOS******/
/*Suffix: Combo of healing, prob gonna get wack REAL fast*/
/datum/reagent/medicine/C2/instabitaluri
	name = "Synthflesh (Instabitaluri)"
	description = "Has a 100% chance of instantly healing brute and burn damage at the cost of toxicity (75% of damage healed). Touch application only."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/medicine/C2/instabitaluri/reaction_mob(mob/living/M, method=TOUCH, reac_volume,show_message = 1)
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

/******NICHE******/
//todo
