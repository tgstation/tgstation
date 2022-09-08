///Blood walk, a bespoke element that causes you to make blood wherever you walk.
/datum/element/blood_walk
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2

	///A unique blood type we might want to spread
	var/blood_type
	///The sound that plays when we spread blood.
	var/sound_played
	///How loud will the sound be, if there is one.
	var/sound_volume
	///The chance of spawning blood whenever walking
	var/blood_spawn_chance
	///Should the decal face the direction of the target
	var/target_dir_change


/datum/element/blood_walk/Attach(
	datum/target,
	blood_type = /obj/effect/decal/cleanable/blood,
	sound_played,
	sound_volume = 80,
	blood_spawn_chance = 100,
	target_dir_change = FALSE
)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.blood_type = blood_type
	src.sound_played = sound_played
	src.sound_volume = sound_volume
	src.blood_spawn_chance = blood_spawn_chance
	src.target_dir_change = target_dir_change
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/spread_blood)

/datum/element/blood_walk/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

///Spawns blood (if possible) under the source, and plays a sound effect (if any)
/datum/element/blood_walk/proc/spread_blood(datum/source)
	SIGNAL_HANDLER

	var/atom/movable/movable_source = source
	var/turf/current_turf = movable_source.loc
	if(!isturf(current_turf))
		return
	if(!prob(blood_spawn_chance))
		return

	var/obj/effect/decal/blood = new blood_type(current_turf)
	if (target_dir_change)
		blood.setDir(movable_source.dir)
	if(!isnull(sound_played))
		playsound(movable_source, sound_played, sound_volume, TRUE, 2, TRUE)
