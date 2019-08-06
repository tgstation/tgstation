// Category 2 medicines are medicines that have an ill effect regardless of volume/OD to dissuade doping. Mostly used as emergency chemicals OR to convert damage (and heal a bit in the process). The type is used to prompt borgs that the medicine is harmful.
/datum/reagent/medicine/C2
	harmful = TRUE

/******BRUTE******/

/datum/reagent/medicine/C2/arnica
	name = "Arnica"
	description = "A unique medicine that heals bruises, scaling with the rate at which one is bleeding out. Constricts blood streams, increasing the amount of blood lost. Overdosing further increases blood loss."
	color = "#ECEC8D" // rgb: 236	236	141
	taste_description = "wolf's bane"
	overdose_threshold = 35
	reagent_state = SOLID

/datum/reagent/medicine/C2/arnica/on_mob_life(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.bleed_rate)
			H.adjustBruteLoss(-0.5*H.bleed_rate*REM)
			H.bleed_rate += 2
	..()
	return TRUE

/datum/reagent/medicine/C2/arnica/overdose_process(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.bleed_rate += 2
	..()
	return TRUE

/datum/reagent/medicine/C2/acetaminophen
	name = "Acetaminophen"
	description = "A common pain reliever. Does minor liver damage."
	color = "#ECEC8D" // rgb: 236	236	141
	taste_description = "a common spacehold drug"
	reagent_state = SOLID

/datum/reagent/medicine/C2/acetaminophen/on_mob_life(mob/living/carbon/M)
	M.adjustLiverLoss(1*REM)
	M.adjustBruteLoss(-1*REM)
	..()
	return TRUE

/******BURN******/

/datum/reagent/medicine/C2/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	description = "Used to treat serious burns. Scales with prolonged exposure, but causes burns to itch as well."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/resetting_probability = 0
	var/spammer = 0

/datum/reagent/medicine/C2/silver_sulfadiazine/on_mob_life(mob/living/carbon/M)
	M.adjustFireLoss(-0.25*current_cycle*REM)
	if(prob(resetting_probability))
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

/datum/reagent/medicine/C2/neomycin_sulfate
	name = "Neomycin Sulfate"
	description = "Used to treat burns. Does minor eye damage."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/resetting_probability = 0
	var/message_cd = 0

/datum/reagent/medicine/C2/neomycin_sulfate/on_mob_life(mob/living/carbon/M)
	var/obj/item/organ/eyes/the_hills_have = M.getorganslot(ORGAN_SLOT_EYES)
	M.adjustFireLoss(-1*REM)
	the_hills_have?.applyOrganDamage(1)
	..()
	return TRUE

/******OXY******/
#define PERF_BASE_DAMAGE		0.5

/datum/reagent/medicine/C2/perfluorodecalin
	name = "Perfluorodecalin"
	description = "Restores oxygen deprivation while producing a lesser amount of toxic byproducts. Both scale with exposure to the drug and current amount of oxygen deprivation. Overdose causes toxic byproducts regardless of oxygen deprivation."
	reagent_state = LIQUID
	color = "#FF6464"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 35 // at least 2 full syringes +some, this stuff is nasty if left in for long

/datum/reagent/medicine/C2/perfluorodecalin/on_mob_life(mob/living/carbon/human/M)
	var/oxycalc = 2.5*REM*current_cycle
	if(!overdosed)
		oxycalc = min(oxycalc,M.getOxyLoss()+PERF_BASE_DAMAGE) //if NOT overdosing, we lower our toxdamage to only the damage we actually healed with a minimum of 0.5. IE if we only heal 10 oxygen damage but we COULD have healed 20, we will only take toxdamage for the 10. We would take the toxdamage for the extra 10 if we were overdosing.
	M.adjustOxyLoss(-oxycalc, 0)
	M.adjustToxLoss(oxycalc/2.5, 0)
	if(prob(current_cycle) && M.losebreath)
		M.losebreath--
	..()
	return TRUE

/datum/reagent/medicine/C2/perfluorodecalin/overdose_process(mob/living/carbon/human/M)
	metabolization_rate += 1
	..()
	return TRUE

#undef PERF_BASE_DAMAGE

/datum/reagent/medicine/C2/theophylline
	name = "Theophylline"
	description = "An oxygen deprivation medication that causes fatigue. Prolonged exposure causes the patient to fall asleep once the medicine metabolizes."
	color = "#FF6464"
	var/drowsycd = 0

/datum/reagent/medicine/C2/theophylline/on_mob_life(mob/living/carbon/human/M)
	M.adjustOxyLoss(-1)
	M.adjustStaminaLoss(2)
	if(drowsycd && (world.time > drowsycd))
		M.drowsyness += 10
		drowsycd = world.time + (45 SECONDS)
	else if(!drowsycd)
		drowsycd = world.time + (15 SECONDS)
	..()
	return TRUE

/datum/reagent/medicine/C2/theophylline/on_mob_end_metabolize(mob/living/L)
	if(current_cycle > 20)
		L.Sleeping(200)
	..()

/******TOXIN******/

#define CORTI_WEAKRATE	0.005

/datum/reagent/medicine/C2/corticoline //made up chem from Corticosteriods, used to treat POISON ivy wink wink
  name = "Corticoline"
  description = "An antitoxin that temporarily weakens the user, making them susceptible to other forms of damage. Weakness and toxin healing scales with exposure."
  overdose_threshold = 11 // Scales every damage so naturally quite abusable. Luckily the OD purges the chem which resets the damage mod *wink*
  var/reset_mods = 0 //amount, not bool

/datum/reagent/medicine/C2/corticoline/on_mob_life(mob/living/carbon/human/M)
	var/maths = CORTI_WEAKRATE * current_cycle
	reset_mods += maths
	var/datum/physiology/phis = M.physiology
	phis.brute_mod += maths
	phis.burn_mod += maths
	phis.oxy_mod += maths
	phis.stamina_mod += maths
	M.adjustToxLoss(round(reset_mods*-1000,0.01)) //Math is fun!
	..()
	return TRUE

/datum/reagent/medicine/C2/corticoline/on_mob_delete(mob/living/carbon/human/M)
	var/datum/physiology/phis = M.physiology
	phis.brute_mod = max(phis.brute_mod - reset_mods, 1)
	phis.burn_mod = max(phis.burn_mod - reset_mods, 1)
	phis.oxy_mod = max(phis.oxy_mod - reset_mods, 1)
	return ..()

/datum/reagent/medicine/C2/corticoline/overdose_process(mob/living/carbon/human/M)
	var/maths = reset_mods*3
	M.adjustBruteLoss(maths)
	M.adjustFireLoss(maths)
	M.adjustOxyLoss(maths)
	..()
	M.reagents.del_reagent(type)
	return TRUE

#undef CORTI_WEAKRATE

/datum/reagent/medicine/C2/palletta //made up chem, it's a PALLETTE cleanser hehe
	name = "Palletta"
	description = "An antitoxin that scales with the more chems in the body as well as purges chems (including itself). Causes loss of breath."

/datum/reagent/medicine/C2/palletta/on_mob_life(mob/living/carbon/human/M)
	var/total_v = 0
	for(var/r in M.reagents.reagent_list)
		var/datum/reagent/the_reagent = r
		total_v += the_reagent.volume
	M.adjustToxLoss(total_v*-0.1)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.type,R.volume*0.1)
		M.losebreath += total_v*0.1
	..()

/******COMBOS******/
/datum/reagent/medicine/C2/synthflesh
	name = "Synthflesh"
	description = "Has a 100% chance of instantly healing brute and burn damage at the cost of toxicity (75% of damage healed). Touch application only."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/medicine/C2/synthflesh/reaction_mob(mob/living/M, method=TOUCH, reac_volume,show_message = 1)
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
