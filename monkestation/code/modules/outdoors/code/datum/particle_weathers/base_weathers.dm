/datum/particle_weather/dust_storm
	name = "Rain"
	desc = "Gentle Rain, la la description."
	particleEffectType = /particles/weather/dust

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/dust_storm)
	weather_messages = list("The whipping sand stings your eyes!")

	minSeverity = 1
	maxSeverity = 50
	maxSeverityChange = 10
	severitySteps = 20
	//immunity_type = TRAIT_DUSTSTORM_IMMUNE
	probability = 1
	target_trait = PARTICLEWEATHER_DUST

//Makes you a little chilly
/datum/particle_weather/dust_storm/weather_act(mob/living/L)
	if ishuman(L)
		var/mob/living/carbon/human/H = L
		var/obj/item/organ/internal/eyes/eyes = H.get_organ_slot(ORGAN_SLOT_EYES)
		eyes?.apply_organ_damage(severityMod() * rand(1,3) - H.get_eye_protection())


/datum/particle_weather/radiation_storm
	name = "Rain"
	desc = "Gentle Rain, la la description."
	particleEffectType = /particles/weather/rads

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/rad_storm)
	weather_messages = list("Your skin feels tingly", "Your face is melting")

	minSeverity = 1
	maxSeverity = 100
	maxSeverityChange = 0
	severitySteps = 50
	immunity_type = TRAIT_RADSTORM_IMMUNE
	probability = 1
	target_trait = PARTICLEWEATHER_RADS

//STOLEN
/datum/particle_weather/radiation_storm/weather_act(mob/living/L)
	var/resist = L.getarmor(null)
	if(prob(40))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.dna && !HAS_TRAIT(H, TRAIT_GENELESS))
				if(prob(max(0,100-resist)))
					H.random_mutate_unique_identity()
					H.random_mutate_unique_features()
					if(prob(50))
						if(prob(90))
							H.easy_random_mutate(NEGATIVE+MINOR_NEGATIVE)
						else
							H.easy_random_mutate(POSITIVE)
						H.domutcheck()

/datum/particle_weather/rain_gentle
	name = "Rain"
	desc = "Gentle Rain, la la description."
	particleEffectType = /particles/weather/rain

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/rain)
	weather_messages = list("The rain cools your skin.")

	minSeverity = 1
	maxSeverity = 10
	maxSeverityChange = 5
	severitySteps = 5
	//immunity_type = TRAIT_RAINSTORM_IMMUNE
	probability = 1
	target_trait = PARTICLEWEATHER_RAIN

//Makes you a little chilly
/datum/particle_weather/rain_gentle/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(1,3))

/datum/particle_weather/rain_storm
	name = "Rain"
	desc = "Gentle Rain, la la description."
	particleEffectType = /particles/weather/rain

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/storm)
	weather_messages = list("The rain cools your skin.", "The storm is really picking up!")

	minSeverity = 4
	maxSeverity = 100
	maxSeverityChange = 50
	severitySteps = 50
	//immunity_type = TRAIT_RAINSTORM_IMMUNE
	probability = 1
	target_trait = PARTICLEWEATHER_RAIN

//Makes you a bit chilly
/datum/particle_weather/rain_storm/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(3,5))

/datum/particle_weather/snow_gentle
	name = "Rain"
	desc = "Gentle Rain, la la description."
	particleEffectType = /particles/weather/snow

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/snow)
	weather_messages = list("It's snowing!","You feel a chill/")

	minSeverity = 1
	maxSeverity = 10
	maxSeverityChange = 5
	severitySteps = 5
	immunity_type = TRAIT_SNOWSTORM_IMMUNE
	probability = 1
	target_trait = PARTICLEWEATHER_SNOW

//Makes you a little chilly
/datum/particle_weather/snow_gentle/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(1,3))


/datum/particle_weather/snow_storm
	name = "Rain"
	desc = "Gentle Rain, la la description."
	particleEffectType = /particles/weather/snow

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/snow)
	weather_messages = list("You feel a chill/", "The cold wind is freezing you to the bone", "How can a man who is warm, understand a man who is cold?")

	minSeverity = 40
	maxSeverity = 100
	maxSeverityChange = 50
	severitySteps = 50
	immunity_type = TRAIT_SNOWSTORM_IMMUNE
	probability = 1
	target_trait = PARTICLEWEATHER_SNOW

//Makes you a lot little chilly
/datum/particle_weather/snow_storm/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(5,15))
