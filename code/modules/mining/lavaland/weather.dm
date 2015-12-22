var/global/datum/weather/activeWeather

#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4

/datum/weather
	var/name = "storm"
	var/start_up_time = 300 //30 seconds
	var/start_up_message = "The wind begins to pick up."
	var/duration = 120 //2 minutes
	var/duration_message = "A storm has started!"
	var/wind_down = 300 // 30 seconds
	var/wind_down_message = "The storm is passing."

	var/target_z = 1
	var/exclude_walls = TRUE
	var/area_type = /area/space
	var/stage = STARTUP_STAGE


	var/start_up_overlay = "lava"
	var/duration_overlay = "lava"
	var/purely_aesthetic = FALSE //If we just want gentle rain that doesn't hurt people

/datum/weather/proc/weather_start_up()
	if(activeWeather)
		return
	activeWeather = src
	update_turfs()
	for(var/mob/M in player_list)
		if(M.z == target_z)
			M << "[start_up_message]"

	sleep(start_up_time)
	stage = MAIN_STAGE
	weather_main()


/datum/weather/proc/weather_main()
	update_turfs()
	for(var/mob/M in player_list)
		if(M.z == target_z)
			M << "[duration_message]"
	if(purely_aesthetic)
		sleep(duration*10)
	else  //Storm effects
		for(var/i in 1 to duration-1)
			for(var/mob/living/L in living_mob_list)	.
				var/turf/Z = get_turf(L)
				if(Z.weather == src)
					storm_act(L)
					sleep(10)

	stage = WIND_DOWN_STAGE
	weather_wind_down()


/datum/weather/proc/weather_wind_down()
	update_turfs()
	for(var/mob/M in player_list)
		if(M.z == target_z)
			M << "[wind_down_message]"

	sleep(wind_down)

	stage = END_STAGE
	update_turfs()


/datum/weather/proc/storm_act(mob/living/L)
	if(prob(30)) //Dont want it spammed very tick
		L << "You're buffeted by the storm!"
		L.adjustBruteLoss(1)

/datum/weather/proc/update_turfs()
	for(var/turf/T in get_area_turfs(area_type, target_z))
		if(exclude_walls && T.density == 1)
			continue
		switch(stage)
			if(STARTUP_STAGE)
				T.overlays += "[start_up_overlay]"
				T.weather = src
			if(MAIN_STAGE)
				T.overlays -= "[duration_overlay]"
				T.overlays += "[duration_overlay]"
				T.weather = src
			if(WIND_DOWN_STAGE)
				T.overlays -= "[duration_overlay]"
				T.overlays += "[start_up_overlay]"
				T.weather = src
			if(END_STAGE)
				T.overlays -= start_up_overlay
				T.weather = null
				activeWeather = null