/datum/status_effect/cult_buff
	id = "cult_buff"
	duration = -1
	tick_interval = 50
	alert_type = /obj/screen/alert/status_effect/cult_buff
  
/obj/screen/alert/status_effect/cult_buff
	name = "Nar-sie Empowerment"
	desc = "The power of the Geometer of Blood flows through you."

/datum/status_effect/cult_buff/tick()
	if(ishuman(owner) && owner.blood_volume < BLOOD_VOLUME_NORMAL)
    owner.blood_volume += 0.4
