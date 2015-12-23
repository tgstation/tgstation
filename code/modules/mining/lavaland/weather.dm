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
	var/duration_lower = 120
	var/duration_upper = 120
	var/duration_message = "A storm has started!"
	var/wind_down = 300 // 30 seconds
	var/wind_down_message = "The storm is passing."

	var/target_z = 1
	var/exclude_walls = TRUE
	var/area_type = /area/space
	var/stage = STARTUP_STAGE


	var/start_up_overlay = "lava"
	var/duration_overlay = "lava"
	var/overlay_layer = 10 //This is the default area layer, and above everything else. 2 is floors/below walls and mobs.
	var/purely_aesthetic = FALSE //If we just want gentle rain that doesn't hurt people

/datum/weather/proc/weather_start_up()
	duration = rand(duration_lower,duration_upper)
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
			for(var/mob/living/L in living_mob_list)
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
		if(stage == END_STAGE)
			T.weather = null
		else
			T.weather = src

	for(var/area/N in get_areas(area_type))
		if(N.z == target_z)
			N.layer = overlay_layer
			N.icon = 'icons/effects/weather_effects.dmi'
			N.invisibility = 0
			N.opacity = 1
			switch(stage)
				if(STARTUP_STAGE)
					N.icon_state = start_up_overlay

				if(MAIN_STAGE)
					N.icon_state = duration_overlay

				if(WIND_DOWN_STAGE)
					N.icon_state = start_up_overlay

				if(END_STAGE)
					N.icon_state = initial(N.icon_state)
					N.layer = 10 //Just default back to normal area stuff since I assume setting a var is faster than initial
					N.invisibility = 100
					N.opacity = 0
					activeWeather = null