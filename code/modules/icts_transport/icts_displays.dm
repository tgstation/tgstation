/obj/machinery/icts/destination_sign
	name = "destination sign"
	desc = "A display to show you what direction the tram is travelling."
	icon = 'icons/obj/machines/tram/tram_display.dmi'
	icon_state = "desto_off"
	base_icon_state = "desto_"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 1.2
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.47
	anchored = TRUE
	density = FALSE
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	layer = SIGN_LAYER

	/// The ID of the tram we're indicating
	var/tram_id = TRAMSTATION_LINE_1
	/// Weakref to the tram piece we indicate
	var/datum/weakref/tram_ref
	/// What sign face prefixes we have icons for
	var/static/list/available_faces = list()
	/// The light mask overlay we use
	var/light_mask
	/// Is this sign malfunctioning?
	var/malfunctioning = FALSE

/obj/machinery/icts/destination_sign/indicator
	icon = 'icons/obj/machines/tram_sign.dmi'
	icon_state = "indicator_off"
	base_icon_state = "indicator_"
	light_range = 1.5
	light_color = LIGHT_COLOR_DARK_BLUE
	light_mask = "indicator_off_e"

/obj/machinery/icts/destination_sign/Initialize(mapload)
	. = ..()
	RegisterSignal(SSicts_transport, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(update_sign))
	SSicts_transport.displays += src
	available_faces = list(
		TRAMSTATION_LINE_1,
	)

/obj/machinery/icts/destination_sign/Destroy()
	SSicts_transport.displays -= src
	. = ..()

/obj/machinery/icts/destination_sign/proc/on_tram_travelling(datum/source, datum/transport_controller/linear/tram/controller, controller_active, controller_status, travel_direction, datum/transport_controller/linear/tram/destination_platform)
	SIGNAL_HANDLER

	if(controller.specific_transport_id != tram_id)
		return
	update_sign()
	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, process))

/obj/machinery/icts/destination_sign/proc/update_operating()
	// Immediately process for snappy feedback
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		begin_processing()
		return
	end_processing()

/obj/machinery/icts/destination_sign/proc/update_sign(datum/source, datum/transport_controller/linear/tram/controller, controller_active, controller_status, travel_direction, obj/effect/landmark/icts/nav_beacon/tram/destination_platform)

	if(!controller || !controller.controller_operational)
		icon_state = "[base_icon_state][DESTINATION_NOT_IN_SERVICE]"
		light_mask = "[base_icon_state][DESTINATION_NOT_IN_SERVICE]_e"
		update_appearance()
		return PROCESS_KILL

	use_power(active_power_usage)

	var/sign_face = ""
	sign_face += "[base_icon_state]"
	if(!LAZYFIND(available_faces, controller.specific_transport_id))
		sign_face += "[TRAMSTATION_LINE_1]"
	else
		sign_face += "[controller.specific_transport_id]"
	sign_face += "[controller_active]"
	sign_face += "[destination_platform.platform_code]"
	sign_face += "[travel_direction]"
	icon_state = "[sign_face]"
	light_mask = "[sign_face]_e"

	update_appearance()
	return PROCESS_KILL

/obj/machinery/icts/destination_sign/update_overlays()
	. = ..()
	if(!light_mask)
		return

	if(!(machine_stat & (NOPOWER|BROKEN)) && !panel_open)
		. += emissive_appearance(icon, light_mask, src, alpha = alpha)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/icts/destination_sign/indicator, 32)
