/datum/status_effect/woozy
	id = "woozy"
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/woozy

/datum/status_effect/woozy/nextmove_modifier()
	return 1.5

/atom/movable/screen/alert/status_effect/woozy
	name = "Woozy"
	desc = "You feel a bit slower than usual, it seems doing things with your hands takes longer than it usually does."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "woozy"

/datum/status_effect/high_blood_pressure
	id = "high_blood_pressure"
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/high_blood_pressure

/datum/status_effect/high_blood_pressure/on_apply()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.bleed_mod *= 1.25
	return TRUE

/datum/status_effect/high_blood_pressure/on_remove()
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.bleed_mod /= 1.25

/atom/movable/screen/alert/status_effect/high_blood_pressure
	name = "High blood pressure"
	desc = "Your blood pressure is real high right now ... You'd probably bleed like a stuck pig."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "highbloodpressure"

/datum/status_effect/seizure
	id = "seizure"
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/seizure

/datum/status_effect/seizure/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/amplitude = rand(1 SECONDS, 3 SECONDS)
	duration = amplitude
	owner.set_jitter_if_lower(100 SECONDS)
	owner.Paralyze(duration)
	owner.visible_message(span_warning("[owner] drops to the ground as [owner.p_they()] start[owner.p_s()] seizing up."), \
	span_warning("[pick("You can't collect your thoughts...", "You suddenly feel extremely dizzy...", "You can't think straight...","You can't move your face properly anymore...")]"))
	return TRUE

/atom/movable/screen/alert/status_effect/seizure
	name = "Seizure"
	desc = "FJOIWEHUWQEFGYUWDGHUIWHUIDWEHUIFDUWGYSXQHUIODSDBNJKVBNKDML <--- this is you right now"
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "paralysis"

/datum/status_effect/stoned
	id = "stoned"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/stoned
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/stoned/on_apply()
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.add_movespeed_modifier(/datum/movespeed_modifier/reagent/cannabis) //slows you down
	human_owner.add_eye_color(BLOODCULT_EYE, EYE_COLOR_WEED_PRIORITY) //makes cult eyes less obvious
	human_owner.add_traits(list(TRAIT_CLUMSY, TRAIT_BLOODSHOT_EYES), TRAIT_STATUS_EFFECT(id)) // impairs motor coordination and dilates blood vessels in eyes
	human_owner.add_mood_event("stoned", /datum/mood_event/stoned) //improves mood
	human_owner.sound_environment_override = SOUND_ENVIRONMENT_DRUGGED //not realistic but very immersive
	return TRUE

/datum/status_effect/stoned/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/cannabis)
	human_owner.remove_eye_color(EYE_COLOR_WEED_PRIORITY)
	human_owner.remove_traits(list(TRAIT_CLUMSY, TRAIT_BLOODSHOT_EYES), TRAIT_STATUS_EFFECT(id))
	human_owner.clear_mood_event("stoned")
	human_owner.sound_environment_override = SOUND_ENVIRONMENT_NONE

/atom/movable/screen/alert/status_effect/stoned
	name = "Stoned"
	desc = "Cannabis is impairing your speed, motor skills, and mental cognition."
	icon_state = "stoned"

/// The amount taken away from saline's blood volume multiplier per second, from its base of 5x.
#define SALINE_GLUCOSE_STACK_DILUTION 0.02

/// Status effect that determines the mob's current saline blood replacement effect. The effect begins at 5 blood per 1 saline and gradually decreases to 1 over the course of ~3 1/2 minutes.
/datum/status_effect/stacking/saline_glucose_dilution
	id = "saline_dilution"
	alert_type = /atom/movable/screen/alert/status_effect/saline_dilution

	stacks = 1
	max_stacks = 4 / SALINE_GLUCOSE_STACK_DILUTION
	consumed_on_threshold = FALSE

/datum/status_effect/stacking/saline_glucose_dilution/on_creation(mob/living/new_owner, stacks_to_apply)
	. = ..()
	var/blood_type = new_owner.get_bloodtype()
	if(istype(blood_type, /datum/blood_type/human) || istype(blood_type, /datum/blood_type/animal))
		return
	if(istype(blood_type, /datum/blood_type/lizard))
		linked_alert.name = "Green blood cell deficiency"
		return
	if(istype(blood_type, /datum/blood_type/clown))
		linked_alert.name = "Potassium deficiency"
		return
	if(istype(blood_type, /datum/blood_type/ethereal))
		linked_alert.name = "Low specific conductance"
		return
	if(istype(blood_type, /datum/blood_type/xeno))
		linked_alert.name = "Alkalosis"

/datum/status_effect/stacking/saline_glucose_dilution/tick(seconds_between_ticks)
	if(owner.has_reagent(/datum/reagent/medicine/salglu_solution))
		if(owner.stat != DEAD)
			add_stacks(seconds_between_ticks)
		linked_alert.desc = initial(linked_alert.desc)
		return
	linked_alert.desc = "Saline-Glucose Solution was supporting your bloodstream, and you are now recovering."
	return ..() // Parent is stack decay, only decay while blood is pure

/datum/status_effect/stacking/saline_glucose_dilution/can_have_status()
	return (stacks > 0)

/datum/status_effect/stacking/saline_glucose_dilution/add_stacks(stacks_added)
	. = ..()
	if(!linked_alert)
		return
	linked_alert.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align:center'>[round(100 - (stacks / max_stacks * 80), 1)]%</span>")

/// returns a number 1 - 5 that represents how many units of blood one unit of saline is worth within the mob's bloodstream.
/datum/status_effect/stacking/saline_glucose_dilution/proc/get_blood_multiplier()
	return max(5 - (stacks * SALINE_GLUCOSE_STACK_DILUTION), 0)

#undef SALINE_GLUCOSE_STACK_DILUTION

/atom/movable/screen/alert/status_effect/saline_dilution
	name = "Red blood cell deficiency"
	desc = "Saline-Glucose Solution is supporting your bloodstream, but it is losing its effectiveness over time."
	icon_state = "saline_dilution"
