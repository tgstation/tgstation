/obj/machinery/portable_atmospherics/pipe_scrubber
	name = "pipe scrubber"
	desc = "A machine for cleaning out pipes of lingering gases. It is a huge tank with a pump attached to it."
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
	. = ..()
	internal_tank = new(src)
	RegisterSignal(internal_tank, COMSIG_ATOM_BREAK, PROC_REF(deconstruct))
	RegisterSignal(internal_tank, COMSIG_QDELETING, PROC_REF(deconstruct))

/obj/machinery/portable_atmospherics/pipe_scrubber/atom_deconstruct(disassembled)
	. = ..()
	var/turf/my_turf = get_turf(src)
	my_turf.assume_air(air_contents)
	my_turf.assume_air(internal_tank.air_contents)
	SSair.stop_processing_machine(internal_tank)
	qdel(internal_tank)

/obj/machinery/portable_atmospherics/pipe_scrubber/return_analyzable_air()
	return list(
		air_contents,
		internal_tank.air_contents
	)

/obj/machinery/portable_atmospherics/pipe_scrubber/welder_act(mob/living/user, obj/item/tool)
	internal_tank.welder_act(user, tool)
	return ..()

/obj/machinery/portable_atmospherics/pipe_scrubber/click_alt(mob/living/user)
	return CLICK_ACTION_BLOCKING

/obj/machinery/portable_atmospherics/pipe_scrubber/replace_tank(mob/living/user, close_valve, obj/item/tank/new_tank)
	return FALSE

/obj/machinery/portable_atmospherics/pipe_scrubber/update_icon_state()
	icon_state = on ? "[initial(icon_state)]_active" : initial(icon_state)
	return ..()

/obj/machinery/portable_atmospherics/pipe_scrubber/process_atmos()
	if(take_atmos_damage())
		excited = TRUE
		return ..()
	if(!on)
		return ..()
	excited = TRUE
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
	data["pressureTank"] = round(internal_tank.air_contents.return_pressure() ? internal_tank.air_contents.return_pressure() : 0)
	data["pressurePump"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["hasHypernobCrystal"] = nob_crystal_inserted
	data["reactionSuppressionEnabled"] = suppress_reactions

	data["filterTypes"] = list()
	for(var/gas_path in GLOB.meta_gas_info)
		var/list/gas = GLOB.meta_gas_info[gas_path]
		data["filterTypes"] += list(list("gasId" = gas[META_GAS_ID], "gasName" = gas[META_GAS_NAME], "enabled" = (gas_path in scrubbing)))

	return data

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_static_data()
	var/list/data = list()
	data["pressureLimitPump"] = pressure_limit
	data["pressureLimitTank"] = internal_tank.pressure_limit
	return data

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
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

/obj/machinery/portable_atmospherics/pipe_scrubber/insert_nob_crystal()
	. = ..()
	internal_tank.nob_crystal_inserted = TRUE

/obj/machinery/portable_atmospherics/pipe_scrubber/proc/toggle_reaction_suppression()
	var/new_value = !suppress_reactions
	suppress_reactions = new_value
	internal_tank.suppress_reactions = new_value
