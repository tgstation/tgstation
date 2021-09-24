#define FEVER_CHANGE "fever"

/*
//////////////////////////////////////

Fever

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Heats up your body.

//////////////////////////////////////
*/

/datum/symptom/fever
	name = "Fever"
	desc = "The virus causes a febrile response from the host, raising its body temperature."
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 2
	level = 2
	severity = 2
	base_message_chance = 20
	symptom_delay_min = 10
	symptom_delay_max = 30
	var/unsafe = FALSE //over the heat threshold
	threshold_descs = list(
		"Resistance 5" = "Increases fever intensity, fever can overheat and harm the host.",
		"Resistance 10" = "Further increases fever intensity.",
	)

/datum/symptom/fever/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 5) //dangerous fever
		power = 1.5
		unsafe = TRUE
	if(A.totalResistance() >= 10)
		power = 2.5

/datum/symptom/fever/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!unsafe || A.stage < 4)
		to_chat(M, span_warning("[pick("You feel hot.", "You feel like you're burning.")]"))
	else
		to_chat(M, span_userdanger("[pick("You feel too hot.", "You feel like your blood is boiling.")]"))
	set_body_temp(A.affected_mob, A)

/**
 * set_body_temp Sets the body temp change
 *
 * Sets the body temp change to the mob based on the stage and resistance of the disease
 * arguments:
 * * mob/living/M The mob to apply changes to
 * * datum/disease/advance/A The disease applying the symptom
 */
/datum/symptom/fever/proc/set_body_temp(mob/living/M, datum/disease/advance/A)
	if(unsafe) // when unsafe the fever can cause heat damage
		M.add_body_temperature_change(FEVER_CHANGE, 6 * power * A.stage)
	else
		// Get the max amount of change allowed before going over heat damage limit, then cap the maximum allowed temperature change from a safe fever to 5 under the heat damage limit
		var/change_limit = max(M.get_body_temp_heat_damage_limit() - 5 - M.get_body_temp_normal(apply_change=FALSE), 0)
		M.add_body_temperature_change(FEVER_CHANGE, min(6 * power * A.stage, change_limit))

/// Update the body temp change based on the new stage
/datum/symptom/fever/on_stage_change(datum/disease/advance/A)
	. = ..()
	if(.)
		set_body_temp(A.affected_mob, A)

/// remove the body temp change when removing symptom
/datum/symptom/fever/End(datum/disease/advance/A)
	var/mob/living/carbon/M = A.affected_mob
	if(M)
		M.remove_body_temperature_change(FEVER_CHANGE)

#undef FEVER_CHANGE
