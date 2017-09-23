//Ash storms happen frequently on lavaland. They heavily obscure vision, and cause high fire damage to anyone caught outside.
/datum/weather/ash_storm
	name = "ash storm"
	desc = "An intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	telegraph_message = "<span class='boldwarning'>An eerie moan rises on the wind. Sheets of burning ash blacken the horizon. Seek shelter.</span>"
	telegraph_duration = 300
	telegraph_sound = 'sound/lavaland/ash_storm_windup.ogg'
	telegraph_overlay = "light_ash"

	weather_message = "<span class='userdanger'><i>Smoldering clouds of scorching ash billow down around you! Get inside!</i></span>"
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_sound = 'sound/lavaland/ash_storm_start.ogg'
	weather_overlay = "ash_storm"

	end_message = "<span class='boldannounce'>The shrieking wind whips away the last of the ash and falls to its usual murmur. It should be safe to go outside now.</span>"
	end_duration = 300
	end_sound = 'sound/lavaland/ash_storm_end.ogg'
	end_overlay = "light_ash"

	area_type = /area/lavaland/surface/outdoors
	target_z = ZLEVEL_LAVALAND

	immunity_type = "ash"

	probability = 90

/datum/weather/ash_storm/proc/is_ash_immune(mob/living/L)
	if(istype(L.loc, /obj/mecha)) //Mechs are immune
		return TRUE
	if(ishuman(L)) //Are you immune?
		var/mob/living/carbon/human/H = L
		var/thermal_protection = H.get_thermal_protection()
		if(thermal_protection >= FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
			return TRUE
	if(istype(L.loc, /mob/living) && L.loc != L) //Matryoshka check
		return is_ash_immune(L.loc)
	return FALSE //RIP you

/datum/weather/ash_storm/weather_act(mob/living/L)
	if(is_ash_immune(L))
		return
	L.adjustFireLoss(4)


//Emberfalls are the result of an ash storm passing by close to the playable area of lavaland. They have a 10% chance to trigger in place of an ash storm.
/datum/weather/ash_storm/emberfall
	name = "emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	weather_message = "<span class='notice'>Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...</span>"
	weather_sound = 'sound/lavaland/ash_storm_windup.ogg'
	weather_overlay = "light_ash"

	end_message = "<span class='notice'>The emberfall slows, stops. Another layer of hardened soot to the basalt beneath your feet.</span>"
	end_sound = null

	aesthetic = TRUE

	probability = 10
