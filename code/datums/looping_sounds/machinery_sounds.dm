/datum/looping_sound/showering
	start_sound = 'sound/machines/shower/shower_start.ogg'
	start_length = 0.2 SECONDS
	mid_sounds = list(
		'sound/machines/shower/shower_mid1.ogg',
		'sound/machines/shower/shower_mid2.ogg',
		'sound/machines/shower/shower_mid3.ogg',
	)
	mid_length = 1 SECONDS
	end_sound = 'sound/machines/shower/shower_end.ogg'
	volume = 20

/datum/looping_sound/supermatter
	mid_sounds = list('sound/machines/sm/loops/calm.ogg')
	mid_length = 6 SECONDS
	volume = 40
	extra_range = 25
	falloff_exponent = 10
	falloff_distance = 5
	vary = TRUE

/datum/looping_sound/destabilized_crystal
	mid_sounds = list('sound/machines/sm/loops/delamming.ogg')
	mid_length = 6 SECONDS
	volume = 55
	extra_range = 15
	vary = TRUE

/datum/looping_sound/hypertorus
	mid_sounds = list('sound/machines/hypertorus/loops/hypertorus_nominal.ogg')
	mid_length = 6 SECONDS
	volume = 55
	extra_range = 15
	vary = TRUE

/datum/looping_sound/generator
	start_sound = 'sound/machines/generator/generator_start.ogg'
	start_length = 0.4 SECONDS
	mid_sounds = list(
		'sound/machines/generator/generator_mid1.ogg',
		'sound/machines/generator/generator_mid2.ogg',
		'sound/machines/generator/generator_mid3.ogg',
	)
	mid_length = 0.4 SECONDS
	end_sound = 'sound/machines/generator/generator_end.ogg'
	volume = 40

/datum/looping_sound/deep_fryer
	start_sound = 'sound/machines/fryer/deep_fryer_immerse.ogg' //my immersions
	start_length = 1 SECONDS
	mid_sounds = list(
		'sound/machines/fryer/deep_fryer_1.ogg',
		'sound/machines/fryer/deep_fryer_2.ogg',
	)
	mid_length = 0.2 SECONDS
	end_sound = 'sound/machines/fryer/deep_fryer_emerge.ogg'
	volume = 15

/datum/looping_sound/clock
	mid_sounds = list('sound/ambience/misc/ticking_clock.ogg')
	mid_length = 4 SECONDS
	volume = 50
	ignore_walls = FALSE

/datum/looping_sound/grill
	mid_sounds = list('sound/machines/grill/grillsizzle.ogg')
	mid_length = 18
	volume = 50

/datum/looping_sound/oven
	start_sound = 'sound/machines/oven/oven_loop_start.ogg' //my immersions
	start_length = 1.2 SECONDS
	mid_sounds = list('sound/machines/oven/oven_loop_mid.ogg')
	mid_length = 1.3 SECONDS
	end_sound = 'sound/machines/oven/oven_loop_end.ogg'
	volume = 100
	falloff_exponent = 4

/datum/looping_sound/deep_fryer
	mid_length = 0.2 SECONDS
	mid_sounds = list(
		'sound/machines/fryer/deep_fryer_1.ogg',
		'sound/machines/fryer/deep_fryer_2.ogg',
	)
	volume = 30

/datum/looping_sound/microwave
	start_sound = 'sound/machines/microwave/microwave-start.ogg'
	start_length = 1 SECONDS
	mid_sounds = list(
		'sound/machines/microwave/microwave-mid1.ogg' = 10,
		'sound/machines/microwave/microwave-mid2.ogg' = 1,
	)
	mid_length = 1 SECONDS
	end_sound = 'sound/machines/microwave/microwave-end.ogg'
	volume = 90

/datum/looping_sound/lathe_print
	mid_sounds = list('sound/machines/lathe/lathe_print.ogg')
	mid_length = 2 SECONDS
	volume = 50
	vary = TRUE
	ignore_walls = FALSE
	falloff_distance = 1
	mid_length_vary = 1 SECONDS

/datum/looping_sound/jackpot
	mid_length = 1.1 SECONDS
	mid_sounds = list('sound/machines/roulette/roulettejackpot.ogg')
	volume = 85
	vary = TRUE

/datum/looping_sound/server
	mid_sounds = list(
		'sound/machines/tcomms/tcomms_mid1.ogg',
		'sound/machines/tcomms/tcomms_mid2.ogg',
		'sound/machines/tcomms/tcomms_mid3.ogg',
		'sound/machines/tcomms/tcomms_mid4.ogg',
		'sound/machines/tcomms/tcomms_mid5.ogg',
		'sound/machines/tcomms/tcomms_mid6.ogg',
		'sound/machines/tcomms/tcomms_mid7.ogg',
	)
	mid_length = 1.8 SECONDS
	extra_range = -8
	falloff_distance = 3
	falloff_exponent = 5
	volume = 35
	ignore_walls = FALSE
	pressure_affected = FALSE

/datum/looping_sound/computer
	start_sound = 'sound/machines/computer/computer_start.ogg'
	start_length = 7.2 SECONDS
	start_volume = 10
	mid_sounds = list(
		'sound/machines/computer/computer_mid1.ogg',
		'sound/machines/computer/computer_mid2.ogg',
	)
	mid_length = 1.8 SECONDS
	end_sound = 'sound/machines/computer/computer_end.ogg'
	end_volume = 1 SECONDS
	volume = 2
	falloff_exponent = 5 //Ultra quiet very fast
	extra_range = -12
	falloff_distance = 1 //Instant falloff after initial tile

/datum/looping_sound/gravgen
	start_sound = 'sound/machines/gravgen/grav_gen_start.ogg'
	start_length = 1 SECONDS
	mid_sounds = list(
		'sound/machines/gravgen/grav_gen_mid1.ogg' = 12,
		'sound/machines/gravgen/grav_gen_mid2.ogg' = 1,
	)
	mid_length = 1.1 SECONDS
	end_sound = 'sound/machines/gravgen/grav_gen_end.ogg'
	extra_range = 8
	vary = TRUE
	volume = 70
	falloff_distance = 5
	falloff_exponent = 20

/datum/looping_sound/firealarm
	mid_sounds = list(
		'sound/machines/fire_alarm/FireAlarm1.ogg',
		'sound/machines/fire_alarm/FireAlarm2.ogg',
		'sound/machines/fire_alarm/FireAlarm3.ogg',
		'sound/machines/fire_alarm/FireAlarm4.ogg',
	)
	mid_length = 2.4 SECONDS
	volume = 30

/datum/looping_sound/gravgen/kinesis
	volume = 20
	falloff_distance = 2
	falloff_exponent = 5

/datum/looping_sound/boiling
	mid_sounds = list('sound/effects/bubbles/bubbles2.ogg')
	mid_length = 7 SECONDS
	volume = 25

/datum/looping_sound/typing
	mid_sounds = list(
		'sound/machines/terminal/terminal_button01.ogg',
		'sound/machines/terminal/terminal_button02.ogg',
		'sound/machines/terminal/terminal_button03.ogg',
		'sound/machines/terminal/terminal_button04.ogg',
		'sound/machines/terminal/terminal_button05.ogg',
		'sound/machines/terminal/terminal_button06.ogg',
		'sound/machines/terminal/terminal_button07.ogg',
		'sound/machines/terminal/terminal_button08.ogg',
	)
	mid_length = 0.3 SECONDS

/datum/looping_sound/soup
	mid_sounds = list(
		'sound/effects/soup_boil/soup_boil1.ogg',
		'sound/effects/soup_boil/soup_boil2.ogg',
		'sound/effects/soup_boil/soup_boil3.ogg',
		'sound/effects/soup_boil/soup_boil4.ogg',
		'sound/effects/soup_boil/soup_boil5.ogg',
	)
	mid_length = 3 SECONDS
	volume = 80
	end_sound = 'sound/effects/soup_boil/soup_boil_end.ogg'
	end_volume = 60
	extra_range = MEDIUM_RANGE_SOUND_EXTRARANGE
	falloff_exponent = 4

/datum/looping_sound/cryo_cell
	mid_sounds = list(
		'sound/machines/cryo/cryo_1.ogg',
		'sound/machines/cryo/cryo_2.ogg',
		'sound/machines/cryo/cryo_3.ogg',
		'sound/machines/cryo/cryo_4.ogg',
		'sound/machines/cryo/cryo_5.ogg',
		'sound/machines/cryo/cryo_6.ogg',
		'sound/machines/cryo/cryo_7.ogg',
		'sound/machines/cryo/cryo_8.ogg',
		'sound/machines/cryo/cryo_9.ogg',
		'sound/machines/cryo/cryo_10.ogg',
	)
	mid_length = 5 SECONDS
	volume = 50
