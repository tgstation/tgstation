/datum/weather/snow_storm
	name = "snow storm"
	desc = "Суровые метели обдувают поверхность этой холодной планеты, зарывая в снег всех, кому не повезло встать на их пути."
	probability = 90

	telegraph_message = span_warning("В воздухе начинают скапливаться крупные снежинки...")
	telegraph_duration = 30 SECONDS
	telegraph_overlay = "light_snow"
	telegraph_sound = 'sound/ambience/weather/snowstorm/snow_start.ogg'
	telegraph_sound_vol = /datum/looping_sound/snowstorm::volume + 10

	weather_message = span_userdanger("<i>Сильная метель начинает разносить падающий с неба снег! Немедленно прячьтесь внутрь!</i>")
	weather_overlay = "snow_storm"
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2.5 MINUTES
	use_glow = FALSE

	end_duration = 10 SECONDS
	end_message = span_bolddanger("Метель успокаивается, теперь можно безопасно выходить наружу.")
	end_sound = 'sound/ambience/weather/snowstorm/snow_end.ogg'
	end_sound_vol = /datum/looping_sound/snowstorm::volume + 10

	area_type = /area
	target_trait = ZTRAIT_SNOWSTORM

	immunity_type = TRAIT_SNOWSTORM_IMMUNE

	// snowstorms should be colder than default icebox atmos
	weather_temperature = ICEBOX_MIN_TEMPERATURE - 40
	// snowstorms temperature ignores any clothing insulation
	weather_flags = (WEATHER_MOBS | WEATHER_BAROMETER | WEATHER_TEMPERATURE_BYPASS_CLOTHING | WEATHER_STRICT_ALERT)

/datum/weather/snow_storm/get_playlist_ref()
	return GLOB.snowstorm_sounds

/datum/weather/snow_storm/start()
	GLOB.snowstorm_sounds.Cut() // it's passed by ref
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.snowstorm_sounds[impacted_area] = /datum/looping_sound/snowstorm
	return ..()

/datum/weather/snow_storm/end()
	GLOB.snowstorm_sounds.Cut()
	return ..()

///A storm that doesn't stop storming, and is a bit stronger
/datum/weather/snow_storm/forever_storm
	telegraph_duration = 0 SECONDS
	weather_flags = parent_type::weather_flags | WEATHER_ENDLESS

	probability = 0
	weather_temperature = parent_type::weather_temperature - 40 // faster cooling effects at lower temps
