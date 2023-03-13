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

/datum/looping_sound/trapped_machine_beep
	mid_sounds = list('sound/machines/beep.ogg' = 1)
	mid_length = 10 SECONDS
	mid_length_vary = 5 SECONDS
	falloff_exponent = 10
	falloff_distance = 1
	volume = 5

/datum/looping_sound/chainsaw
	start_sound = list('sound/items/taperecorder/taperecorder_hiss_start.ogg' = 1)
	start_length = 5 SECONDS
	mid_sounds = list('sound/weapons/chainsaw_loop.ogg' = 1)
	mid_length = 5 SECONDS
	volume = 55
	extra_range = 15
	ignore_walls = FALSE
