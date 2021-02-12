/datum/status_effect/woozy
	id = "woozy"
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/woozy


/datum/status_effect/woozy/nextmove_modifier()
	return 1.5

/atom/movable/screen/alert/status_effect/woozy
	name = "Woozy"
	desc = "You feel a bit slower than usual, it seems doing things with your hands takes longer than it usually does"
	icon_state = "frozen"


/datum/status_effect/high_blood_pressure
	id = "high_blood_pressure"
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/high_blood_pressure

/atom/movable/screen/alert/status_effect/high_blood_pressure
	name = "High blood pressure"
	desc = "This stuff is driving my blood pressure up the wall...I'll probably bleed like crazy."
	icon_state = "frozen"



/datum/status_effect/seizure
	id = "seizure"
	tick_interval = -1

	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/seizure

/datum/status_effect/seizure/on_creation(mob/living/new_owner, ...)
	. = ..()
	var/amplitude = rand(1 SECONDS, 3 SECONDS)
	duration = amplitude
	new_owner.Paralyze(amplitude)
	new_owner.jitter(50)

/atom/movable/screen/alert/status_effect/seizure
	name = "Seizure"
	desc = "You cant smile real well at the moment..."
	icon_state = "frozen"
