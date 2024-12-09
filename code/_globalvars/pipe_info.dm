///Pipe info
/datum/pipe_info
	///Name of this pipe
	var/name
	///Icon state of this pipe
	var/icon_state
	///Type path of this recipe
	var/id = -1
	/// see code/__DEFINES/pipe_construction.dm
	var/dirtype = PIPE_BENDABLE
	/// Is this pipe layer indenpendent
	var/all_layers

/datum/pipe_info/pipe/New(label, obj/machinery/atmospherics/path, use_five_layers)
	name = label
	id = path
	all_layers = use_five_layers
	icon_state = initial(path.pipe_state)
	var/obj/item/pipe/c = initial(path.construction_type)
	dirtype = initial(c.RPD_type)

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
		var/flipped = ((dirtype == PIPE_TRIN_M) || (dirtype == PIPE_UNARY_FLIPPABLE) || (dirtype == PIPE_ONEDIR_FLIPPABLE)) && (ISDIAGONALDIR(numdir))
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

/datum/pipe_info/meter/New(label)
	name = label

//==============================================================================================

///Disposal pipe info
/datum/pipe_info/disposal/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path

	icon_state = initial(path.icon_state)
	if(ispath(path, /obj/structure/disposalpipe))
		icon_state = "con[icon_state]"

	dirtype = dt


//==============================================================================================

///Transient tube pipe info
/datum/pipe_info/transit/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path
	dirtype = dt
	icon_state = initial(path.icon_state)
	if(dt == PIPE_UNARY_FLIPPABLE)
		icon_state = "[icon_state]_preview"
