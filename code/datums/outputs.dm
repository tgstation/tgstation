//NOTE: When adding new sounds here, check to make sure they haven't been added already via CTRL + F.

/datum/outputs
	var/text = ""
	var/list/sounds = 'sound/items/airhorn.ogg' //can be either a sound path or a WEIGHTED list, put multiple for random selection between sounds
	var/list/image = list('icons/sound_icon.dmi',"circle", HUD_LAYER) //syntax: icon, icon_state, layer

/datum/outputs/proc/send_info(mob/receiver, turf/turf_source, vol as num, vary, frequency, falloff, channel = 0, pressure_affected = TRUE)
	var/sound/sound_output
	//Pick sound
	if(islist(sounds))
		if(sounds.len)
			var/soundin = pickweight(sounds)
			sound_output = sound(get_sfx(soundin))
	else
		sound_output = sound(get_sfx(sounds))
	//Process sound
	if(sound_output)
		sound_output.wait = 0 //No queue
		sound_output.channel = channel || open_sound_channel()
		sound_output.volume = vol

		if(vary)
			if(frequency)
				sound_output.frequency = frequency
			else
				sound_output.frequency = get_rand_frequency()

		if(isturf(turf_source))
			var/turf/T = get_turf(receiver)

			//sound volume falloff with distance
			var/distance = get_dist(T, turf_source)

			sound_output.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

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

				sound_output.volume *= pressure_factor
				//End Atmosphere affecting sound

			if(sound_output.volume <= 0)
				return //No sound

			var/dx = turf_source.x - T.x // Hearing from the right/left
			sound_output.x = dx
			var/dz = turf_source.y - T.y // Hearing from infront/behind
			sound_output.z = dz
			// The y value is for above your head, but there is no ceiling in 2d spessmens.
			sound_output.y = 1
			sound_output.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	//Process image
	var/image/sound_icon = image(image[1], , image[2], image[3])

	receiver.display_output(sound_output, sound_icon, text, turf_source, vol, vary, frequency, falloff, channel, pressure_affected)

/datum/outputs/bikehorn
	text = "You hear a HONK."
	sounds = 'sound/items/bikehorn.ogg'

/datum/outputs/airhorn
	text = "You hear the violent blaring of an airhorn."
	sounds = 'sound/items/airhorn2.ogg'

/datum/outputs/alarm
	text = "You hear a blaring alarm."
	sounds = 'sound/machines/alarm.ogg'

/datum/outputs/squeak
	text = "You hear a squeak."
	sounds = 'sound/effects/mousesqueek.ogg'

/datum/outputs/clownstep
	sounds = list('sound/effects/clownstep1.ogg' = 1,'sound/effects/clownstep2.ogg' = 1)

/datum/outputs/bite
	text = "You hear ravenous biting."
	sounds = 'sound/weapons/bite.ogg'

/datum/outputs/demonattack
	text = "You hear a terrifying, unholy noise."
	sounds = 'sound/magic/demon_attack1.ogg'

/datum/outputs/slash
	text = "You hear a slashing noise."
	sounds = 'sound/weapons/slash.ogg'

/datum/outputs/punch
	text = "You hear a punch."
	sounds = 'sound/effects/hit_punch.ogg'

/datum/outputs/squelch
	text = "You hear a horrendous squelching sound."
	sounds = 'sound/effects/blobattack.ogg'
