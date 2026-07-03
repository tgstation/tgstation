//Darude sandstorm starts playing
/datum/weather/sand_storm
	name = "severe sandstorm"
	desc = "Сильный песчаный шторм охватывает обширные территории, нанося ощутимый ущерб всем, кому не повезло оказаться без защиты."

	telegraph_message = span_danger("Вы видите песчаные облака, поднимающиеся из-за горизонта. Это не кажется чем-то хорошим...")
	telegraph_duration = 30 SECONDS
	telegraph_overlay = "dust_med"
	telegraph_sound = 'sound/effects/siren.ogg'

	weather_message = span_userdanger("<i>Ветер ударяет в вас горячим песком. Немедленно прячьтесь внутрь!</i>")
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2 MINUTES
	weather_overlay = "dust_high"

	end_message = span_bolddanger("Ветер уносит от вас остатки песка и возвращается к своему привычному тихому гулу. Теперь можно безопасно выходить наружу.")
	end_duration = 30 SECONDS
	end_overlay = "dust_med"

	area_type = /area
	target_trait = ZTRAIT_SANDSTORM
	immunity_type = TRAIT_SANDSTORM_IMMUNE
	probability = 90

	weather_flags = (WEATHER_MOBS | WEATHER_BAROMETER)

/datum/weather/sand_storm/get_playlist_ref()
	return GLOB.sand_storm_sounds

/datum/weather/sand_storm/telegraph()
	GLOB.sand_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.sand_storm_sounds[impacted_area] = /datum/looping_sound/weak_outside_ashstorm
	return ..()

/datum/weather/sand_storm/start()
	GLOB.sand_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.sand_storm_sounds[impacted_area] = /datum/looping_sound/active_outside_ashstorm
	return ..()

/datum/weather/sand_storm/wind_down()
	GLOB.sand_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.sand_storm_sounds[impacted_area] = /datum/looping_sound/weak_outside_ashstorm
	return ..()

/datum/weather/sand_storm/weather_act_mob(mob/living/victim)
	victim.adjust_brute_loss(5, required_bodytype = BODYTYPE_ORGANIC)
	return ..()

/datum/weather/sand_storm/harmless
	name = "sandfall"
	desc = "Пролетающий мимо песчаный шторм покрывает местность слоем песка и пыли."

	telegraph_message = span_danger("Ветер начинает усиливаться, вздувая наверх песок с земли...")
	telegraph_overlay = "dust_low"
	telegraph_sound = null

	weather_message = span_notice("Песчинки медленно осыпаются вокруг вас, словно снег. Кажется, в этот раз шторм обошёл вас стороной...")
	weather_overlay = "dust_med"

	end_message = span_notice("Ветер постепенно замедляется и угасает. Очередной слой песка оседает на землю под вами...")
	end_overlay = "dust_low"

	probability = 10
	weather_flags = parent_type::weather_flags & ~WEATHER_MOBS
