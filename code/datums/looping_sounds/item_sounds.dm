/datum/looping_sound/reverse_bear_trap
	mid_sounds = list('sound/effects/clock_tick.ogg' = 1)
	mid_length = 3.5
	volume = 25


/datum/looping_sound/reverse_bear_trap_beep
	mid_sounds = list('sound/machines/beep.ogg' = 1)
	mid_length = 60
	volume = 10

/datum/looping_sound/siren
	mid_sounds = list('sound/items/weeoo1.ogg' = 1)
	mid_length = 15
	volume = 20

/datum/looping_sound/tape_recorder_hiss
	mid_sounds = list('sound/items/taperecorder/taperecorder_hiss_mid.ogg' = 1)
	start_sound = list('sound/items/taperecorder/taperecorder_hiss_start.ogg' = 1)
	volume = 10

/datum/looping_sound/heartbeat
	mid_sounds = list('sound/effects/singlebeat.ogg' = 1)
	mid_length = 1 SECONDS

/datum/looping_sound/trapped_machine_beep
	mid_sounds = list('sound/machines/beep.ogg' = 1)
	mid_length = 10 SECONDS
	mid_length_vary = 5 SECONDS
	falloff_exponent = 10
	falloff_distance = 1
	volume = 5

/datum/looping_sound/chainsaw
	start_sound = list('sound/weapons/chainsaw_start.ogg' = 1)
	start_length = 0.85 SECONDS
	mid_sounds = list('sound/weapons/chainsaw_loop.ogg' = 1)
	mid_length = 0.85 SECONDS
	end_sound = list('sound/weapons/chainsaw_stop.ogg' = 1)
	end_volume = 35
	volume = 40
	ignore_walls = FALSE

/datum/looping_sound/beesmoke
	mid_sounds = list('sound/weapons/beesmoke.ogg' = 1)
	volume = 5
