/obj/machinery/portable_atmospherics/pipe_scrubber
	name = "pipe scrubber"
	icon_state = "pipe_scrubber"
	density = TRUE
	max_integrity = 250
	volume = 200
	///The internal air tank obj of the mech
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	///Is the machine on?
	var/on = FALSE
	///What direction is the machine pumping to (into scrubber or out to the port)?
	var/direction = PUMP_IN
	///the rate the machine will scrub air
	var/volume_rate = 1000
	///List of gases that can be scrubbed
	var/list/scrubbing = list(
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide,
		/datum/gas/nitrous_oxide,
		/datum/gas/bz,
		/datum/gas/nitrium,
		/datum/gas/tritium,
		/datum/gas/hypernoblium,
		/datum/gas/water_vapor,
		/datum/gas/freon,
		/datum/gas/hydrogen,
		/datum/gas/healium,
		/datum/gas/proto_nitrate,
		/datum/gas/zauker,
		/datum/gas/halon,
	)

/obj/machinery/portable_atmospherics/pipe_scrubber/Initialize(mapload)
	internal_tank = new(src)
	. = ..()

/obj/machinery/portable_atmospherics/pipe_scrubber/Destroy()
	var/turf/my_turf = get_turf(src)
	my_turf.assume_air(air_contents)
	my_turf.assume_air(internal_tank.air_contents)
	SSair.stop_processing_machine(internal_tank)
	qdel(internal_tank)
	return ..()

/obj/machinery/portable_atmospherics/pipe_scrubber/return_analyzable_air()
	return list(
		air_contents,
		internal_tank.air_contents
	)

/obj/machinery/portable_atmospherics/pipe_scrubber/disconnect()
	on = FALSE
	return ..()

/obj/machinery/portable_atmospherics/pipe_scrubber/click_alt(mob/living/user)
	return FALSE

/obj/machinery/portable_atmospherics/pipe_scrubber/attackby(obj/item/item, mob/user, params)
	return TRUE

/obj/machinery/portable_atmospherics/pipe_scrubber/update_icon_state()
	icon_state = on ? "[initial(icon_state)]_active" : initial(icon_state)
	return ..()

/obj/machinery/portable_atmospherics/pipe_scrubber/process_atmos()
	if(take_atmos_damage())
		excited = TRUE
		return ..()
	if(!on)
		return ..()
	if(isnull(connected_port))
		return ..()
	if(direction == PUMP_IN)
		scrub(air_contents)
	else
		internal_tank.air_contents.pump_gas_to(air_contents, PUMP_MAX_PRESSURE)
	return ..()

/// Scrub gasses from own air_contents into internal_tank.air_contents
/obj/machinery/portable_atmospherics/pipe_scrubber/proc/scrub()
	if(internal_tank.air_contents.return_pressure() >= PUMP_MAX_PRESSURE)
		return

	var/transfer_moles = min(1, volume_rate / air_contents.volume) * air_contents.total_moles()

	var/datum/gas_mixture/filtering = air_contents.remove(transfer_moles) // Remove part of the mixture to filter.
	var/datum/gas_mixture/filtered = new
	if(!filtering)
		return

	filtered.temperature = filtering.temperature
	for(var/gas in filtering.gases & scrubbing)
		filtered.add_gas(gas)
		filtered.gases[gas][MOLES] = filtering.gases[gas][MOLES] // Shuffle the "bad" gasses to the filtered mixture.
		filtering.gases[gas][MOLES] = 0
	filtering.garbage_collect() // Now that the gasses are set to 0, clean up the mixture.

	internal_tank.air_contents.merge(filtered) // Store filtered out gasses.
	air_contents.merge(filtering) // Returned the cleaned gas.

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PipeScrubber", name)
		ui.open()

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_data()
	var/data = list()
	data["on"] = on
	data["direction"] = direction
	data["connected"] = connected_port ? 1 : 0
	data["pressure"] = round(internal_tank.air_contents.return_pressure() ? internal_tank.air_contents.return_pressure() : 0)
	data["maxPressure"] = PUMP_MAX_PRESSURE

	data["hasHypernobCrystal"] = has_nob_crystal()
	data["reactionSuppressionEnabled"] = !!internal_tank.suppress_reactions

	data["filterTypes"] = list()
	for(var/path in GLOB.meta_gas_info)
		var/list/gas = GLOB.meta_gas_info[path]
		data["filterTypes"] += list(list("gasId" = gas[META_GAS_ID], "gasName" = gas[META_GAS_NAME], "enabled" = (path in scrubbing)))

	return data

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			if (!connected_port)
				return
			on = !on
			if(on)
				SSair.start_processing_machine(src)
				SSair.start_processing_machine(internal_tank)
			. = TRUE
		if("direction")
			direction = !direction
			. = TRUE
		if("toggle_filter")
			scrubbing ^= gas_id2path(params["val"])
			. = TRUE
		if("reaction_suppression")
			if(!internal_tank.nob_crystal_inserted)
				message_admins("[ADMIN_LOOKUPFLW(usr)] tried to toggle reaction suppression on a pipe scrubber without a noblium crystal inside, possible href exploit attempt.")
				return
			internal_tank.suppress_reactions = !internal_tank.suppress_reactions
			SSair.start_processing_machine(internal_tank)
			message_admins("[ADMIN_LOOKUPFLW(usr)] turned [internal_tank.suppress_reactions ? "on" : "off"] the [internal_tank] reaction suppression.")
			usr.investigate_log("turned [internal_tank.suppress_reactions ? "on" : "off"] the [internal_tank] reaction suppression.")
			. = TRUE
	update_appearance()

/obj/machinery/portable_atmospherics/pipe_scrubber/has_nob_crystal()
	return internal_tank.nob_crystal_inserted

/obj/machinery/portable_atmospherics/pipe_scrubber/insert_nob_crystal()
	internal_tank.nob_crystal_inserted = TRUE
