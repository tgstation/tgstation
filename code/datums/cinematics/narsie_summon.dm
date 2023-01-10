/// A blood cult summoned Nar'sie, and most of the station was harvested or converted!
/datum/cinematic/cult_arm // Colloquially known as "the arm"

/datum/cinematic/cult_arm/play_cinematic()
	screen.icon_state = null
	flick("intro_cult", screen)
	stoplag(2.5 SECONDS)
	play_cinematic_sound(sound('sound/magic/enter_blood.ogg'))
	stoplag(2.8 SECONDS)
	play_cinematic_sound(sound('sound/machines/terminal_off.ogg'))
	stoplag(2 SECONDS)
	flick("station_corrupted", screen)
	play_cinematic_sound(sound('sound/effects/ghost.ogg'))
	stoplag(7 SECONDS)
	special_callback?.Invoke()

/// A blood cult summoned Nar'sie, but some badass (or admin) managed to destroy Nar'sie themselves.
/datum/cinematic/cult_fail

/datum/cinematic/cult_fail/play_cinematic()
	screen.icon_state = "station_intact"
	stoplag(2 SECONDS)
	play_cinematic_sound(sound('sound/creatures/narsie_rises.ogg'))
	stoplag(6 SECONDS)
	play_cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	stoplag(1 SECONDS)
	play_cinematic_sound(sound('sound/magic/demon_dies.ogg'))
	stoplag(3 SECONDS)
	special_callback?.Invoke()
