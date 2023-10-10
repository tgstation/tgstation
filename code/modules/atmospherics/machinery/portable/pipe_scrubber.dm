/obj/machinery/portable_atmospherics/pipe_scrubber
	name = "pipe scrubber"
	icon_state = "pipe_scrubber"
	density = TRUE
	max_integrity = 250
	volume = 0
	///The internal air tank obj of the mech
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	///Is the machine on?
	var/on = FALSE
	///the rate the machine will scrub air
	var/volume_rate = 1000
	///Multiplier with ONE_ATMOSPHERE, if the pipe pressure is higher than that, the scrubber won't work
	var/overpressure_m = 80
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

/obj/machinery/portable_atmospherics/pipe_scrubber/Destroy()
	var/turf/my_turf = get_turf(src)
	my_turf.assume_air(air_contents)
	my_turf.assume_air(internal_tank.air_contents)
	qdel(internal_tank)
	return ..()

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

	var/atom/target = connected_port.parents[1]
	scrub(target.return_air())
	return ..()

/**
 * Called in process_atmos(), handles the scrubbing of the given gas_mixture
 * Arguments:
 * * mixture: the gas mixture to be scrubbed
 */
/obj/machinery/portable_atmospherics/pipe_scrubber/proc/scrub(datum/gas_mixture/mixture)
	if(air_contents.return_pressure() >= overpressure_m * ONE_ATMOSPHERE)
		return

	var/transfer_moles = min(1, volume_rate / mixture.volume) * mixture.total_moles()

	var/datum/gas_mixture/filtering = mixture.remove(transfer_moles) // Remove part of the mixture to filter.
	var/datum/gas_mixture/filtered = new
	if(!filtering)
		return

	filtered.temperature = filtering.temperature
	for(var/gas in filtering.gases & scrubbing)
		filtered.add_gas(gas)
		filtered.gases[gas][MOLES] = filtering.gases[gas][MOLES] // Shuffle the "bad" gasses to the filtered mixture.
		filtering.gases[gas][MOLES] = 0
	filtering.garbage_collect() // Now that the gasses are set to 0, clean up the mixture.

	air_contents.merge(filtered) // Store filtered out gasses.
	mixture.merge(filtering) // Returned the cleaned gas.
	if(!holding)
		air_update_turf(FALSE, FALSE)

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableScrubber", name)
		ui.open()

/obj/machinery/portable_atmospherics/pipe_scrubber/ui_data()
	var/data = list()
	data["on"] = on
	data["connected"] = connected_port ? 1 : 0
	data["pressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)

	data["hasHypernobCrystal"] = !!nob_crystal_inserted
	data["reactionSuppressionEnabled"] = !!suppress_reactions

	data["filterTypes"] = list()
	for(var/path in GLOB.meta_gas_info)
		var/list/gas = GLOB.meta_gas_info[path]
		data["filterTypes"] += list(list("gasId" = gas[META_GAS_ID], "gasName" = gas[META_GAS_NAME], "enabled" = (path in scrubbing)))

	if(holding)
		data["holding"] = list()
		data["holding"]["name"] = holding.name
		var/datum/gas_mixture/holding_mix = holding.return_air()
		data["holding"]["pressure"] = round(holding_mix.return_pressure())
	else
		data["holding"] = null
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
			. = TRUE
		if("eject")
			if(holding)
				replace_tank(usr, FALSE)
				. = TRUE
		if("toggle_filter")
			scrubbing ^= gas_id2path(params["val"])
			. = TRUE
		if("reaction_suppression")
			if(!nob_crystal_inserted)
				message_admins("[ADMIN_LOOKUPFLW(usr)] tried to toggle reaction suppression on a scrubber without a noblium crystal inside, possible href exploit attempt.")
				return
			suppress_reactions = !suppress_reactions
			SSair.start_processing_machine(src)
			message_admins("[ADMIN_LOOKUPFLW(usr)] turned [suppress_reactions ? "on" : "off"] the [src] reaction suppression.")
			usr.investigate_log("turned [suppress_reactions ? "on" : "off"] the [src] reaction suppression.")
			. = TRUE
	update_appearance()

/obj/machinery/portable_atmospherics/pipe_scrubber/unregister_holding()
	on = FALSE
	return ..()
