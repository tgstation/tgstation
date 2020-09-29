/obj/machinery/atmospherics/components/trinary/filter
	icon_state = "filter_off-0"
	density = FALSE

	name = "gas filter"
	desc = "Very useful for filtering gasses."

	can_unwrench = TRUE

	/// The rate (in moles/s) this machine transfers gas.
	var/transfer_rate = MAX_TRANSFER_RATE
	/// The default filter type this machine has. Used for mapping.
	var/filter_type = null
	/// The list of gases this filter can filter. If not hardcoded this defaults to all gas types.
	var/list/possible_filter_types
	/// Lazy list of gas types this filter is actively filtering from the input gases.
	var/list/active_filter_types
	/// The radio frequency this filter broadcasts and receives on.
	var/frequency = 0
	/// The radio connection this filter broadcasts and receives on.
	var/datum/radio_frequency/radio_connection

	construction_type = /obj/item/pipe/trinary/flippable
	pipe_state = "filter"

/obj/machinery/atmospherics/components/trinary/filter/Initialize()
	. = ..()
	if(length(possible_filter_types))
		return

	possible_filter_types = list()
	for(var/gas_type in subtypesof(/datum/gas))
		possible_filter_types[gas_type] = TRUE

	if(filter_type)
		enable_filter(filter_type)

/obj/machinery/atmospherics/components/trinary/filter/Destroy()
	clear_active_filters()
	if(length(possible_filter_types))
		possible_filter_types.Cut()
		possible_filter_types = null
	SSradio.remove_object(src,frequency)
	return ..()

/** Adds a filter type to the list of active filter types.
  *
  * Arguments:
  * - filter_type: The filter type to add.
  */
/obj/machinery/atmospherics/components/trinary/filter/proc/enable_filter(filter_type)
	if(!ispath(filter_type, /datum/gas))
		filter_type = gas_id2path(filter_type) //support for mappers so they don't need to type out paths
	if(!filter_type || !possible_filter_types[filter_type])
		return FALSE

	if(LAZYACCESS(active_filter_types, filter_type) || !LAZYACCESS(possible_filter_types, filter_type))
		return FALSE

	LAZYSET(active_filter_types, filter_type, TRUE)
	return TRUE

/** Removes a filter type from the list of active filter types.
  *
  * Arguments:
  * - filter_type: The filter type to add.
  */
/obj/machinery/atmospherics/components/trinary/filter/proc/disable_filter(filter_type)
	if(!ispath(filter_type, /datum/gas))
		filter_type = gas_id2path(filter_type) //support for mappers so they don't need to type out paths
	if(!filter_type || !possible_filter_types[filter_type])
		return FALSE

	if(!LAZYACCESS(active_filter_types, filter_type) || !LAZYACCESS(possible_filter_types, filter_type))
		return FALSE

	LAZYREMOVE(active_filter_types, filter_type)
	return TRUE

/** Clears the list of active filter types.
  */
/obj/machinery/atmospherics/components/trinary/filter/proc/clear_active_filters()
	if(!length(active_filter_types))
		return FALSE

	active_filter_types.Cut()
	active_filter_types = null
	return TRUE


/obj/machinery/atmospherics/components/trinary/filter/CtrlClick(mob/user)
	if(can_interact(user))
		on = !on
		investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/trinary/filter/AltClick(mob/user)
	if(can_interact(user))
		transfer_rate = MAX_TRANSFER_RATE
		investigate_log("was set to [transfer_rate] L/s by [key_name(user)]", INVESTIGATE_ATMOS)
		to_chat(user, "<span class='notice'>You maximize the volume output on [src] to [transfer_rate] L/s.</span>")
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/trinary/filter/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/trinary/filter/update_icon()
	cut_overlays()
	for(var/direction in GLOB.cardinals)
		if(!(direction & initialize_directions))
			continue
		var/obj/machinery/atmospherics/node = findConnecting(direction)

		var/image/cap
		if(node)
			cap = getpipeimage(icon, "cap", direction, node.pipe_color, piping_layer = piping_layer, trinary = TRUE)
		else
			cap = getpipeimage(icon, "cap", direction, piping_layer = piping_layer, trinary = TRUE)

		add_overlay(cap)

	return ..()

/obj/machinery/atmospherics/components/trinary/filter/update_icon_nopipes()
	var/on_state = on && nodes[1] && nodes[2] && nodes[3] && is_operational
	icon_state = "filter_[on_state ? "on" : "off"]-[set_overlay_offset(piping_layer)][flipped ? "_f" : ""]"

/obj/machinery/atmospherics/components/trinary/filter/process_atmos(delta_time)
	..()
	if(!on || !(nodes[1] && nodes[2] && nodes[3]) || !is_operational)
		return

	//Early return
	var/datum/gas_mixture/air1 = airs[1]
	if(!air1 || air1.temperature <= 0)
		return

	var/datum/gas_mixture/air2 = airs[2]
	var/datum/gas_mixture/air3 = airs[3]

	var/output_starting_pressure = air3.return_pressure()

	if(output_starting_pressure >= MAX_OUTPUT_PRESSURE)
		//No need to transfer if target is already full!
		return

	var/transfer_ratio = (transfer_rate * delta_time) / air1.volume

	//Actually transfer the gas

	if(transfer_ratio <= 0)
		return

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	if(!removed)
		return

	if(length(active_filter_types))
		var/datum/gas_mixture/filtered_out = new
		filtered_out.temperature = removed.temperature

		var/list/removed_gases = removed.gases
		var/list/filtered_gases = filtered_out.gases
		for(var/filter_type in active_filter_types)
			if(!removed_gases[filter_type])
				continue

			ADD_GAS(filter_type, filtered_gases)
			filtered_gases[filter_type][MOLES] = removed_gases[filter_type][MOLES]
			removed_gases[filter_type][MOLES] = 0

		removed.garbage_collect()

		var/datum/gas_mixture/target = (air2.return_pressure() < MAX_OUTPUT_PRESSURE ? air2 : air1) //if there's no room for the filtered gas; just leave it in air1
		target.merge(filtered_out)

	air3.merge(removed)
	update_parents()

/obj/machinery/atmospherics/components/trinary/filter/atmosinit()
	set_frequency(frequency)
	return ..()

/obj/machinery/atmospherics/components/trinary/filter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosFilter", name)
		ui.open()

/obj/machinery/atmospherics/components/trinary/filter/ui_data()
	var/data = list()
	data["on"] = on
	data["rate"] = round(transfer_rate)
	data["max_rate"] = round(MAX_TRANSFER_RATE)

	data["filter_types"] = list()
	data["filter_types"] += list(list("name" = "Nothing", "path" = "", "selected" = !filter_type))
	for(var/path in possible_filter_types)
		var/list/gas = GLOB.meta_gas_info[path]
		if(!gas)
			continue

		data["filter_types"] += list(list("name" = gas[META_GAS_NAME], "id" = gas[META_GAS_ID], "selected" = LAZYACCESS(active_filter_types, path)))

	return data

/obj/machinery/atmospherics/components/trinary/filter/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("rate")
			var/rate = params["rate"]
			if(rate == "max")
				rate = MAX_TRANSFER_RATE
				. = TRUE
			else if(text2num(rate) != null)
				rate = text2num(rate)
				. = TRUE
			if(.)
				transfer_rate = clamp(rate, 0, MAX_TRANSFER_RATE)
				investigate_log("was set to [transfer_rate] L/s by [key_name(usr)]", INVESTIGATE_ATMOS)
		if("filter")
			filter_type = null
			var/filter_name = "nothing"
			var/gas = gas_id2path(params["mode"])
			if(!gas)
				clear_active_filters()

			if(LAZYACCESS(possible_filter_types, gas))
				if(LAZYACCESS(active_filter_types, gas))
					disable_filter(gas)
				else
					enable_filter(gas)

				filter_name	= GLOB.meta_gas_info[gas][META_GAS_NAME]
			investigate_log("was set to filter [filter_name] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
	update_icon()

/obj/machinery/atmospherics/components/trinary/filter/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		return FALSE

// mapping

/obj/machinery/atmospherics/components/trinary/filter/layer2
	piping_layer = 2
	icon_state = "filter_off_map-2"
/obj/machinery/atmospherics/components/trinary/filter/layer4
	piping_layer = 4
	icon_state = "filter_off_map-4"

/obj/machinery/atmospherics/components/trinary/filter/on
	on = TRUE
	icon_state = "filter_on-0"

/obj/machinery/atmospherics/components/trinary/filter/on/layer2
	piping_layer = 2
	icon_state = "filter_on_map-2"
/obj/machinery/atmospherics/components/trinary/filter/on/layer4
	piping_layer = 4
	icon_state = "filter_on_map-4"

/obj/machinery/atmospherics/components/trinary/filter/flipped
	icon_state = "filter_off-0_f"
	flipped = TRUE

/obj/machinery/atmospherics/components/trinary/filter/flipped/layer2
	piping_layer = 2
	icon_state = "filter_off_f_map-2"
/obj/machinery/atmospherics/components/trinary/filter/flipped/layer4
	piping_layer = 4
	icon_state = "filter_off_f_map-4"

/obj/machinery/atmospherics/components/trinary/filter/flipped/on
	on = TRUE
	icon_state = "filter_on-0_f"

/obj/machinery/atmospherics/components/trinary/filter/flipped/on/layer2
	piping_layer = 2
	icon_state = "filter_on_f_map-2"
/obj/machinery/atmospherics/components/trinary/filter/flipped/on/layer4
	piping_layer = 4
	icon_state = "filter_on_f_map-4"

/obj/machinery/atmospherics/components/trinary/filter/atmos //Used for atmos waste loops
	on = TRUE
	icon_state = "filter_on-0"
/obj/machinery/atmospherics/components/trinary/filter/atmos/n2
	name = "nitrogen filter"
	filter_type = "n2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/o2
	name = "oxygen filter"
	filter_type = "o2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/co2
	name = "carbon dioxide filter"
	filter_type = "co2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/n2o
	name = "nitrous oxide filter"
	filter_type = "n2o"
/obj/machinery/atmospherics/components/trinary/filter/atmos/plasma
	name = "plasma filter"
	filter_type = "plasma"

/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped //This feels wrong, I know
	icon_state = "filter_on-0_f"
	flipped = TRUE
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/n2
	name = "nitrogen filter"
	filter_type = "n2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/o2
	name = "oxygen filter"
	filter_type = "o2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/co2
	name = "carbon dioxide filter"
	filter_type = "co2"
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/n2o
	name = "nitrous oxide filter"
	filter_type = "n2o"
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/plasma
	name = "plasma filter"
	filter_type = "plasma"

// These two filter types have critical_machine flagged to on and thus causes the area they are in to be exempt from the Grid Check event.

/obj/machinery/atmospherics/components/trinary/filter/critical
	critical_machine = TRUE

/obj/machinery/atmospherics/components/trinary/filter/flipped/critical
	critical_machine = TRUE
