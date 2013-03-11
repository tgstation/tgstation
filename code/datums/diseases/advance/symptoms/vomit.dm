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

/datum/symptom/vomit/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB / 2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("You feel nauseous.", "You feel like you're going to throw up!")]</span>"
			else
				Vomit(M)

	return

/datum/symptom/vomit/proc/Vomit(var/mob/living/M)

	M.visible_message("<B>[M]</B> vomits on the floor!")

	M.nutrition -= 20
	M.adjustToxLoss(-3)

	var/turf/pos = get_turf(M)
	pos.add_vomit_floor(M)
	playsound(pos, 'sound/effects/splat.ogg', 50, 1)
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

/datum/symptom/vomit/blood/Vomit(var/mob/living/M)

	M.Stun(1)
	M.visible_message("<B>[M]</B> vomits on the floor!")

	// They lose blood and health.
	var/brute_dam = M.getBruteLoss()
	if(brute_dam < 50)
		M.adjustBruteLoss(3)

	var/turf/pos = get_turf(M)
	pos.add_blood_floor(M)
	playsound(pos, 'sound/effects/splat.ogg', 50, 1)