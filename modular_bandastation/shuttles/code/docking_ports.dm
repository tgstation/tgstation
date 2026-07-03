// Register certain shuttles in subsystem
/datum/controller/subsystem/shuttle
	/// The current gamma shuttle's mobile docking port.
	var/obj/docking_port/mobile/gamma/gamma

/obj/docking_port/mobile
	/// Object effect that places the landing zone effect in the center of the landing area
	var/drop_landing_effect = null
	/// Sound that played before drop landing
	var/drop_landing_sound = null
	/// If mobile docking is in progress
	var/drop_landing_in_progress = FALSE

/// Initiate the landing zone effect
/obj/docking_port/mobile/proc/initiate_drop_landing(obj/docking_port/stationary/S1, animate_time)
	if(!S1 || S1.roundstart_template || drop_landing_in_progress || (!drop_landing_sound && !drop_landing_effect))
		return

	drop_landing_in_progress = TRUE

	// Find the center of the landing area
	var/list/bounding_corners = return_coords(S1.x, S1.y, S1.dir)
	var/min_x = bounding_corners[1]
	var/min_y = bounding_corners[2]
	var/max_x = bounding_corners[3]
	var/max_y = bounding_corners[4]

	// Calculate the central point of the landing zone
	var/center_x = round((min_x + max_x) / 2)
	var/center_y = round((min_y + max_y) / 2)
	var/center_z = S1.z

	var/turf/effect_turf = locate(center_x, center_y, center_z)
	if(!effect_turf)
		return

	if(drop_landing_sound)
		playsound(effect_turf, drop_landing_sound, vol = 100, vary = FALSE, pressure_affected = FALSE)

	if(drop_landing_effect)
		create_drop_landing_effect(S1, effect_turf, animate_time)

	var/mutable_appearance/alert_overlay = mutable_appearance('icons/mob/telegraphing/telegraph_holographic.dmi', "target_box")
	notify_ghosts("Зона посадки десантной капсулы!", source = effect_turf, header = "Десант", alert_overlay = alert_overlay)

/// Create the landing zone effect in center of landing area
/obj/docking_port/mobile/proc/create_drop_landing_effect(obj/docking_port/stationary/S1, turf/effect_turf, animate_time)
	var/obj/landing_zone_effect = new drop_landing_effect(effect_turf, animate_time)

	// Constants for icon size calculation (in pixels)
	var/list/landing_icon_dimensions = get_icon_dimensions(landing_zone_effect.icon)
	var/landing_icon_size_px = max(landing_icon_dimensions["width"], landing_icon_dimensions["height"])

	// Calculate the required scale based on shuttle's tile size
	// We'll use the larger dimension to ensure the effect covers the entire shuttle
	var/shuttle_size_px = max(width, height) * ICON_SIZE_ALL
	var/shuttle_scale = shuttle_size_px / landing_icon_size_px

	animate(landing_zone_effect, time = animate_time, alpha = 255, transform = matrix().Scale(shuttle_scale, shuttle_scale))
	QDEL_IN(landing_zone_effect, animate_time)

// Checks for drop landing effects, if non of them present, then call parent proc instead. Reuses logic from our parent
/obj/docking_port/mobile/check_effects()
	if(!drop_landing_effect && !drop_landing_sound)
		return ..()

	if((mode == SHUTTLE_CALL) || (mode == SHUTTLE_RECALL))
		var/tl = timeLeft(1)
		if(tl <= SHUTTLE_RIPPLE_TIME)
			initiate_drop_landing(destination, tl)

/obj/docking_port/mobile/initiate_docking(obj/docking_port/stationary/S1, force = FALSE)
	. = ..()
	// Failsafe reset to FALSE, even if it's already FALSE because initiate_drop_landing() isn't called
	drop_landing_in_progress = FALSE

/obj/docking_port/mobile/syndicate_sit
	name = "syndicate sit shuttle"
	shuttle_id = "syndicate_sit"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = EAST
	port_direction = WEST
	preferred_direction = NORTH

/obj/docking_port/mobile/syndicate_sst
	name = "syndicate sst shuttle"
	shuttle_id = "syndicate_sst"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = WEST
	port_direction = EAST
	preferred_direction = NORTH

/obj/docking_port/mobile/argos
	name = "argos shuttle"
	shuttle_id = "argos"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = NORTH
	port_direction = SOUTH
	preferred_direction = NORTH

/obj/docking_port/mobile/specops
	name = "specops shuttle"
	shuttle_id = "specops"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = SOUTH
	port_direction = NORTH
	preferred_direction = NORTH

/obj/docking_port/mobile/assault_pod
	drop_landing_sound = 'sound/effects/alert.ogg'

/obj/docking_port/mobile/assault_pod/nanotrasen
	name = "Nanotrasen assault pod"
	shuttle_id = "assault_pod_nt"
	drop_landing_effect = /obj/effect/abstract/landing_zone
	drop_landing_sound = 'modular_bandastation/shuttles/sound/landing_specops.ogg'

/obj/docking_port/mobile/gamma
	name = "gamma armory shuttle"
	shuttle_id = "gamma"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = EAST
	port_direction = WEST
	preferred_direction = NORTH

/obj/docking_port/mobile/gamma/register()
	. = ..()
	SSshuttle.gamma = src
