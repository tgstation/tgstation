/atom/movable/screen/alert/status_effect/emp
	name = "Electro-Magnetic Pulse"
	desc = "You've been hit with an EMP! You're malfunctioning!"
	icon_state = "hypnosis"

/datum/status_effect/ipc/emp
	id = "ipc_emp"
	duration = 120 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/emp
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/ipc/emp/get_examine_text()
	return "<span class='warning'>SUBJECTPRONOUN is buzzing and twitching!</span>"
