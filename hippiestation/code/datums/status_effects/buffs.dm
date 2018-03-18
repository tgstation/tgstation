//Fleshmend nerf

/datum/status_effect/fleshmend
	id = "fleshmend"
	duration = 150
	alert_type = /obj/screen/alert/status_effect/fleshmend

/datum/status_effect/fleshmend/tick()
	if(owner.on_fire)
		linked_alert.icon_state = "fleshmend_fire"
		return
	else
		linked_alert.icon_state = "fleshmend"
	owner.adjustBruteLoss(-4, FALSE)
	owner.adjustFireLoss(-4, FALSE)
	owner.adjustOxyLoss(-5)