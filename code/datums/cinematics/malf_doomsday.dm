/// A malfunctioning AI has activated the doomsday device and wiped the station!
/datum/cinematic/malf

/datum/cinematic/malf/play_cinematic()
	flick("intro_malf", screen)
	stoplag(7.6 SECONDS)
	flick("station_explode_fade_red", screen)
	play_cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	special_callback?.Invoke()
	screen.icon_state = "summary_malf"
