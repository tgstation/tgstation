#define CHILLS_CHANGE "chills"
/** Chills
 * No change to stealth.
 * Increases resistance.
 * Increases stage speed.
 * Increases transmissibility
 * Low level
 * Bonus: Cools down your body.
 */

/datum/symptom/chills
	name = "Chills"
	desc = "The virus inhibits the body's thermoregulation, cooling the body down."
	illness = "Cold Shoulder"
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
		"Stage Speed 5" = "Increases the intensity of the cooling; the host can fall below safe temperature levels.",
		"Stage Speed 10" = "Increases the intensity of the cooling even further."
	)

/datum/symptom/chills/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 5) //dangerous cold
		power = 1.5
		unsafe = TRUE
	if(A.totalStageSpeed() >= 10)
		power = 2.5

/datum/symptom/chills/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!unsafe || A.stage < 4)
		to_chat(M, span_warning("[pick("You feel cold.", "You shiver.")]"))
	else
		to_chat(M, span_userdanger("[pick("You feel your blood run cold.", "You feel ice in your veins.", "You feel like you can't heat up.", "You shiver violently.")]"))
	set_body_temp(A.affected_mob, A)

/**
 * set_body_temp Sets the body temp change
 *
 * Sets the body temp change to the mob based on the stage and resistance of the disease
 * arguments:
 * * mob/living/M The mob to apply changes to
 * * datum/disease/advance/A The disease applying the symptom
 */
/datum/symptom/chills/proc/set_body_temp(mob/living/M, datum/disease/advance/A)
	if(unsafe) // when unsafe the shivers can cause cold damage
		M.add_body_temperature_change(CHILLS_CHANGE, -6 * power * A.stage)
	else
		// Get the max amount of change allowed before going under cold damage limit, then cap the maximum allowed temperature change from safe chills to 5 over the cold damage limit
		var/change_limit = min(M.get_body_temp_cold_damage_limit() + 5 - M.get_body_temp_normal(apply_change=FALSE), 0)
		M.add_body_temperature_change(CHILLS_CHANGE, max(-6 * power * A.stage, change_limit))

/// Update the body temp change based on the new stage
/datum/symptom/chills/on_stage_change(datum/disease/advance/A)
	. = ..()
	if(.)
		set_body_temp(A.affected_mob, A)

/// remove the body temp change when removing symptom
/datum/symptom/chills/End(datum/disease/advance/A)
	var/mob/living/carbon/M = A.affected_mob
	if(M)
		M.remove_body_temperature_change(CHILLS_CHANGE)

#undef CHILLS_CHANGE
