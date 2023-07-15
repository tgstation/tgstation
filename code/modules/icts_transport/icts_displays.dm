/obj/machinery/destination_blank
	name = "destination sign"
	icon = 'icons/obj/machines/tram_sign.dmi'
	icon_state = "desto_off"
	base_icon_state = "desto_"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 1.2
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.47
	anchored = TRUE
	density = FALSE
	layer = CORGI_ASS_PIN_LAYER

/obj/machinery/destination_sign
	name = "destination sign"
	desc = "A display to show you what direction the tram is travelling."
	icon = 'icons/obj/machines/tram_display.dmi'
	icon_state = "desto_off"
	base_icon_state = "desto_"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 1.2
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.47
	anchored = TRUE
	density = FALSE
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	layer = SIGN_LAYER
	bound_width = 64

	/// The ID of the tram we're indicating
	var/tram_id = TRAMSTATION_LINE_1
	/// Weakref to the tram piece we indicate
	var/datum/weakref/tram_ref
	/// The last destination we were at
	var/previous_destination
	/// The light mask overlay we use
	var/light_mask
	/// Is this sign malfunctioning?
	var/malfunctioning = FALSE
	/// A default list of possible sign states
	var/static/list/sign_states = list()

/obj/machinery/destination_sign/indicator
	icon = 'icons/obj/machines/tram_sign.dmi'
	icon_state = "indicator_off"
	base_icon_state = "indicator_"
	light_range = 1.5
	light_color = LIGHT_COLOR_DARK_BLUE
	light_mask = "indicator_off_e"

/obj/machinery/destination_sign/Initialize(mapload)
	. = ..()
	RegisterSignal(SSicts_transport, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(update_sign))
	SSicts_transport.displays += src
	sign_states = list(
		"[DESTINATION_WEST_ACTIVE]",
		"[DESTINATION_WEST_IDLE]",
		"[DESTINATION_EAST_ACTIVE]",
		"[DESTINATION_EAST_IDLE]",
		"[DESTINATION_CENTRAL_IDLE]",
		"[DESTINATION_CENTRAL_EASTBOUND_ACTIVE]",
		"[DESTINATION_CENTRAL_WESTBOUND_ACTIVE]",
	)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/destination_sign/LateInitialize()
	. = ..()
	find_tram()

/obj/machinery/destination_sign/Destroy()
	SSicts_transport.displays -= src
	. = ..()

/obj/machinery/destination_sign/proc/find_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in SSicts_transport.transports_by_type[ICTS_TYPE_TRAM])
		if(tram.specific_transport_id != tram_id)
			continue
		tram_ref = WEAKREF(tram)
		break

/obj/machinery/destination_sign/proc/on_tram_travelling(datum/source, travelling)
	SIGNAL_HANDLER
	update_sign()
	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, process))

/obj/machinery/destination_sign/proc/update_operating()
	// Immediately process for snappy feedback
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		begin_processing()
		return
	end_processing()

/obj/machinery/destination_sign/proc/update_sign()
	var/datum/transport_controller/linear/tram/tram = tram_ref?.resolve()

	if(!tram || !tram.controller_operational)
		icon_state = "[base_icon_state][DESTINATION_NOT_IN_SERVICE]"
		light_mask = "[base_icon_state][DESTINATION_NOT_IN_SERVICE]_e"
		update_appearance()
		return PROCESS_KILL

	use_power(active_power_usage)

	if(malfunctioning)
		icon_state = "[base_icon_state][pick(sign_states)]"
		light_mask = "[base_icon_state][pick(sign_states)]_e"
		update_appearance()
		return PROCESS_KILL

	if(!tram.controller_active)
		if(istype(tram.idle_platform, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/west))
			icon_state = "[base_icon_state][DESTINATION_WEST_IDLE]"
			light_mask = "[base_icon_state][DESTINATION_WEST_IDLE]_e"
			previous_destination = tram.idle_platform
			update_appearance()
			return PROCESS_KILL

		if(istype(tram.idle_platform, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/central))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_IDLE]"
			light_mask = "[base_icon_state][DESTINATION_CENTRAL_IDLE]_e"
			previous_destination = tram.idle_platform
			update_appearance()
			return PROCESS_KILL

		if(istype(tram.idle_platform, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/east))
			icon_state = "[base_icon_state][DESTINATION_EAST_IDLE]"
			light_mask = "[base_icon_state][DESTINATION_EAST_IDLE]_e"
			previous_destination = tram.idle_platform
			update_appearance()
			return PROCESS_KILL

	if(istype(tram.destination_platform, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/west))
		icon_state = "[base_icon_state][DESTINATION_WEST_ACTIVE]"
		light_mask = "[base_icon_state][DESTINATION_WEST_ACTIVE]_e"
		update_appearance()
		return PROCESS_KILL

	if(istype(tram.destination_platform, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/central))
		if(istype(previous_destination, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/west))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_EASTBOUND_ACTIVE]"
			light_mask = "[base_icon_state][DESTINATION_CENTRAL_EASTBOUND_ACTIVE]_e"
		if(istype(previous_destination, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/east))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_WESTBOUND_ACTIVE]"
			light_mask = "[base_icon_state][DESTINATION_CENTRAL_WESTBOUND_ACTIVE]_e"
		update_appearance()
		return PROCESS_KILL

	if(istype(tram.destination_platform, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/east))
		icon_state = "[base_icon_state][DESTINATION_EAST_ACTIVE]"
		light_mask = "[base_icon_state][DESTINATION_EAST_ACTIVE]_e"
		update_appearance()
		return PROCESS_KILL

/obj/machinery/destination_sign/update_overlays()
	. = ..()
	if(!light_mask)
		return

	if(!(machine_stat & (NOPOWER|BROKEN)) && !panel_open)
		. += emissive_appearance(icon, light_mask, src, alpha = alpha)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/destination_sign/indicator, 32)
