/*
//////////////////////////////////////

Vomiting

	Very Very Noticable.
	Decreases resistance.
	Doesn't increase stage speed.
	Little transmittable.
	Medium Level.

Bonus
	Forces the affected mob to vomit!
	Meaning your disease can spread via
	people walking on vomit.
	Makes the affected mob lose nutrition and
	heal toxin damage.

//////////////////////////////////////
*/

/datum/symptom/vomit

	name = "Vomiting"
	stealth = -2
	resistance = -1
	stage_speed = 0
	transmittable = 1
	level = 3
	severity = 4

/datum/symptom/vomit/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB / 2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				to_chat(M, "<span class='warning'>[pick("You feel nauseous.", "You feel like you're going to throw up!")]</span>")
			else
				Vomit(M)

	return

/datum/symptom/vomit/proc/Vomit(mob/living/carbon/M)
	M.vomit(20)

/*
//////////////////////////////////////

Vomiting Blood

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Little transmittable.
	Intense level.

Bonus
	Forces the affected mob to vomit blood!
	Meaning your disease can spread via
	people walking on the blood.
	Makes the affected mob lose health.

//////////////////////////////////////
*/

/datum/symptom/vomit/blood

	name = "Blood Vomiting"
	stealth = -2
	resistance = -1
	stage_speed = -1
	transmittable = 1
	level = 4
	severity = 5

/datum/symptom/vomit/blood/Vomit(mob/living/carbon/M)
	M.vomit(0,TRUE)


/*
//////////////////////////////////////

Projectile Vomiting

	Very Very Noticable.
	Decreases resistance.
	Doesn't increase stage speed.
	Little transmittable.
	Medium Level.

Bonus
	As normal vomiting, except it will spread further,
	likely causing more to walk across the vomit.

//////////////////////////////////////
*/

/datum/symptom/vomit/projectile

	name = "Projectile Vomiting"
	stealth = -2
	level = 4

/datum/symptom/vomit/projectile/Vomit(mob/living/carbon/M)
	M.vomit(6, distance = 5)
