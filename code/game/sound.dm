/proc/playsound(var/atom/source, soundin, vol as num, vary, extrarange as num)
	//Frequency stuff only works with 45kbps oggs.

	switch(soundin)
		if ("shatter") soundin = pick('Glassbr1.ogg','Glassbr2.ogg','Glassbr3.ogg')
		if ("explosion") soundin = pick('Explosion1.ogg','Explosion2.ogg')
		if ("sparks") soundin = pick('sparks1.ogg','sparks2.ogg','sparks3.ogg','sparks4.ogg')
		if ("rustle") soundin = pick('rustle1.ogg','rustle2.ogg','rustle3.ogg','rustle4.ogg','rustle5.ogg')
		if ("punch") soundin = pick('punch1.ogg','punch2.ogg','punch3.ogg','punch4.ogg')
		if ("clownstep") soundin = pick('clownstep1.ogg','clownstep2.ogg')
		if ("swing_hit") soundin = pick('genhit1.ogg', 'genhit2.ogg', 'genhit3.ogg')
		if ("hiss") soundin = pick('hiss1.ogg','hiss2.ogg','hiss3.ogg','hiss4.ogg')
		if ("pageturn") soundin = pick('pageturn1.ogg', 'pageturn2.ogg','pageturn3.ogg')

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol

	if (vary)
		S.frequency = rand(32000, 55000)
	for (var/mob/M in range(world.view+extrarange, source))       // Plays for people in range.
		if(locate(/mob/, M))
			var/mob/M2 = locate(/mob/, M)
			if (M2.client)
				if(M2.ear_deaf <= 0 || !M.ear_deaf)
					if(isturf(source))
						var/dx = source.x - M2.x
						S.pan = max(-100, min(100, dx/8.0 * 100))

					M2 << S

		if (M.client)
			if(M.ear_deaf <= 0 || !M.ear_deaf)
				if(isturf(source))
					var/dx = source.x - M.x
					S.pan = max(-100, min(100, dx/8.0 * 100))

				M << S

	for(var/obj/structure/closet/L in range(world.view+extrarange, source))
		if(locate(/mob/, L))
			for(var/mob/M in L)
				if (M.client)
					if(M.ear_deaf <= 0 || !M.ear_deaf)
						if(isturf(source))
							var/dx = source.x - M.x
							S.pan = max(-100, min(100, dx/8.0 * 100))

						M << S
																		// Now plays for people in lockers!  -- Polymorph

/mob/proc/playsound_local(var/atom/source, soundin, vol as num, vary, extrarange as num)
	if(!src.client || ear_deaf > 0)	return
	switch(soundin)
		if ("shatter") soundin = pick('Glassbr1.ogg','Glassbr2.ogg','Glassbr3.ogg')
		if ("explosion") soundin = pick('Explosion1.ogg','Explosion2.ogg')
		if ("sparks") soundin = pick('sparks1.ogg','sparks2.ogg','sparks3.ogg','sparks4.ogg')
		if ("rustle") soundin = pick('rustle1.ogg','rustle2.ogg','rustle3.ogg','rustle4.ogg','rustle5.ogg')
		if ("punch") soundin = pick('punch1.ogg','punch2.ogg','punch3.ogg','punch4.ogg')
		if ("clownstep") soundin = pick('clownstep1.ogg','clownstep2.ogg')
		if ("swing_hit") soundin = pick('genhit1.ogg', 'genhit2.ogg', 'genhit3.ogg')
		if ("hiss") soundin = pick('hiss1.ogg','hiss2.ogg','hiss3.ogg','hiss4.ogg')

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol

	if (vary)
		S.frequency = rand(32000, 55000)
	if(isturf(source))
		var/dx = source.x - src.x
		S.pan = max(-100, min(100, dx/8.0 * 100))

	src << S

client/verb/Toggle_Soundscape() //All new ambience should be added here so it works with this verb until someone better at things comes up with a fix that isn't awful
	set category = "Special Verbs"
	set name = "Toggle Ambience"
	usr:client:no_ambi = !usr:client:no_ambi
	if(usr:client:no_ambi)
		usr << sound(pick('shipambience.ogg','ambigen1.ogg','ambigen3.ogg','ambigen4.ogg','ambigen5.ogg','ambigen6.ogg','ambigen7.ogg','ambigen8.ogg','ambigen9.ogg','ambigen10.ogg','ambigen11.ogg','ambigen12.ogg','ambigen14.ogg','ambicha1.ogg','ambicha2.ogg','ambicha3.ogg','ambicha4.ogg','ambimalf.ogg','ambispace.ogg','ambimine.ogg','title2.ogg'), repeat = 0, wait = 0, volume = 0, channel = 2)
	else
		usr << sound(pick('shipambience.ogg','ambigen1.ogg','ambigen3.ogg','ambigen4.ogg','ambigen5.ogg','ambigen6.ogg','ambigen7.ogg','ambigen8.ogg','ambigen9.ogg','ambigen10.ogg','ambigen11.ogg','ambigen12.ogg','ambigen14.ogg','ambicha1.ogg','ambicha2.ogg','ambicha3.ogg','ambicha4.ogg','ambimalf.ogg','ambispace.ogg','ambimine.ogg','title2.ogg'), repeat = 1, wait = 0, volume = 35, channel = 2)
	usr << "Toggled ambience sound."
	return


