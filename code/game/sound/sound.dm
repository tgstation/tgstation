/**
 * playsound is a proc used to play a 3D sound in a specific range. This uses SOUND_RANGE + extra_range to determine that.
 *
 * Arguments:
 * * source - Origin of sound.
 * * soundin - Either a file, or a string that can be used to get an SFX.
 * * vol - The volume of the sound, excluding falloff and pressure affection.
 * * vary - bool that determines if the sound changes pitch every time it plays.
 * * extrarange - modifier for sound range. This gets added on top of SOUND_RANGE.
 * * falloff_exponent - Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
 * * frequency - playback speed of audio.
 * * channel - The channel the sound is played at.
 * * pressure_affected - Whether or not difference in pressure affects the sound (E.g. if you can hear in space).
 * * ignore_walls - Whether or not the sound can pass through walls.
 * * falloff_distance - Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
 * * volume_preference - Optional: Will be checked to modify the volume of the sound for each listener.
 */
/proc/playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff_exponent = SOUND_FALLOFF_EXPONENT, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, use_reverb = TRUE, datum/preference/numeric/volume/volume_preference = null)
	if(isarea(source))
		CRASH("playsound(): source is an area")

	if(islist(soundin))
		CRASH("playsound(): soundin attempted to pass a list! Consider using pick()")

	if(!soundin)
		CRASH("playsound(): no soundin passed")

	if(vol < SOUND_AUDIBLE_VOLUME_MIN) // never let sound go below SOUND_AUDIBLE_VOLUME_MIN or bad things will happen
		CRASH("playsound(): volume below SOUND_AUDIBLE_VOLUME_MIN. [vol] < [SOUND_AUDIBLE_VOLUME_MIN]")

	var/turf/turf_source = get_turf(source)
	if (!turf_source)
		return

	//allocate a channel if necessary now so its the same for everyone
	channel = channel || SSsounds.random_available_channel()

	var/sound/S = isdatum(soundin) ? soundin : sound(get_sfx(soundin))
	var/maxdistance = SOUND_RANGE + extrarange
	var/source_z = turf_source.z

	if(vary && !frequency)
		frequency = get_rand_frequency() // skips us having to do it per-sound later. should just make this a macro tbh

	var/list/listeners

	var/turf/above_turf = GET_TURF_ABOVE(turf_source)
	var/turf/below_turf = GET_TURF_BELOW(turf_source)

	var/audible_distance = CALCULATE_MAX_SOUND_AUDIBLE_DISTANCE(vol, maxdistance, falloff_distance, falloff_exponent)

	if(ignore_walls)
		listeners = get_hearers_in_range(audible_distance, turf_source, RECURSIVE_CONTENTS_CLIENT_MOBS)
		if(above_turf && istransparentturf(above_turf))
			listeners += get_hearers_in_range(audible_distance, above_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)

		if(below_turf && istransparentturf(turf_source))
			listeners += get_hearers_in_range(audible_distance, below_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)

	else //these sounds don't carry through walls
		listeners = get_hearers_in_view(audible_distance, turf_source, RECURSIVE_CONTENTS_CLIENT_MOBS)

		if(above_turf && istransparentturf(above_turf))
			listeners += get_hearers_in_view(audible_distance, above_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)

		if(below_turf && istransparentturf(turf_source))
			listeners += get_hearers_in_view(audible_distance, below_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)
		for(var/mob/listening_ghost as anything in SSmobs.dead_players_by_zlevel[source_z])
			if(get_dist(listening_ghost, turf_source) <= audible_distance)
				listeners += listening_ghost

	for(var/mob/listening_mob in listeners)//had nulls sneak in here, hence the typecheck
		listening_mob.playsound_local(turf_source, soundin, vol, vary, frequency, falloff_exponent, channel, pressure_affected, S, maxdistance, falloff_distance, 1, use_reverb, volume_preference)

	return listeners

/**
 * Plays a sound with a specific point of origin for src mob
 * Affected by pressure, distance, terrain and environment (see arguments)
 *
 * Arguments:
 * * turf_source - The turf our sound originates from, if this is not a turf, the sound is played with no spatial audio
 * * soundin - Either a file, or a string that can be used to get an SFX.
 * * vol - The volume of the sound, excluding falloff and pressure affection.
 * * vary - bool that determines if the sound changes pitch every time it plays.
 * * frequency - playback speed of audio.
 * * falloff_exponent - Rate of falloff for the audio. Higher means quicker drop to low volume. Should generally be over 1 to indicate a quick dive to 0 rather than a slow dive.
 * * channel - Optional: The channel the sound is played at.
 * * pressure_affected - bool Whether or not difference in pressure affects the sound (E.g. if you can hear in space).
 * * sound_to_use - Optional: Will default to soundin when absent
 * * max_distance - number, determines the maximum distance of our sound
 * * falloff_distance - Distance at which falloff begins. Sound is at peak volume (in regards to falloff) aslong as it is in this range.
 * * distance_multiplier - Default 1, multiplies the maximum distance of our sound
 * * use_reverb - bool default TRUE, determines if our sound has reverb
 * * volume_preference - Optional: Will be checked to modify the volume of the sound.
 */
/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff_exponent = SOUND_FALLOFF_EXPONENT, channel = 0, pressure_affected = TRUE, sound/sound_to_use, max_distance, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, distance_multiplier = 1, use_reverb = TRUE, datum/preference/numeric/volume/volume_preference = null)
	if(!client || !can_hear())
		return

	if(!sound_to_use)
		sound_to_use = sound(get_sfx(soundin))

	sound_to_use.wait = 0 //No queue
	sound_to_use.channel = channel || SSsounds.random_available_channel()
	sound_to_use.volume = vol

	if(vary)
		if(frequency)
			sound_to_use.frequency = frequency
		else
			sound_to_use.frequency = get_rand_frequency()

	var/distance = 0

	if(isturf(turf_source))
		var/turf/turf_loc = get_turf(src)

		//sound volume falloff with distance
		distance = get_dist(turf_loc, turf_source) * distance_multiplier

		if(max_distance) //If theres no max_distance we're not a 3D sound, so no falloff.
			sound_to_use.volume -= CALCULATE_SOUND_VOLUME(vol, distance, max_distance, falloff_distance, falloff_exponent)

		if(pressure_affected)
			//Atmosphere affects sound
			var/pressure_factor = 1
			var/datum/gas_mixture/hearer_env = turf_loc.return_air()
			var/datum/gas_mixture/source_env = turf_source.return_air()

			if(hearer_env && source_env)
				var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else //space
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

			sound_to_use.volume *= pressure_factor
			//End Atmosphere affecting sound

		if(sound_to_use.volume < SOUND_AUDIBLE_VOLUME_MIN)
			return //No sound

		var/dx = turf_source.x - turf_loc.x // Hearing from the right/left
		sound_to_use.x = dx * distance_multiplier
		var/dz = turf_source.y - turf_loc.y // Hearing from infront/behind
		sound_to_use.z = dz * distance_multiplier
		var/dy = (turf_source.z - turf_loc.z) * 5 * distance_multiplier // Hearing from  above / below, multiplied by 5 because we assume height is further along coords.
		sound_to_use.y = dy

		sound_to_use.falloff = max_distance || 1 //use max_distance, else just use 1 as we are a direct sound so falloff isnt relevant.

		// Sounds can't have their own environment. A sound's environment will be:
		// 1. the mob's
		// 2. the area's (defaults to SOUND_ENVRIONMENT_NONE)
		if(sound_environment_override != SOUND_ENVIRONMENT_NONE)
			sound_to_use.environment = sound_environment_override
		else
			var/area/A = get_area(src)
			sound_to_use.environment = A.sound_environment

		if(!use_reverb || sound_to_use.environment == SOUND_ENVIRONMENT_NONE)
			sound_to_use.echo ||= new /list(18)
			sound_to_use.echo[3] = -10000
			sound_to_use.echo[4] = -10000

	// Apply user-specific volume modifier, if necessary
	if(ispath(volume_preference) && client.prefs)
		var/client_volume_modifier = client.prefs.read_preference(volume_preference)
		sound_to_use.volume *= (client_volume_modifier / 100)
		if(sound_to_use.volume < SOUND_AUDIBLE_VOLUME_MIN)
			return

	if(HAS_TRAIT(src, TRAIT_SOUND_DEBUGGED))
		to_chat(src, span_admin("Max Range-[max_distance] Distance-[distance] Vol-[round(sound_to_use.volume, 0.01)] Sound-[sound_to_use.file]"))

	SEND_SOUND(src, sound_to_use)

/proc/sound_to_playing_players(soundin, volume = 100, vary = FALSE, frequency = 0, channel = 0, pressure_affected = FALSE, sound/S)
	if(!S)
		S = sound(get_sfx(soundin))
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.playsound_local(M, null, volume, vary, frequency, null, channel, pressure_affected, S)

/mob/proc/stop_sound_channel(chan)
	SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = chan))

/mob/proc/set_sound_channel_volume(channel, volume)
	var/sound/S = sound(null, FALSE, FALSE, channel, volume)
	S.status = SOUND_UPDATE
	SEND_SOUND(src, S)

/client/proc/playtitlemusic(volume_multiplier = 1)
	set waitfor = FALSE
	UNTIL(SSticker.login_music) //wait for SSticker init to set the login music

	var/music_volume = prefs.read_preference(/datum/preference/numeric/volume/sound_lobby_volume) * volume_multiplier
	if((prefs && music_volume) && !CONFIG_GET(flag/disallow_title_music))
		SEND_SOUND(src, sound(SSticker.login_music, repeat = 0, wait = 0, volume = music_volume, channel = CHANNEL_LOBBYMUSIC)) // MAD JAMS

///get a random frequency.
/proc/get_rand_frequency()
	return rand(32000, 55000)

///get_rand_frequency but lower range.
/proc/get_rand_frequency_low_range()
	return rand(38000, 45000)

///Used to convert a SFX define into a .ogg so we can add some variance to sounds. If soundin is already a .ogg, we simply return it
/proc/get_sfx(soundin)
	if(!istext(soundin))
		return soundin
	var/datum/sound_effect/sfx = GLOB.sfx_datum_by_key[soundin]
	return sfx?.return_sfx() || soundin
