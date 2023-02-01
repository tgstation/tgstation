GLOBAL_LIST_EMPTY(tram_signs)

/obj/machinery/destination_sign
	name = "destination sign"
	desc = "A display to show you what direction the tram is travelling."
	icon = 'icons/obj/machines/tram_sign.dmi'
	icon_state = "desto_central_idle"
	base_icon_state = "desto_"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	anchored = TRUE
	density = FALSE
	subsystem_type = /datum/controller/subsystem/processing/fastprocess

	/// The ID of the tram we're indicating
	var/tram_id = MAIN_STATION_TRAM
	/// Weakref to the tram piece we indicate
	var/datum/weakref/tram_ref
	/// The last destination we were at
	var/previous_destination

/obj/machinery/destination_sign/indicator
	icon_state = "indicator_central_idle"
	base_icon_state = "indicator_"

/obj/machinery/destination_sign/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/destination_sign/LateInitialize()
	. = ..()
	find_tram()

	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		RegisterSignal(tram_part, COMSIG_TRAM_SET_TRAVELLING, PROC_REF(on_tram_travelling))
		GLOB.tram_signs += src

/obj/machinery/destination_sign/Destroy()
	GLOB.tram_signs -= src
	. = ..()

	var/datum/lift_master/tram/tram_part = tram_ref?.resolve()
	if(tram_part)
		UnregisterSignal(tram_part, COMSIG_TRAM_SET_TRAVELLING)

/obj/machinery/destination_sign/proc/find_tram()
	for(var/datum/lift_master/tram/tram as anything in GLOB.active_lifts_by_type[TRAM_LIFT_ID])
		if(tram.specific_lift_id != tram_id)
			continue
		tram_ref = WEAKREF(tram)
		break

/obj/machinery/destination_sign/proc/on_tram_travelling(datum/source, travelling)
	SIGNAL_HANDLER
	update_sign()
	process()

/obj/machinery/destination_sign/proc/update_operating()
	// Immediately process for snappy feedback
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		begin_processing()
		return
	end_processing()

/obj/machinery/destination_sign/proc/update_sign()
	var/datum/lift_master/tram/tram = tram_ref?.resolve()

	if(!tram || !is_operational)
		icon_state = "[base_icon_state][DESTINATION_NOT_IN_SERVICE]"
		return PROCESS_KILL

	use_power(active_power_usage)

	if(!tram.travelling)
		if(istype(tram.from_where, /obj/effect/landmark/tram/left_part))
			icon_state = "[base_icon_state][DESTINATION_WEST_IDLE]"
			previous_destination = tram.from_where
			update_appearance()
			return PROCESS_KILL

		if(istype(tram.from_where, /obj/effect/landmark/tram/middle_part))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_IDLE]"
			previous_destination = tram.from_where
			update_appearance()
			return PROCESS_KILL

		if(istype(tram.from_where, /obj/effect/landmark/tram/right_part))
			icon_state = "[base_icon_state][DESTINATION_EAST_IDLE]"
			previous_destination = tram.from_where
			update_appearance()
			return PROCESS_KILL

	if(istype(tram.from_where, /obj/effect/landmark/tram/left_part))
		icon_state = "[base_icon_state][DESTINATION_WEST_ACTIVE]"
		update_appearance()
		return PROCESS_KILL

	if(istype(tram.from_where, /obj/effect/landmark/tram/middle_part))
		if(istype(previous_destination, /obj/effect/landmark/tram/left_part))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_EASTBOUND_ACTIVE]"
		if(istype(previous_destination, /obj/effect/landmark/tram/right_part))
			icon_state = "[base_icon_state][DESTINATION_CENTRAL_WESTBOUND_ACTIVE]"
		update_appearance()
		return PROCESS_KILL

	if(istype(tram.from_where, /obj/effect/landmark/tram/right_part))
		icon_state = "[base_icon_state][DESTINATION_EAST_ACTIVE]"
		update_appearance()
		return PROCESS_KILL
