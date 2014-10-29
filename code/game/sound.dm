var/list/shatter_sound = list('sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg')
var/list/explosion_sound = list('sound/effects/Explosion1.ogg','sound/effects/Explosion2.ogg','sound/effects/Explosion3.ogg','sound/effects/Explosion4.ogg','sound/effects/Explosion5.ogg','sound/effects/Explosion6.ogg')
var/list/spark_sound = list('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
var/list/rustle_sound = list('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
var/list/punch_sound = list('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
var/list/clown_sound = list('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
var/list/swing_hit_sound = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
var/list/hiss_sound = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
var/list/page_sound = list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
var/list/mechstep_sound = list('sound/mecha/mechstep1.ogg', 'sound/mecha/mechstep2.ogg')
var/list/gib_sound = list('sound/effects/gib1.ogg', 'sound/effects/gib2.ogg', 'sound/effects/gib3.ogg')
var/list/mommicomment_sound = list('sound/voice/mommi_comment1.ogg', 'sound/voice/mommi_comment2.ogg', 'sound/voice/mommi_comment3.ogg', 'sound/voice/mommi_comment5.ogg', 'sound/voice/mommi_comment6.ogg', 'sound/voice/mommi_comment7.ogg', 'sound/voice/mommi_comment8.ogg')
//var/list/gun_sound = list('sound/weapons/Gunshot.ogg', 'sound/weapons/Gunshot2.ogg','sound/weapons/Gunshot3.ogg','sound/weapons/Gunshot4.ogg')

//gas_modified controls if a sound is affected by how much gas there is in the atmosphere of the source
/proc/playsound(var/atom/source, soundin, vol as num, vary, extrarange as num, falloff, var/gas_modified = 1)

	soundin = get_sfx(soundin) // same sound for everyone

	if(isarea(source))
		error("[source] is an area and is trying to make the sound: [soundin]")
		return

	var/frequency = get_rand_frequency() // Same frequency for everybody
	var/turf/turf_source = get_turf(source)

/* What's going on in this block?
	If the proc isn't set to not be modified by air, the following steps occur:
	 - The atmospheric pressure of the turf where the sound is played is determined
	 - A calculation is made as to the fraction of one atmosphere that the pressure is at, in tenths e.g. 0.1, 0.3, 0.7, never exceeding 1
	 - If the proc has extrarange, the fraction of this extrarange that applies is equal to that of the pressure of the tile
	 - If the proc has NO extrarange, the fraction of the 7 range is used, so a sound only trasmits to those in the screen at regular pressure
	 - This means that at low or 0 pressure, sound doesn't trasmit from the tile at all! How cool is that?
*/
	if(gas_modified)
		var/atmosphere = 0
		if(istype(turf_source, /turf/simulated))
			var/turf/simulated/TS = turf_source
			if(!TS.zone)
				if(turf_source.air)
					atmosphere = turf_source.air.return_pressure()
			else if(TS.zone.air)
				atmosphere = TS.zone.air.return_pressure()
		else if(turf_source.air)
			atmosphere = turf_source.air.return_pressure()
		//message_admins("We're starting off with [atmosphere] and [extrarange]")
		if(extrarange)
			extrarange = -7 + min ( round( extrarange * round(atmosphere/101.325, 0.1), 1 ), extrarange )
		else
			extrarange = -7 + min( round(7 * round(atmosphere/101.325, 0.1), 1 ), 10 )
		//message_admins("We've adjusted the sound of [source] at [turf_source.loc] to have a range of [7 + extrarange]")

 	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/P in player_list)
		var/mob/M = P
		if(!M || !M.client)
			continue
		if(get_dist(M, turf_source) <= world.view + extrarange)
			var/turf/T = get_turf(M)
			if(T && T.z == turf_source.z)
				M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff)

var/const/FALLOFF_SOUNDS = 1
var/const/SURROUND_CAP = 7

/mob/proc/playsound_local(var/turf/turf_source, soundin, vol as num, vary, frequency, falloff)
	if(!src.client || ear_deaf > 0)	return
	soundin = get_sfx(soundin)

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol

	if (vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)
		var/dx = turf_source.x - T.x // Hearing from the right/left

		S.x = round(max(-SURROUND_CAP, min(SURROUND_CAP, dx)), 1)

		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = round(max(-SURROUND_CAP, min(SURROUND_CAP, dz)), 1)

		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	src << S

/client/proc/playtitlemusic()
	if(!ticker || !ticker.login_music)	return
	if(prefs.toggles & SOUND_LOBBY)
		src << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS

/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("shatter") soundin = pick(shatter_sound)
			if ("explosion") soundin = pick(explosion_sound)
			if ("sparks") soundin = pick(spark_sound)
			if ("rustle") soundin = pick(rustle_sound)
			if ("punch") soundin = pick(punch_sound)
			if ("clownstep") soundin = pick(clown_sound)
			if ("swing_hit") soundin = pick(swing_hit_sound)
			if ("hiss") soundin = pick(hiss_sound)
			if ("pageturn") soundin = pick(page_sound)
			if ("mechstep") soundin = pick(mechstep_sound)
			if ("gib") soundin = pick(gib_sound)
			if ("mommicomment") soundin = pick(mommicomment_sound)
			//if ("gunshot") soundin = pick(gun_sound)
	return soundin