SUBSYSTEM_DEF(hotspots)
	name = "Oshan Hotspots"
	wait = 1 SECONDS
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_HOTSPOTS
	priority = FIRE_PRIORITY_HOTSPOT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	///the list of all the hotspots generated
	var/list/generated_hotspots = list()
	///the amount of groups we want to create. TODO defer hotspot generation until after roundstart to change this value for wackier rounds
	var/hotspots_to_generate = 30
	///the map_start map icon
	var/icon/map
	///the map icon with all the hotspots rendered ontop
	var/icon/finished_map
	///colors used in generating the map
	var/list/colors = list(
		"empty" = rgb(0, 0, 50),
		"solid" = rgb(0, 0, 255),
		"station" = rgb(0, 255, 149),
		"other" = rgb(73, 160, 194))

/datum/controller/subsystem/hotspots/Initialize()
	if(!length(SSmapping.levels_by_trait(ZTRAIT_OSHAN)))
		can_fire = FALSE // We dont want excess firing
		return SS_INIT_NO_NEED
	generate_hotspots()
	generate_map()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/hotspots/fire()
	if(!length(generated_hotspots))
		return
	for(var/datum/hotspot/generated_hotspot as anything in generated_hotspots)
		generated_hotspot.drift_count++
		if(generated_hotspot.drift_count >= generated_hotspot.drift_speed)
			generated_hotspot.drift_count = 0
			generated_hotspot.move_center(get_step(generated_hotspot.center.return_turf(), generated_hotspot.drift_direction))

/datum/controller/subsystem/hotspots/proc/generate_hotspots()
	var/datum/hotspot/new_hotspot
	for(var/integer = 1, integer <= hotspots_to_generate, integer++)
		//generate and append
		new_hotspot = new
		generated_hotspots += new_hotspot

		//random turf selection and checking to make sure we are in a non station area to prevent instant quakes
		var/turf/random_turf
		var/sanity_cap = 6
		while(sanity_cap > 0 && (!random_turf || istype(random_turf.loc, /area/station)))
			random_turf = locate(rand(1, world.maxx),rand(1, world.maxy), SSmapping.levels_by_trait(ZTRAIT_STATION)[1])
			sanity_cap--
		if(!random_turf)
			message_admins("ERROR: No random turf returned this is a severe issue")
			continue
		new_hotspot.move_center(random_turf)

/datum/controller/subsystem/hotspots/proc/debug_clear()
	generated_hotspots = list()

///attempts to retrieve a hotspot in this turf, if none found return FALSE.
///This only retrieves the first hotspot found, to retrieve a list call [retrieve_hotspot_list]
/datum/controller/subsystem/hotspots/proc/retrieve_hotspot(turf/pinged)
	. = FALSE
	for(var/datum/hotspot/listed_hotspot in generated_hotspots)
		if(listed_hotspot.get_tile_heat(pinged))
			. = listed_hotspot
			break

///works like [retrieve_hotspot] but on failure returns empty list, so check against length to determine if found.
/datum/controller/subsystem/hotspots/proc/retrieve_hotspot_list(turf/pinged)
	. = list()
	for(var/datum/hotspot/listed_hotspot in generated_hotspots)
		if(listed_hotspot.get_tile_heat(pinged))
			. += listed_hotspot

///when a turf is disturbed on maps with hotspot controller we need to check if we are inside the radius of a hotspot.
///NOTE: this will early return if not on a mining level because we only want the amplification if we had miners work for it.
/datum/controller/subsystem/hotspots/proc/disturb_turf(turf/triggered)
	if(!length(SSmapping.levels_by_trait(ZTRAIT_MINING)))
		return

	///total value of heat from the hotspots we ended up being inside
	var/total_heat = 0
	for(var/datum/hotspot/listed_hotspot in generated_hotspots)
		///temporary value of the heat, we need to check on the station z however as thats where we generated the hotspots
		var/heat = listed_hotspot.get_tile_heat(locate(triggered.x, triggered.y, SSmapping.levels_by_trait(ZTRAIT_STATION)[1]))
		if(heat)
			listed_hotspot.bonus_heat += listed_hotspot.per_disturbance
		total_heat += heat
	if(total_heat)
		kerpow(triggered)

///this is basically the flash's [AOE_flash] but here because aoe flash isn't a global proc.
/datum/controller/subsystem/hotspots/proc/kerpow(turf/source)
	var/list/mob/targets = get_flash_targets(get_turf(source), 3, FALSE)
	for(var/mob/living/carbon/nearby_carbon in targets)
		nearby_carbon.flash_act(1,1)
	return TRUE

/datum/controller/subsystem/hotspots/proc/get_flash_targets(atom/target_loc, range = 3, override_vision_checks = FALSE)
	if(!target_loc)
		return list()
	if(override_vision_checks)
		return get_hearers_in_view(range, get_turf(target_loc))
	if(isturf(target_loc) || (ismob(target_loc) && isturf(target_loc.loc)))
		return viewers(range, get_turf(target_loc))
	else
		return typecache_filter_list(target_loc.get_all_contents(), GLOB.typecache_living)

///this is where we handle the interaction between using a stomper on a turf and affecting a hotspot
///if its the center it locks position, if not it drifts it away from the stomper
///we calculate the drift direction using [angle2dir] and [arctan], which is less than perfect
///if this stops working in the future its because we broke one of those procs.
/datum/controller/subsystem/hotspots/proc/stomp(turf/stomped)
	. = 0
	for(var/datum/hotspot/listed_hotspot in generated_hotspots)
		if(!listed_hotspot.get_tile_heat(stomped))
			continue

		var/turf/hotspot_center = listed_hotspot.center.return_turf()

		///gotta be centered to stop movement
		if(BOUNDS_DIST(stomped, hotspot_center) > 0)
			listed_hotspot.can_drift = TRUE
			. = TRUE
		else
			listed_hotspot.can_drift = FALSE

		///we handle movement and recentering here
		listed_hotspot.drift_direction = angle2dir(arctan(hotspot_center.x - stomped.x, hotspot_center.y - stomped.y))
		listed_hotspot.move_center(get_step(hotspot_center, listed_hotspot.drift_direction))

///this proc returns the heat value from the given turf
/datum/controller/subsystem/hotspots/proc/return_heat(turf/source)
	var/return_value = 0
	for(var/datum/hotspot/listed_hotspot in generated_hotspots)
		if(listed_hotspot.vent_count <= 1)
			return_value += listed_hotspot.get_tile_heat(source)
		else
			return_value += (listed_hotspot.get_tile_heat(source) / listed_hotspot.vent_count) * (2 - (1 / (listed_hotspot.vent_count - 1)))
	var/hotspot_amount = length(retrieve_hotspot_list(source))
	return ((hotspot_amount > 1) ? (return_value * (1+ (hotspot_amount / 2.3))) : return_value)

///this is a debug tool item to move all hotspots to me
/datum/controller/subsystem/hotspots/proc/move_all_hotspots(client/source)
	if(!source.mob)
		return
	var/turf/turf = get_turf(source.mob)
	for(var/datum/hotspot/listed as anything in generated_hotspots)
		listed.move_center(turf, TRUE)
