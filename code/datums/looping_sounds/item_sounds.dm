/datum/looping_sound/reverse_bear_trap
	mid_sounds = list('sound/effects/clock_tick.ogg' = 1)
	mid_length = 0.35 SECONDS
	volume = 25

/datum/looping_sound/reverse_bear_trap_beep
	mid_sounds = list('sound/machines/beep/beep.ogg' = 1)
	mid_length = 6 SECONDS
	volume = 10

/datum/looping_sound/siren
	mid_sounds = list('sound/items/weeoo1.ogg' = 1)
	mid_length = 1.5 SECONDS
	volume = 20

/datum/looping_sound/tape_recorder_hiss
	mid_sounds = list('sound/items/taperecorder/taperecorder_hiss_mid.ogg' = 1)
	start_sound = list('sound/items/taperecorder/taperecorder_hiss_start.ogg' = 1)
	volume = 10

/datum/looping_sound/heartbeat
	mid_sounds = list('sound/effects/singlebeat.ogg' = 1)
	mid_length = 1 SECONDS

/datum/looping_sound/trapped_machine_beep
	mid_sounds = list('sound/machines/beep/beep.ogg' = 1)
	mid_length = 10 SECONDS
	mid_length_vary = 5 SECONDS
	falloff_exponent = 10
	falloff_distance = 1
	volume = 5

/datum/looping_sound/chainsaw
	start_sound = list('sound/items/weapons/chainsaw_start.ogg' = 1)
	start_length = 0.85 SECONDS
	mid_sounds = list('sound/items/weapons/chainsaw_loop.ogg' = 1)
	mid_length = 0.85 SECONDS
	end_sound = list('sound/items/weapons/chainsaw_stop.ogg' = 1)
	end_volume = 35
	volume = 40
	ignore_walls = FALSE

/datum/looping_sound/beesmoke
	mid_sounds = list('sound/items/weapons/beesmoke.ogg' = 1)
	volume = 5

/datum/looping_sound/zipline
	mid_sounds = list('sound/items/weapons/zipline_mid.ogg' = 1)
	volume = 5

/datum/looping_sound/tesla_cannon
	start_sound = list('sound/items/weapons/gun/tesla/tesla_start.ogg' = 1)
	start_volume = 100
	start_length = 200 MILLISECONDS
	mid_sounds = list('sound/items/weapons/gun/tesla/tesla_loop.ogg' = 1)
	mid_length = 3.8 SECONDS
	volume = 100
	end_sound = list('sound/items/weapons/gun/tesla/power_breaker_fan.ogg' = 1)
	end_volume = 15
	ignore_walls = FALSE
	reserve_random_channel = TRUE
