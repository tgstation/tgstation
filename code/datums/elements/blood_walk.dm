///Blood walk element, causes you to make blood wherever you walk.
/datum/element/blood_walk
	///A unique blood type we might want to spread
	var/blood_type = /obj/effect/decal/cleanable/blood
	///The sound that plays when we spread blood.
	var/sound_played
	///How loud will the sound be, if there is one.
	var/sound_volume = 80


/datum/element/blood_walk/Attach(datum/target, _blood_type, _sound_played, _sound_volume)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	if(_blood_type)
		blood_type = _blood_type
	sound_played = _sound_played
	sound_volume = _sound_volume
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/spread_blood)

/datum/element/blood_walk/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/datum/element/blood_walk/proc/spread_blood(datum/source)
	SIGNAL_HANDLER

	var/atom/movable/movable_source = source
	var/turf/current_turf = movable_source.loc
	if(!isturf(current_turf))
		return

	new blood_type(current_turf)
	if(!isnull(sound_played))
		playsound(movable_source, sound_played, sound_volume, TRUE, 2, TRUE)
