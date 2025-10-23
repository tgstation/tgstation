/// Used to track the state of surgeries on a mob generically rather than a bodypart
/datum/status_effect/basic_surgery_state
	id = "surgery_state"

	alert_type = null
	tick_interval = STATUS_EFFECT_NO_TICK
	status_type = STATUS_EFFECT_REFRESH

	var/skin_state = SURGERY_SKIN_CLOSED
	var/vessel_state = SURGERY_VESSELS_NORMAL

/datum/status_effect/basic_surgery_state/on_creation(mob/living/new_owner, new_skin_state = SURGERY_SKIN_INTACT, new_vessel_state = SURGERY_VESSELS_INTACT)
	. = ..()
	skin_state = new_skin_state
	vessel_state = new_vessel_state

/datum/status_effect/basic_surgery_state/refresh(mob/living/old_owner, new_skin_state = src.skin_state, new_vessel_state = src.vessel_state)
	skin_state = new_skin_state
	vessel_state = new_vessel_state
	if(skin_state == SURGERY_SKIN_CLOSED && vessel_state == SURGERY_VESSELS_NORMAL)
		qdel(src)
