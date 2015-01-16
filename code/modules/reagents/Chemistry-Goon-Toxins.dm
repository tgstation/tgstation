#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

datum/reagent/polonium
	name = "Polonium"
	id = "polonium"
	description = "+8 RAD."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1

datum/reagent/polonium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.radiation += 8
	..()
	return


datum/reagent/histamine
	name = "Histamine"
	id = "histamine"
	description = "Dose-dependent, ranges from annoying to incredibly lethal."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.2

datum/reagent/histamine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(volume >= 20)
		M.adjustOxyLoss(pick(5,10)*REM)
		M.adjustBruteLoss(pick(5,10)*REM)
		M.adjustToxLoss(pick(5,10)*REM)
	if(volume < 20)
		switch(pick(1, 2, 3))
			if(1)
				M << "<span class='danger'>You are unable to look straight!</span>"
				M.Dizzy(10)
			if(2)
				M.emote("cough")
				var/obj/item/I = M.get_active_hand()
				if(I)
					M.drop_item()
			if(3)
				M.adjustBruteLoss(5*REM)
	..()
	return

datum/reagent/formaldehyde
	name = "Formaldehyde"
	id = "formaldehyde"
	description = "+1 TOX, 10% chance to decay into 5-15 units of histamine."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

datum/reagent/formaldehyde/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1*REM)
	if(prob(10))
		M.reagents.add_reagent("histamine",pick(5,15))
		M.reagents.remove_reagent("formaldehyde",1)
	..()
	return

/datum/chemical_reaction/formaldehyde
	name = "formaldehyde"
	id = "Formaldehyde"
	result = "formaldehyde"
	required_reagents = list("ethanol" = 1, "oxygen" = 1, "silver" = 1)
	result_amount = 3
	required_temp = 420

datum/reagent/venom
	name = "Venom"
	id = "venom"
	description = "Scaling TOX and BRUTE damage with dose. 25% chance to decay into 5-10 histamine."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.2
datum/reagent/venom/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss((0.1*volume)*REM)
	M.adjustBruteLoss((0.1*volume)*REM)
	if(prob(25))
		M.reagents.add_reagent("histamine",pick(5,10))
		M.reagents.remove_reagent("venom",1)
	..()
	return

datum/reagent/neurotoxin2
	name = "Neurotoxin"
	id = "neurotoxin2"
	description = "+1 TOX, +1 BRAIN up to 60 before it slows down, confusion, knockout after 17 elapsed cycles."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	var/cycle_count = 0
	metabolization_rate = 1

datum/reagent/neurotoxin2/on_mob_life(var/mob/living/M as mob)
	cycle_count++
	if(!M) M = holder.my_atom
	if(!(M.brainloss + M.toxloss) >= 60)
		M.adjustBrainLoss(1*REM)
		M.adjustToxLoss(1*REM)
	if(cycle_count == 17)
		M.sleeping += 1
	..()
	return

/datum/chemical_reaction/neurotoxin2
	name = "neurotoxin2"
	id = "neurotoxin2"
	result = "neurotoxin2"
	required_reagents = list("space_drugs" = 1)
	result_amount = 1
	required_temp = 200

datum/reagent/cyanide
	name = "Cyanide"
	id = "cyanide"
	description = "+1.5 TOX, 10% chance of +1 LOSEBREATH, 8% chance of stun and extra +2 TOX."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1

datum/reagent/cyanide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1.5*REM)
	if(prob(10))
		M.adjustOxyLoss(1*REM)
	if(prob(8))
		M.sleeping += 1
		M.adjustToxLoss(4*REM)
	..()
	return

/datum/chemical_reaction/cyanide
	name = "Cyanide"
	id = "cyanide"
	result = "cyanide"
	required_reagents = list("oil" = 1, "ammonia" = 1, "oxygen" = 1)
	result_amount = 3
	required_temp = 380

/datum/reagent/questionmark // food poisoning
	name = "Bad Food"
	id = "????"
	description = "????"
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.2

datum/reagent/questionmark/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1*REM)
	..()
	return