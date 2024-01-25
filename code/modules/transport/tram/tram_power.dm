/obj/machinery/transport/power_rectifier
	name = "tram power rectifier"
	desc = "An electrical device that converts alternating current (AC) to direct current (DC) for powering the tram."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "intercom"
	base_icon_state = "intercom"
	layer = TRAM_SIGNAL_LAYER
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 11.4
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 114
	power_channel = AREA_USAGE_ENVIRON
	anchored = TRUE
	density = FALSE
	pixel_y = 32
	/// The tram platform we're connected to and providing power
	var/obj/effect/landmark/transport/nav_beacon/tram/platform/connected_platform

/obj/machinery/transport/power_rectifier/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/transport/power_rectifier/LateInitialize(mapload)
	. = ..()
	RegisterSignal(SStransport, COMSIG_TRANSPORT_ACTIVE, PROC_REF(power_tram))
	find_platform()

/**
 * The mapper should have placed the rectifier in the area containing the station, the object will search for a landmark within
 * its control area and set its idle position.
 */
/obj/machinery/transport/power_rectifier/proc/find_platform()
	var/area/my_area = get_area(src)
	to_chat(world, "power rectifier [id_tag] area is [my_area.name]")
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/candidate_platform in SStransport.nav_beacons[configured_transport_id])
		to_chat(world, "power rectifier [id_tag] checking platform [candidate_platform.name]")
		if(get_area(candidate_platform) == my_area)
			connected_platform = candidate_platform
			to_chat(world, "power rectifier [id_tag] found connected platform [candidate_platform.name]")
			return

/obj/machinery/transport/power_rectifier/proc/power_tram(datum/source, datum/transport_controller/linear/tram/controller, controller_active, controller_status, travel_direction, obj/effect/landmark/transport/nav_beacon/tram/platform/destination_platform)
	SIGNAL_HANDLER

	if(controller_active && destination_platform == connected_platform)
		update_use_power(ACTIVE_POWER_USE)
	else
		update_use_power(IDLE_POWER_USE)
