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

datum/reagent/nicotine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/smoke_message = pick("You can just feel your lungs dying!", "You feel relaxed.", "You feel calmed.", "You feel the lung cancer forming.", "You feel the money you wasted.", "You feel like a space cowboy.", "You feel rugged.")
	if(prob(5))
		M << "<span class='notice'>[smoke_message]</span>"
	M.AdjustStunned(-1)
	M.adjustStaminaLoss(-1*REM)
	if(volume > 35)
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

datum/reagent/crank/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/high_message = pick("You feel jittery.", "You feel like you gotta go fast.", "You feel like you need to step it up.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	M.AdjustParalysis(-2)
	M.AdjustStunned(-2)
	M.AdjustWeakened(-2)
	if(volume > 20)
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
	var/cycle_count = 0
	var/overdosed


/datum/reagent/krokodil/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(prob(5))
		M << "<span class='notice'>[high_message]</span>"
	if(prob(10))
		M.adjustBrainLoss(rand(1,5)*REM)
		M.adjustToxLoss(rand(1,5)*REM)
	if(cycle_count == 10)
		M.adjustBrainLoss(rand(1,10)*REM)
		M.adjustToxLoss(rand(1,10)*REM)
	if(cycle_count == 20)
		M << "<span class='danger'>Your skin feels loose...</span>"
	if(cycle_count == 50)
		M << "<span class='userdanger'>Your skin falls off!</span>"
		M.adjustBruteLoss(rand(50,80)*REM) // holy shit your skin just FELL THE FUCK OFF
		hardset_dna(M, null, null, null, null, /datum/species/skeleton)
	if(volume > 20)
		overdosed = 1
	if(overdosed)
		cycle_count++
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