/datum/looping_sound/colony_fabricator_running
	start_sound = 'modular_doppler/colony_fabricator/sounds/fabricator/fabricator_start.wav'
	start_length = 1
	mid_sounds = list(
		'modular_doppler/colony_fabricator/sounds/fabricator/fabricator_mid_1.wav' = 1,
		'modular_doppler/colony_fabricator/sounds/fabricator/fabricator_mid_2.wav' = 1,
		'modular_doppler/colony_fabricator/sounds/fabricator/fabricator_mid_3.wav' = 1,
		'modular_doppler/colony_fabricator/sounds/fabricator/fabricator_mid_4.wav' = 1,
	)
	mid_length = 3 SECONDS
	end_sound = 'modular_doppler/colony_fabricator/sounds/fabricator/fabricator_end.wav'
	volume = 100
	falloff_exponent = 3

/datum/looping_sound/arc_furnace_running
	mid_sounds = list(
		'modular_doppler/colony_fabricator/sounds/arc_furnace/arc_furnace_mid_1.wav' = 1,
		'modular_doppler/colony_fabricator/sounds/arc_furnace/arc_furnace_mid_2.wav' = 1,
		'modular_doppler/colony_fabricator/sounds/arc_furnace/arc_furnace_mid_3.wav' = 1,
		'modular_doppler/colony_fabricator/sounds/arc_furnace/arc_furnace_mid_4.wav' = 1,
	)
	mid_length = 1 SECONDS
	volume = 200 // This sound effect is very quiet I've noticed
	falloff_exponent = 2

/datum/looping_sound/conditioner_running
	mid_sounds = list(
		'modular_doppler/colony_fabricator/sounds/conditioner/conditioner_1.wav' = 1,
		'modular_doppler/colony_fabricator/sounds/conditioner/conditioner_2.wav' = 1,
		'modular_doppler/colony_fabricator/sounds/conditioner/conditioner_3.wav' = 1,
		'modular_doppler/colony_fabricator/sounds/conditioner/conditioner_4.wav' = 1,
	)
	mid_length = 3 SECONDS
	volume = 40
	falloff_exponent = 3
