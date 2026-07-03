/// A blood cult summoned Nar'sie, but Central Command fleet BSA'd the station to stop them.
/datum/cinematic/nuke/cult
	after_nuke_summary_state = "summary_cult_fleet"

/datum/cinematic/nuke/cult/play_cinematic()
	flick("intro_cult_fleet", screen)
	stoplag(3.5 SECONDS)
	play_nuke_effect()
	if(special_callback)
		special_callback.Invoke()
	if(after_nuke_summary_state)
		screen.icon_state = after_nuke_summary_state

/datum/cinematic/nuke/cult/play_nuke_effect()
	flick("station_explode_fleet_fade_red", screen)
	play_cinematic_sound(sound('sound/effects/explosion/explosion_distant.ogg'))
