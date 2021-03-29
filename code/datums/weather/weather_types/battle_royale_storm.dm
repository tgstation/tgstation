


GLOBAL_DATUM(storm_controller, /datum/storm_controller)

/datum/storm_controller
	var/area_consume_timer = 1 MINUTES
	///which list to pick from
	var/list/current_area_pick
	///outer areas, does not include space
	var/list/outer_areas
	///middle areas
	var/list/middle_areas
	///inner areas
	var/list/inner_areas
	///how many lists it has left
	var/progression = 3
	///timer id to the next area consumption
	var/timerid
	///active weathers
	var/list/storms = list()

/datum/storm_controller/New()
	outer_areas = GLOB.externalareasstorm.Copy()
	//middle
	//inner
	current_area_pick = outer_areas
	send_to_playing_players("<span class='userdanger'>The storm has been created! It will consume the station from the outside in, so keep on the move!</span>")
	consume_area(area/space, repeat = FALSE)
	consume_area(area/space/nearstation, repeat = TRUE) //start the storm


/datum/storm_controller/proc/consume_area(area/area_path, repeat = TRUE)
	var/datum/weather/royale_storm/storm = new storm(list(SSmapping.levels_by_trait(STATION_TRAIT)))
	storms += storm
	storm.area_type = area_path
	storm.telegraph()
	if(repeat)
		if(!current_area_pick.len) //there was none left, don't try and take from an empty list
			return
		timerid = addtimer(CALLBACK(src, .proc/consume_area, pick_n_take(current_area_pick)), area_consume_timer)
		if(!current_area_pick.len) //we took the last one
			progression--
			switch(progression)
				if(2)
					send_to_playing_players("<span class='userdanger'>The storm has consumed the entire outer station!</span>")
					area_consume_timer -= 25 SECONDS //get a little faster
					current_area_pick = middle_areas
				if(1)
					send_to_playing_players("<span class='userdanger'>The storm has consumed the majority of the station!</span>")
					current_area_pick = inner_areas
				if(0)
					send_to_playing_players("<span class='userdanger'>The storm has consumed the ENTIRE station!</span>")

///stops the storm.
/datum/storm_controller/proc/stop_storm()
	send_to_playing_players("<span class='userdanger'>The storm has been halted by centcom!</span>")
	if(timerid)
		deltimer(timerid)

///ends the storm.
/datum/storm_controller/proc/end_storm()
	for(var/datum/weather/storm as anything in storms)
		storm.wind_down()
	storms = null
	qdel(src)

/// these nuts?
/datum/weather/royale_storm
	name = "royale storm"
	desc = "A sick creation of the most ADHD ridden centcom scientists, used to force stationgoers to fight with the threat of being shredded by an artificial storm for entertainment."

	weather_overlay = "royale"
	weather_duration_lower = INFINITY-1
	weather_duration_upper = INFINITY


	telegraph_message = null
	weather_message = null
	end_message = null

	target_trait = ZTRAIT_STATION

	immunity_type = "NOTHING KID"

/datum/weather/royale_storm/weather_act(mob/living/L)
	L.adjustFireLoss(15)
	if(L.stat == DEAD)
		to_chat(L, "<span class='userdanger'>You're torn apart from the violent forces in the storm!</span>")
		L.gib(TRUE)
	else
		to_chat(L, "<span class='userdanger'>You're badly burned by the storm!</span>")

