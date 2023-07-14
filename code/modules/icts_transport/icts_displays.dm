/obj/machinery/destination_sign
	name = "destination sign"
	desc = "A display to show you what direction the tram is travelling."
	icon = 'icons/obj/machines/tram_sign.dmi'
	icon_state = "desto_off"
	base_icon_state = "desto_"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 1.2
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.47
	anchored = TRUE
	density = FALSE
	subsystem_type = /datum/controller/subsystem/processing/fastprocess

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

/obj/machinery/destination_sign/north
	layer = BELOW_OBJ_LAYER

/obj/machinery/destination_sign/south
	plane = WALL_PLANE_UPPER
	layer = BELOW_OBJ_LAYER

/obj/machinery/destination_sign/indicator
	icon_state = "indicator_off"
	base_icon_state = "indicator_"
	light_range = 1.5
	light_color = LIGHT_COLOR_DARK_BLUE
	light_mask = "indicator_off_e"

/obj/machinery/destination_sign/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/destination_sign/LateInitialize()
	. = ..()
	find_tram()

	var/datum/transport_controller/linear/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		RegisterSignal(tram_part, COMSIG_ICTS_TRANSPORT_ACTIVE, PROC_REF(on_tram_travelling))
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

/obj/machinery/destination_sign/Destroy()
	SSicts_transport.displays -= src
	. = ..()

	var/datum/transport_controller/linear/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		UnregisterSignal(tram_part, COMSIG_ICTS_TRANSPORT_ACTIVE)

/obj/machinery/destination_sign/proc/find_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
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

	if(istype(tram.idle_platform, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/west))
		icon_state = "[base_icon_state][DESTINATION_WEST_ACTIVE]"
		light_mask = "[base_icon_state][DESTINATION_WEST_ACTIVE]_e"
		update_appearance()
		return PROCESS_KILL

	if(istype(tram.idle_platform, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/central))
		if(istype(previous_destination, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/west))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_EASTBOUND_ACTIVE]"
			light_mask = "[base_icon_state][DESTINATION_CENTRAL_EASTBOUND_ACTIVE]_e"
		if(istype(previous_destination, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/east))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_WESTBOUND_ACTIVE]"
			light_mask = "[base_icon_state][DESTINATION_CENTRAL_WESTBOUND_ACTIVE]_e"
		update_appearance()
		return PROCESS_KILL

	if(istype(tram.idle_platform, /obj/effect/landmark/icts/nav_beacon/tram/tramstation/east))
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

/obj/machinery/button/tram
	name = "tram request"
	desc = "A button for calling the tram. It has a speakerbox in it with some internals."
	base_icon_state = "tram"
	icon_state = "tram"
	light_color = LIGHT_COLOR_DARK_BLUE
	can_alter_skin = FALSE
	device_type = /obj/item/assembly/control/tram
	req_access = list()
	id = 1
	/// The specific lift id of the tram we're calling.
	var/lift_id = TRAMSTATION_LINE_1

/obj/machinery/button/tram/setup_device()
	var/obj/item/assembly/control/tram/tram_device = device
	tram_device.initial_id = id
	tram_device.specific_transport_id = lift_id
	return ..()

/obj/machinery/button/tram/examine(mob/user)
	. = ..()
	. += span_notice("There's a small inscription on the button...")
	. += span_notice("THIS CALLS THE TRAM! IT DOES NOT OPERATE IT! The console on the tram tells it where to go!")

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/tram_controls, 0)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/destination_sign/indicator, 32)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/tram, 32)
