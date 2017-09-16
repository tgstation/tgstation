/*
//////////////////////////////////////

Shivering

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Cools down your body.

//////////////////////////////////////
*/

/datum/symptom/shivering
	name = "Shivering"
	desc = "The virus inhibits the body's thermoregulation, cooling the body down."
	stealth = 0
	resistance = 2
	stage_speed = 2
	transmittable = 2
	level = 2
	severity = 2
	symptom_delay_min = 10
	symptom_delay_max = 30
	var/unsafe = FALSE //over the cold threshold
	threshold_desc = "<b>Stage Speed 5:</b> Increases cooling speed; the host can fall below safe temperature levels.<br>\
					  <b>Stage Speed 10:</b> Further increases cooling speed."

/datum/symptom/fever/Start(datum/disease/advance/A)
	..()
	if(A.properties["stage_speed"] >= 5) //dangerous cold
		power = 1.5
		unsafe = TRUE
	if(A.properties["stage_speed"] >= 10)
		power = 2.5

/datum/symptom/shivering/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!unsafe || A.stage < 4)
		to_chat(M, "<span class='warning'>[pick("You feel cold.", "You shiver.")]</span>")
	else
		to_chat(M, "<span class='userdanger'>[pick("You feel your blood run cold.", "You feel ice in your veins.", "You feel like you can't heat up.", "You shiver violently." )]</span>")
	if(M.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT || unsafe)
		Chill(M, A)

/datum/symptom/shivering/proc/Chill(mob/living/M, datum/disease/advance/A)
	var/get_cold = 6 * power
	if(!unsafe)
		M.bodytemperature = min(M.bodytemperature - (get_cold * A.stage), BODYTEMP_COLD_DAMAGE_LIMIT + 1)
	else
		M.bodytemperature -= (get_cold * A.stage)
	return 1