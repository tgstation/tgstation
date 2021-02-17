/datum/reagent/drug
	name = "Drug"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	var/trippy = TRUE //Does this drug make you trip?

/datum/reagent/drug/on_mob_end_metabolize(mob/living/M)
	if(trippy)
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "[type]_high")

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 30
	ph = 9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/hallucinogens = 10) //4 per 2 seconds

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(15)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED))
			if(prob(10))
				step(M, pick(GLOB.cardinals))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/space_drugs/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You start tripping hard!</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)

/datum/reagent/drug/space_drugs/overdose_process(mob/living/M)
	if(M.hallucination < volume && prob(20))
		M.hallucination += 5
	..()

/datum/reagent/drug/nicotine
	name = "Nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "smoke"
	trippy = FALSE
	overdose_threshold=15
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	ph = 8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

	//Nicotine is used as a pesticide IRL.
/datum/reagent/drug/nicotine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(type, 1))
		mytray.adjustToxic(round(chems.get_reagent_amount(type)))
		mytray.adjustPests(-rand(1,2))

/datum/reagent/drug/nicotine/on_mob_life(mob/living/carbon/M)
	if(prob(1))
		var/smoke_message = pick("You feel relaxed.", "You feel calmed.","You feel alert.","You feel rugged.")
		to_chat(M, "<span class='notice'>[smoke_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "smoked", /datum/mood_event/smoked, name)
	M.AdjustStun(-5)
	M.AdjustKnockdown(-5)
	M.AdjustUnconscious(-5)
	M.AdjustParalyzed(-5)
	M.AdjustImmobilized(-5)
	..()
	. = 1

/datum/reagent/drug/nicotine/overdose_process(mob/living/M)
	M.adjustToxLoss(0.1*REM, 0)
	M.adjustOxyLoss(1.1*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank
	name = "Crank"
	description = "Reduces stun times by about 200%. If overdosed it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#FA00C8"
	overdose_threshold = 20
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 14) //5.6 per 2 seconds

/datum/reagent/drug/crank/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		var/high_message = pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")
		to_chat(M, "<span class='notice'>[high_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "tweaking", /datum/mood_event/stimulant_medium, name)
	M.AdjustStun(-20)
	M.AdjustKnockdown(-20)
	M.AdjustUnconscious(-20)
	M.AdjustImmobilized(-20)
	M.AdjustParalyzed(-20)
	..()
	. = 1
/datum/reagent/drug/krokodil
	name = "Krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage."
	reagent_state = LIQUID
	color = "#0064B4"
	overdose_threshold = 20
	ph = 9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opiods = 18) //7.2 per 2 seconds


/datum/reagent/drug/krokodil/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "smacked out", /datum/mood_event/narcotic_heavy, name)
	if(current_cycle == 35 && creation_purity <= 0.6)
		if(!istype(M.dna.species, /datum/species/krokodil_addict))
			to_chat(M, "<span class='userdanger'>Your skin falls off easily!</span>")
			M.adjustBruteLoss(50*REM, 0) // holy shit your skin just FELL THE FUCK OFF
			M.set_species(/datum/species/krokodil_addict)
	..()

/datum/reagent/drug/krokodil/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25*REM)
	M.adjustToxLoss(0.25*REM, 0)
	..()
	. = 1



/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	description = "Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 20
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	ph = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 12) //4.8 per 2 seconds

/datum/reagent/drug/methamphetamine/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)

/datum/reagent/drug/methamphetamine/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/methamphetamine)
	..()

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "tweaking", /datum/mood_event/stimulant_medium, name)
	M.AdjustStun(-40)
	M.AdjustKnockdown(-40)
	M.AdjustUnconscious(-40)
	M.AdjustParalyzed(-40)
	M.AdjustImmobilized(-40)
	M.adjustStaminaLoss(-2, 0)
	M.Jitter(2)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(1,4))
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	..()
	. = 1

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/M)
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i in 1 to 4)
			step(M, pick(GLOB.cardinals))
	if(prob(20))
		M.emote("laugh")
	if(prob(33))
		M.visible_message("<span class='danger'>[M]'s hands flip out and flail everywhere!</span>")
		M.drop_all_held_items()
	..()
	M.adjustToxLoss(1, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	. = 1
/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	description = "Makes you impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 20
	taste_description = "salt" // because they're bathsalts?
	addiction_types = list(/datum/addiction/stimulants = 25)  //8 per 2 seconds
	var/datum/brain_trauma/special/psychotic_brawling/bath_salts/rage
	ph = 8.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/drug/bath_salts/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		rage = new()
		C.gain_trauma(rage, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/reagent/drug/bath_salts/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	if(rage)
		QDEL_NULL(rage)
	..()

/datum/reagent/drug/bath_salts/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "salted", /datum/mood_event/stimulant_heavy, name)
	M.adjustStaminaLoss(-5, 0)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 4)
	M.hallucination += 5
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		step(M, pick(GLOB.cardinals))
		step(M, pick(GLOB.cardinals))
	..()
	. = 1

/datum/reagent/drug/bath_salts/overdose_process(mob/living/M)
	M.hallucination += 5
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !ismovable(M.loc))
		for(var/i in 1 to 8)
			step(M, pick(GLOB.cardinals))
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	if(prob(33))
		M.drop_all_held_items()
	..()

/datum/reagent/drug/aranesp
	name = "Aranesp"
	description = "Amps you up, gets you going, and rapidly restores stamina damage. Side effects include breathlessness and toxicity."
	reagent_state = LIQUID
	color = "#78FFF0"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 8)

/datum/reagent/drug/aranesp/on_mob_life(mob/living/carbon/M)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.adjustStaminaLoss(-18, 0)
	M.adjustToxLoss(0.5, 0)
	if(prob(50))
		M.losebreath++
		M.adjustOxyLoss(1, 0)
	..()
	. = 1

/datum/reagent/drug/happiness
	name = "Happiness"
	description = "Fills you with ecstasic numbness and causes minor brain damage. Highly addictive. If overdosed causes sudden mood swings."
	reagent_state = LIQUID
	color = "#EE35FF"
	overdose_threshold = 20
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	taste_description = "paint thinner"
	addiction_types = list(/datum/addiction/hallucinogens = 18)

/datum/reagent/drug/happiness/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug)

/datum/reagent/drug/happiness/on_mob_delete(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_FEARLESS, type)
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, "happiness_drug")
	..()

/datum/reagent/drug/happiness/on_mob_life(mob/living/carbon/M)
	M.jitteriness = 0
	M.set_confusion(0)
	M.disgust = 0
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.2)
	..()
	. = 1

/datum/reagent/drug/happiness/overdose_process(mob/living/M)
	if(prob(30))
		var/reaction = rand(1,3)
		switch(reaction)
			if(1)
				M.emote("laugh")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_good_od)
			if(2)
				M.emote("sway")
				M.Dizzy(25)
			if(3)
				M.emote("frown")
				SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "happiness_drug", /datum/mood_event/happiness_drug_bad_od)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5)
	..()
	. = 1

/datum/reagent/drug/pumpup
	name = "Pump-Up"
	description = "Take on the world! A fast acting, hard hitting drug that pushes the limit on what you can handle."
	reagent_state = LIQUID
	color = "#e38e44"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 6) //2.6 per 2 seconds

/datum/reagent/drug/pumpup/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_STUNRESISTANCE, type)

/datum/reagent/drug/pumpup/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNRESISTANCE, type)
	..()

/datum/reagent/drug/pumpup/on_mob_life(mob/living/carbon/M)
	M.Jitter(5)

	if(prob(5))
		to_chat(M, "<span class='notice'>[pick("Go! Go! GO!", "You feel ready...", "You feel invincible...")]</span>")
	if(prob(15))
		M.losebreath++
		M.adjustToxLoss(2, 0)
	..()
	. = 1

/datum/reagent/drug/pumpup/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You can't stop shaking, your heart beats faster and faster...</span>")

/datum/reagent/drug/pumpup/overdose_process(mob/living/M)
	M.Jitter(5)
	if(prob(5))
		M.drop_all_held_items()
	if(prob(15))
		M.emote(pick("twitch","drool"))
	if(prob(20))
		M.losebreath++
		M.adjustStaminaLoss(4, 0)
	if(prob(15))
		M.adjustToxLoss(2, 0)
	..()

/datum/reagent/drug/maint
	name = "Maintenance Drugs"
	chemical_flags = NONE

/datum/reagent/drug/maint/powder
	name = "Maintenance Powder"
	description = "An unknown powder that you most likely gotten from an assistant, a bored chemist... or cooked yourself. It is a refined form of tar that enhances your mental ability, making you learn stuff a lot faster."
	reagent_state = SOLID
	color = "#ffffff"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 14)

/datum/reagent/drug/maint/powder/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN,0.1)
	// 5x if you want to OD, you can potentially go higher, but good luck managing the brain damage.
	var/amt = max(1,round(volume/3,0.1))
	M?.mind?.experience_multiplier_reasons |= type
	M?.mind?.experience_multiplier_reasons[type] = amt

/datum/reagent/drug/maint/powder/on_mob_end_metabolize(mob/living/M)
	. = ..()
	M?.mind?.experience_multiplier_reasons[type] = null
	M?.mind?.experience_multiplier_reasons -= type

/datum/reagent/drug/maint/powder/overdose_process(mob/living/M)
	. = ..()
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN,3)

/datum/reagent/drug/maint/sludge
	name = "Maintenance Sludge"
	description = "An unknown sludge that you most likely gotten from an assistant, a bored chemist... or cooked yourself. Half refined, it fills your body with itself, making it more resistant to wounds, but causes toxins to accumulate."
	reagent_state = LIQUID
	color = "#203d2c"
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 25
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 8)

/datum/reagent/drug/maint/sludge/on_mob_metabolize(mob/living/L)

	. = ..()
	ADD_TRAIT(L,TRAIT_HARDLY_WOUNDED,type)

/datum/reagent/drug/maint/sludge/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjustToxLoss(0.5)

/datum/reagent/drug/maint/sludge/on_mob_end_metabolize(mob/living/M)
	. = ..()
	REMOVE_TRAIT(M,TRAIT_HARDLY_WOUNDED,type)

/datum/reagent/drug/maint/sludge/overdose_process(mob/living/M)
	. = ..()
	if(!iscarbon(M))
		return
	var/mob/living/carbon/carbie = M
	//You will be vomiting so the damage is really for a few ticks before you flush it out of your system
	carbie.adjustToxLoss(1)
	if(prob(10))
		carbie.adjustToxLoss(5)
		carbie.vomit()

/datum/reagent/drug/maint/tar
	name = "Maintenance Tar"
	description = "An unknown tar that you most likely gotten from an assistant, a bored chemist... or cooked yourself. Raw tar, straight from the floor. It can help you with escaping bad situations at the cost of liver damage."
	reagent_state = LIQUID
	color = "#000000"
	overdose_threshold = 30
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/maintenance_drugs = 5)

/datum/reagent/drug/maint/tar/on_mob_life(mob/living/carbon/M)
	. = ..()

	M.AdjustStun(-10)
	M.AdjustKnockdown(-10)
	M.AdjustUnconscious(-10)
	M.AdjustParalyzed(-10)
	M.AdjustImmobilized(-10)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER,1.5)

/datum/reagent/drug/maint/tar/overdose_process(mob/living/M)
	. = ..()

	M.adjustToxLoss(5)
	M.adjustOrganLoss(ORGAN_SLOT_LIVER,3)
