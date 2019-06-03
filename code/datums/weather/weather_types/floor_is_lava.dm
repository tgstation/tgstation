//Causes fire damage to anyone not standing on a dense object.
/datum/weather/floor_is_lava
	name = "the floor is lava"
	desc = "The ground turns into surprisingly cool lava, lightly damaging anything on the floor."

	telegraph_message = "<span class='warning'>You feel the ground beneath you getting hot. Waves of heat distort the air.</span>"
	telegraph_duration = 15 SECONDS

	weather_message = "<span class='userdanger'>The floor is lava! Get on top of something!</span>"
	weather_duration_lower = 30 SECONDS
	weather_duration_upper = 60 SECONDS
	weather_overlay = "lava"

	end_message = "<span class='danger'>The ground cools and returns to its usual form.</span>"
	end_duration = 0

	area_type = /area
	protected_areas = list(/area/space)
	target_trait = ZTRAIT_STATION

	overlay_layer = ABOVE_OPEN_TURF_LAYER //Covers floors only
	overlay_plane = FLOOR_PLANE
	immunity_type = "lava"


/datum/weather/floor_is_lava/weather_act(mob/living/L)
	if(issilicon(L))
		return
	if(istype(L.buckled, /obj/structure/bed))
		return
	for(var/obj/structure/O in L.loc)
		if(O.density)
			return
	if(L.loc.density)
		return
	if(!L.client) //Only sentient people are going along with it!
		return
	if(L.movement_type & FLYING)
		return
	L.adjustFireLoss(3)

/datum/weather/floor_is_lava/molten
	target_trait = ZTRAIT_STATION
	probability = 0
	telegraph_duration = 30 SECONDS
	protected_areas = list(/area/shuttle)
	barometer_predictable = TRUE

/datum/weather/floor_is_lava/molten/telegraph()
	..()
	priority_announce("Incoming molten heat", "Anomaly Alert")

/datum/weather/floor_is_lava/molten/end()
	..()
	priority_announce("The molten heat has passed", "Anomaly Alert")
