/datum/looping_sound/sacrament
	mid_sounds = list('massmeta/sounds/magic/sacrament_heartbeat_01.ogg' = 1, 'massmeta/sounds/magic/sacrament_heartbeat_02.ogg' = 1, 'massmeta/sounds/magic/sacrament_heartbeat_03.ogg' = 1)
	mid_length = 10
	volume = 30
	var/stage = 1

/datum/looping_sound/sacrament/get_sound(looped)
	mid_length = 12 - (stage * 2)
	volume = 30 + (stage * 10)
	return ..(looped)
