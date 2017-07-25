/proc/playsound(atom/source, soundin, vol as num, vary, extrarange as num, falloff, frequency = null, channel = 0, pressure_affected = TRUE, is_global = FALSE)
	if(isarea(source))
		throw EXCEPTION("playsound(): source is an area")
		return

	soundin = get_sfx(soundin) // same sound for everyone

	var/turf/turf_source = get_turf(source)

	//allocate a channel if necessary now so its the same for everyone
	channel = channel || open_sound_channel()

 	// Looping through the player list has the added bonus of working for mobs inside containers
	var/sound/S = sound(soundin)
	var/maxdistance = (world.view + extrarange) * 3
	for(var/P in GLOB.player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue
		var/distance = get_dist(M, turf_source)

		if(distance <= maxdistance)
			var/turf/T = get_turf(M)
			if(T && T.z == turf_source.z)
				M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, channel, pressure_affected, is_global, S)

/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff, channel = 0, pressure_affected = TRUE, is_global = FALSE, sound/S)
	if(!client || !can_hear())
		return

	if(!S)
		S = sound(get_sfx(soundin))

	S.wait = 0 //No queue
	S.channel = channel || open_sound_channel()
	S.volume = vol
	S.environment = SOUND_ENV_DEFAULT //Always reset the sound environment, or else it'll end up getting applied globally

	if(vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		S.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

		if(pressure_affected)
			//Atmosphere affects sound
			var/pressure_factor = 1
			var/datum/gas_mixture/hearer_env = T.return_air()
			var/datum/gas_mixture/source_env = turf_source.return_air()

			if(hearer_env && source_env)
				var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else //space
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

			S.volume *= pressure_factor
			//End Atmosphere affecting sound

		if(S.volume <= 0)
			return //No sound

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz
		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	if(!is_global)
		S.environment = SOUND_ENV_ROOM

	src << S

/proc/sound_to_playing_players(sound, volume = 100, vary)
	sound = get_sfx(sound)
	for(var/M in GLOB.player_list)
		if(ismob(M) && !isnewplayer(M))
			var/mob/MO = M
			MO.playsound_local(get_turf(MO), sound, volume, vary, pressure_affected = FALSE, is_global = TRUE)

/proc/open_sound_channel()
	var/static/next_channel = 1	//loop through the available 1024 - (the ones we reserve) channels and pray that its not still being used
	. = ++next_channel
	if(next_channel > CHANNEL_HIGHEST_AVAILABLE)
		next_channel = 1

/mob/proc/stop_sound_channel(chan)
	src << sound(null, repeat = 0, wait = 0, channel = chan)

/client/proc/playtitlemusic()
	UNTIL(SSticker.login_music) //wait for SSticker init to set the login music

	if(prefs && (prefs.toggles & SOUND_LOBBY))
		src << sound(SSticker.login_music, repeat = 0, wait = 0, volume = 85, channel = CHANNEL_LOBBYMUSIC) // MAD JAMS

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("shatter")
				soundin = pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')
			if ("explosion")
				soundin = pick('sound/effects/explosion1.ogg','sound/effects/explosion2.ogg')
			if ("sparks")
				soundin = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
			if ("rustle")
				soundin = pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
			if ("bodyfall")
				soundin = pick('sound/effects/bodyfall1.ogg','sound/effects/bodyfall2.ogg','sound/effects/bodyfall3.ogg','sound/effects/bodyfall4.ogg')
			if ("punch")
				soundin = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
			if ("clownstep")
				soundin = pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
			if ("suitstep")
				soundin = pick('sound/effects/suitstep1.ogg','sound/effects/suitstep2.ogg')
			if ("swing_hit")
				soundin = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
			if ("hiss")
				soundin = pick('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
			if ("pageturn")
				soundin = pick('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
			if ("gunshot")
				soundin = pick('sound/weapons/gunshot.ogg', 'sound/weapons/gunshot2.ogg','sound/weapons/gunshot3.ogg','sound/weapons/gunshot4.ogg')
			if ("ricochet")
				soundin = pick(	'sound/weapons/effects/ric1.ogg', 'sound/weapons/effects/ric2.ogg','sound/weapons/effects/ric3.ogg','sound/weapons/effects/ric4.ogg','sound/weapons/effects/ric5.ogg')
			if ("terminal_type")
				soundin = pick('sound/machines/terminal_button01.ogg', 'sound/machines/terminal_button02.ogg', 'sound/machines/terminal_button03.ogg', \
								'sound/machines/terminal_button04.ogg', 'sound/machines/terminal_button05.ogg', 'sound/machines/terminal_button06.ogg', \
								'sound/machines/terminal_button07.ogg', 'sound/machines/terminal_button08.ogg')
			if ("desceration")
				soundin = pick('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg')
			if ("im_here")
				soundin = pick('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg')
			if ("can_open")
				soundin = pick('sound/effects/can_open1.ogg', 'sound/effects/can_open2.ogg', 'sound/effects/can_open3.ogg')
	return soundin

/proc/playsound_global(file, repeat = 0, wait, channel, volume)
	for(var/V in GLOB.clients)
		V << sound(file, repeat, wait, channel, volume)
