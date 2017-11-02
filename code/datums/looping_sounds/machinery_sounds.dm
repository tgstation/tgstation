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
	mid_sounds = list('sound/machines/tcomms/server_mid1.ogg'=1,'sound/machines/tcomms/server_mid2.ogg'=1,'sound/machines/tcomms/server_mid3.ogg'=1,)
	mid_length = 5
	volume = 50

/datum/looping_sound/computer
	start_sound = 'sound/machines/computer/computer_start.ogg'
	start_length = 40
	mid_sounds = list('sound/machines/computer/computer_mid1.ogg'=1, 'sound/machines/computer/computer_mid2.ogg'=1)
	mid_length = 10
	end_sound = 'sound/machines/computer/computer_end.ogg'
	volume = 15
	range_modifier = -5.5
