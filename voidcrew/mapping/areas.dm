/**
 * area
 *
 * we're adding mobile port to station areas, which all ships use.
 */
/area/station
	/// The mobile port attached to this area
	var/obj/docking_port/mobile/station_ship

/area/station/Initialize(mapload)
	. = ..()
	//we always have gravity.
	has_gravity = TRUE

/area/station/Destroy()
	station_ship = null
	return ..()

/area/station/PlaceOnTopReact(list/new_baseturfs, turf/fake_turf_type, flags)
	. = ..()
	if(length(new_baseturfs) > 1 || fake_turf_type)
		return // More complicated larger changes indicate this isn't a player
	if(ispath(new_baseturfs[1], /turf/open/floor/plating) && !new_baseturfs.Find(/turf/baseturf_skipover/shuttle))
		new_baseturfs.Insert(1, /turf/baseturf_skipover/shuttle)

/area/station/proc/link_to_shuttle(obj/docking_port/mobile/link)
	station_ship = link
