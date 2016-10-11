/*
//////////////////////////////////////
Sensory-Restoration
	Very very very very noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	Fatal.
Bonus
	The body generates Sensory restorational chemicals.
	inacusiate for ears
	antihol for removal of alcohol
	synaphydramine to purge sensory hallucigens and histamine based impairment
	mannitol to kickstart the mind

//////////////////////////////////////
*/
/datum/symptom/sensory_restoration
	name = "Sensory Restoration"
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 0

/datum/symptom/sensory_restoration/Activate(var/datum/disease/advance/A)
	..()
	var/mob/living/M = A.affected_mob
	if(A.stage >= 2)
		M.setEarDamage(0,0)

	if(A.stage >= 3)
		M.dizziness = 0
		M.drowsyness = 0
		M.slurring = 0
		M.confused = 0
		M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.drunkenness = max(H.drunkenness - 10, 0)

	if(A.stage >= 4)
		M.drowsyness = max(M.drowsyness-5, 0)
		if(M.reagents.has_reagent("mindbreaker"))
			M.reagents.remove_reagent("mindbreaker", 5)
		if(M.reagents.has_reagent("histamine"))
			M.reagents.remove_reagent("histamine", 5)
		M.hallucination = max(0, M.hallucination - 10)

	if(A.stage >= 5)
		M.adjustBrainLoss(-3)
	return

/*
//////////////////////////////////////
Sensory-Destruction
	noticable.
	Lowers resistance
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	the drugs hit them so hard they have to focus on not dying

Bonus
	The body generates Sensory destructive chemicals.
	You cannot taste anything anymore.
	ethanol for extremely drunk victim
	mindbreaker to break the mind
	impedrezene to ruin the brain

//////////////////////////////////////
*/
/datum/symptom/sensory_destruction
	name = "Sensory destruction"
	stealth = -1
	resistance = -2
	stage_speed = -3
	transmittable = -4
	level = 6
	severity = 5
	var/sleepy = 0
	var/sleepy_ticks = 0

/datum/symptom/sensory_destruction/Activate(var/datum/disease/advance/A)
	..()
	var/mob/living/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB))
		switch(A.stage)
			if(1)
				M << "<span class='warning'>You can't feel anything.</span>"
			if(2)
				M << "<span class='warning'>You feel absolutely hammered.</span>"
				if(prob(10))
					sleepy_ticks += rand(10,14)
			if(3)
				M.reagents.add_reagent("ethanol",rand(5,7))
				M << "<span class='warning'>You try to focus on not dying.</span>"
				if(prob(15))
					sleepy_ticks += rand(10,14)
			if(4)
				M.reagents.add_reagent("ethanol",rand(6,10))
				M << "<span class='warning'>u can count 2 potato!</span>"
				if(prob(20))
					sleepy_ticks += rand(10,14)
			if(5)
				M.reagents.add_reagent("ethanol",rand(7,13))
				if(prob(25))
					sleepy_ticks += rand(10,14)

	if(sleepy_ticks)
		if(A.stage>=4)
			M.hallucination = min(M.hallucination + 10, 50)
		if(A.stage>=5)
			if(prob(80))
				M.adjustBrainLoss(1)
			if(prob(50))
				M.drowsyness = max(M.drowsyness, 3)
		sleepy++
		sleepy_ticks--
	else
		sleepy = 0

	switch(sleepy) //Works like morphine
		if(11)
			M << "<span class='warning'>You start to feel tired...</span>"
		if(12 to 24)
			M.drowsyness += 1
		if(24 to INFINITY)
			M.Sleeping(2, 0)

	return
