var/global/activeWeather = FALSE

/datum/weather
	var/name = "storm"
	var/start_up_time = 300 //30 seconds
	var/start_up_message = "The wind begins to pick up."
	var/duration = 1200 //2 minutes
	var/duration_message = "A storm has started!"
	var/wind_down = 300 // 30 seconds
	var/wind_down_message = "The storm is passing."

	var/target_z = 1
	var/exclude_walls = TRUE
	var/area_type = /area/space

	var/start_up_overlay = "lava"
	var/duration_overlay = "lava"
	var/purely_aesthetic = FALSE //If we just want gentle rain that doesn't hurt people



/datum/weather/proc/weather_start_up()
	if(activeWeather)
		return
	activeWeather = TRUE
	for(var/turf/T in get_area_turfs(area_type, target_z))
		if(exclude_walls && T.density == 1)
			continue
		T.overlays += "lava"
		T.weather = TRUE
	for(var/mob/M in player_list)
		if(M.z == target_z)
			M << "[start_up_message]"

	sleep(start_up_time)
	weather_main()



/datum/weather/proc/weather_main()
	for(var/turf/T in get_area_turfs(area_type, target_z))
		if(exclude_walls && T.density == 1)
			continue
		T.overlays -= "lava"
		T.overlays += "[duration_overlay]"
		T.weather = TRUE
	for(var/mob/M in player_list)
		if(M.z == target_z)
			M << "[duration_message]"
	if(purely_aesthetic)
		sleep(duration*10)
		weather_wind_down()
		return

	//Storm effects
	for(var/i = i, i < duration, i++)
		for(var/mob/living/L in living_mob_list)	.
			var/turf/Z = get_turf(L)
			if(Z.weather)
				storm_act(L)

	weather_wind_down()


/datum/weather/proc/weather_wind_down()
	for(var/turf/T in get_area_turfs(area_type, target_z))
		if(exclude_walls && T.density == 1)
			continue
		T.overlays -= "lava"
		T.overlays += "[start_up_overlay]"
		T.weather = TRUE
	for(var/mob/M in player_list)
		if(M.z == target_z)
			M << "[wind_down_message]"

	sleep(wind_down)

	for(var/turf/T in get_area_turfs(area_type, target_z))
		if(exclude_walls && T.density == 1)
			continue
		T.overlays -= start_up_overlay
		T.weather = FALSE
	activeWeather = FALSE


/datum/weather/proc/storm_act(mob/living/L)
	if(prob(30)) //Dont want it spammed very tick
		L << "You're buffeted by the storm!"
		L.adjustBruteLoss(1)