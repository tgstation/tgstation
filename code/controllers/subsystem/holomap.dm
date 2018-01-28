GLOBAL_LIST_INIT(holomap_obstacles, typecacheof(/turf/open/space, /turf/open/indestructible/reebe_void, /area/mine/unexplored, /turf/closed/wall, /obj/structure/grille, /obj/structure/window/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/window/plasma/reinforced/fulltile))
GLOBAL_LIST_INIT(holomap_paths, typecacheof(/turf/open/floor, /obj/structure/lattice/catwalk))

SUBSYSTEM_DEF(holomap)
	name = "Holomap"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_HOLOMAP
	var/list/holoMiniMaps = list()
	var/list/centcom_minimaps = list()
	var/list/extraMiniMaps = list()
	var/list/holomap_markers = list()

/datum/controller/subsystem/holomap/Initialize(timeofday)
	var/list/filters = list(
		HOLOMAP_FILTER_DEATHSQUAD,
		HOLOMAP_FILTER_ERT,
		HOLOMAP_FILTER_NUKEOPS,
		HOLOMAP_FILTER_ELITESYNDICATE,
		HOLOMAP_FILTER_CLOCKCULT,
		)

	for (var/f in filters)
		generate_centcom_minimap(f)

	for (var/z = 1 to world.maxz)
		holoMiniMaps |= z
		generateMarkers(z)
		generateHoloMinimap(z)

	//Station Holomaps display the map of the Z-Level they were built on.
	for(var/A in SSmapping.levels_by_trait(ZTRAIT_REEBE))
		generateStationMinimap(A)
	generateStationMinimap(ZLEVEL_STATION_PRIMARY)
	//If they were built on another Z-Level, they will display an error screen.
	return ..()


/datum/controller/subsystem/holomap/proc/generateMarkers(var/ZLevel)
	//generating specific markers
	if(ZLevel == ZLEVEL_STATION_PRIMARY)
		var/i = 1
		for(var/obj/machinery/power/smes/S in GLOB.machines)
			var/datum/holomap_marker/newMarker = new()
			newMarker.id = HOLOMAP_MARKER_SMES
			newMarker.filter = HOLOMAP_FILTER_STATIONMAP_STRATEGIC
			newMarker.x = S.x
			newMarker.y = S.y
			newMarker.z = S.z
			holomap_markers[HOLOMAP_MARKER_SMES+"_[i]"] = newMarker
			i++
	//generating area markers
	for(var/_A in GLOB.sortedAreas)
		var/area/A = _A
		if(A.holomap_marker)
			var/turf/T = A.getAreaCenter(ZLevel)
			if(T)
				var/datum/holomap_marker/newMarker = new()
				newMarker.id = A.holomap_marker
				newMarker.filter = A.holomap_filter
				newMarker.x = T.x
				newMarker.y = T.y
				newMarker.z = ZLevel
				holomap_markers[newMarker.id] = newMarker

/datum/controller/subsystem/holomap/proc/generateHoloMinimap(zLevel=ZLEVEL_STATION_PRIMARY)
	var/icon/canvas = icon('icons/480x480.dmi', "blank")
	if(!is_centcom_level(zLevel))
		for(var/i = 1 to ((2 * world.view + 1)*world.icon_size))
			for(var/r = 1 to ((2 * world.view + 1)*world.icon_size))
				var/turf/tile = locate(i, r, zLevel)
				if(tile && tile.loc.holomapAlwaysDraw())
					if(is_type_in_typecache(tile, GLOB.holomap_obstacles) || is_type_in_typecache(get_area(tile), GLOB.holomap_obstacles) || tile.contents_in_typecache(GLOB.holomap_obstacles))
						canvas.DrawBox(HOLOMAP_OBSTACLE, i, r)
					else if(is_type_in_typecache(tile, GLOB.holomap_paths) || tile.contents_in_typecache(GLOB.holomap_paths))
						canvas.DrawBox(HOLOMAP_PATH, i, r)

	holoMiniMaps[zLevel] = canvas

/datum/controller/subsystem/holomap/proc/generate_centcom_minimap(var/filter="all")
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	var/list/allowed_areas = list()
	var/list/restricted_areas = list()

	switch(filter)
		if(HOLOMAP_FILTER_DEATHSQUAD)
			allowed_areas = list(/area/centcom)
		if(HOLOMAP_FILTER_ERT)
			allowed_areas = list(/area/centcom/ferry)
		if(HOLOMAP_FILTER_NUKEOPS)
			allowed_areas = list(/area/syndicate_mothership)
			restricted_areas = list(/area/syndicate_mothership/elite_squad)
		if(HOLOMAP_FILTER_ELITESYNDICATE)
			allowed_areas = list(/area/syndicate_mothership)
		if(HOLOMAP_FILTER_CLOCKCULT)
			allowed_areas = list(/area/reebe)

	for(var/z in SSmapping.levels_by_trait(ZTRAIT_CENTCOM))
		for(var/i = 1 to ((2 * world.view + 1)*world.icon_size))
			for(var/r = 1 to ((2 * world.view + 1)*world.icon_size))
				var/turf/tile = locate(i, r, z)
				if(tile && (is_type_in_list(tile.loc, allowed_areas) && !is_type_in_list(tile.loc, restricted_areas)))
					if(is_type_in_typecache(tile, GLOB.holomap_obstacles) || is_type_in_typecache(get_area(tile), GLOB.holomap_obstacles) || tile.contents_in_typecache(GLOB.holomap_obstacles))
						canvas.DrawBox(HOLOMAP_OBSTACLE, i, r)
					else if(is_type_in_typecache(tile, GLOB.holomap_paths) || tile.contents_in_typecache(GLOB.holomap_paths))
						canvas.DrawBox(HOLOMAP_PATH, i, r)

	centcom_minimaps["[filter]"] = canvas

/datum/controller/subsystem/holomap/proc/generateStationMinimap(var/StationZLevel)
	var/icon/canvas = icon('icons/480x480.dmi', "blank")

	for(var/i = 1 to ((2 * world.view + 1)*world.icon_size))
		for(var/r = 1 to ((2 * world.view + 1)*world.icon_size))
			var/turf/tile = locate(i, r, StationZLevel)
			if(tile && tile.loc)
				var/area/areaToPaint = tile.loc
				if(areaToPaint.holomap_color)
					canvas.DrawBox(areaToPaint.holomap_color, i, r)

	var/icon/big_map = icon('icons/480x480.dmi', "stationmap")
	var/icon/small_map = icon('icons/480x480.dmi', "blank")
	var/icon/map_base = icon(holoMiniMaps[StationZLevel])
/*
	var/icon/map_with_areas = icon(holoMiniMaps[StationZLevel])
	map_with_areas = icon(holoMiniMaps[StationZLevel])
	map_with_areas.Blend(canvas,ICON_OVERLAY)
*/
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPAREAS+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPAREAS+"_[StationZLevel]"] = canvas

	map_base.Blend("#79ff79",ICON_MULTIPLY)

	small_map.Blend(map_base,ICON_OVERLAY)
	small_map.Blend(canvas,ICON_OVERLAY)
	small_map.Scale(32,32)

	big_map.Blend(map_base,ICON_OVERLAY)
	big_map.Blend(canvas,ICON_OVERLAY)

	if(is_station_level(StationZLevel))
		var/icon/strategic_map = icon(big_map)

		for(var/marker in holomap_markers)
			var/datum/holomap_marker/holomarker = holomap_markers[marker]
			if(holomarker.z == StationZLevel && holomarker.filter & HOLOMAP_FILTER_STATIONMAP_STRATEGIC)
				strategic_map.Blend(icon(holomarker.marker_icon,holomarker.id), ICON_OVERLAY, holomarker.x-8, holomarker.y-8)

		extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAP_STRATEGIC
		extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP_STRATEGIC] = strategic_map

	for(var/marker in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[marker]
		if(holomarker.z == StationZLevel && holomarker.filter & HOLOMAP_FILTER_STATIONMAP)
			big_map.Blend(icon(holomarker.marker_icon,holomarker.id), ICON_OVERLAY, holomarker.x-8, holomarker.y-8)

	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAP+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAP+"_[StationZLevel]"] = big_map

	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH+"_[StationZLevel]"] = small_map

	var/icon/small_map_east = turn(icon(small_map), 90)
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_EAST+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_EAST+"_[StationZLevel]"] = small_map_east

	var/icon/small_map_south = turn(icon(small_map_east), 90)
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_SOUTH+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_SOUTH+"_[StationZLevel]"] = small_map_south

	var/icon/small_map_west = turn(icon(small_map_south), 90)
	extraMiniMaps |= HOLOMAP_EXTRA_STATIONMAPSMALL_WEST+"_[StationZLevel]"
	extraMiniMaps[HOLOMAP_EXTRA_STATIONMAPSMALL_WEST+"_[StationZLevel]"] = small_map_west


/datum/holomap_marker
	var/x
	var/y
	var/z
	var/offset_x = -8
	var/offset_y = -8
	var/filter
	var/id
	var/icon/marker_icon = 'icons/effects/holomap_markers.dmi'