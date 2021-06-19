#define SHIVERING_CHANGE "shivering"

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
	stage_speed = 3
	transmittable = 2
	level = 2
	severity = 2
	symptom_delay_min = 10
	symptom_delay_max = 30
	var/unsafe = FALSE //over the cold threshold
	threshold_descs = list(
		"Stage Speed 5" = "Increases cooling speed,; the host can fall below safe temperature levels.",
		"Stage Speed 10" = "Further increases cooling speed."
	)

/datum/symptom/shivering/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 5) //dangerous cold
		power = 1.5
		unsafe = TRUE
	if(A.totalStageSpeed() >= 10)
		power = 2.5

/datum/symptom/shivering/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!unsafe || A.stage < 4)
		to_chat(M, "<span class='warning'>[pick("You feel cold.", "You shiver.")]</span>")
	else
		to_chat(M, "<span class='userdanger'>[pick("You feel your blood run cold.", "You feel ice in your veins.", "You feel like you can't heat up.", "You shiver violently." )]</span>")
	set_body_temp(A.affected_mob, A)

/**
 * set_body_temp Sets the body temp change
 *
 * Sets the body temp change to the mob based on the stage and resistance of the disease
 * arguments:
 * * mob/living/M The mob to apply changes to
 * * datum/disease/advance/A The disease applying the symptom
 */
/datum/symptom/shivering/proc/set_body_temp(mob/living/M, datum/disease/advance/A)
	// Get the max amount of change allowed before going under cold damage limit, 5 over the cold damage limit
	var/change_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT - 5) - M.get_body_temp_normal(apply_change=FALSE)
	if(unsafe) // when unsafe the shivers can cause (cold?)burn damage (not wounds)
		change_limit -= 20
	M.add_body_temperature_change(SHIVERING_CHANGE, max(-((6 * power) * A.stage), change_limit))

/// Update the body temp change based on the new stage
/datum/symptom/shivering/on_stage_change(datum/disease/advance/A)
	. = ..()
	if(.)
		set_body_temp(A.affected_mob, A)

/// remove the body temp change when removing symptom
/datum/symptom/shivering/End(datum/disease/advance/A)
	var/mob/living/carbon/M = A.affected_mob
	if(M)
		M.remove_body_temperature_change(SHIVERING_CHANGE)

#undef SHIVERING_CHANGE
