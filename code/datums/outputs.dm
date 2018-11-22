GLOBAL_LIST_EMPTY(outputs_list)

//NOTE: When adding new sounds here, check to make sure they haven't been added already via CTRL + F.

/datum/outputs
	var/text = ""
	var/list/sounds = list('sound/items/airhorn.ogg'=1) //weighted, put multiple for random selection between sounds
	var/list/icon = list('icons/sound_icon.dmi',"circle", HUD_LAYER) //syntax: icon, icon_state, layer

/datum/outputs/New()
	GLOB.outputs_list[type] = src

/datum/outputs/proc/send_info(mob/receiver, turf/turf_source, vol as num, vary, frequency, falloff, channel = 0, pressure_affected = TRUE)
	var/sound/S
	if(receiver.client)
		//Pick sound
		if(sounds.len)
			var/soundin = pickweight(sounds)
			S = sound(get_sfx(soundin))
		//Process sound
		if(S)
			S.wait = 0 //No queue
			S.channel = channel || open_sound_channel()
			S.volume = vol

			if(vary)
				if(frequency)
					S.frequency = frequency
				else
					S.frequency = get_rand_frequency()

			if(isturf(turf_source))
				var/turf/T = get_turf(receiver)

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

	//Process icon
	var/image/I = image(icon[1], turf_source, icon[2], icon[3])
	if(S && vol)
		I.alpha = I.alpha * (vol / 100)

	receiver.display_output(S, I, text, turf_source, vol, vary, frequency, falloff, channel, pressure_affected)

/datum/outputs/bikehorn
	text = "You hear a HONK."
	sounds = list('sound/items/bikehorn.ogg' = 1)

/datum/outputs/airhorn
	text = "You hear the violent blaring of an airhorn."
	sounds = list('sound/items/airhorn2.ogg' = 1)

/datum/outputs/alarm
	text = "You hear a blaring alarm."
	sounds = list('sound/machines/alarm.ogg' = 1)

/datum/outputs/squeak
	text = "You hear a squeak."
	sounds = list('sound/effects/mousesqueek.ogg' = 1)

/datum/outputs/clownstep
	sounds = list('sound/effects/clownstep1.ogg' = 1,'sound/effects/clownstep2.ogg' = 1)

/datum/outputs/bite
	text = "You hear ravenous biting."
	sounds = list('sound/weapons/bite.ogg' = 1)

/datum/outputs/demonattack
	text = "You hear a terrifying, unholy noise."
	sounds = list('sound/magic/demon_attack1.ogg' = 1)

/datum/outputs/slash
	text = "You hear a slashing noise."
	sounds = list('sound/weapons/slash.ogg' = 1)

/datum/outputs/punch
	text = "You hear a punch."
	sounds = list('sound/effects/hit_punch.ogg' = 1)

/datum/outputs/squelch
	text = "You hear a horrendous squelching sound."
	sounds = list('sound/effects/blobattack.ogg' = 1)