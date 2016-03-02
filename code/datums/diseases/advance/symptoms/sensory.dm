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
	synaptizine to purge sensory hallucigens
	mannitol to kickstart the mind

//////////////////////////////////////
*/
/datum/symptom/sensory_restoration
	name = "Sensory Restoration"
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 6
	severity = 0

/datum/symptom/sensory_restoration/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 3))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(2)
				if(M.reagents.get_reagent_amount("inacusiate")<10)
					M.reagents.add_reagent("inacusiate"=10)
					M << "<span class='notice'><b>Your hearing feels clearer and crisp</b></span>"
			if(3)
				if(M.reagents.get_reagent_amount("antihol") < 10 && M.reagents.get_reagent_amount("inacusiate") < 10 )
					M.reagents.add_reagent_list(list("antihol"=10, "inacusiate"=10))
					M << "<span class='notice'><b>You feel sober.</b></span>"
			if(4)
				if(M.reagents.get_reagent_amount("antihol") < 10 && M.reagents.get_reagent_amount("inacusiate") < 10 && M.reagents.get_reagent_amount("synaptizine") < 10)
					M.reagents.add_reagent_list(list("antihol"=10, "inacusiate"=10, "synaptizine"=5))
					M << "<span class='notice'><b>You feel focused.</b></span>"
			if(5)
				if(M.reagents.get_reagent_amount("antihol") < 10 && M.reagents.get_reagent_amount("inacusiate") < 10 && M.reagents.get_reagent_amount("synaptizine") < 10 && M.reagents.get_reagent_amount("mannitol") < 10)
					M.reagents.add_reagent_list(list("mannitol"=10, "antihol"=10, "inacusiate"=10, "synaptizine"=10))
					M << "<span class='notice'><b>Your mind feels relaxed.</b></span>"
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

/datum/symptom/sensory_destruction/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				M << "<span class='warning'><b>You can't taste a thing.</b></span>"
			if(2)
				M << "<span class='warning'><b>You can't anything with your fingers.</b></span>"
			if(3)
				M.reagents.add_reagent("ethanol",rand(7,10))
				M << "<span class='warning'><b>You feel absolutely hammered.</b></span>"
			if(4)
				M.reagents.add_reagent_list(list("ethanol",rand(7,15),"mindbreaker",rand(5,10)))
				M << "<span class='warning'><b>You try to focus on not dying.</b></span>"
			if(5)
				M.reagents.add_reagent_list(list("impedrezene",rand(5,15),"ethanol",rand(7,20),"mindbreaker",rand(5,15)))
				M << "<span class='warning'><b>u can count 2 potato!</b></span>"
	return