/datum/status_effect/cult_buff
	id = "cult_buff"
	duration = -1
	tick_interval = 50
	alert_type = null

/datum/status_effect/cult_buff/tick()
	if(ishuman(owner) && owner.stat != DEAD && owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume += 0.4
