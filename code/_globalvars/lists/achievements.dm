GLOBAL_LIST_EMPTY(commendations)
///A list of the current achievement categories supported by the UI and checked by the achievement unit test
GLOBAL_LIST_INIT(achievement_categories, list("Bosses", "Jobs", "Skills", "Misc", "Mafia", "Scores"))
///A list of sounds that can be played when unlocking an achievement, set in the preferences.
GLOBAL_LIST_INIT(achievement_sounds, list(
	CHEEVO_SOUND_PING = sound('sound/effects/glockenspiel_ping.ogg', volume = 70),
	CHEEVO_SOUND_JINGLE = sound('sound/effects/beeps_jingle.ogg', volume = 70),
	CHEEVO_SOUND_TADA = sound('sound/effects/tada_fanfare.ogg', volume = 30),
))
