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

/datum/status_effect/seizure/on_apply()
	if(!iscarbon(owner))
		return FALSE
	var/amplitude = rand(1 SECONDS, 3 SECONDS)
	duration = amplitude
	owner.Jitter(50)
	owner.Paralyze(duration)
	owner.visible_message("<span class='warning'>[owner] drops to the ground as [owner.p_they()] start seizing up.</span>", \
	"<span class='warning'>[pick("You can't collect your thoughts...", "You suddenly feel extremely dizzy...", "You cant think straight...","You can't move your face properly anymore...")]</span>")
	return TRUE

/atom/movable/screen/alert/status_effect/seizure
	name = "Seizure"
	desc = "You cant smile real well at the moment..."
	icon_state = "frozen"
