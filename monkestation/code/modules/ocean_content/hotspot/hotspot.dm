/datum/hotspot
	///list of statics
	///the amount of heat we lose per turf
	var/static/heat_diminish = 0.1
	///the base amount of heat every hotspot starts with
	var/static/base_heat = 1000
	///the amount of heat we add per disturbance
	var/static/per_disturbance = 60
	///the amount of distance of leeway we give tile_heat.
	var/static/leeway = 2

	///how much of our heat is bonus heat
	var/bonus_heat = 0
	///the center point of our hotspot stored as a datum as its more than a turf.
	///The reason its a datum over a turf is because i dont wanna add listeners to a turf incase of destruction as we dont deal with the turf enough to justify that.
	///another reason is because this needs to be tracked on the trench aswell
	var/datum/hotspot_center/center = new
	///the radius of our hotspot
	var/radius = 8
	///are we able to drift?
	var/can_drift = TRUE
	///the direction we are currently drifting, randomized on creation.
	var/drift_direction
	///the speed in seconds until we move
	var/drift_speed = 60
	///the amount of counts we've gone up, compares against the above var for movement
	var/drift_count = 0
	///number of capturing vents inside of us
	var/vent_count = 0


/datum/hotspot/New()
	. = ..()
	drift_direction = pick(GLOB.alldirs)

/datum/hotspot/proc/move_center(turf/destination, force = FALSE)
	if(!can_drift && !force)
		return
	if(!destination)
		return
	///we check if we touch the worlds edge, or hit a turf we deem as a blacklist ie unbreakable trench edge walls
	if(is_edge_or_blacklist(destination))
		drift_direction = turn(drift_direction, 180)
		return

	center.relocate(destination.x, destination.y, destination.z)

	///if we are end of round or pre round no point in checking vents or dousing rods. As latter there will never be any and former doesn't matter as rounds over.
	if(SSticker.current_state != GAME_STATE_PLAYING)
		return
	///we need to recalculate vents
	vent_count = 0

	///list of heat dousing rods in the radius
	var/list/dousing_rods = list()
	for(var/turf/listed_turf in range(radius, destination))
		if(!istype(listed_turf, /turf/open/floor/plating/ocean))
			continue
		///assign the ocean turf and check if captured if so add to {vent_count}
		var/turf/open/floor/plating/ocean/listed_ocean = listed_turf
		if(listed_ocean.captured)
			vent_count++

		///now we early return a [locate] on a dousing rod. If we find one we add it to a list to run checks on at the end
		var/obj/item/dousing_rod/located_rod = locate() in listed_ocean
		if(!located_rod)
			continue
		dousing_rods += located_rod

	///now we check if the dousing rods are deployed, and if so we follow the hotspot
	for(var/obj/item/dousing_rod/located_rod as anything in dousing_rods)
		if(!located_rod.deployed)
			continue
		step(located_rod, drift_direction)

	after_move_effect()

/datum/hotspot/proc/is_edge_or_blacklist(turf/destination)
	///we want hotspots to always stay on the station z-level
	if(destination.z != SSmapping.levels_by_trait(ZTRAIT_STATION)[1])
		return TRUE
	///okay so um, you can somehow get values higher than world.maxx or world.maxy according to runtimes so this fixes that
	if(destination.x >= world.maxx || destination.x <= 1 || destination.y >= world.maxy || destination.y <= 1)
		return TRUE
	return FALSE

///this proc is pretty expensive but it forces a recalculation of vents in the radius of the hotspot from the center
/datum/hotspot/proc/calculate_vent_count(turf/center_turf)
	vent_count = 0
	for(var/turf/open/floor/plating/ocean/surrounding_ocean in range(radius, center_turf))
		if(!surrounding_ocean.captured)
			continue
		vent_count++

///this returns the amount of heat the given tile generates, if none returns 0/FALSE
/datum/hotspot/proc/get_tile_heat(turf/given_turf)
	var/distance = get_dist(given_turf, center.return_turf())

	//this handles anything greater than radius + leeway and leaves us with 2 ranges in leeway but greater than radius, and in radius
	if(distance > radius + leeway)
		return 0

	var/total_heat = base_heat + bonus_heat

	if(given_turf == center.return_turf())//we fucked up bad
		return total_heat

	if(distance > radius)
		return total_heat * ((heat_diminish * 0.6) / (distance - radius))

	//calculates heat very badly using this graph as a base https://www.desmos.com/calculator/kyxrzpdzuf
	return max(total_heat - (total_heat * (heat_diminish * distance)), 0)



#define WEAK_QUAKE 1
#define QUAKE 2
#define WEAK_FIRE 4
#define FIRE_EVENT 8
#define WEAK_EXPLOSION 16
#define EXPLOSION 32

#define SUBCALL_HEATCOST 9500

/datum/hotspot/proc/after_move_effect(subcalls = 1, subcall_heat)
	var/turf/center_turf = center.return_turf()
	if(!center_turf)//how?
		return
	///we run all events of a snigle turf inside the hotspots area, this allows stuff like flashes and fires to happen from the inside if a centers turf is outside
	var/turf/calculation_point = locate(center_turf.x + (rand(-radius, radius) * 0.5), center_turf.y + (rand(-radius, radius) * 0.5), SSmapping.levels_by_trait(ZTRAIT_STATION)[1])
	if(!calculation_point)
		return
	///now we calculate heat
	var/heat = subcall_heat ? subcall_heat : SShotspots.return_heat(calculation_point)
	///event flags
	var/event_flags

	///we need to somehow convert a value into a list of flags we are gonna do this via a switch statement, now with 100% more distribution to quakes
	switch(heat)
		///QUAKES
		if(200 to 1499)
			event_flags = WEAK_QUAKE
		if(1500 to 4999)
			event_flags = QUAKE
		///FIRES
		if(5000 to 5999)
			event_flags = QUAKE | WEAK_FIRE
		if(6000 to 6999)
			event_flags = QUAKE | FIRE_EVENT
		///EXPLOSIONS
		if(7000 to 8999)
			event_flags = QUAKE | FIRE_EVENT | WEAK_EXPLOSION
		if(9000 to INFINITY)
			event_flags = QUAKE | FIRE_EVENT | EXPLOSION

	///quakes are camera shakes so we scan for mobs in range
	for(var/mob/listed_mob in range(9, calculation_point))
		if((event_flags & WEAK_QUAKE))
			to_chat(listed_mob, span_notice("The ground shakes softly beneath you."))
			shake_camera(listed_mob, 2, 2)
		if(event_flags & QUAKE)
			to_chat(listed_mob, span_danger("The ground shakes violently beneath you."))
			shake_camera(listed_mob, 4, 4)
			if(isliving(listed_mob))
				var/mob/living/listed_living = listed_mob
				listed_living.adjustBruteLoss(5)
				if(iscarbon(listed_mob))
					var/mob/living/carbon/carbon_mob = listed_mob
					carbon_mob.stamina.adjust(-30)

	if(!istype(calculation_point, /turf/open/floor/plating/ocean))
		if(event_flags & WEAK_FIRE)
			explosion(calculation_point, 0,  0, 0, 3, 0, adminlog = FALSE)
		if(event_flags & FIRE_EVENT)
			explosion(calculation_point, 0,  0, 0, 7, 0, adminlog = FALSE)

	if(event_flags & WEAK_EXPLOSION)
		explosion(calculation_point, 0,  0, 1, 0, 3, adminlog = FALSE)
	if(event_flags & EXPLOSION)
		explosion(calculation_point, 0, 0, 3, 0, 5, adminlog = FALSE)

	var/area_name_string = get_area_name(calculation_point)
	var/message
	if(heat > SUBCALL_HEATCOST * subcalls)
		message = "Big Hotspot event triggered at [AREACOORD(calculation_point)] in [area_name_string] with a heat value of [heat]"
		spawn(3 SECONDS)
			after_move_effect(subcalls++, heat - ((SUBCALL_HEATCOST + 500) * subcalls))
	else
		message = "Small Hotspot event triggered at [AREACOORD(calculation_point)] in [area_name_string] with a heat value of [heat]"

	if((istype(calculation_point.loc, /area/station) && heat > 4500) || heat > SUBCALL_HEATCOST * subcalls)
		message_admins(message)
	log_admin(message)

#undef SUBCALL_HEATCOST

#undef WEAK_QUAKE
#undef QUAKE
#undef WEAK_FIRE
#undef FIRE_EVENT
#undef WEAK_EXPLOSION
#undef EXPLOSION
