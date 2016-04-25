

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

/datum/reagent/drug/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = rgb(0,0,0)
	overdose_threshold = 30

/datum/reagent/drug/nicotine/on_mob_life(mob/living/M)
	if(prob(1))
		var/smoke_message = pick("You feel relaxed.", "You feel calmed.","You feel alert.","You feel rugged.")
		M << "<span class='notice'>[smoke_message]</span>"
	if(prob(50))
		M.Jitter(5)
		M.AdjustStunned(-1, 0)
		M.AdjustParalysis(-1, 0)
		M.AdjustWeakened(-1, 0)
	M.adjustStaminaLoss(-0.5*REM, 0)
	..()
	. = 1

/datum/reagent/drug/nicotine/overdose_process(mob/living/M)
	if(prob(75))
		return
	var/effect = rand(1,7)
	switch(volume)
		if(1 to 49)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> looks nervous!</span>")
					M.confused += 15
					M.adjustToxLoss(2)
					M.Jitter(10)
					M.emote("twitch")
				if(4 to 6)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> is all sweaty!</span>")
					M.bodytemperature += rand(15,30)
					M.adjustToxLoss(3)
				if(7)
					M.adjustToxLoss(4)
					M.emote("twitch")
					M.Jitter(10)
		if(50 to INFINITY)
			switch(effect)
				if(1 to 3)
					M << "<span class = 'userdanger'>You can't breathe!</span>"
					M.emote("gasp")
					M.adjustOxyLoss(15)
					M.adjustToxLoss(3)
					M.Stun(1)
				if(4 to 6)
					M << "<span class = 'userdanger'>You feel terrible!</span>"
					M.emote("drool")
					M.Jitter(10)
					M.Weaken(1)
					M.confused += 33
				if(7)
					M.emote("collapse")
					M << "<span class = 'userdanger'>Your heart is pounding!</span>"
					M.Paralyse(5)
					M.Jitter(30)
					M.adjustToxLoss(6)
					M.adjustOxyLoss(20)
	..()

/datum/reagent/drug/crank
	name = "Crank"
	id = "crank"
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = rgb(250,0,200)
	overdose_threshold = 20
	addiction_threshold = 10

/datum/reagent/drug/crank/on_mob_life(mob/living/M)
	M.AdjustParalysis(-2, 0)
	M.AdjustStunned(-2, 0)
	M.AdjustWeakened(-2, 0, 0)
	if(prob(15))
		M.emote(pick("twitch", "twitch_s", "grumble", "laugh"))
	if(prob(8))
		M << "<span class = 'notice'><b>You feel great!</b></span>"
		M.reagents.add_reagent("methamphetamine", rand(1,2))
		M.emote(pick("laugh","giggle"))
	if(prob(6))
		M << "<span class = 'notice'><b>You feel warm.</b></span>"
		M.bodytemperature += rand(1,10)
	if(prob(4))
		M << "<span class = 'danger'><b>You feel kinda awful!</b></span>"
		M.adjustToxLoss(1)
		M.Jitter(30)
		M.emote(pick("groan","moan"))
	..()
	. = 1

/datum/reagent/drug/crank/overdose_process(mob/living/M)
	if(prob(75))
		return
	var/effect = rand(1,7)
	switch(volume)
		if(1 to 39)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> looks confused!</span>")
					M.confused += 20
					M.Jitter(20)
					M.emote("scream")
				if(4 to 6)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> is all sweaty!</span>")
					M.bodytemperature += rand(5,30)
					M.adjustToxLoss(1)
					M.adjustBrainLoss(1)
					M.Stun(2)
				if(7)
					M.emote("grumble")
					M.Jitter(30)
		if(40 to INFINITY)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> is sweating like a pig!</span>")
					M.bodytemperature += rand(20,100)
					M.adjustToxLoss(5)
					M.Stun(3)
				if(4 to 6)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> starts tweaking the hell out!</span>")
					M.emote("scream")
					M.adjustToxLoss(2)
					M.adjustBrainLoss(8)
					M.Jitter(100)
					M.Weaken(3)
					M.confused += 25
					M.ForceContractDisease(new /datum/disease/berserker(0))
				if(7)
					M.emote("scream")
					M.visible_message("<span class = 'danger'><b>[M.name]</b> nervously scratches at their skin!</span>")
					M.Jitter(10)
					M.adjustBruteLoss(5)
					M.emote("twitch")
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

/datum/reagent/drug/krokodil
	name = "Krokodil"
	id = "krokodil"
	description = "Cools and calms you down. If overdosed it will deal significant Brain and Toxin damage. If addicted it will begin to deal fatal amounts of Brute damage as the subject's skin falls off."
	reagent_state = LIQUID
	color = rgb(0,100,180)
	overdose_threshold = 20


/datum/reagent/drug/krokodil/on_mob_life(mob/living/M)
	M.Jitter(-40)
	if(prob(25))
		M.adjustBrainLoss(1)
	if(prob(15))
		M.emote(pick("smile", "grin", "yawn", "laugh", "drool"))
	if(prob(10))
		M << "<span class = 'notice'><b>You feel pretty chill.</b></span>"
		M.bodytemperature--
		M.emote("smile")
	if(prob(5))
		M << "<span class = 'danger'><b>You feel too chill!</b></span>"
		M.emote(pick("yawn","drool"))
		M.Stun(1)
		M.adjustToxLoss(1)
		M.adjustBrainLoss(1)
		M.bodytemperature -= 20
	if(prob(2))
		M << "<span class = 'danger'><b>Your skin feels all rough and dry.</b></span>"
		M.adjustBruteLoss(2)
	..()

/datum/reagent/drug/krokodil/overdose_process(mob/living/M)
	if(prob(75))
		return
	var/effect = rand(1,7)
	switch(volume)
		if(1 to 39)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> looks dazed!</span>")
					M.Stun(3)
					M.emote("drool")
				if(4 to 6)
					M.bodytemperature -= 40
					M.emote("shiver")
				if(7)
					M << "<span class = 'userdanger'>Your skin is cracking and bleeding!</span>"
					M.adjustBruteLoss(5)
					M.adjustToxLoss(2)
					M.adjustBrainLoss(1)
					M.emote("cry")
		if(40 to INFINITY)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> sways and falls over!</span>")
					M.adjustToxLoss(3)
					M.adjustBrainLoss(3)
					M.Weaken(8)
					M.emote("faint")
				if(4 to 6)
					M.visible_message("<span class = 'danger'><b>[M.name]'s</b> skin is rotting away!</span>")
					M.adjustBruteLoss(25)
					M.emote("scream")
					M.set_species(/datum/species/cosmetic_zombie)
					M.emote("faint")
				if(7)
					M.emote("shiver")
					M.bodytemperature -= 70
	..()
	. = 1

/datum/reagent/drug/methamphetamine
	name = "Methamphetamine"
	id = "methamphetamine"
	description = "Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = rgb(250,250,250)
	overdose_threshold = 20
	metabolization_rate = 0.6 * REAGENTS_METABOLISM

/datum/reagent/drug/methamphetamine/on_mob_life(mob/living/M)
	M.status_flags |= GOTTAGOREALLYFAST
	M.AdjustParalysis(-2.5, 0)
	M.AdjustStunned(-2.5, 0)
	M.AdjustWeakened(-2.5, 0, 0)
	M.adjustStaminaLoss(-2, 0)
	M.Jitter(5)
	if(prob(50))
		M.adjustBrainLoss(1)
	M.drowsyness = max(M.drowsyness-10, 0)
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	..()
	. = 1

/datum/reagent/drug/methamphetamine/overdose_process(mob/living/M)
	if(prob(75))
		return
	var/effect = rand(1,7)
	switch(volume)
		if(1 to 59)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> can't seem to control their legs!</span>") // i do meth
					M.Weaken(4) // so i can work longer
					M.confused += 20 // so i can earn more
				if(4 to 6) // so i can do more meth
					M.visible_message("<span class = 'danger'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>") // i do meth
					M.drop_item() // so i can work longer
				if(7) // so i can earn more
					M.emote("laugh") // so i can do more meth
		if(60 to INFINITY)
			M.reagents.add_reagent("triplemeth", 10)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
					M.drop_item()
				if(4 to 6)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> falls to the floor and flails uncontrollably!</span>")
					M.Weaken(10)
					M.Jitter(10)
				if(7)
					M.emote("laugh")
	..()
	. = 1

/datum/reagent/drug/triplemeth
	name = "Triple Meth"
	id = "triplemeth"
	description = "Holy shit."
	reagent_state = LIQUID
	color = rgb(250,250,250)
	overdose_threshold = 20
	metabolization_rate = 0.2 * REAGENTS_METABOLISM

/datum/reagent/drug/triplemeth/on_mob_life(mob/living/M)
	M.AdjustParalysis(-M.paralysis, 0)
	M.AdjustStunned(-M.stunned, 0)
	M.AdjustWeakened(-M.weakened, 0, 0)
	M.adjustStaminaLoss(-M.getStaminaLoss(), 0)
	M.Jitter(5)
	M.Dizzy(5)
	M.confused += 15
	M.adjustBrainLoss(1)
	M.overlay_fullscreen("triplemeth1", /obj/screen/fullscreen/triplemeth1)
	M.overlay_fullscreen("triplemeth2", /obj/screen/fullscreen/triplemeth2)
	M.overlay_fullscreen("triplemeth3", /obj/screen/fullscreen/triplemeth3)
	if(prob(50))
		M.emote(pick("twitch", "shiver"))
	..()
	. = 1

/datum/reagent/drug/triplemeth/overdose_process(mob/living/M)
	if(prob(75))
		return
	var/effect = rand(1,7)
	switch(volume)
		if(1 to 39)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> can't seem to control their legs!</span>") // i do meth
					M.Weaken(4) // so i can work longer
					M.confused += 12 // so i can earn more
				if(4 to 6) // so i can do more meth
					M.visible_message("<span class = 'danger'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>") // i do meth
					M.drop_item() // so i can work longer
				if(7) // so i can earn more
					M.emote("laugh") // so i can do more meth
		if(40 to INFINITY)
			M.reagents.add_reagent("triplemeth", 10)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]'s</b> hands flip out and flail everywhere!</span>")
					M.drop_item()
				if(4 to 6)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> falls to the floor and flails uncontrollably!</span>")
					M.Weaken(10)
					M.Jitter(10)
				if(7)
					M.emote("laugh")
	..()
	. = 1

/datum/reagent/drug/triplemeth/on_mob_delete(mob/living/M)
	M.clear_fullscreen("triplemeth1")
	M.clear_fullscreen("triplemeth2")
	M.clear_fullscreen("triplemeth3")
	..()

/datum/reagent/drug/bath_salts
	name = "Bath Salts"
	id = "bath_salts"
	description = "Makes you nearly impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_threshold = 10

/datum/reagent/drug/bath_salts/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == INGEST)
		M << "<span class = 'danger'><font face='[pick("Curlz MT", "Comic Sans MS")]' size='[rand(4,6)]'>You feel FUCKED UP!!!!!!</font></span>"
		M.playsound_local(M.loc, 'goon/sound/effects/heartbeat.ogg', 50, 1)
		M.emote("faint")
		M.radiation += 5
		M.adjustToxLoss(5)
		M.adjustBrainLoss(10)
	else
		M << "<span class = 'notice'>You feel a bit more salty than usual.</span>"
	return ..()

/datum/reagent/drug/bath_salts/on_mob_life(mob/living/M)
	var/check = rand(0,100)
	if(check < 8)
		M.visible_message("<span class = 'danger'><b>[M.name]</b> has a wild look in their eyes!</span>")
	if(check < 60)
		M.AdjustParalysis(-M.paralysis, 0)
		M.AdjustStunned(-M.stunned, 0)
		M.AdjustWeakened(-M.weakened, 0, 0)
		M.adjustStaminaLoss(-M.getStaminaLoss(), 0)
	if(check < 30)
		M.emote(pick("twitch", "twitch_s", "scream", "drool", "grumble", "mumble"))
	M.druggy = max(M.druggy, 15)
	if(check < 20)
		M.confused += 10
	M.adjustBrainLoss(0.5)
	M.adjustToxLoss(0.1, 0)
	M.hallucination += 10
	if(check < 8)
		M.reagents.add_reagent(pick("methamphetamine", "crank", "neurotoxin"), rand(1,5))
		M.visible_message("<span class = 'danger'><b>[M.name]</b> scratches at something under their skin!</span>")
		M.adjustBruteLoss(5)
	else if(check < 24)
		M << "<span class = 'danger'><b>They're coming for you!</b></span>"
	else if(check < 28)
		M << "<span class = 'userdanger'><b>THEY'RE GONNA GET YOU!</b></span>"
	..()
	. = 1

/datum/reagent/drug/bath_salts/overdose_process(mob/living/M)
	if(prob(75))
		return
	var/effect = rand(1,7)
	switch(volume)
		if(1 to 39)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> flails around like a lunatic!</span>")
					M.confused += 25
					M.Jitter(10)
					M.emote("scream")
					M.ForceContractDisease(new /datum/disease/berserker(0))
				if(4 to 6)
					M.visible_message("<span class = 'danger'><b>[M.name]'s</b> eyes dilate!</span>")
					M.bodytemperature += rand(5,30)
					M.adjustToxLoss(2)
					M.adjustBrainLoss(1)
					M.Stun(3)
					M.emote("twitch")
					M.blur_eyes(7)
					M.ForceContractDisease(new /datum/disease/berserker(0))
				if(7)
					M.emote("faint")
					M.ForceContractDisease(new /datum/disease/berserker(0))
		if(40 to INFINITY)
			switch(effect)
				if(1 to 3)
					M.visible_message("<span class = 'danger'><b>[M.name]'s</b> eyes dilate!</span>")
					M.bodytemperature += rand(5,30)
					M.adjustToxLoss(2)
					M.adjustBrainLoss(1)
					M.Stun(3)
					M.emote("twitch")
					M.blur_eyes(7)
					M.ForceContractDisease(new /datum/disease/berserker(0))
				if(4 to 6)
					M.visible_message("<span class = 'danger'><b>[M.name]</b> convulses violently and falls to the floor!</span>")
					M.emote("gasp")
					M.adjustToxLoss(2)
					M.adjustBrainLoss(1)
					M.Jitter(50)
					M.Weaken(8)
					M.ForceContractDisease(new /datum/disease/berserker(0))
				if(7)
					M.emote("scream")
					M.visible_message("<span class = 'danger'><b>[M.name]</b> tears at their own skin!</span>")
					M.adjustBruteLoss(5)
					M.emote("twitch")
					M.ForceContractDisease(new /datum/disease/berserker(0))
	..()

/datum/reagent/drug/aranesp
	name = "Aranesp"
	id = "aranesp"
	description = "Amps you up and gets you going, fixes all stamina damage you might have but can cause toxin and oxygen damage.."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

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
