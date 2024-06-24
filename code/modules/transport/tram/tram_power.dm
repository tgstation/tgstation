/obj/machinery/transport/power_rectifier
	name = "tram power rectifier"
	desc = "An electrical device that converts alternating current (AC) to direct current (DC) for powering the tram."
	icon = 'icons/obj/tram/tram_controllers.dmi'
	icon_state = "rectifier"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 11.4
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 114
	power_channel = AREA_USAGE_ENVIRON
	anchored = TRUE
	density = FALSE
	armor_type = /datum/armor/transport_module
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 750
	pixel_y = 32
	/// The tram platform we're connected to and providing power
	var/obj/effect/landmark/transport/nav_beacon/tram/platform/connected_platform

/obj/machinery/transport/power_rectifier/post_machine_initialize()
	. = ..()
	RegisterSignal(SStransport, COMSIG_TRANSPORT_ACTIVE, PROC_REF(power_tram))
	find_platform()

/**
 * The mapper should have placed the rectifier in the area containing the station, the object will search for a landmark within
 * its control area and set its idle position.
 */
/obj/machinery/transport/power_rectifier/proc/find_platform()
	var/area/my_area = get_area(src)
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/candidate_platform in SStransport.nav_beacons[configured_transport_id])
		if(get_area(candidate_platform) == my_area)
			connected_platform = candidate_platform
			RegisterSignal(connected_platform, COMSIG_QDELETING, PROC_REF(on_landmark_qdel))
			log_transport("[id_tag]: Power rectifier linked to landmark [connected_platform.name]")
			return

/obj/machinery/transport/power_rectifier/proc/power_tram(datum/source, datum/transport_controller/linear/tram/controller, controller_active, controller_status, travel_direction, obj/effect/landmark/transport/nav_beacon/tram/platform/destination_platform)
	SIGNAL_HANDLER

	if(controller_active && destination_platform == connected_platform)
		update_use_power(ACTIVE_POWER_USE)
	else
		update_use_power(IDLE_POWER_USE)

	update_appearance()

/**
 * Update the lights based on the rectifier status.
 */
/obj/machinery/transport/power_rectifier/update_overlays()
	. = ..()

	if(machine_stat & NOPOWER)
		. += mutable_appearance(icon, "rec-power-0")
		. += emissive_appearance(icon, "rec-power-0", src, alpha = src.alpha)
		return

	. += mutable_appearance(icon, "rec-power-1")
	. += emissive_appearance(icon, "rec-power-1", src, alpha = src.alpha)

	var/is_active = use_power == ACTIVE_POWER_USE
	. += mutable_appearance(icon, "rec-active-[is_active]")
	. += emissive_appearance(icon, "rec-active-[is_active]", src, alpha = src.alpha)

/**
 * Clear reference to the connected landmark if it gets destroyed.
 */
/obj/machinery/transport/power_rectifier/proc/on_landmark_qdel()
	log_transport("[id_tag]: Power rectifier received QDEL from landmark [connected_platform.name]")
	connected_platform = null
