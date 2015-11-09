

/datum/reagent/drug
	name = "Drug"
	id = "drug"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	synth_cost = 3
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
//	overdose_threshold = 25

/datum/reagent/drug/space_drugs/on_mob_life(var/mob/living/M as mob)
	M.druggy = max(M.druggy, 15)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove)
			if(prob(10)) step(M, pick(cardinal))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()
	return

/datum/reagent/drug/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	synth_cost = 5
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	color = "#202040" // rgb: 20, 20, 40
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/serotrotium/on_mob_life(var/mob/living/M as mob)
	if(ishuman(M))
		if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
	..()
	return
/*
/datum/reagent/drug/space_drugs/overdose_process(var/mob/living/M as mob)
	if(prob(20))
		M.hallucination = max(M.hallucination, 5)
	M.adjustBrainLoss(0.25*REM)
	M.adjustToxLoss(0.25*REM)
	..()
	return
*/
/datum/reagent/drug/nicotine
	name = "Nicotine"
	id = "nicotine"
	synth_cost = 2
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	addiction_threshold = 30 //What, no addiction_act defined?

/datum/reagent/drug/nicotine/on_mob_life(var/mob/living/M as mob)
	var/smoke_message = pick("You feel relaxed.", "You feel calmed.", "You feel the money you wasted.", "You feel like a space cowboy.", "You feel rugged.")
	if(prob(5))
		M << "<span class='notice'>[smoke_message]</span>"
	M.AdjustStunned(-1)
	M.adjustStaminaLoss(-0.5*REM)
	..()

/datum/reagent/drug/crank
	name = "Crank"
	id = "crank"
	synth_cost = 10
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_threshold = 10

/datum/reagent/drug/crank/on_mob_life(var/mob/living/M as mob)
	var/high_message = pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	..()

/datum/reagent/drug/crank/overdose_process(var/mob/living/M as mob)
	M.adjustBrainLoss(2*REM)
	M.adjustToxLoss(2*REM)
	M.adjustBruteLoss(2*REM)
	..()

/datum/reagent/drug/crank/addiction_act_stage1(var/mob/living/M as mob)
	M.adjustBrainLoss(5*REM)
	..()

/datum/reagent/drug/crank/addiction_act_stage2(var/mob/living/M as mob)
	M.adjustToxLoss(5*REM)
	..()

/datum/reagent/drug/crank/addiction_act_stage3(var/mob/living/M as mob)
	M.adjustBruteLoss(5*REM)
	..()

/datum/reagent/drug/crank/addiction_act_stage4(var/mob/living/M as mob)
	M.adjustBrainLoss(5*REM)
	M.adjustToxLoss(5*REM)
	M.adjustBruteLoss(5*REM)
	..()

/datum/reagent/drug/krokodil
	name = "Krokodil"
	id = "krokodil"
	synth_cost = 15
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage. If addicted it will begin to deal fatal amounts of Brute damage as the subject's skin falls off."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_threshold = 15


/datum/reagent/drug/krokodil/on_mob_life(var/mob/living/M as mob)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	..()
	return

/datum/reagent/drug/krokodil/overdose_process(var/mob/living/M as mob)
	M.adjustBrainLoss(0.25*REM)
	M.adjustToxLoss(0.25*REM)
	..()
	return


/datum/reagent/drug/krokodil/addiction_act_stage1(var/mob/living/M as mob)
	M.adjustBrainLoss(2*REM)
	M.adjustToxLoss(2*REM)
	..()
	return
/datum/reagent/krokodil/addiction_act_stage2(var/mob/living/M as mob)
	if(prob(25))
		M << "<span class='danger'>Your skin feels loose...</span>"
	..()
	return
/datum/reagent/drug/krokodil/addiction_act_stage3(var/mob/living/M as mob)
	if(prob(25))
		M << "<span class='danger'>Your skin starts to peel away...</span>"
	M.adjustBruteLoss(3*REM)
	..()
	return

/datum/reagent/drug/krokodil/addiction_act_stage4(var/mob/living/carbon/human/M as mob)
	if(!istype(M.dna.species, /datum/species/skeleton))
		M << "<span class='userdanger'>Your skin falls off easily!</span>"
		M.adjustBruteLoss(rand(50,80)*REM) // holy shit your skin just FELL THE FUCK OFF
		hardset_dna(M, null, null, null, null, /datum/species/skeleton)
	else
		M.adjustBruteLoss(5*REM)
	..()
	return

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	id = "methamphetamine"
	synth_cost = 10
	description = "Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_threshold = 10
	metabolization_rate = 0.75 * REAGENTS_METABOLISM

/datum/reagent/drug/methamphetamine/on_mob_life(var/mob/living/M as mob)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.AdjustParalysis(-2)
	M.AdjustStunned(-2)
	M.AdjustWeakened(-2)
	M.adjustStaminaLoss(-2)
	M.status_flags |= GOTTAGOREALLYFAST
	M.Jitter(2)
	M.adjustBrainLoss(0.25)
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	..()
	return

/datum/reagent/drug/methamphetamine/overdose_process(var/mob/living/M as mob)
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 4, i++)
			step(M, pick(cardinal))
	if(prob(20))
		M.emote("laugh")
	if(prob(33))
		M.visible_message("<span class = 'danger'>[M]'s hands flip out and flail everywhere!</span>")
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
	..()
	M.adjustToxLoss(1)
	M.adjustBrainLoss(pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	return

/datum/reagent/drug/methamphetamine/addiction_act_stage1(var/mob/living/M as mob)
	M.Jitter(5)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/drug/methamphetamine/addiction_act_stage2(var/mob/living/M as mob)
	M.Jitter(10)
	M.Dizzy(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/drug/methamphetamine/addiction_act_stage3(var/mob/living/M as mob)
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 4, i++)
			step(M, pick(cardinal))
	M.Jitter(15)
	M.Dizzy(15)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/drug/methamphetamine/addiction_act_stage4(var/mob/living/carbon/human/M as mob)
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	M.Jitter(20)
	M.Dizzy(20)
	M.adjustToxLoss(5)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	return

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	id = "bath_salts"
	synth_cost = 17
	description = "Makes you nearly impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_threshold = 10


/datum/reagent/drug/bath_salts/on_mob_life(var/mob/living/M as mob)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.AdjustParalysis(-3)
	M.AdjustStunned(-3)
	M.AdjustWeakened(-3)
	M.adjustStaminaLoss(-5)
	M.adjustBrainLoss(0.5)
	M.adjustToxLoss(0.1)
	M.hallucination += 2
	if(M.canmove && !istype(M.loc, /atom/movable))
		step(M, pick(cardinal))
		step(M, pick(cardinal))
	..()
	return

/datum/reagent/drug/bath_salts/overdose_process(var/mob/living/M as mob)
	M.hallucination += 2
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
	..()
	return

/datum/reagent/drug/bath_salts/addiction_act_stage1(var/mob/living/M as mob)
	M.hallucination += 10
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	M.Jitter(5)
	M.adjustBrainLoss(10)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/drug/bath_salts/addiction_act_stage2(var/mob/living/M as mob)
	M.hallucination += 20
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	M.Jitter(10)
	M.Dizzy(10)
	M.adjustBrainLoss(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/drug/bath_salts/addiction_act_stage3(var/mob/living/M as mob)
	M.hallucination += 30
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 12, i++)
			step(M, pick(cardinal))
	M.Jitter(15)
	M.Dizzy(15)
	M.adjustBrainLoss(10)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/drug/bath_salts/addiction_act_stage4(var/mob/living/carbon/human/M as mob)
	M.hallucination += 40
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 16, i++)
			step(M, pick(cardinal))
	M.Jitter(50)
	M.Dizzy(50)
	M.adjustToxLoss(5)
	M.adjustBrainLoss(10)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	return

/datum/reagent/drug/aranesp
	name = "Aranesp"
	id = "aranesp"
	synth_cost = 10
	description = "Amps you up and gets you going, fixes all stamina damage you might have but can cause toxin and oxygen damage.."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/reagent/drug/aranesp/on_mob_life(var/mob/living/M as mob)
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.adjustStaminaLoss(-18)
	M.adjustToxLoss(0.5)
	if(prob(50))
		M.losebreath++
		M.adjustOxyLoss(1)
	..()
	return


/datum/reagent/drug/hotline //gotta get a grip
	name = "Hotline"
	id = "hotline"
	synth_cost = 50
	description = "It isn't just wrong. It's dead wrong."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 15
	addiction_threshold = 10

/datum/reagent/drug/hotline/on_mob_life(var/mob/living/M as mob)
	var/high_message = pick("You feel alert.", "You feel like you can see everything more clearly.", "You feel like you need to relax and examine your surroundings.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.druggy = max(M.druggy, 15)
	M.hallucination += 2
	M.adjustBrainLoss(0.2*REM)
	M.adjustBruteLoss(-0.2*REM)
	M.adjustFireLoss(-0.2*REM)
	M.status_flags |= GOTTAGOFAST
	M.adjustStaminaLoss(-3)
	..()
	return

/datum/reagent/drug/hotline/overdose_process(var/mob/living/M as mob)
	M.adjustBrainLoss(2*REM)
	M.adjustToxLoss(2*REM)
	M.adjustBruteLoss(2*REM)
	M.druggy = max(M.druggy, 30)
	M.hallucination += 3
	if(prob(5))
		M << pick("<span class = 'userdanger'>Your head feels like it's ripping apart!</span>","<span class = 'userdanger'>You wonder why the fuck did you decide to take [src.name].</span>","<span class = 'userdanger'>It hurts so bad!</span>","<span class = 'userdanger'>Please, end it now!</span>","<span class = 'userdanger'>Dear god please no it hurts!</span>")
	..()
	return

/datum/reagent/drug/hotline/addiction_act_stage1(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,10))
	M.hallucination += 10
	M.druggy = max(M.druggy, 30)
	..()
	return
/datum/reagent/drug/hotline/addiction_act_stage2(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,20))
	M.hallucination += 20
	M.druggy = max(M.druggy, 30)
	..()
	return
/datum/reagent/drug/hotline/addiction_act_stage3(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,30))
	M.hallucination += 30
	M.druggy = max(M.druggy, 30)
	..()
	return
/datum/reagent/drug/hotline/addiction_act_stage4(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,30))
	M.hallucination += 30
	M.druggy = max(M.druggy, 30)
	if(prob(1))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.visible_message("<span class = 'userdanger'>[M] clutches at their chest! It looks like they're having a heart attack!</span>")
			H.heart_attack = 1 // don't do drugs kids
	..()
	return

/datum/reagent/drug/happyhappy
	name = "Happy Happy"
	id = "2happy"
	synth_cost = 50
	description = "A powerful psychoactive drug that heals damage and temporarily shrivels your nerve endings, preventing you from feeling pain. it has some NASTY side effects..."
	reagent_state = LIQUID
	color = "#D4EBF2" // rgb: 212, 235, 242
	addiction_threshold = 1 //stupidly addictive, but powerful
	overdose_threshold = 5 //yep, that's right. Abused it, and Sweeney Todd goes to town on your DNA.

/datum/reagent/drug/happyhappy/on_mob_life(var/mob/living/M as mob)
	//Heals a bunch of stuff, makes you shaky
	M.adjustStaminaLoss(-20)
	M.adjustToxLoss(-10)
	M.adjustBruteLoss(-10)
	M.adjustFireLoss(-10)
	M.adjustCloneLoss(-10)
	M.adjustOxyLoss(-10)
	M.adjustBrainLoss(-5)
	M.AdjustWeakened(-5)
	M.AdjustStunned(-5)
	M.AdjustParalysis(-5)
	M.radiation = max(0,M.radiation - 3)
	M.dizziness = max(0, M.dizziness - 3) //Dizzy is a proc, not a var. You call Dizzy(ammount) to make someone Dizzy
	M.drowsyness = max(0, M.drowsyness - 3)
	M.confused = max(0, M.confused - 3)
	M.sleeping = 0
	M.Jitter(5)
	//You don't "feel pain", you can't even see your health
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.hal_screwyhud = 5
	..()

/datum/reagent/medicine/happyhappy/on_mob_delete(var/mob/living/M as mob)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.hal_screwyhud = 0
	..()

//No overdose since if you don't have this drug in your system you get fucked up by addiction.
//Bullshit, you get mutated now. Patch new body mutations once dismemberment gets here.
//copypasted from unstable, minus the good mutations, and with more chance to activate.
/datum/reagent/drug/happyhappy/overdose_process(var/mob/living/carbon/M as mob)
	if(!..())
		return
	if(holder.has_reagent("ryetalyn"))
		holder.remove_reagent("ryetalyn", 5*REM)
	if(!istype(M) || !M.dna)
		return  //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	else if(prob(15))
		randmuti(M)
		domutcheck(M, null)
		updateappearance(M)
	..()

/datum/reagent/drug/happyhappy/proc/disturbing_messages(var/mob/living/M as mob)
	if(prob(0.3*addiction_stage)) //0.3*10 == 3, 3% chance at addiction stage 1
		if(prob(66))
			M.say(pick("I'm going to CUT YOU!", "What was that?", "YOU SAY SOMETHING BITCH!?!!", "37, 37, 38, 38?, 37, 37, 38!, 37", "Kill...", "Kill?", "YES, THAT'S RIGHT MR NUBBINS!!", "The rain in spain causes everybody around me great pain... GREAT PAIN!!!"))
		else
			M.emote(pick("giggle", "cries", "moan", "pale", "aflap", "collapse"))

//Plenty of addiction though!
/datum/reagent/drug/happyhappy/addiction_act_stage1(var/mob/living/M as mob)
	disturbing_messages(M)
	M.adjustBrainLoss(2*REM)
	M.adjustToxLoss(2*REM)
	M.adjustBruteLoss(2*REM)
	..()

/datum/reagent/drug/happyhappy/addiction_act_stage2(var/mob/living/M as mob)
	disturbing_messages(M)
	M.adjustBrainLoss(3*REM)
	M.adjustToxLoss(3*REM)
	M.adjustBruteLoss(3*REM)
	..()

/datum/reagent/drug/happyhappy/addiction_act_stage3(var/mob/living/M as mob)
	disturbing_messages(M)
	M.adjustBrainLoss(4*REM)
	M.adjustToxLoss(4*REM)
	M.adjustBruteLoss(4*REM)
	..()

/datum/reagent/drug/happyhappy/addiction_act_stage4(var/mob/living/M as mob)
	disturbing_messages(M)
	M.adjustBrainLoss(5*REM)
	M.adjustToxLoss(5*REM)
	M.adjustBruteLoss(5*REM)

	if(prob(22))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			randmutb(C)
			if(prob(11))
				randmutb(C)

	..()
