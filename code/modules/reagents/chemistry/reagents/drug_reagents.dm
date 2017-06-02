/datum/reagent/drug
	name = "Drug"
	id = "drug"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "bitterness"

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 30

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/M)
	M.set_drugginess(15)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if(M.canmove)
			if(prob(10)) step(M, pick(GLOB.cardinal))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/space_drugs/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You start tripping hard!</span>")


/datum/reagent/drug/space_drugs/overdose_process(mob/living/M)
	if(M.hallucination < volume && prob(20))
		M.hallucination += 5
	..()

/datum/reagent/drug/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	addiction_threshold = 30
	taste_description = "smoke"

/datum/reagent/drug/nicotine/on_mob_life(mob/living/M)
	if(prob(1))
		var/smoke_message = pick("You feel relaxed.", "You feel calmed.","You feel alert.","You feel rugged.")
		to_chat(M, "<span class='notice'>[smoke_message]</span>")
	M.AdjustParalysis(-1, 0)
	M.AdjustStunned(-1, 0)
	M.AdjustWeakened(-1, 0)
	M.adjustStaminaLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/menthol
	name = "Menthol"
	id = "menthol"
	description = "Tastes naturally minty, and imparts a very mild numbing sensation."
	taste_description = "mint"
	reagent_state = LIQUID
	color = "#80AF9C"

/datum/reagent/drug/crank
	name = "Crank"
	id = "crank"
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#FA00C8"
	overdose_threshold = 20
	addiction_threshold = 10

/datum/reagent/drug/crank/on_mob_life(mob/living/M)
	var/high_message = pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.AdjustParalysis(-1, 0)
	M.AdjustStunned(-1, 0)
	M.AdjustWeakened(-1, 0)
	..()
	. = 1

/datum/reagent/drug/crank/overdose_process(mob/living/M)
	M.adjustBrainLoss(2*REM)
	M.adjustToxLoss(2*REM, 0)
	M.adjustBruteLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage1(mob/living/M)
	M.adjustBrainLoss(5*REM)
	..()

/datum/reagent/drug/crank/addiction_act_stage2(mob/living/M)
	M.adjustToxLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage3(mob/living/M)
	M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage4(mob/living/M)
	M.adjustBrainLoss(5*REM)
	M.adjustToxLoss(5*REM, 0)
	M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/celeritate
	name = "Celeritate"
	id = "celeritate"
	description = "A chemical that is derived from Omega Cannibis, taking this will heal a lot of damage when low health, speed you up and lower the effects of stuns. Even injecting less than a unit will cause an addiction, overdose makes you hyper and take brain damage."
	reagent_state = LIQUID
	color = "#000080"
	overdose_threshold = 16
	addiction_threshold = 0.01 //Very addictive
	metabolization_rate = 0.75 * REAGENTS_METABOLISM //Taking the drug makes your body work faster, so it will metabolize more

/datum/reagent/drug/celeritate/on_mob_life(mob/living/M)
	M.status_flags |= GOTTAGOFAST
	if(prob(25)) // (i don't know how to math pls help me) 4 units on average until your healed, on average 7.2 seconds for -10 damage of the 3 basic damage types at 1.8 tick rate
		if (M.health < 70) //No, you need some regular medicine to get to 100 health
			M.adjustBruteLoss(-10*REM, 0)
			M.adjustFireLoss(-10*REM, 0)
			M.adjustToxLoss(-10*REM, 0)
			M.adjustBrainLoss(1*REM, 0) //Brain starts to deterirate from the speed for some reason
			M.Nutrition(-10) //Body uses nutriments to repair skin and process toxins
			M << "<span class='notice'>You feel your wounds repairing itself!</span>"
			user.visible_message("<span class='notice'>[user] wounds seems to nearly instantly repair itself!</span>") //Invisible healing is bad, fix with visual text
			if(M.has_reagent("mannitol", 1))
				M.reagents.remove_reagent("mannitol", 5) //Prevents using other medicines to counter the brain damage done by the effects of Celeritate, use medicines after the effects expire
	if(prob(5))
		M.AdjustParalysis(-2, 0)
		M.adjustStunned(-2, 0)
		M.adjustWeakened(-2, 0)
		M.adjustStaminaLoss(-5, 0)
		M << "<span class='notice'>You suddenly feel a surge of energy inside of you!</span>"
		M.visible_message("<span class='notice'>[user] looks much more energetic!</span>")

/datum/reagent/drug/celeritate/overdose_process(mob/living/M)
	M.status_flags |= GOTTAGOREALLYFAST
	if (prob(5))
		M << "<span class='warning'>You feel like you took to much of celeritate! </span>"

	if (prob(5))
		if (M.age < 101) //Don't want people to get instakilled from stage 4 addiction
			M.age += 3
			M << "<span class='notice'>Your body feels a lot older!</span>"
	if (prob(25)) //Keeps your health down
		if(M.health > 70)
			M.adjustBruteLoss(10)
			M.adjustFireLoss(10)
			M.adjustToxLoss(10)
	if (prob(5))
		M << "<span class='warning'>You feel your mind deteriate from old age!</span>"
		M.adjustBrainLoss(1 * M.age / 4)
	if (prob(5))
		M << "<span class='notice'>Your body feels a bit weird.</span>" //I have no idea what to put here
		M.adjustCloneLoss(1 * M.age / 4) //Your body is replicating DNA fast enough for the tiny errors to matter
/datum/reagent/drug/celeritate/addiction_act_stage1(mob/living/carbon/human/M)
	if (prob(10))
		M << "<span class='notice'>You feel a slight craving for some celeritate.</span>"

	if (prob(1))
		if(!M.has_dna())
			M << "<span class='notice'>Your body suddenly feels just like your old self.</span>"
			clean_dna() //Kills all mutations

/datum/reagent/celeritate/addiction_act_stage2(mob/living/carbon/human/M)
	if (prob(10))
		M << "<span class='notice'>Your body craves for some celeritate.</span>"
	if(!M.has_dna())
		if (prob(1))
			if (prob(80))
				M << "<span class='notice'>Your body suddenly feels just like your old self.</span>"
				dna.remove_all_mutations() //Kills all mutations
			if (prob(20))
				M << "<span class='notice'>Your body feels slightly different from before.</span>"
				/mob/living/carbon/proc/randmutg()

/datum/reagent/drug/celeritate/addiction_act_stage3(mob/living/carbon/human/M)
	if (prob(1))
		M << "<span class='notice'>Your body feels older than it used to be.</span>"
		M.age += 1
		M.adjustBrainLoss(5) //Your getting old, brain is rip
	if (prob(1))
		M << "<span class='notice'>Your body feels slightly different from before, some celeritate would really help you out</span>"
			randmutb()
	if (prob(1))
		M << "<span class='warning'>You suddenly throw up! Your body is aching in pain for celeritate!</span>"
			Vomit(2)

/datum/reagent/drug/celeritate/addiction_act_stage4(mob/living/carbon/human/M)
	if(prob(10))
		if (M.age < 101)
		M.age += 3
		M << "<span class='notice'>Your body feels much more older.</span>"
		user.visible_message("<span class='notice'>[user] suddenly looks much more older</span>")
	if (prob(8))
		M.adjustBrainLoss(1 * M.age / 4) //Brain damage can be fixed easily with mannitol
		M.adjustToxLoss(3)
		M.adjustBruteLoss(3)
		M << "<span class='warning'>You feel an awful pain inside of you, if only you could get some celeritate!</span>"
	if (prob(5))
		if (prob(33))
			randmutb()
			M << "<span class='warning'>Your body tries to adept to it's new disability!</span>"
		if (prob(33))
			randmutvg() //Impossible to get hulk or dwarfism this way
			M << "<span class='notice'>Your body tries to adapt to its new evolutionary advantage!</span>"
		if (prob(34)) //+1% is op
			clean_dna()
			M << "<span class='notce'>Your body suddenly feels like it's old self again!</span>"

/datum/reagent/drug/krokodil
	name = "Krokodil"
	id = "krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage. If addicted it will begin to deal fatal amounts of Brute damage as the subject's skin falls off."
	reagent_state = LIQUID
	color = "#0064B4"
	overdose_threshold = 20
	addiction_threshold = 15


/datum/reagent/drug/krokodil/on_mob_life(mob/living/M)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	..()

/datum/reagent/drug/krokodil/overdose_process(mob/living/M)
	M.adjustBrainLoss(0.25*REM)
	M.adjustToxLoss(0.25*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage1(mob/living/M)
	M.adjustBrainLoss(2*REM)
	M.adjustToxLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/krokodil/addiction_act_stage2(mob/living/M)
	if(prob(25))
		to_chat(M, "<span class='danger'>Your skin feels loose...</span>")
	..()

/datum/reagent/drug/krokodil/addiction_act_stage3(mob/living/M)
	if(prob(25))
		to_chat(M, "<span class='danger'>Your skin starts to peel away...</span>")
	M.adjustBruteLoss(3*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage4(mob/living/carbon/human/M)
	CHECK_DNA_AND_SPECIES(M)
	if(!istype(M.dna.species, /datum/species/krokodil_addict))
		to_chat(M, "<span class='userdanger'>Your skin falls off easily!</span>")
		M.adjustBruteLoss(50*REM, 0) // holy shit your skin just FELL THE FUCK OFF
		M.set_species(/datum/species/krokodil_addict)
	else
		M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	id = "methamphetamine"
	description = "Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 20
	addiction_threshold = 10
	metabolization_rate = 0.75 * REAGENTS_METABOLISM

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/M)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.AdjustParalysis(-2, 0)
	M.AdjustStunned(-2, 0)
	M.AdjustWeakened(-2, 0)
	M.adjustStaminaLoss(-2, 0)
	M.status_flags |= GOTTAGOREALLYFAST
	M.Jitter(2)
	M.adjustBrainLoss(0.25)
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	..()
	. = 1

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/M)
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i in 1 to 4)
			step(M, pick(GLOB.cardinal))
	if(prob(20))
		M.emote("laugh")
	if(prob(33))
		M.visible_message("<span class='danger'>[M]'s hands flip out and flail everywhere!</span>")
		var/obj/item/I = M.get_active_held_item()
		if(I)
			M.drop_item()
	..()
	M.adjustToxLoss(1, 0)
	M.adjustBrainLoss(pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	. = 1

/datum/reagent/drug/methamphetamine/addiction_act_stage1(mob/living/M)
	M.Jitter(5)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage2(mob/living/M)
	M.Jitter(10)
	M.Dizzy(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage3(mob/living/M)
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 4, i++)
			step(M, pick(GLOB.cardinal))
	M.Jitter(15)
	M.Dizzy(15)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage4(mob/living/carbon/human/M)
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinal))
	M.Jitter(20)
	M.Dizzy(20)
	M.adjustToxLoss(5, 0)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	id = "bath_salts"
	description = "Makes you nearly impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 20
	addiction_threshold = 10
	taste_description = "salt" // because they're bathsalts?


/datum/reagent/drug/bath_salts/on_mob_life(mob/living/M)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.AdjustParalysis(-3, 0)
	M.AdjustStunned(-3, 0)
	M.AdjustWeakened(-3, 0)
	M.adjustStaminaLoss(-5, 0)
	M.adjustBrainLoss(0.5)
	M.adjustToxLoss(0.1, 0)
	M.hallucination += 10
	if(M.canmove && !istype(M.loc, /atom/movable))
		step(M, pick(GLOB.cardinal))
		step(M, pick(GLOB.cardinal))
	..()
	. = 1

/datum/reagent/drug/bath_salts/overdose_process(mob/living/M)
	M.hallucination += 10
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i in 1 to 8)
			step(M, pick(GLOB.cardinal))
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	if(prob(33))
		var/obj/item/I = M.get_active_held_item()
		if(I)
			M.drop_item()
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage1(mob/living/M)
	M.hallucination += 10
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinal))
	M.Jitter(5)
	M.adjustBrainLoss(10)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage2(mob/living/M)
	M.hallucination += 20
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(GLOB.cardinal))
	M.Jitter(10)
	M.Dizzy(10)
	M.adjustBrainLoss(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage3(mob/living/M)
	M.hallucination += 30
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 12, i++)
			step(M, pick(GLOB.cardinal))
	M.Jitter(15)
	M.Dizzy(15)
	M.adjustBrainLoss(10)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage4(mob/living/carbon/human/M)
	M.hallucination += 40
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 16, i++)
			step(M, pick(GLOB.cardinal))
	M.Jitter(50)
	M.Dizzy(50)
	M.adjustToxLoss(5, 0)
	M.adjustBrainLoss(10)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/aranesp
	name = "Aranesp"
	id = "aranesp"
	description = "Amps you up and gets you going, fixes all stamina damage you might have but can cause toxin and oxygen damage.."
	reagent_state = LIQUID
	color = "#78FFF0"

/datum/reagent/drug/aranesp/on_mob_life(mob/living/M)
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
