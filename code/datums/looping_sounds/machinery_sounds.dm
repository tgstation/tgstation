/datum/looping_sound/showering
	start_sound = 'sound/machines/shower/shower_start.ogg'
	start_length = 2
	mid_sounds = list('sound/machines/shower/shower_mid1.ogg'=1,'sound/machines/shower/shower_mid2.ogg'=1,'sound/machines/shower/shower_mid3.ogg'=1)
	mid_length = 10
	end_sound = 'sound/machines/shower/shower_end.ogg'
	volume = 25

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/supermatter
	mid_sounds = list('sound/machines/sm/supermatter1.ogg'=1,'sound/machines/sm/supermatter2.ogg'=1,'sound/machines/sm/supermatter3.ogg'=1)
	mid_length = 6
	volume = 1

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/generator
	start_sound = 'sound/machines/generator/generator_start.ogg'
	start_length = 4
	mid_sounds = list('sound/machines/generator/generator_mid1.ogg'=1, 'sound/machines/generator/generator_mid2.ogg'=1, 'sound/machines/generator/generator_mid3.ogg'=1)
	mid_length = 4
	end_sound = 'sound/machines/generator/generator_end.ogg'
	volume = 40


/datum/looping_sound/server
	mid_sounds = list('sound/machines/tcomms/tcomms_mid1.ogg'=1,'sound/machines/tcomms/tcomms_mid2.ogg'=1,'sound/machines/tcomms/tcomms_mid3.ogg'=1,'sound/machines/tcomms/tcomms_mid4.ogg'=1,\
										'sound/machines/tcomms/tcomms_mid5.ogg'=1,'sound/machines/tcomms/tcomms_mid6.ogg'=1,'sound/machines/tcomms/tcomms_mid7.ogg'=1)
	mid_length = 17
	range_modifier = -4.5
	volume = 50

/datum/looping_sound/computer
	start_sound = 'sound/machines/computer/computer_start.ogg'
	start_length = 72
	mid_sounds = list('sound/machines/computer/computer_mid1.ogg'=1, 'sound/machines/computer/computer_mid2.ogg'=1)
	mid_length = 6.1
	end_sound = 'sound/machines/computer/computer_end.ogg'
	volume = 10
	range_modifier = -5.5

/datum/looping_sound/borg
	mid_sounds = list('sound/machines/borg/borg_mid1.ogg'=1, 'sound/machines/borg/borg_mid2.ogg'=1, 'sound/machines/borg/borg_mid3.ogg'=1)
	mid_length = 19.5
	end_sound = 'sound/machines/computer/computer_end.ogg'
	volume = 80
	range_modifier = -5.5

/datum/looping_sound/microwave
	start_sound = 'sound/machines/microwave/microwave-start.ogg'
	start_length = 10
	mid_sounds = list('sound/machines/microwave/microwave-mid1.ogg'=10, 'sound/machines/microwave/microwave-mid2.ogg'=1)
	mid_length = 10
	end_sound = 'sound/machines/microwave/microwave-end.ogg'
	volume = 90

/datum/looping_sound/gravgen
	mid_sounds = list('sound/machines/gravgen/gravgen_mid1.ogg'=1,'sound/machines/gravgen/gravgen_mid2.ogg'=1,'sound/machines/gravgen/gravgen_mid3.ogg'=1,'sound/machines/gravgen/gravgen_mid4.ogg'=1,)
	mid_length = 17
	range_modifier = -4.5
	volume = 70
