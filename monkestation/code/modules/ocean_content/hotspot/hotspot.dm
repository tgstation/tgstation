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
	///we check if we touch the worlds edge, or hit a turf we deem as a blacklist ie unbreakable trench edge walls
	if(is_edge_or_blacklist(destination))
		drift_direction = turn(drift_direction, 180)
		return

	center.relocate(destination.x, destination.y, destination.z)

	///if we are end of round or pre round no point in checking vents or dousing rods. As latter there will never be any and former doesn't matter as rounds over.
	if(!SSticker.current_state != GAME_STATE_PLAYING)
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

	if(distance == -1)//we fucked up bad
		return
	//this handles anything greater than radius + leeway and leaves us with 2 ranges in leeway but greater than radius, and in radius
	if(distance > radius + leeway)
		return 0

	var/total_heat = base_heat + bonus_heat

	if(distance > radius)
		return total_heat * ((heat_diminish * 0.6) / (distance - radius))

	//calculates heat very badly using this graph as a base https://www.desmos.com/calculator/kyxrzpdzuf
	return max(total_heat - (total_heat * (heat_diminish * distance)), 0)
