//Restricts the vision of affected mobs to a single tile in the cardinal directions.
/datum/weather/advanced_darkness
	name = "advanced darkness"
	desc = "Everything in the area is effectively blinded, unable to see more than a foot or so around itself."

	telegraph_message = "<span class='warning'>Your eyes hurt... a vignette settles in your vision and closes in.</span>"
	telegraph_duration = 150

	weather_message = "<span class='userdanger'>This isn't your average everday darkness... this is <i>advanced</i> darkness!</span>"
	weather_duration_lower = 300
	weather_duration_upper = 300

	end_message = "<span class='danger'>At last, the darkness recedes.</span>"
	end_duration = 0

	area_type = /area
	target_z = ZLEVEL_STATION_PRIMARY

/datum/weather/advanced_darkness/update_areas()
	for(var/V in impacted_areas)
		var/area/A = V
		if(stage == MAIN_STAGE)
			A.invisibility = 0
			A.set_opacity(TRUE)
			A.layer = overlay_layer
			A.icon = 'icons/effects/weather_effects.dmi'
			A.icon_state = "darkness"
		else
			A.invisibility = INVISIBILITY_MAXIMUM
			A.set_opacity(FALSE)
