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
	var/list/impacted_areas = list()

/datum/weather/proc/weather_start_up()
	for(var/area/N in get_areas(area_type))
		if(N.z == target_z)
			impacted_areas += N
	duration = rand(duration_lower,duration_upper)
	update_areas()
	for(var/mob/M in player_list)
		if(M.z == target_z)
			M << "<span class='danger'><B>[start_up_message]</B></span>"

	sleep(start_up_time)
	stage = MAIN_STAGE
	weather_main()


/datum/weather/proc/weather_main()
	update_areas()
	for(var/mob/M in player_list)
		if(M.z == target_z)
			M << "<span class='danger'><B>[duration_message]</B></span>"
	if(purely_aesthetic)
		sleep(duration*10)
	else  //Storm effects
		for(var/i in 1 to duration-1)
			for(var/mob/living/L in living_mob_list)
				var/area/storm_area = get_area(L)
				if(storm_area in impacted_areas)
					storm_act(L)
			sleep(10)

	stage = WIND_DOWN_STAGE
	weather_wind_down()


/datum/weather/proc/weather_wind_down()
	update_areas()
	for(var/mob/M in player_list)
		if(M.z == target_z)
			M << "<span class='danger'><B>[wind_down_message]</B></span>"

	sleep(wind_down)

	stage = END_STAGE
	update_areas()


/datum/weather/proc/storm_act(mob/living/L)
	if(prob(30)) //Dont want it spammed very tick
		L << "You're buffeted by the storm!"
		L.adjustBruteLoss(1)

/datum/weather/proc/update_areas()
	for(var/area/N in impacted_areas)
		N.layer = overlay_layer
		N.icon = 'icons/effects/weather_effects.dmi'
		N.invisibility = 0
		switch(stage)
			if(STARTUP_STAGE)
				N.icon_state = start_up_overlay

			if(MAIN_STAGE)
				N.icon_state = duration_overlay

			if(WIND_DOWN_STAGE)
				N.icon_state = start_up_overlay

			if(END_STAGE)
				N.icon_state = initial(N.icon_state)
				N.icon = 'icons/turf/areas.dmi'
				N.layer = 10 //Just default back to normal area stuff since I assume setting a var is faster than initial
				N.invisibility = 100
				N.opacity = 0