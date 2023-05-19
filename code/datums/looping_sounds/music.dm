/datum/looping_sound/elevator_music
	start_sound = 'sound/ambience/music/elevator/elevator-01.ogg'
	start_length = 7.62 SECONDS

	mid_sounds = list(
		'sound/ambience/music/elevator/elevator-01.ogg',
		'sound/ambience/music/elevator/elevator-02.ogg',
		'sound/ambience/music/elevator/elevator-03.ogg',
		'sound/ambience/music/elevator/elevator-04.ogg',
		'sound/ambience/music/elevator/elevator-05.ogg',
		'sound/ambience/music/elevator/elevator-06.ogg',
		'sound/ambience/music/elevator/elevator-07.ogg',
		'sound/ambience/music/elevator/elevator-08.ogg',
	)
	mid_length = 7.62 SECONDS

	end_sound = 'sound/ambience/music/elevator/elevator-08.ogg'

	volume = 20
	falloff_exponent = 5
	falloff_distance = 3
	vary = FALSE
	ignore_walls = FALSE
	use_reverb = FALSE
	each_once = TRUE
	skip_starting_sounds = TRUE
	in_order = TRUE
	direct = TRUE
