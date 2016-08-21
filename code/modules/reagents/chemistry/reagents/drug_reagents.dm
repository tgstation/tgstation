/datum/reagent/drug
	name = "Drug"
	id = "drug"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/drug/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	description = "An illegal chemical compound used as drug."
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 30

/datum/reagent/drug/space_drugs/on_mob_life(mob/living/M)
	M.set_drugginess(15)
	if(isturf(M.loc) && !istype(M.loc, /turf/open/space))
		if(M.canmove)
			if(prob(10)) step(M, pick(cardinal))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/drug/space_drugs/overdose_start(mob/living/M)
	M << "<span class='userdanger'>You start tripping hard!</span>"


/datum/reagent/drug/space_drugs/overdose_process(mob/living/M)
	if(M.hallucination < volume && prob(20))
		M.hallucination += 5
	..()

/datum/reagent/drug/fartium
	name = "Fartium"
	id = "fartium"
	description = "A chemical compound that promotes concentrated production of gas in your groin area."
	color = "#8A4B08" // rgb: 138, 75, 8
	reagent_state = LIQUID
	overdose_threshold = 30
	addiction_threshold = 50

/datum/reagent/drug/fartium/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/butt/B = locate() in H.internal_organs
		if(prob(7))
			if(B)
				H.emote("fart")
			else
				H << "<span class='danger'>Your stomach rumbles as pressure builds up inside of you.</span>"
				H.adjustToxLoss(1*REM)
	..()
	return

/datum/reagent/drug/fartium/overdose_process(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/butt/B = locate() in H.internal_organs
		if(prob(9))
			if(B)
				H.emote("fart")
			else
				H << "<span class='danger'>Your stomach hurts a bit as pressure builds up inside of you.</span>"
				H.adjustToxLoss(2*REM)
	..()

/datum/reagent/drug/fartium/addiction_act_stage1(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/butt/B = locate() in H.internal_organs
		if(prob(11))
			if(B)
				H.emote("fart")
			else
				H << "<span class='danger'>Your stomach hurts as pressure builds up inside of you.</span>"
				H.adjustToxLoss(3*REM)
	..()

/datum/reagent/drug/fartium/addiction_act_stage2(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/butt/B = locate() in H.internal_organs
		if(prob(13))
			if(B)
				H.emote("fart")
			else
				H << "<span class='danger'>Your stomach hurts a lot as pressure builds up inside of you.</span>"
				H.adjustToxLoss(4*REM)
	..()

/datum/reagent/drug/fartium/addiction_act_stage3(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/butt/B = locate() in H.internal_organs
		if(prob(15))
			if(B)
				if(prob(2) && !B.loose) H.emote("superfart")
				else H.emote("fart")
			else
				H << "<span class='danger'>Your stomach hurts too much as pressure builds up inside of you.</span>"
				H.adjustToxLoss(5*REM)
	..()

/datum/reagent/drug/fartium/addiction_act_stage4(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/butt/B = locate() in H.internal_organs
		if(prob(15))
			if(B)
				if(prob(5) && !B.loose) H.emote("superfart")
				else H.emote("fart")
			else
				H << "<span class='danger'>Your stomach hurts too much as pressure builds up inside of you.</span>"
				H.adjustToxLoss(6*REM)
	..()

/datum/reagent/drug/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	addiction_threshold = 30

/datum/reagent/drug/nicotine/on_mob_life(mob/living/M)
	if(prob(1))
		var/smoke_message = pick("You feel relaxed.", "You feel calmed.","You feel alert.","You feel rugged.")
		M << "<span class='notice'>[smoke_message]</span>"
	M.AdjustParalysis(-1, 0)
	M.AdjustStunned(-1, 0)
	M.AdjustWeakened(-1, 0)
	M.adjustStaminaLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank
	name = "Crank"
	id = "crank"
	description = "Grants near-immunity to a single stun after about seven seconds as well as granting a minor speedboost. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#FA00C8"
	overdose_threshold = 20
	addiction_threshold = 10
	metabolization_rate = 0.75* REAGENTS_METABOLISM
	stun_threshold = 4
	stun_resist = 6
	speedboost = FAST

/datum/reagent/drug/crank/on_mob_life(mob/living/M)
	var/high_message = pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.adjustToxLoss(0.15*REM, 0)
	M.sleeping = max(0,M.sleeping - 2)
	M.Jitter(1)
	stun_resist_act(M)
	..()
	. = 1

/datum/reagent/drug/crank/overdose_process(mob/living/M)
	M.adjustBrainLoss(2*REM)
	M.adjustToxLoss(2*REM, 0)
	M.adjustBruteLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage1(mob/living/M)
	M.adjustBrainLoss(2*REM)
	..()

/datum/reagent/drug/crank/addiction_act_stage2(mob/living/M)
	M.adjustToxLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage3(mob/living/M)
	M.adjustBruteLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/drug/crank/addiction_act_stage4(mob/living/M)
	M.adjustBrainLoss(2*REM)
	M.adjustToxLoss(2*REM, 0)
	M.adjustBruteLoss(2*REM, 0)
	..()
	. = 1

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
		M << "<span class='notice'>[high_message]</span>"
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
		M << "<span class='danger'>Your skin feels loose...</span>"
	..()

/datum/reagent/drug/krokodil/addiction_act_stage3(mob/living/M)
	if(prob(25))
		M << "<span class='danger'>Your skin starts to peel away...</span>"
	M.adjustBruteLoss(3*REM, 0)
	..()
	. = 1

/datum/reagent/drug/krokodil/addiction_act_stage4(mob/living/carbon/human/M)
	CHECK_DNA_AND_SPECIES(M)
	if(!istype(M.dna.species, /datum/species/krokodil_addict))
		M << "<span class='userdanger'>Your skin falls off easily!</span>"
		M.adjustBruteLoss(50*REM, 0) // holy shit your skin just FELL THE FUCK OFF
		M.set_species(/datum/species/krokodil_addict)
	else
		M.adjustBruteLoss(5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	id = "methamphetamine"
	description = "Grants near-immunity to a single stun after 10 seconds, greatly speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of toxin damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#FAFAFA"
	overdose_threshold = 15
	addiction_threshold = 10
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	stun_threshold = 6
	stun_resist = 6
	speedboost = VERY_FAST

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/M)
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.Jitter(2)
	M.adjustBrainLoss(0.25)
	M.adjustToxLoss(0.6, 0)
	M.adjustStaminaLoss(-3)
	M.sleeping = max(0,M.sleeping - 2)
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	stun_resist_act(M)
	..()
	. = 1

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/M)
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 4, i++)
			step(M, pick(cardinal))
	if(prob(20))
		M.emote("laugh")
	if(prob(33))
		M.visible_message("<span class='danger'>[M]'s hands flip out and flail everywhere!</span>")
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
	stun_timer = max(0, stun_timer - 0.5)
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
			step(M, pick(cardinal))
	M.Jitter(15)
	M.Dizzy(15)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/drug/methamphetamine/addiction_act_stage4(mob/living/carbon/human/M)
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	M.Jitter(20)
	M.Dizzy(20)
	M.adjustToxLoss(2.5, 0)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	. = 1

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	id = "bath_salts"
	description = "Makes you nearly impervious to stuns, grants an extreme stamina regeneration and movement speed buff and lets you ignore slowdown completely, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 15
	addiction_threshold = 10
	stun_threshold = 2
	stun_resist = 12
	speedboost = VERY_FAST + IGNORE_SLOWDOWN


/datum/reagent/drug/bath_salts/on_mob_life(mob/living/M)
	var/high_message = pick("You feel your grip on reality loosening.", "You feel like your heart is beating out of control.", "You feel as if you're about to die.")
	if(prob(15))
		M << "<span class='notice'>[high_message]</span>"
	if(holder.has_reagent("synaptizine"))
		holder.remove_reagent("synaptizine", 5)
		M.hallucination += 5
	M.adjustBrainLoss(0.2)
	M.adjustStaminaLoss(-8)
	M.adjustToxLoss(0.6, 0)
	M.hallucination += 7.5
	M.sleeping = max(0,M.sleeping - 2)
	M.Jitter(4)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	if(M.canmove && !istype(M.loc, /atom/movable))
		step(M, pick(cardinal))
		step(M, pick(cardinal))
	stun_resist_act(M)
	..()
	. = 1

/datum/reagent/drug/bath_salts/overdose_process(mob/living/M)
	M.adjustToxLoss(0.8, 0)
	M.hallucination += 10
	M.set_drugginess(15)
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	if(prob(20))
		M.emote(pick("twitch","drool","moan","vomit","flip","scream"))
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
	stun_timer += 1
	..()
	. = 1

/datum/reagent/drug/bath_salts/addiction_act_stage1(mob/living/M)
	M.hallucination += 10
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	M.Jitter(5)
	M.adjustBrainLoss(10)
	if(prob(20))
		M.emote(pick("twitch","drool","moan","vomit","flip","scream"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage2(mob/living/M)
	M.hallucination += 20
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	M.Jitter(10)
	M.Dizzy(10)
	M.adjustBrainLoss(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan","vomit","flip","scream"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage3(mob/living/M)
	M.hallucination += 30
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 12, i++)
			step(M, pick(cardinal))
	M.Jitter(15)
	M.Dizzy(15)
	M.adjustBrainLoss(10)
	if(prob(40))
		M.emote(pick("twitch","drool","moan","vomit","flip","scream"))
	..()

/datum/reagent/drug/bath_salts/addiction_act_stage4(mob/living/carbon/human/M)
	M.hallucination += 40
	if(M.canmove && !istype(M.loc, /atom/movable))
		for(var/i = 0, i < 16, i++)
			step(M, pick(cardinal))
	M.Jitter(50)
	M.Dizzy(50)
	M.adjustToxLoss(3, 0)
	M.adjustBrainLoss(10)
	if(prob(50))
		M.emote(pick("twitch","drool","moan","vomit","flip","scream"))
	..()
	. = 1

/datum/reagent/drug/heroin
	name = "Heroin"
	id = "heroin"
	description = "An extremely advanced painkiller/narcotic. Heroin allows you to ignore all slowdown and grants you full immunity to stamina damage, but stuns are twice as effective against you. Mildly toxic. Overdosing will make you periodically fall asleep."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	overdose_threshold = 15
	addiction_threshold = 10
	speedboost = IGNORE_SLOWDOWN

/datum/reagent/drug/heroin/on_mob_life(mob/living/M)
	M.setStaminaLoss(0)
	if(M.stunned)
		M.AdjustStunned(0.5)
	if(M.weakened)
		M.AdjustWeakened(0.5)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = 5
	M.adjustToxLoss(0.3*REM, 0)
	M.adjustFireLoss(-0.5*REM, 0)
	M.adjustBruteLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/heroin/on_mob_delete(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/N = M
		N.hal_screwyhud = 0
	..()

/datum/reagent/drug/heroin/overdose_process(mob/living/M)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.Dizzy(2)
	if(prob(20))
		M.emote("yawn")
	if(prob(10) && !(M.sleeping))
		M.sleeping += 7
	..()
	. = 1

/datum/reagent/drug/heroin/addiction_act_stage1(mob/living/M)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.Dizzy(2)
		M.Jitter(2)
	..()
/datum/reagent/drug/heroin/addiction_act_stage2(mob/living/M)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(1*REM, 0)
		M.Dizzy(3)
		M.Jitter(3)
	..()
/datum/reagent/drug/heroin/addiction_act_stage3(mob/living/M)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(2*REM, 0)
		M.Dizzy(4)
		M.Jitter(4)
	M.drowsyness += 1
	..()
/datum/reagent/drug/heroin/addiction_act_stage4(mob/living/M)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(3*REM, 0)
		M.Dizzy(5)
		M.Jitter(5)
	M.drowsyness += 1
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
		M << "<span class='notice'>[high_message]</span>"
	M.adjustStaminaLoss(-18, 0)
	M.adjustToxLoss(0.5, 0)
	if(prob(50))
		M.losebreath++
		M.adjustOxyLoss(1, 0)
	..()
	. = 1
