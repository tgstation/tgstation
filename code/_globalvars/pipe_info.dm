///Pipe info
/datum/pipe_info
	///Name of this pipe
	var/name
	///Icon state of this pipe
	var/icon_state
	///Description of how the pipe is used
	var/desc
	///Type path of this recipe
	var/obj/machinery/id
	/// see code/__DEFINES/pipe_construction.dm
	var/dirtype = PIPE_BENDABLE
	/// Is this pipe layer indenpendent
	var/all_layers

/**
 * Get preview image of an pipe
 * Arguments
 *
 * * selected_dir - the direction of the pipe to get preview of
 * * selected - is this pipe meant to be highlighted in the UI
 */
/datum/pipe_info/proc/get_preview(selected_dir, selected = FALSE)
	SHOULD_BE_PURE(TRUE)

	var/list/dirs
	switch(dirtype)
		if(PIPE_STRAIGHT, PIPE_BENDABLE)
			dirs = list("[NORTH]" = "Vertical", "[EAST]" = "Horizontal")
			if(dirtype == PIPE_BENDABLE)
				dirs += list("[NORTHWEST]" = "West to North", "[NORTHEAST]" = "North to East",
							"[SOUTHWEST]" = "South to West", "[SOUTHEAST]" = "East to South")
		if(PIPE_TRINARY)
			dirs = list("[NORTH]" = "West South East", "[SOUTH]" = "East North West",
						"[EAST]" = "North West South", "[WEST]" = "South East North")
		if(PIPE_TRIN_M)
			dirs = list("[NORTH]" = "North East South", "[SOUTHWEST]" = "North West South",
						"[NORTHEAST]" = "South East North", "[SOUTH]" = "South West North",
						"[WEST]" = "West North East", "[SOUTHEAST]" = "West South East",
						"[NORTHWEST]" = "East North West", "[EAST]" = "East South West",)
		if(PIPE_UNARY)
			dirs = list("[NORTH]" = "North", "[SOUTH]" = "South", "[WEST]" = "West", "[EAST]" = "East")
		if(PIPE_ONEDIR)
			dirs = list("[SOUTH]" = name)
		if(PIPE_UNARY_FLIPPABLE)
			dirs = list("[NORTH]" = "North", "[EAST]" = "East", "[SOUTH]" = "South", "[WEST]" = "West",
						"[NORTHEAST]" = "North Flipped", "[SOUTHEAST]" = "East Flipped", "[SOUTHWEST]" = "South Flipped", "[NORTHWEST]" = "West Flipped")
		if(PIPE_ONEDIR_FLIPPABLE)
			dirs = list("[SOUTH]" = name, "[SOUTHEAST]" = "[name] Flipped")

	var/list/rows = list()
	for(var/dir in dirs)
		var/numdir = text2num(dir)
		var/flipped = ((dirtype == PIPE_TRIN_M && !ispath(id, /obj/structure/disposalpipe)) || (dirtype == PIPE_UNARY_FLIPPABLE) || (dirtype == PIPE_ONEDIR_FLIPPABLE)) && (ISDIAGONALDIR(numdir))
		var/is_variant_selected = selected && (!selected_dir ? FALSE : (dirtype == PIPE_ONEDIR ? TRUE : (numdir == selected_dir)))
		rows += list(list(
			"selected" = is_variant_selected,
			"dir" = dir2text(numdir),
			"dir_name" = dirs[dir],
			"icon_state" = icon_state,
			"flipped" = flipped,
		))

	return rows

//==============================================================================================

///Meter pipe info
/datum/pipe_info/meter
	icon_state = "meter"
	dirtype = PIPE_ONEDIR
	all_layers = TRUE

/datum/pipe_info/pipe
	dirtype = null

/datum/pipe_info/pipe/New(label, obj/machinery/atmospherics/path, use_five_layers)
	if(isnull(name)) // name ??= label
		name = label
	if(isnull(id)) // id ??= path
		id = path
	if(isnull(all_layers)) // all_layers ??= use_five_layers
		all_layers = use_five_layers

	if(!ispath(id, /obj/machinery/atmospherics))
		return

	var/obj/machinery/atmospherics/id_atmos = id
	if(isnull(icon_state)) // icon_state ??= initial(path.pipe_state)
		icon_state = id_atmos::pipe_state
	if(isnull(dirtype)) // dirtype ??= id_atmos::construction_type::RPD_type
		dirtype = id_atmos::construction_type::RPD_type

/datum/pipe_info/pipe/bridge_pipe
	name = "Bridge Pipe"
	desc = "Can be used to cross pipelines of the same layer and color without accidentally joining them together.<br>\
		Redundant for pipelines on different layers or of different colors."
	id = /obj/machinery/atmospherics/pipe/bridge_pipe
	all_layers = TRUE

/datum/pipe_info/pipe/multiz_connector
	name = "Multi-Deck Adapter"
	desc = "Directly connects pipelines vertically across station levels."
	id = /obj/machinery/atmospherics/pipe/multiz
	all_layers = FALSE

/datum/pipe_info/pipe/manual_valve
	name = "Manual Valve"
	desc = "Blocks the flow of gas through the pipeline.<br>Cannot be operated by silicons. Does not require power."
	id = /obj/machinery/atmospherics/components/binary/valve
	all_layers = TRUE

/datum/pipe_info/pipe/digital_valve
	name = "Digital Valve"
	desc = "Blocks the flow of gas through the pipeline.<br>Can be operated by silicons. Does not require power, despite being digital."
	id = /obj/machinery/atmospherics/components/binary/valve/digital
	all_layers = TRUE

/datum/pipe_info/pipe/gas_pump
	name = "Pressure Pump"
	desc = "Moves gas from one pipeline to another.<br>Transfers a variable amount of gas until the output network reaches the configured pressure."
	id = /obj/machinery/atmospherics/components/binary/pump
	all_layers = TRUE

/datum/pipe_info/pipe/volume_pump
	name = "Volume Pump"
	desc = "Moves gas from one pipeline to another.<br>Transfers a fixed volume of gas based on the configured volume.<br>\
		Can be overclocked to increase volume moved, though potentially causing leaks."
	id = /obj/machinery/atmospherics/components/binary/volume_pump
	all_layers = TRUE

/datum/pipe_info/pipe/passive_gate
	name = "Passive Gate"
	desc = "Blocks the flow of gas through the pipeline while the output pipeline has higher pressure \
		than either the configured pressure or the input pipeline's pressure.<br>Does not allow backwards flow, and does not require power."
	id = /obj/machinery/atmospherics/components/binary/passive_gate
	all_layers = TRUE

/datum/pipe_info/pipe/pressure_valve
	name = "Pressure Gate"
	desc = "Blocks the flow of gas through the pipeline while the input pipeline's pressure \
		is below the configured pressure.<br>Does not allow backwards flow, and does not require power."
	id = /obj/machinery/atmospherics/components/binary/pressure_valve
	all_layers = TRUE

/datum/pipe_info/pipe/temperature_gate
	name = "Temperature Gate"
	desc = "Blocks the flow of gas through the pipeline while the input pipeline's temperature is below the configured temperature.<br>\
		Does not allow backwards flow, and can be multitooled to instead check for exceeding the configured temperature."
	id = /obj/machinery/atmospherics/components/binary/temperature_gate
	all_layers = TRUE

/datum/pipe_info/pipe/temperature_pump
	name = "Temperature Pump"
	desc = "Moves heat from one pipeline to another, cooling the input pipeline and heating the output pipeline. No gas is transferred."
	id = /obj/machinery/atmospherics/components/binary/temperature_pump
	all_layers = TRUE

/datum/pipe_info/pipe/vent
	name = "Pump Vent"
	desc = "A vent with an inbuilt pressure pump.<br>Forces gas from the connected pipeline into the exterior atmosphere, \
		or pulls gas from the exterior atmosphere into the connected pipeline, depending on air alarm configuration.<br>\
		Can be overclocked."
	id = /obj/machinery/atmospherics/components/unary/vent_pump
	all_layers = TRUE

/datum/pipe_info/pipe/passive_vent
	name = "Passive Vent"
	desc = "Combines exterior atmosphere with the connected pipeline.<br>Does not require power."
	id = /obj/machinery/atmospherics/components/unary/passive_vent
	all_layers = TRUE

/datum/pipe_info/pipe/heat_exchanger
	name = "Heat Exchanger"
	desc = "When directly facing another heat exchanger, balances the temperature of the gases within each connected pipeline."
	id = /obj/machinery/atmospherics/components/unary/heat_exchanger
	all_layers = FALSE

//==============================================================================================

///Disposal pipe info
/datum/pipe_info/disposal

/datum/pipe_info/disposal/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path

	icon_state = initial(path.icon_state)
	if(ispath(path, /obj/structure/disposalpipe))
		icon_state = "con[icon_state]"

	dirtype = dt


//==============================================================================================

///Transient tube pipe info
/datum/pipe_info/transit

/datum/pipe_info/transit/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path
	dirtype = dt
	icon_state = initial(path.icon_state)
	if(dt == PIPE_UNARY_FLIPPABLE)
		icon_state = "[icon_state]_preview"
