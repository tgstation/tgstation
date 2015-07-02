//SLIME REAGENTS
/datum/reagent/toxin/slime/
	name = "Slime Reagent"
	id = "slimejuice"
	description = "slime juice"
	var/slimepower = 0
	toxpwr = 0
/datum/reagent/toxin/slime/on_mob_life(var/mob/living/M as mob)
	for (var/datum/reagent/toxin/slime/S in M.reagents)
		if(!istype(S,src.type)) //Reagents don't increase their own power.
			slimepower += (S.slimepower / SLIME_POWER_RATE)
	..()
/datum/reagent/toxin/slime/slimefeed
	name = "Slime Feed"
	id = "slimefeed"
	description = "A chemical that stimulates very fast growth in slimes. Mildly toxic."
	color = "#86A296" // rgb: 134, 162, 150
	slimepower = 10
	toxpwr = 1
/datum/reagent/toxin/slime/slimefeed/on_mob_life(var/mob/living/M as mob)
	if(istype(M, /mob/living/simple_animal/slime))
		var/mob/living/simple_animal/slime/S = M
		S.add_nutrition(5*slimepower)
	else
		..()

	return

/datum/reagent/toxin/slime/jelly
	name = "Slime Jelly"
	id = "slimejelly"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	color = "#801E28" // rgb: 128, 30, 40
	toxpwr = 0
	slimepower = 10
/datum/reagent/toxin/slime/jelly/on_mob_life(var/mob/living/M as mob)
	if(prob(slimepower))
		M << "<span class='danger'>Your insides are burning!</span>"
		M.adjustToxLoss(rand(20,60)*REM)
	else if(prob(4*slimepower))
		M.heal_organ_damage(5*REM,0)
	..()
	return

/datum/reagent/consumable/frostoil/slimefrost
	name = "Slime Frost Oil"
	id = "slimefrost"
	description = "An extra powerful oil that noticably chills the body. Extraced from Dark Blue slimes."
	color = "#B31008" // rgb: 139, 166, 233
	freezepower = 20

/datum/reagent/toxin/slime/shocker
	name = "Slime Electrodes"
	id = "slime_electrodes"
	description = "An electrically charged substance, extracted from yellow slimes."
	color = "#E6E600" //rgb: 230, 230, 0
	slimepower = 5
/datum/reagent/toxin/slime/shocker/on_mob_life(var/mob/living/M as mob)
	if(prob(slimepower*5))
		M.Weaken(slimepower/5)
		M.adjustFireLoss(slimepower)
	..()
/datum/reagent/toxin/slime/slimeadrenaline
	name = "Slime Adrenaline"
	id = "slime_adrenaline"
	description = "A modified version of red slime adrenaline. Banned in proffesional holosports."
	color = "#C75305" //rgb: 199, 83, 5
	slimepower = 2
	toxpwr = 1
	var/storedbrute
	var/storedburn
	var/storedtox
	overdose_threshold = 10
/datum/reagent/toxin/slime/slimeadrenaline/on_mob_life(var/mob/living/M as mob)
	if(volume > 1)
		storedbrute += M.getBruteLoss()
		storedburn += M.getFireLoss()
		storedtox += M.getToxLoss()
		M.setBruteLoss(0)
		M.setFireLoss(0)
		M.setToxLoss(0)
	else
		M.adjustBruteLoss(storedbrute)
		M.adjustFireLoss(storedburn)
		M.adjustToxLoss(storedtox)
/datum/reagent/toxin/slime/slimeadrenaline/overdose_process(var/mob/living/M as mob)
	M.adjustBruteLoss(slimepower/2)
	M.adjustFireLoss(slimepower/2)
	M.adjustToxLoss(slimepower/2)
	..()

/datum/reagent/toxin/slime/medicine
	name = "Slime Medicine"
	id = "slimemeds"
	description = "A powerful medicine extracted from Slime Cores"
	color = "#FED6F4" //rgb: 254, 214, 244
	slimepower = 1
	overdose_threshold = 40
/datum/reagent/toxin/slime/medicine/on_mob_life(var/mob/living/M as mob)
	if (prob(slimepower*20))
		M.adjustBruteLoss(-slimepower/2)
		M.adjustFireLoss(-slimepower/2)
	else if(prob(40))
		M << "You feel squishy"
	..()
/datum/reagent/toxin/slime/medicine/overdose_process(var/mob/living/M as mob)
	if(prob(slimepower*25))
		M.adjustBruteLoss(-slimepower)
		M.adjustFireLoss(-slimepower)
/datum/reagent/toxin/slime/slimebuff
	name = "Adamantine Proteins Jelly"
	id = "slime_buff"
	description = "A series of protiens that bond to skin cells, causing them to become re-enforced for a time."
	color = "#89C0ED" //rgb: 137, 192, 237
	slimepower = 5
	var/oldmaxhealth = 0
	overdose_threshold = 20

/datum/reagent/toxin/slime/slimebuff/on_mob_life(var/mob/living/M as mob)
	if(volume > 1)
		if(!oldmaxhealth)
			oldmaxhealth = M.getMaxHealth()
			M.setMaxHealth(oldmaxhealth+slimepower*10)
		else
			..()
	else
		if(oldmaxhealth)
			M.setMaxHealth(oldmaxhealth)
		else
			..()
	..()

/datum/reagent/toxin/slime/slimebuff/overdose_process(var/mob/living/M as mob)
	M.adjustBruteLoss(4)
	..()

/datum/reagent/toxin/slime/pyritepoison
	name = "Genetic Poison"
	id = "Pyrite Poison"
	description = "A powerful poison extracted from slimes cores that damages the subjects DNA."
	color = "#F8EC05" //rgb: 248, 236, 5
	slimepower = 10
	toxpwr = 1

/datum/reagent/toxin/slime/pyritepoison/on_mob_life(var/mob/living/M as mob)
	if (prob(slimepower*5))
		M.adjustCloneLoss(slimepower/2)
	else if(prob(40))
		M << "You feel your DNA starting to become unraveled"




