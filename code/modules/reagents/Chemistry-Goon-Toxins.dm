#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

datum/reagent/polonium
	name = "Polonium"
	id = "polonium"
	description = "Cause significant Radiation damage over time."
	reagent_state = LIQUID
	color = "#CF3600"
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
	color = "#CF3600"
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
	description = "Deals a moderate amount of Toxin damage over time. 10% chance to decay into 10-15 histamine."
	reagent_state = LIQUID
	color = "#CF3600"

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
	description = "Will deal scaling amounts of Toxin and Brute damage over time. 25% chance to decay into 5-10 histamine."
	reagent_state = LIQUID
	color = "#CF3600"
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
	description = "Deals toxin and brain damage up to 60 before it slows down, causing confusion and a knockout after 17 elapsed cycles."
	reagent_state = LIQUID
	color = "#CF3600"
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
	description = "Deals toxin damage, alongside some oxygen loss. 8% chance of stun and some extra toxin damage."
	reagent_state = LIQUID
	color = "#CF3600"
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
	color = "#CF3600"
	metabolization_rate = 0.2

datum/reagent/questionmark/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1*REM)
	..()
	return

datum/reagent/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	description = "Lots of annoying random effects, chances to do some brute damage from scratching. 6% chance to decay into 1-3 units of histamine."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.3

/datum/reagent/itching_powder/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.reagents.add_reagent("itching_powder", volume)
		return

datum/reagent/itching_powder/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(27))
		M << "You scratch at your head."
		M.adjustBruteLoss(0.2*REM)
	if(prob(27))
		M << "You scratch at your leg."
		M.adjustBruteLoss(0.2*REM)
	if(prob(27))
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

datum/reagent/initropidril
	name = "Initropidril"
	id = "initropidril"
	description = "33% chance to hit with a random amount of toxin damage, 5-10% chances to cause stunning, suffocation, or immediate heart failure."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.4

datum/reagent/initropidril/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(33))
		M.adjustToxLoss(rand(5,25))
	if(prob(7))
		var/picked_option = rand(1,3)
		switch(picked_option)
			if(1)
				M.Stun(3)
				M.Weaken(3)
			if(2)
				M.losebreath += 10
				M.adjustOxyLoss(rand(5,25))
			if(3)
				var/mob/living/carbon/human/H = M
				if(!H.heart_attack)
					H.visible_message("<span class = 'danger'>[H] clutches at their chest as if their heart stopped!</span>", "<span class = 'userdanger'>You clutch at your chest as if your heart stopped!</span>")
					H.heart_attack = 1 // rip in pepperoni
				else
					H.losebreath += 10
					H.adjustOxyLoss(rand(5,25))
	..()
	return

datum/reagent/pancuronium
	name = "Pancuronium"
	id = "pancuronium"
	description = "Knocks you out after 30 seconds, 7% chance to cause some oxygen loss."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.2

datum/reagent/pancuronium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(current_cycle >= 10)
		M.SetParalysis(3)
	if(prob(7))
		M.losebreath += rand(3,5)
	..()
	return

datum/reagent/sodium_thiopental
	name = "Sodium Thiopental"
	id = "sodium_thiopental"
	description = "Puts you to sleep after 30 seconds, along with some major stamina loss."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.7

datum/reagent/sodium_thiopental/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(current_cycle >= 10)
		M.sleeping += 3
	M.adjustStaminaLoss(10)
	..()
	return

datum/reagent/sulfonal
	name = "Sulfonal"
	id = "sulfonal"
	description = "Deals some toxin damage, and puts you to sleep after 66 seconds."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1

/datum/chemical_reaction/sulfonal
	name = "sulfonal"
	id = "sulfonal"
	result = "sulfonal"
	required_reagents = list("acetone" = 1, "diethylamine" = 1, "sulfur" = 1)
	result_amount = 3

datum/reagent/sulfonal/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(current_cycle >= 22)
		M.sleeping += 3
	M.adjustToxLoss(1)
	..()
	return

datum/reagent/amanitin
	name = "Amanitin"
	id = "amanitin"
	description = "On the last second that it's in you, it hits you with a stack of toxin damage based on how long it's been in you. The more you use, the longer it takes before anything happens, but the harder it hits when it does."
	reagent_state = LIQUID
	color = "#CF3600"

datum/reagent/amanitin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	..()
	return

datum/reagent/amanitin/on_mob_delete(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(current_cycle*rand(2,4))
	..()

datum/reagent/lipolicide
	name = "Lipolicide"
	id = "lipolicide"
	description = "Deals some toxin damage unless they keep eating food. Will reduce nutrition values."
	reagent_state = LIQUID
	color = "#CF3600"

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
	M.nutrition -= 10 * REAGENTS_METABOLISM
	M.overeatduration = 0
	if(M.nutrition < 0)//Prevent from going into negatives.
		M.nutrition = 0
	..()
	return

datum/reagent/coniine
	name = "Coniine"
	id = "coniine"
	description = "Does moderate toxin damage and oxygen loss."
	reagent_state = LIQUID
	color = "#CF3600"
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
	description = "Does some oxygen and toxin damage, weakens you after 33 seconds."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1

datum/reagent/curare/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(current_cycle >= 11)
		M.Weaken(3)
	M.adjustToxLoss(1)
	M.adjustOxyLoss(1)
	..()
	return