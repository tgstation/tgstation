/// Ash storms happen frequently on lavaland. They heavily obscure vision, and cause high fire damage to anyone caught outside.
/datum/weather/particle/ash_storm
	name = "ash storm"
	desc = "An intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	particle_type = /particles/weather/ash_storm
	emissive_type = /particles/weather/ash_storm/embers
	min_severity = 60
	optimal_severity = 80
	particle_weather_alpha = 100
	wind_sign = -1 // Always blows left to sync with the animated overlays

	telegraph_message = span_boldwarning("An eerie moan rises on the wind. Sheets of burning ash blacken the horizon. Seek shelter.")
	telegraph_duration = 30 SECONDS
	telegraph_overlay = "light_ash"

	weather_message = span_userdanger("<i>Smoldering clouds of scorching ash billow down around you! Get inside!</i>")
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2 MINUTES
	weather_overlay = "ash_storm"

	end_message = span_bolddanger("The shrieking wind whips away the last of the ash and falls to its usual murmur. It should be safe to go outside now.")
	end_duration = 30 SECONDS
	end_overlay = "light_ash"

	area_type = /area
	target_trait = ZTRAIT_ASHSTORM
	immunity_type = TRAIT_ASHSTORM_IMMUNE
	probability = 90
	turf_thunder_chance = THUNDER_CHANCE_VERY_RARE
	thunder_color = "#7a0000"

	weather_flags = (WEATHER_MOBS | WEATHER_BAROMETER | WEATHER_THUNDER)

	var/list/weak_sounds = list()
	var/list/strong_sounds = list()

/particles/weather/ash_storm
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("chill_1" = 4, "chill_2" = 3, "chill_3" = 2)
	position = generator(GEN_BOX, list(-510, -256, 0), list(400, 512, 0))
	grow = list(-0.01, -0.01)
	gravity = list(0, -7, 0.5)
	drift = generator(GEN_BOX, list(-1, -1, 0), list(1, 0, 0))
	friction = 0.3
	min_spawn = 20
	max_spawn = 400
	wind_strength = 16
	spin = generator(GEN_NUM, -5, 5, NORMAL_RAND)
	/// Y-coordinate of our gravity
	var/gravity_power = -12

/particles/weather/ash_storm/animate_severity(severity)
	. = ..()
	if (length(gravity) > 1)
		gravity[2] = gravity_power * severity
	else
		gravity = list(gravity[1], gravity_power * severity, 0.5)

/particles/weather/ash_storm/embers
	icon = 'icons/effects/particles/generic.dmi'
	icon_state = list("dot" = 4, "cross" = 2, "curl" = 1)
	color = LIGHT_COLOR_FIRE
	min_spawn = 10
	max_spawn = 80

/particles/weather/ash_storm/emberfall
	min_spawn = 20
	max_spawn = 200
	wind_strength = 3
	gravity_power = -2

/particles/weather/ash_storm/embers/emberfall
	min_spawn = 20
	max_spawn = 200
	wind_strength = 3
	gravity_power = -2

/datum/weather/particle/ash_storm/get_playlist_ref()
	return GLOB.ash_storm_sounds

/datum/weather/particle/ash_storm/telegraph()
	for(var/area/impacted_area as anything in impacted_areas)
		if(impacted_area.outdoors)
			weak_sounds[impacted_area] = /datum/looping_sound/weak_outside_ashstorm
			strong_sounds[impacted_area] = /datum/looping_sound/active_outside_ashstorm
		else
			weak_sounds[impacted_area] = /datum/looping_sound/weak_inside_ashstorm
			strong_sounds[impacted_area] = /datum/looping_sound/active_inside_ashstorm

	//We modify this list instead of setting it to weak/stron sounds in order to preserve things that hold a reference to it
	//It's essentially a playlist for a bunch of components that chose what sound to loop based on the area a player is in
	GLOB.ash_storm_sounds += weak_sounds
	return ..()

/datum/weather/particle/ash_storm/start()
	GLOB.ash_storm_sounds -= weak_sounds
	GLOB.ash_storm_sounds += strong_sounds
	return ..()

/datum/weather/particle/ash_storm/wind_down()
	GLOB.ash_storm_sounds -= strong_sounds
	GLOB.ash_storm_sounds += weak_sounds
	return ..()

/datum/weather/particle/ash_storm/recursive_weather_protection_check(atom/to_check)
	. = ..()
	if(. || !ishuman(to_check))
		return
	var/mob/living/carbon/human/human_to_check = to_check
	if(human_to_check.get_thermal_protection() >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
		return TRUE

/datum/weather/particle/ash_storm/weather_act_mob(mob/living/victim)
	victim.adjust_fire_loss(4, required_bodytype = BODYTYPE_ORGANIC)
	return ..()

/datum/weather/particle/ash_storm/end()
	GLOB.ash_storm_sounds -= weak_sounds
	GLOB.ash_storm_sounds -= strong_sounds
	for(var/turf/open/misc/asteroid/basalt/basalt as anything in GLOB.dug_up_basalt)
		if(!(basalt.loc in impacted_areas) || !(basalt.z in impacted_z_levels))
			continue
		basalt.refill_dug()
	return ..()

//Emberfalls are the result of an ash storm passing by close to the playable area of lavaland. They have a 10% chance to trigger in place of an ash storm.
/datum/weather/particle/ash_storm/emberfall
	name = "emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	weather_message = span_notice("Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...")
	weather_overlay = "light_ash"

	end_message = span_notice("The emberfall slows, stops. Another layer of hardened soot to the basalt beneath your feet.")
	end_sound = null

	weather_flags = parent_type::weather_flags & ~(WEATHER_MOBS|WEATHER_THUNDER)

	probability = 10

	particle_type = /particles/weather/ash_storm/emberfall
	emissive_type = /particles/weather/ash_storm/embers/emberfall
