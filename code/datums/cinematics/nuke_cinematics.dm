/// Simple, base cinematic for all animations based around a nuke detonating.
/datum/cinematic/nuke
	/// If set, this is the summary screen that pops up after the nuke is done.
	var/after_nuke_summary_state

/datum/cinematic/nuke/play_cinematic()
	flick("intro_nuke", screen)
	stoplag(3.5 SECONDS)
	play_nuke_effect()
	if(special_callback)
		special_callback.Invoke()
	if(after_nuke_summary_state)
		screen.icon_state = after_nuke_summary_state

/// Specific effects for each type of cinematics goes here.
/datum/cinematic/nuke/proc/play_nuke_effect()
	return

/// The syndicate nuclear bomb was activated, and destroyed the station!
/datum/cinematic/nuke/ops_victory
	after_nuke_summary_state = "summary_nukewin"

/datum/cinematic/nuke/ops_victory/play_nuke_effect()
	flick("station_explode_fade_red", screen)
	play_cinematic_sound(sound('sound/effects/explosion/explosion_distant.ogg'))

/// The syndicate nuclear bomb was activated, but just barely missed the station!
/datum/cinematic/nuke/ops_miss
	after_nuke_summary_state = "summary_nukefail"

/datum/cinematic/nuke/ops_miss/play_nuke_effect()
	flick("station_intact_fade_red", screen)
	play_cinematic_sound(sound('sound/effects/explosion/explosion_distant.ogg'))

/// The self destruct, or another station-destroying entity like a blob, destroyed the station!
/datum/cinematic/nuke/self_destruct
	after_nuke_summary_state = "summary_selfdes"

/datum/cinematic/nuke/self_destruct/play_nuke_effect()
	flick("station_explode_fade_red", screen)
	play_cinematic_sound(sound('sound/effects/explosion/explosion_distant.ogg'))

/// The self destruct was activated, yet somehow avoided destroying the station!
/datum/cinematic/nuke/self_destruct_miss
	after_nuke_summary_state = "station_intact"

/datum/cinematic/nuke/self_destruct_miss/play_nuke_effect()
	play_cinematic_sound(sound('sound/effects/explosion/explosion_distant.ogg'))
	special_callback?.Invoke()

/// The syndicate nuclear bomb was activated, and the nuclear operatives failed to extract on their shuttle before it detonated on the station!
/datum/cinematic/nuke/mutual_destruction
	after_nuke_summary_state = "summary_totala"

/datum/cinematic/nuke/mutual_destruction/play_nuke_effect()
	flick("station_explode_fade_red", screen)
	play_cinematic_sound(sound('sound/effects/explosion/explosion_distant.ogg'))

/// A blood cult summoned Nar'sie, but central command deployed a nuclear package to stop them.
/datum/cinematic/nuke/cult
	after_nuke_summary_state = "summary_cult"

/datum/cinematic/nuke/cult/play_nuke_effect()
	flick("station_explode_fade_red", screen)
	play_cinematic_sound(sound('sound/effects/explosion/explosion_distant.ogg'))

/// A fake version of the nuclear detonation, where it winds up, but doesn't explode.
/datum/cinematic/nuke/fake
	cleanup_time = 10 SECONDS

/datum/cinematic/nuke/fake/play_nuke_effect()
	play_cinematic_sound(sound('sound/items/bikehorn.ogg'))
	flick("summary_selfdes", screen) //???

/// The clown operative nuclear bomb was activated and clowned the station!
/datum/cinematic/nuke/clown
	cleanup_time = 10 SECONDS

/datum/cinematic/nuke/clown/play_nuke_effect()
	play_cinematic_sound(sound('sound/items/airhorn/airhorn.ogg'))
	flick("summary_selfdes", screen) //???

/// A fake version of the nuclear detonation, where it winds up, but doesn't explode as the nuke core within was missing.
/datum/cinematic/nuke/no_core
	cleanup_time = 10 SECONDS

/datum/cinematic/nuke/no_core/play_nuke_effect()
	flick("station_intact", screen)
	play_cinematic_sound(sound('sound/ambience/misc/signal.ogg'))
	stoplag(10 SECONDS)

/// The syndicate nuclear bomb was activated, but just missed the station by a whole z-level!
/datum/cinematic/nuke/far_explosion
	cleanup_time = 0 SECONDS

/datum/cinematic/nuke/far_explosion/play_cinematic()
	// This one has no intro sequence.
	// It's actually just a global sound, which makes you wonder why it's a cinematic.
	play_cinematic_sound(sound('sound/effects/explosion/explosion_distant.ogg'))
	special_callback?.Invoke()
