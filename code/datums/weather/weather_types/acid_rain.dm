//Acid rain is part of the natural weather cycle in the humid forests of Planetstation, and cause acid damage to anyone unprotected.
/datum/weather/acid_rain
	name = "acid rain"
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	telegraph_duration = 400
	telegraph_message = "<span class='boldwarning'>Thunder rumbles far above. You hear droplets drumming against the canopy. Seek shelter.</span>"
	telegraph_sound = 'sound/ambience/acidrain_start.ogg'

	weather_message = "<span class='userdanger'><i>Acidic rain pours down around you! Get inside!</i></span>"
	weather_overlay = "acid_rain"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_sound = 'sound/ambience/acidrain_mid.ogg'

	end_duration = 100
	end_message = "<span class='boldannounce'>The downpour gradually slows to a light shower. It should be safe outside now.</span>"
	end_sound = 'sound/ambience/acidrain_end.ogg'

	area_type = /area/lavaland/surface/outdoors
	target_trait = ZTRAIT_MINING

	immunity_type = "acid" // temp

	barometer_predictable = TRUE


/datum/weather/acid_rain/weather_act(mob/living/L)
	L.acid_act(100,1)

/datum/weather/acid_rain/cloud
	target_trait = ZTRAIT_STATION
	probability = 0
	barometer_predictable = FALSE
	area_type = /area
	protected_areas = list(/area/shuttle)
	telegraph_message = "<span class='boldwarning'>Droplets of acid begin to drip and sizzle around you.</span>"
	weather_message = "<span class='userdanger'><i>Acidic rain pours down around you!</i></span>"
	end_message = "<span class='boldannounce'>The downpour gradually slows and stops.</span>"


/datum/weather/acid_rain/cloud/telegraph()
	..()
	priority_announce("Incoming acid cloud", "Anomaly Alert")

/datum/weather/acid_rain/cloud/end()
	..()
	priority_announce("The acid cloud has passed", "Anomaly Alert")
