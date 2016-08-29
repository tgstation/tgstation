/*
//////////////////////////////////////

Headache

	Noticable.
	Highly resistant.
	Increases stage speed.
	Not transmittable.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/headache

	name = "Headache"
	stealth = -1
	resistance = 4
	stage_speed = 2
	transmittable = 0
	level = 1
	severity = 1

/datum/symptom/headache/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		M << "<span class='warning'>[pick("Your head hurts.", "Your head starts pounding.")]</span>"
	return

/*
//////////////////////////////////////

Cluster Headache

	Noticable.
	Highly resistant.
	Increases stage speed.
	Not transmittable.
	High Level

BONUS
	Causes extreme pain at random times! Stuns and does some brain damage.

//////////////////////////////////////
*/

/datum/symptom/headache/cluster

	name = "Cluster Headache"
	stealth = -2
	resistance = 4
	stage_speed = 2
	transmittable = 0
	level = 5
	severity = 1

/datum/symptom/headache/cluster/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4)
				M << "<span class='userdanger'>Your feel an intense pain inside your head!</span>"
				M.Stun(2)

			if(5)
				M << "<span class='userdanger'>[pick("You feel an incredible pain behind your eyes!", "YOUR HEAD HURTS!")]</span>"
				M.Weaken(4)
				if(M.getBrainLoss()<=45)
					M.adjustBrainLoss(5)
					M.updatehealth()

			else
				M << "<span class='warning'>[pick("Your head really hurts.", "You feel needles in your brain.")]</span>"
	return