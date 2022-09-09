/**
 * area
 *
 * we're adding mobile port to station areas, which all ships use.
 */
/area/station
	/// The mobile port attached to this area
	var/obj/docking_port/mobile/voidcrew/station_ship

/area/station/Initialize(mapload)
	. = ..()
	//we always have gravity.
	has_gravity = TRUE
	RegisterSignal(SSdcs, COMSIG_AREA_CREATED, .proc/on_area_creation)

/area/station/Destroy()
	station_ship = null
	UnregisterSignal(SSdcs, COMSIG_AREA_CREATED)
	return ..()

/area/station/PlaceOnTopReact(list/new_baseturfs, turf/fake_turf_type, flags) //from shiptest
	. = ..()
	if(length(new_baseturfs) > 1 || fake_turf_type)
		return // More complicated larger changes indicate this isn't a player
	if(ispath(new_baseturfs[1], /turf/open/floor/plating) && !new_baseturfs.Find(/turf/baseturf_skipover/shuttle))
		new_baseturfs.Insert(1, /turf/baseturf_skipover/shuttle)

/area/station/proc/link_to_shuttle(obj/docking_port/mobile/link)
	station_ship = link

/area/station/proc/on_area_creation(datum/source, area/created, area/overwritten, mob/creator)
	SIGNAL_HANDLER

	if(!(overwritten in created)) //not our ship? not our problem.
		return

	INVOKE_ASYNC(station_ship, /obj/docking_port/mobile/.proc/recalculate_bounds)

// VERY EXPENSIVE (I think)
/obj/docking_port/mobile/proc/recalculate_bounds() //from shiptest
	if(!istype(src, /obj/docking_port/mobile))
		return FALSE

	//Heights is the distance away from the port
	//width is the distance perpendicular to the port
	var/minX = INFINITY
	var/maxX = 0
	var/minY = INFINITY
	var/maxY = 0
	for(var/area/A as anything in shuttle_areas)
		for(var/turf/T in A)
			minX = min(T.x, minX)
			maxX = max(T.x, maxX)
			minY = min(T.y, minY)
			maxY = max(T.y, maxY)
	//Make sure shuttle was actually found.
	if(maxX == INFINITY || maxY == INFINITY)
		return FALSE
	minX--
	minY--
	var/new_width = maxX - minX
	var/new_height = maxY - minY
	var/offset_x = x - minX
	var/offset_y = y - minY
	switch(dir) //Source: code/datums/shuttles.dm line 77 (14/03/2020) :)
		if(NORTH)
			width = new_width
			height = new_height
			dwidth = offset_x - 1
			dheight = offset_y - 1
		if(EAST)
			width = new_height
			height = new_width
			dwidth = new_height - offset_y
			dheight = offset_x - 1
		if(SOUTH)
			width = new_width
			height = new_height
			dwidth = new_width - offset_x
			dheight = new_height - offset_y
		if(WEST)
			width = new_height
			height = new_width
			dwidth = offset_y - 1
			dheight = new_width - offset_x


/area/station/external
	name = "External"
	area_flags = UNIQUE_AREA | NO_ALERTS | AREA_USES_STARLIGHT
	icon_state = "space_near"
