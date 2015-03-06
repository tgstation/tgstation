#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

datum/reagent/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "Stun reduction per cycle, slight stamina regeneration buff. Overdoses become rapidly deadly."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 35
	addiction_threshold = 30

datum/reagent/nicotine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/smoke_message = pick("You can just feel your lungs dying!", "You feel relaxed.", "You feel calmed.", "You feel the lung cancer forming.", "You feel the money you wasted.", "You feel like a space cowboy.", "You feel rugged.")
	if(prob(5))
		M << "<span class='notice'>[smoke_message]</span>"
	M.AdjustStunned(-1)
	M.adjustStaminaLoss(-1*REM)
	..()
	return

datum/reagent/nicotine/overdose_process(var/mob/living/M as mob)
	if(prob(20))
		M << "You feel like you smoked too much."
	M.adjustToxLoss(1*REM)
	M.adjustOxyLoss(1*REM)
	..()
	return

datum/reagent/crank
	name = "Crank"
	id = "crank"
	description = "2x stun reduction per cycle. Warms you up, makes you jittery as hell."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_threshold = 10

datum/reagent/crank/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/high_message = pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.AdjustParalysis(-2)
	M.AdjustStunned(-2)
	M.AdjustWeakened(-2)
	..()
	return
datum/reagent/crank/overdose_process(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,10)*REM)
	M.adjustToxLoss(rand(1,10)*REM)
	M.adjustBruteLoss(rand(1,10)*REM)
	..()
	return

datum/reagent/crank/addiction_act_stage1(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,10)*REM)
	..()
	return
datum/reagent/crank/addiction_act_stage2(var/mob/living/M as mob)
	M.adjustToxLoss(rand(1,10)*REM)
	..()
	return
datum/reagent/crank/addiction_act_stage3(var/mob/living/M as mob)
	M.adjustBruteLoss(rand(1,10)*REM)
	..()
	return
datum/reagent/crank/addiction_act_stage4(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,10)*REM)
	M.adjustToxLoss(rand(1,10)*REM)
	M.adjustBruteLoss(rand(1,10)*REM)
	..()
	return
/datum/chemical_reaction/crank
	name = "Crank"
	id = "crank"
	result = "crank"
	required_reagents = list("diphenhydramine" = 1, "ammonia" = 1, "lithium" = 1, "sacid" = 1, "fuel" = 1)
	result_amount = 5
	mix_message = "The mixture violently reacts, leaving behind a few crystalline shards."
	required_temp = 390

/datum/reagent/krokodil
	name = "Krokodil"
	id = "krokodil"
	description = "Cools and calms you down, occasional BRAIN and TOX damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_threshold = 15


/datum/reagent/krokodil/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	..()
	return

/datum/reagent/krokodil/overdose_process(var/mob/living/M as mob)
	if(prob(10))
		M.adjustBrainLoss(rand(1,5)*REM)
		M.adjustToxLoss(rand(1,5)*REM)
	..()
	return


/datum/reagent/krokodil/addiction_act_stage1(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,5)*REM)
	M.adjustToxLoss(rand(1,5)*REM)
	..()
	return
/datum/reagent/krokodil/addiction_act_stage2(var/mob/living/M as mob)
	if(prob(25))
		M << "<span class='danger'>Your skin feels loose...</span>"
	..()
	return
/datum/reagent/krokodil/addiction_act_stage3(var/mob/living/M as mob)
	if(prob(25))
		M << "<span class='danger'>Your skin starts to peel away...</span>"
	M.adjustBruteLoss(3*REM)
	..()
	return
/datum/reagent/krokodil/addiction_act_stage4(var/mob/living/carbon/human/M as mob)
	M << "<span class='userdanger'>Your skin sloughs off!</span>"
	M.adjustBruteLoss(rand(50,80)*REM) // holy shit your skin just FELL THE FUCK OFF
	..()
	return

/datum/chemical_reaction/krokodil
	name = "Krokodil"
	id = "krokodil"
	result = "krokodil"
	required_reagents = list("diphenhydramine" = 1, "morphine" = 1, "cleaner" = 1, "potassium" = 1, "phosphorus" = 1, "fuel" = 1)
	result_amount = 6
	mix_message = "The mixture dries into a pale blue powder."
	required_temp = 380

/datum/reagent/methamphetamine
	name = "Methamphetamine"
	id = "methamphetamine"
	description = "3x stun reduction per cycle, significant stamina regeneration buff, makes you really jittery, dramatically increases movement speed."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_threshold = 10
	metabolization_rate = 0.6

/datum/reagent/methamphetamine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/high_message = pick("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.AdjustParalysis(-3)
	M.AdjustStunned(-3)
	M.AdjustWeakened(-3)
	M.adjustStaminaLoss(-3)
	M.status_flags |= GOTTAGOREALLYFAST
	M.Jitter(3)
	M.adjustBrainLoss(0.5)
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	..()
	return

/datum/reagent/methamphetamine/overdose_process(var/mob/living/M as mob)
	if(M.canmove && !istype(M.loc, /turf/space))
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
	if(prob(20))
		M.adjustToxLoss(5)
	M.adjustBrainLoss(pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	return

/datum/reagent/methamphetamine/addiction_act_stage1(var/mob/living/M as mob)
	M.Jitter(5)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/methamphetamine/addiction_act_stage2(var/mob/living/M as mob)
	M.Jitter(10)
	M.Dizzy(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/methamphetamine/addiction_act_stage3(var/mob/living/M as mob)
	if(M.canmove && !istype(M.loc, /turf/space))
		for(var/i = 0, i < 4, i++)
			step(M, pick(cardinal))
	M.Jitter(15)
	M.Dizzy(15)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/methamphetamine/addiction_act_stage4(var/mob/living/carbon/human/M as mob)
	if(M.canmove && !istype(M.loc, /turf/space))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	M.Jitter(20)
	M.Dizzy(20)
	M.adjustToxLoss(5)
	if(prob(50))
		M.emote(pick("twitch","drool","moan"))
	..()
	return

/datum/chemical_reaction/methamphetamine
	name = "methamphetamine"
	id = "methamphetamine"
	result = "methamphetamine"
	required_reagents = list("ephedrine" = 1, "iodine" = 1, "phosphorus" = 1, "hydrogen" = 1)
	result_amount = 4
	required_temp = 374

/datum/chemical_reaction/methamphetamine_two
	name = "methamphetamine_two"
	id = "methamphetamine_two"
	result = "methamphetamine"
	required_reagents = list("muriatic_acid" = 1, "caustic_soda" = 1, "hydrogen_chloride" = 1)
	result_amount = 3
	required_temp = 374

/datum/reagent/muriatic_acid
	name = "Muriatic Acid"
	id = "muriatic_acid"
	description = "A chemical compound."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/reagent/caustic_soda
	name = "Caustic Soda"
	id = "caustic_soda"
	description = "A chemical compound."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/reagent/hydrogen_chloride
	name = "Hydrogen Chloride"
	id = "hydrogen_chloride"
	description = "A chemical compound."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/chemical_reaction/muriatic_acid
	name = "muriatic_acid"
	id = "muriatic_acid"
	result = "muriatic_acid"
	required_reagents = list("mutadone" = 1, "sacid" = 1)
	result_amount = 2
	required_temp = 500

/datum/chemical_reaction/caustic_soda
	name = "caustic_soda"
	id = "caustic_soda"
	result = "caustic_soda"
	required_reagents = list("sacid" = 1, "cola" = 1)
	result_amount = 2
	required_temp = 500

/datum/chemical_reaction/hydrogen_chloride
	name = "hydrogen_chloride"
	id = "hydrogen_chloride"
	result = "hydrogen_chloride"
	required_reagents = list("hydrogen" = 1, "chlorine" = 1)
	result_amount = 2
	required_temp = 500

/datum/chemical_reaction/saltpetre
	name = "saltpetre"
	id = "saltpetre"
	result = "saltpetre"
	required_reagents = list("potassium" = 1, "nitrogen" = 1, "oxygen" = 3)
	result_amount = 3

/datum/reagent/saltpetre
	name = "Saltpetre"
	id = "saltpetre"
	description = "Volatile."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/reagent/bath_salts
	name = "Bath Salts"
	id = "bath_salts"
	description = "Makes you nearly impervious to stuns and grants a stamina regeneration buff, but you will be a nearly uncontrollable tramp-bearded raving lunatic."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_threshold = 10


/datum/reagent/bath_salts/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.AdjustParalysis(-5)
	M.AdjustStunned(-5)
	M.AdjustWeakened(-5)
	M.adjustStaminaLoss(-10)
	M.adjustBrainLoss(1)
	M.adjustToxLoss(0.1)
	M.hallucination += 10
	if(M.canmove && !istype(M.loc, /turf/space))
		step(M, pick(cardinal))
		step(M, pick(cardinal))
	..()
	return

/datum/chemical_reaction/bath_salts
	name = "bath_salts"
	id = "bath_salts"
	result = "bath_salts"
	required_reagents = list("????" = 1, "saltpetre" = 1, "nutriment" = 1, "cleaner" = 1, "enzyme" = 1, "tea" = 1, "mercury" = 1)
	result_amount = 7
	required_temp = 374

/datum/reagent/bath_salts/overdose_process(var/mob/living/M as mob)
	M.hallucination += 10
	if(M.canmove && !istype(M.loc, /turf/space))
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

/datum/reagent/bath_salts/addiction_act_stage1(var/mob/living/M as mob)
	M.hallucination += 10
	if(M.canmove && !istype(M.loc, /turf/space))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	M.Jitter(5)
	M.adjustBrainLoss(10)
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/bath_salts/addiction_act_stage2(var/mob/living/M as mob)
	M.hallucination += 20
	if(M.canmove && !istype(M.loc, /turf/space))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	M.Jitter(10)
	M.Dizzy(10)
	M.adjustBrainLoss(10)
	if(prob(30))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/bath_salts/addiction_act_stage3(var/mob/living/M as mob)
	M.hallucination += 30
	if(M.canmove && !istype(M.loc, /turf/space))
		for(var/i = 0, i < 12, i++)
			step(M, pick(cardinal))
	M.Jitter(15)
	M.Dizzy(15)
	M.adjustBrainLoss(10)
	if(prob(40))
		M.emote(pick("twitch","drool","moan"))
	..()
	return
/datum/reagent/bath_salts/addiction_act_stage4(var/mob/living/carbon/human/M as mob)
	M.hallucination += 40
	if(M.canmove && !istype(M.loc, /turf/space))
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

/datum/chemical_reaction/aranesp
	name = "aranesp"
	id = "aranesp"
	result = "aranesp"
	required_reagents = list("epinephrine" = 1, "atropine" = 1, "morphine" = 1)
	result_amount = 3

/datum/reagent/aranesp
	name = "Aranesp"
	id = "aranesp"
	description = "Volatile."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/reagent/aranesp/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.adjustStaminaLoss(-35)
	M.adjustToxLoss(1)
	if(prob(rand(1,100)))
		M.losebreath++
		M.adjustOxyLoss(20)
	..()
	return

/obj/item/weapon/reagent_containers/food/drinks/muriatic_acid
	name = "jug of muriatic acid"
	desc = "We needed those cooks."
	icon_state = "chem_jug"
	item_state = "carton"
	list_reagents = list("muriatic_acid" = 50)

/obj/item/weapon/reagent_containers/food/drinks/caustic_soda
	name = "jug of caustic soda"
	desc = "We needed those cooks."
	icon_state = "chem_jug"
	item_state = "carton"
	list_reagents = list("caustic_soda" = 50)

/obj/item/weapon/reagent_containers/food/drinks/hydrogen_chloride
	name = "jug of hydrogen chloride"
	desc = "We needed those cooks."
	icon_state = "chem_jug"
	item_state = "carton"
	list_reagents = list("hydrogen_chloride" = 50)

datum/reagent/hotline
	name = "Hotline"
	id = "hotline"
	description = "It isn't just wrong. It's dead wrong."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 15
	addiction_threshold = 10

datum/reagent/hotline/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/high_message = pick("You feel alert.", "You feel like you can see everything more clearly.", "You feel like you need to relax and examine your surroundings.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.druggy = max(M.druggy, 15)
	M.hallucination += 10
	M.adjustBrainLoss(0.2)
	M.adjustBruteLoss(-0.2)
	M.adjustFireLoss(-0.2)
	M.status_flags |= GOTTAGOFAST
	M.adjustStaminaLoss(-3)
	..()
	return
datum/reagent/hotline/overdose_process(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,20)*REM)
	M.adjustToxLoss(rand(1,20)*REM)
	M.adjustBruteLoss(rand(1,20)*REM)
	M.druggy = max(M.druggy, 30)
	M.hallucination += 30
	if(prob(5))
		M << pick("<span class = 'userdanger'>Your head feels like it's ripping apart!</span>","<span class = 'userdanger'>You wonder why the fuck did you decide to take [src.name].</span>","<span class = 'userdanger'>It hurts so bad!</span>","<span class = 'userdanger'>Please, end it now!</span>","<span class = 'userdanger'>Dear [ticker.Bible_deity_name] please no it hurts!</span>")
	..()
	return

datum/reagent/hotline/addiction_act_stage1(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,10))
	M.hallucination += 30
	M.druggy = max(M.druggy, 30)
	..()
	return
datum/reagent/hotline/addiction_act_stage2(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,20))
	M.hallucination += 30
	M.druggy = max(M.druggy, 30)
	..()
	return
datum/reagent/hotline/addiction_act_stage3(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,30))
	M.hallucination += 30
	M.druggy = max(M.druggy, 30)
	..()
	return
datum/reagent/hotline/addiction_act_stage4(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,30))
	M.hallucination += 30
	M.druggy = max(M.druggy, 30)
	if(prob(1))
		M.visible_message("<span class = 'userdanger'>[M] clutches at their chest! It looks like they're having a heart attack!</span>")
		M.adjustBruteLoss(80) // don't do drugs kids
	..()
	return
