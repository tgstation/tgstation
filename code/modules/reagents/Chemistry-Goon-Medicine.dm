#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

datum/reagent/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	description = "100% chance per cycle of healing 2 points of BURN damage."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 2

datum/reagent/silver_sulfadiazine/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.adjustFireLoss((volume-(volume*2))*REM)
		M << "<span class='notice'>You feel your burns healing!</span>"
		M.emote("scream")
	if(method == INGEST)
		M.adjustToxLoss(0.5*volume)
		M << "<span class='notice'>You probably shouldn't have eaten that. Maybe you should of splashed it on, or applied a patch?</span>"
	..()
	return

datum/reagent/silver_sulfadiazine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(55))
		M.adjustFireLoss(-2*REM)
	..()
	return

datum/reagent/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	description = "100% chance per cycle of healing 2 points of BRUTE damage."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 2

datum/reagent/styptic_powder/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.heal_organ_damage(volume*REM,0)
		M << "<span class='notice'>You feel your wounds knitting back together!</span>"
		M.emote("scream")
	if(method == INGEST)
		M.adjustToxLoss(0.5*volume)
		M << "<span class='notice'>You probably shouldn't have eaten that. Maybe you should of splashed it on, or applied a patch?</span>"
	..()
	return

datum/reagent/styptic_powder/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(55))
		M.adjustBruteLoss(-2*REM)
	..()
	return

datum/reagent/salglu_solution
	name = "Saline-Glucose Solution"
	id = "salglu_solution"
	description = "100% chance per cycle of healing 1 point each of OXY and TOX damage."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/salglu_solution/on_mob_life(var/mob/living/M as mob)
	if(M.stat == DEAD)
		return
	if(!M) M = holder.my_atom
	if(M.getOxyLoss()) M.adjustOxyLoss(-1*REM)
	if(M.getToxLoss()) M.adjustToxLoss(-1*REM)
	..()
	return

datum/reagent/synthflesh
	name = "Synthflesh"
	id = "synthflesh"
	description = "100% chance per cycle of healing 1 point each of BRUTE and BURN damage."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/synthflesh/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!M) M = holder.my_atom
	if(method == TOUCH)
		M.heal_organ_damage(volume*REM,0)
		M.adjustFireLoss((volume-(volume*2)*REM))
		M << "<span class='notice'>You feel your burns healing and your flesh knitting together!</span>"
	..()
	return

datum/reagent/charcoal
	name = "Charcoal"
	id = "charcoal"
	description = "Heals 2 TOX damage per cycle."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/charcoal/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(-1.5*REM)
	for(var/datum/reagent/R in M.reagents)
		if(M != src)
			M.reagents.remove_reagent(R.id,0.5)
	..()
	return

/datum/chemical_reaction/charcoal
	name = "Charcoal"
	id = "charcoal"
	result = "charcoal"
	required_reagents = list("ash" = 1, "sodiumchloride" = 1)
	result_amount = 2
	mix_message = "The mixture yields a fine black powder."
	required_temp = 380

/datum/chemical_reaction/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	result = "silver_sulfadiazine"
	required_reagents = list("ammonia" = 1, "silver" = 1, "sulfur" = 1, "oxygen" = 1, "chlorine" = 1)
	result_amount = 5

/datum/chemical_reaction/salglu_solution
	name = "Saline-Glucose Solution"
	id = "salglu_solution"
	result = "salglu_solution"
	required_reagents = list("sodiumchloride" = 1, "water" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/synthflesh
	name = "Synthflesh"
	id = "synthflesh"
	result = "synthflesh"
	required_reagents = list("blood" = 1, "carbon" = 1, "styptic_powder" = 1)
	result_amount = 3

/datum/chemical_reaction/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	result = "styptic_powder"
	required_reagents = list("aluminium" = 1, "hydrogen" = 1, "oxygen" = 1, "sacid" = 1)
	result_amount = 4
	mix_message = "The solution yields an astringent powder."

datum/reagent/omnizine
	name = "Omnizine"
	id = "omnizine"
	description = "Heals one each of OXY, TOX, BRUTE and BURN per cycle."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.2

datum/reagent/omnizine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(-1*REM)
	M.adjustOxyLoss(-1*REM)
	M.adjustBruteLoss(-1*REM)
	M.adjustFireLoss(-1*REM)
	..()
	return

datum/reagent/calomel
	name = "Calomel"
	id = "calomel"
	description = "Increases all depletion rates by 5. +5 TOX damage while health > 20."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/calomel/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	for(var/datum/reagent/R in M.reagents)
		if(M != src)
			M.reagents.remove_reagent(R.id,5)
	if(M.health > 20)
		M.adjustToxLoss(5*REM)
	..()
	return

/datum/chemical_reaction/calomel
	name = "Calomel"
	id = "calomel"
	result = "calomel"
	required_reagents = list("mercury" = 1, "chlorine" = 1)
	result_amount = 2
	required_temp = 374

datum/reagent/potass_iodide
	name = "Potassium Iodide"
	id = "potass_iodide"
	description = "80% chance of removing 1 RAD. Radiation is cumulative and causes tox+burn."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/potass_iodide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.radiation > 0)
		if(prob(80))
			M.radiation--
	if(M.radiation < 0)
		M.radiation = 0
	..()
	return

/datum/chemical_reaction/potass_iodide
	name = "Potassium Iodide"
	id = "potass_iodide"
	result = "potass_iodide"
	required_reagents = list("potassium" = 1, "iodine" = 1)
	result_amount = 2

datum/reagent/pen_acid
	name = "Pentetic Acid"
	id = "pen_acid"
	description = "Reduces 7 RAD, heals 4 TOX damage, increases all depletion rates by 4. 33% chance of taking 1 unit brute damage"
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/pen_acid/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.radiation > 0)
		M.radiation -= 7
	M.adjustToxLoss(-4*REM)
	if(prob(33))
		M.adjustBruteLoss(1*REM)
	if(M.radiation < 0)
		M.radiation = 0
	for(var/datum/reagent/R in M.reagents)
		if(M != src)
			M.reagents.remove_reagent(R.id,4)
	..()
	return

/datum/chemical_reaction/pen_acid
	name = "Pentetic Acid"
	id = "pen_acid"
	result = "pen_acid"
	required_reagents = list("fuel" = 1, "chlorine" = 1, "ammonia" = 1, "formaldehyde" = 1, "sodium" = 1, "cyanide" = 1)
	result_amount = 6

datum/reagent/sal_acid
	name = "Salicyclic Acid"
	id = "sal_acid"
	description = "If BRUTE damage is under 50, 50% chance to heal one unit."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/sal_acid/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.getBruteLoss() < 50)
		if(prob(50))
			M.adjustBruteLoss(-1*REM)
	..()
	return

/datum/chemical_reaction/sal_acid
	name = "Salicyclic Acid"
	id = "sal_acid"
	result = "sal_acid"
	required_reagents = list("sodium" = 1, "phenol" = 1, "carbon" = 1, "oxygen" = 1, "sacid" = 1)
	result_amount = 5

datum/reagent/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	description = "Heals 6 OXY damage, reduces LOSEBREATH by 4."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.2

datum/reagent/salbutamol/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-6*REM)
	if(M.losebreath >= 4)
		M.losebreath -= 4
	..()
	return

/datum/chemical_reaction/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	result = "salbutamol"
	required_reagents = list("sal_acid" = 1, "lithium" = 1, "aluminium" = 1, "bromine" = 1, "ammonia" = 1)
	result_amount = 5

datum/reagent/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	description = "Heals 25 OXY damage, but you can't talk. 33% chance of healing 1 BRUTE and 1 BURN."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.2

datum/reagent/perfluorodecalin/on_mob_life(var/mob/living/carbon/human/M as mob)
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-25*REM)
	M.silent = max(M.silent, 5)
	if(prob(33))
		M.adjustBruteLoss(-1*REM)
		M.adjustFireLoss(-1*REM)
	..()
	return

/datum/chemical_reaction/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	result = "perfluorodecalin"
	required_reagents = list("hydrogen" = 1, "fluorine" = 1, "oil" = 1)
	result_amount = 3
	required_temp = 370
	mix_message = "The mixture rapidly turns into a dense pink liquid."

datum/reagent/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	description = "Stun reduction per cycle, increases run speed slightly, minor stamina regeneration buff, stabilizes crit."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.3

datum/reagent/ephedrine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.status_flags |= GOTTAGOFAST
	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath-5)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	M.adjustStaminaLoss(-1*REM)
	..()
	return

/datum/chemical_reaction/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	result = "ephedrine"
	required_reagents = list("sugar" = 1, "oil" = 1, "hydrogen" = 1, "diethylamine" = 1)
	result_amount = 4
	mix_message = "The solution fizzes and gives off toxic fumes."

datum/reagent/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	description = "Causes a little bit of drowsiness, reduces jitteriness. Raises histamine depletion rates by 3"
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
datum/reagent/diphenhydramine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.drowsyness += 1
	M.jitteriness -= 1
	M.reagents.remove_reagent("histamine",3)
	..()
	return

/datum/chemical_reaction/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	result = "diphenhydramine"
	required_reagents = list("oil" = 1, "carbon" = 1, "bromine" = 1, "diethylamine" = 1, "ethanol" = 1)
	result_amount = 4
	mix_message = "The mixture dries into a pale blue powder."

datum/reagent/morphine
	name = "Morphine"
	id = "morphine"
	description = "Dramatically counters movement reduction from severe injury. Reduces jitteriness if someone is shaking like crazy from whatever. Will knock you out within 36 cycles if any remains in you."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	var/cycle_count = 0

datum/reagent/morphine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.status_flags |= GOTTAGOFAST
	if(cycle_count == 36)
		M.sleeping += 1
	if(volume > 20)
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
	cycle_count++
	..()
	return