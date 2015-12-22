/datum/weather/floor_is_lava
	name = "floor is lava"
	start_up_time = 30 //3 seconds
	start_up_message = "The ground begins to bubble."
	duration = 60 //1 minute
	duration_message = "The floor is lava!"
	wind_down = 30// 3 seconds
	wind_down_message = "The ground begins to cool."

	target_z = 1
	exclude_walls = TRUE
	area_type = /area

	start_up_overlay = "lava"
	duration_overlay = "lava"


/datum/weather/floor_is_lavaproc/storm_act(mob/living/L)
	var/safe = 0
	var/turf/F = get_turf(L)
	for(var/obj/structure/O in L.contents)
		if(O.level > F.level && !istype(O, /obj/structure/window)) // Something to stand on and it isn't under the floor!
			safe = 1
			break
	if(!safe)
		L.adjustFireLoss(3)