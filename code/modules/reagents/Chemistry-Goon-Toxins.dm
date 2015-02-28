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
	description = "A dose-dependent toxin, ranges from annoying to incredibly lethal."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.2
	overdose_threshold = 30

datum/reagent/histamine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	switch(pick(1, 2, 3, 4))
		if(1)
			M << "<span class='danger'>You can barely see!</span>"
			M.eye_blurry = 3
		if(2)
			M.emote("cough")
		if(3)
			M.emote("sneeze")
		if(4)
			if(prob(75))
				M << "You scratch at an itch."
				M.adjustBruteLoss(2*REM)
	..()
	return
datum/reagent/histamine/overdose_process(var/mob/living/M as mob)
	M.adjustOxyLoss(pick(1,3)*REM)
	M.adjustBruteLoss(pick(1,3)*REM)
	M.adjustToxLoss(pick(1,3)*REM)
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
	if(M.brainloss + M.toxloss <= 60)
		M.adjustBrainLoss(1*REM)
		M.adjustToxLoss(1*REM)
	if(cycle_count == 17)
		M.sleeping += 10 // buffed so it works
	..()
	return

/datum/chemical_reaction/neurotoxin2
	name = "neurotoxin2"
	id = "neurotoxin2"
	result = "neurotoxin2"
	required_reagents = list("space_drugs" = 1)
	result_amount = 1
	required_temp = 674

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
		M.losebreath += 1
	if(prob(8))
		M << "You feel horrendously weak!"
		M.Stun(2)
		M.adjustToxLoss(2*REM)
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

datum/reagent/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	description = "Lots of annoying random effects, chances to do BRUTE damage from scratching. 6% chance to decay into 1-3 units of histamine."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.3

/datum/reagent/itching_powder/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.reagents.add_reagent("itching_powder", volume)
		return

datum/reagent/itching_powder/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(rand(5,50)))
		M << "You scratch at your head."
		M.adjustBruteLoss(0.2*REM)
	if(prob(rand(5,50)))
		M << "You scratch at your leg."
		M.adjustBruteLoss(0.2*REM)
	if(prob(rand(5,50)))
		M << "You scratch at your arm."
		M.adjustBruteLoss(0.2*REM)
	if(prob(6))
		M.reagents.add_reagent("histamine",rand(1,3))
		M.reagents.remove_reagent("itching_powder",1)
	..()
	return

/datum/chemical_reaction/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	result = "itching_powder"
	required_reagents = list("fuel" = 1, "ammonia" = 1, "charcoal" = 1)
	result_amount = 3

/datum/chemical_reaction/facid
	name = "Fluorosulfuric acid"
	id = "facid"
	result = "facid"
	required_reagents = list("sacid" = 1, "fluorine" = 1, "hydrogen" = 1, "potassium" = 1)
	result_amount = 4
	required_temp = 380

datum/reagent/regadenoson
	name = "Regadenoson"
	id = "regadenoson"
	description = "Major stamina regeneration buff. 33% chance to hit with 5-25 TOX. 5-10% chances to stun and cause suffocation or immediate heart failure."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.4

datum/reagent/regadenoson/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustStaminaLoss(-5)
	if(prob(33))
		M.adjustToxLoss(rand(5,25))
	if(prob(rand(5,10)))
		var/picked_option = rand(1,3)
		switch(picked_option)
			if(1)
				M.Stun(3)
				M.Weaken(3)
			if(2)
				M.losebreath += 10
				M.adjustOxyLoss(rand(5,25))
			if(3)
				M.visible_message("<span class = 'userdanger'>[M] clutches at their chest as if their heart stopped!</span>")
				M.adjustBruteLoss(100) // rip in pepperoni
	..()
	return

datum/reagent/pancuronium
	name = "Pancuronium"
	id = "pancuronium"
	description = "10 cycles to paralysis, 7% chance to cause 3-5 LOSEBREATH."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.2
	var/current_cycle = 0

datum/reagent/pancuronium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	current_cycle++
	if(current_cycle == 10)
		M.SetParalysis(10)
	if(prob(7))
		M.losebreath += rand(3,5)
	..()
	return

datum/reagent/sodium_thiopental
	name = "Sodium Thiopental"
	id = "sodium_thiopental"
	description = "KOs in ten cycles. Major total stamina penalty."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.7
	var/current_cycle = 0

datum/reagent/sodium_thiopental/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	current_cycle++
	if(current_cycle == 10)
		M.sleeping += 20
	M.adjustStaminaLoss(10)
	..()
	return

datum/reagent/sulfonal
	name = "Sulfonal"
	id = "sulfonal"
	description = "+1 TOX, KOs in 22 cycles."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1
	var/current_cycle = 0

/datum/chemical_reaction/sulfonal
	name = "sulfonal"
	id = "sulfonal"
	result = "sulfonal"
	required_reagents = list("acetone" = 1, "diethylamine" = 1, "sulfur" = 1)
	result_amount = 3

datum/reagent/sulfonal/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	current_cycle++
	if(current_cycle == 22)
		M.sleeping += 20
	M.adjustToxLoss(1)
	..()
	return

datum/reagent/amanitin
	name = "Amanitin"
	id = "amanitin"
	description = "On the last cycle that it's in you, it hits you with a stack of TOX damage based on elapsed cycles * rand(2,4). The more you use, the longer it takes before anything happens, but the harder it hits when it does."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	var/cycles = 0

datum/reagent/amanitin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	cycles++
	..()
	return

datum/reagent/amanitin/reagent_deleted(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(cycles*rand(2,4))
	..()
	return

datum/reagent/lipolicide
	name = "Lipolicide"
	id = "lipolicide"
	description = "+1 TOX unless they keep eating food."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

/datum/chemical_reaction/lipolicide
	name = "lipolicide"
	id = "lipolicide"
	result = "lipolicide"
	required_reagents = list("mercury" = 1, "diethylamine" = 1, "ephedrine" = 1)
	result_amount = 3

datum/reagent/lipolicide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!holder.has_reagent("nutriment"))
		M.adjustToxLoss(1)
	..()
	return

datum/reagent/coniine
	name = "Coniine"
	id = "coniine"
	description = "+2 TOX, +5 LOSEBREATH."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.05

datum/reagent/coniine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.losebreath += 5
	M.adjustToxLoss(2)
	..()
	return

datum/reagent/curare
	name = "Curare"
	id = "curare"
	description = "+1 TOX, +1 OXY, paralyzes after 11 cycles."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1
	var/current_cycle = 0

datum/reagent/curare/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	current_cycle++
	if(current_cycle == 11)
		M.SetParalysis(20)
	M.adjustToxLoss(1)
	M.adjustOxyLoss(1)
	..()
	return