///////////////////////////////////////////////////////////////
//SS13 Optimized Map loader
//////////////////////////////////////////////////////////////
#define SPACE_KEY "space"

/datum/grid_set
	var/xcrd
	var/ycrd
	var/zcrd
	var/gridLines

/datum/parsed_map
	var/original_path
	/// The length of a key in this file. This is promised by the standard to be static
	var/key_len = 0
	var/list/grid_models = list()
	var/list/gridSets = list()

	var/list/modelCache

	/// Unoffset bounds. Null on parse failure.
	var/list/parsed_bounds
	/// Offset bounds. Same as parsed_bounds until load().
	var/list/bounds

	///any turf in this list is skipped inside of build_coordinate. Lazy assoc list
	var/list/turf_blacklist

	// raw strings used to represent regexes more accurately
	// '' used to avoid confusing syntax highlighting
	var/static/regex/dmmRegex = new(@'"([a-zA-Z]+)" = \(((?:.|\n)*?)\)\n(?!\t)|\((\d+),(\d+),(\d+)\) = \{"([a-zA-Z\n]*)"\}', "g")
	var/static/regex/trimRegex = new(@'^[\s\n]+|[\s\n]+$', "g")

	#ifdef TESTING
	var/turfsSkipped = 0
	#endif

//text trimming (both directions) helper macro
#define TRIM_TEXT(text) (trim_reduced(text))

/// Shortcut function to parse a map and apply it to the world.
///
/// - `dmm_file`: A .dmm file to load (Required).
/// - `x_offset`, `y_offset`, `z_offset`: Positions representign where to load the map (Optional).
/// - `cropMap`: When true, the map will be cropped to fit the existing world dimensions (Optional).
/// - `measureOnly`: When true, no changes will be made to the world (Optional).
/// - `no_changeturf`: When true, [/turf/proc/AfterChange] won't be called on loaded turfs
/// - `x_lower`, `x_upper`, `y_lower`, `y_upper`: Coordinates (relative to the map) to crop to (Optional).
/// - `placeOnTop`: Whether to use [/turf/proc/PlaceOnTop] rather than [/turf/proc/ChangeTurf] (Optional).
/proc/load_map(dmm_file as file, x_offset as num, y_offset as num, z_offset as num, cropMap as num, measureOnly as num, no_changeturf as num, x_lower = -INFINITY as num, x_upper = INFINITY as num, y_lower = -INFINITY as num, y_upper = INFINITY as num, placeOnTop = FALSE as num)
	var/datum/parsed_map/parsed = new(dmm_file, x_lower, x_upper, y_lower, y_upper, measureOnly)
	if(parsed.bounds && !measureOnly)
		parsed.load(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop)
	return parsed

/// Parse a map, possibly cropping it.
/datum/parsed_map/New(tfile, x_lower = -INFINITY, x_upper = INFINITY, y_lower = -INFINITY, y_upper=INFINITY, measureOnly=FALSE)
	// This proc sleeps for like 6 seconds. why?
	// Is it file accesses? if so, can those be done ahead of time, async to save on time here? I wonder.
	// Love ya :)
	if(isfile(tfile))
		original_path = "[tfile]"
		tfile = file2text(tfile)
	else if(isnull(tfile))
		// create a new datum without loading a map
		return

	src.bounds = parsed_bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)
	// lists are structs don't you know :)
	var/list/bounds = src.bounds
	var/list/grid_models = src.grid_models
	var/key_len = src.key_len

	var/stored_index = 1
	var/list/regexOutput
	//multiz lool
	while(dmmRegex.Find(tfile, stored_index))
		stored_index = dmmRegex.next
		// Datum var lookup is expensive, this isn't
		regexOutput = dmmRegex.group

		// "aa" = (/type{vars=blah})
		if(regexOutput[1]) // Model
			var/key = regexOutput[1]
			if(grid_models[key]) // Duplicate model keys are ignored in DMMs
				continue
			if(key_len != length(key))
				if(!key_len)
					key_len = length(key)
				else
					CRASH("Inconsistent key length in DMM")
			if(!measureOnly)
				grid_models[key] = regexOutput[2]

		// (1,1,1) = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
		else if(regexOutput[3]) // Coords
			if(!key_len)
				CRASH("Coords before model definition in DMM")

			var/curr_x = text2num(regexOutput[3])

			if(curr_x < x_lower || curr_x > x_upper)
				continue

			var/datum/grid_set/gridSet = new

			gridSet.xcrd = curr_x
			//position of the currently processed square
			gridSet.ycrd = text2num(regexOutput[4])
			gridSet.zcrd = text2num(regexOutput[5])

			bounds[MAP_MINX] = min(bounds[MAP_MINX], curr_x)
			bounds[MAP_MINZ] = min(bounds[MAP_MINZ], gridSet.zcrd)
			bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], gridSet.zcrd)

			var/list/gridLines = splittext(regexOutput[6], "\n")
			gridSet.gridLines = gridLines

			var/leadingBlanks = 0
			while(leadingBlanks < length(gridLines) && gridLines[++leadingBlanks] == "")
			if(leadingBlanks > 1)
				gridLines.Cut(1, leadingBlanks) // Remove all leading blank lines.

			if(!length(gridLines)) // Skip it if only blank lines exist.
				continue

			gridSets += gridSet

			if(gridLines[length(gridLines)] == "")
				gridLines.Cut(length(gridLines)) // Remove only one blank line at the end.

			bounds[MAP_MINY] = min(bounds[MAP_MINY], gridSet.ycrd)
			gridSet.ycrd += length(gridLines) - 1 // Start at the top and work down
			bounds[MAP_MAXY] = max(bounds[MAP_MAXY], gridSet.ycrd)

			var/maxx = curr_x
			if(length(gridLines)) //Not an empty map
				maxx = max(maxx, curr_x + length(gridLines[1]) / key_len - 1)

			bounds[MAP_MAXX] = max(bounds[MAP_MAXX], maxx)
		CHECK_TICK

	// Indicate failure to parse any coordinates by nulling bounds
	if(bounds[1] == 1.#INF)
		src.bounds = null
	else
		// Clamp all our mins and maxes down to the proscribed limits
		bounds[MAP_MINX] = clamp(bounds[MAP_MINX], x_lower, x_upper)
		bounds[MAP_MAXX] = clamp(bounds[MAP_MAXX], x_lower, x_upper)
		bounds[MAP_MINY] = clamp(bounds[MAP_MINY], y_lower, y_upper)
		bounds[MAP_MAXY] = clamp(bounds[MAP_MAXY], y_lower, y_upper)

	parsed_bounds = src.bounds
	src.key_len = key_len

/// Load the parsed map into the world. See [/proc/load_map] for arguments.
/datum/parsed_map/proc/load(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop, whitelist = FALSE)
	//How I wish for RAII
	Master.StartLoadingMap()
	. = _load_impl(x_offset, y_offset, z_offset, cropMap, no_changeturf, x_lower, x_upper, y_lower, y_upper, placeOnTop)
	Master.StopLoadingMap()


#define MAPLOADING_CHECK_TICK \
	if(TICK_CHECK) { \
		SSatoms.map_loader_stop(); \
		stoplag(); \
		SSatoms.map_loader_begin(); \
	}
//#define MAPLOADING_CHECK_TICK
// Do not call except via load() above.
/datum/parsed_map/proc/_load_impl(x_offset = 1, y_offset = 1, z_offset = world.maxz + 1, cropMap = FALSE, no_changeturf = FALSE, x_lower = -INFINITY, x_upper = INFINITY, y_lower = -INFINITY, y_upper = INFINITY, placeOnTop = FALSE)
	PRIVATE_PROC(TRUE)
	var/list/modelCache = build_cache(no_changeturf)
	var/space_key = modelCache[SPACE_KEY]
	var/list/bounds
	var/key_len = src.key_len
	src.bounds = bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)

	// Tell ss atoms that we're doing maploading
	// We'll have to account for this in the following tick_checks so it doesn't overflow
	SSatoms.map_loader_begin()

	//used for sending the maxx and maxy expanded global signals at the end of this proc
	var/has_expanded_world_maxx = FALSE
	var/has_expanded_world_maxy = FALSE
	var/y_relative_to_absolute = y_offset - 1
	var/x_relative_to_absolute = x_offset - 1
	for(var/datum/grid_set/gset as anything in gridSets)
		var/relative_x = gset.xcrd
		var/relative_y = gset.ycrd
		var/true_xcrd = relative_x + x_relative_to_absolute
		var/ycrd = relative_y + y_relative_to_absolute
		var/zcrd = gset.zcrd + z_offset - 1
		if(!cropMap && ycrd > world.maxy)
			world.maxy = ycrd // Expand Y here.  X is expanded in the loop below
			has_expanded_world_maxy = TRUE
		var/zexpansion = zcrd > world.maxz
		var/no_afterchange = no_changeturf
		if(zexpansion)
			if(cropMap)
				continue
			else
				while (zcrd > world.maxz) //create a new z_level if needed
					world.incrementMaxZ()
			if(!no_changeturf)
				WARNING("Z-level expansion occurred without no_changeturf set, this may cause problems when /turf/AfterChange is called")
				no_afterchange = TRUE
		// Ok so like. something important
		// We talk in "relative" coords here, so the coordinate system of the map datum
		// This is so we can do offsets, but it is NOT the same as positions in game
		// That's why there's some uses of - y_relative_to_absolute here, to turn absolute positions into relative ones

		// Skip Y coords that are above the smallest of the three params
		// So maxy and y_upper get to act as thresholds, and relative_y can play
		var/y_skip_above = min(world.maxy - y_relative_to_absolute, y_upper, relative_y)
		// How many lines to skip because they'd be above the y cuttoff line
		var/y_starting_skip = relative_y - y_skip_above
		ycrd += y_starting_skip

		// Y is the LOWEST it will ever be here, so we can easily set a threshold for how low to go
		var/line_count = length(gset.gridLines)
		var/lowest_y = relative_y - (line_count - 1) // -1 because we decrement at the end of the loop, not the start
		var/y_ending_skip = max(max(y_lower, 1 - y_relative_to_absolute) - lowest_y, 0)

		// Now we're gonna precompute the x thresholds
		// We skip all the entries below the lower x, or 1
		var/starting_x_delta = max(max(x_lower, 1 - x_relative_to_absolute) - relative_x, 0)
		// The x loop counts by key length, so we gotta multiply here
		var/x_starting_skip = starting_x_delta * key_len
		true_xcrd += starting_x_delta

		var/line_length = 0
		if(line_count)
			// This is promised as static, so we will treat it as such
			line_length = length(gset.gridLines[1])
		// We're gonna skip all the entries above the upper x, or maxx if cropMap is set
		var/x_target = line_length - key_len + 1
		var/x_step_count = ROUND_UP(x_target / key_len)
		var/final_x = relative_x + (x_step_count - 1)
		var/x_delta_with = x_upper
		if(cropMap)
			// Take our smaller crop threshold yes?
			x_delta_with = min(x_delta_with, world.maxx)
		if(final_x > x_delta_with)
			// If our relative x is greater then X upper, well then we've gotta limit our expansion
			var/delta = max(final_x - x_delta_with, 0)
			x_step_count -= delta
			final_x -= delta
			x_target = x_step_count * key_len
		if(final_x > world.maxx && !cropMap)
			world.maxx = final_x
			has_expanded_world_maxx = TRUE

		// We're gonna track the first and last pairs of coords we find
		// The first x is guarenteed to be the lowest, the first y the highest, and vis versa
		// This is faster then doing mins and maxes inside the hot loop below
		var/first_found = FALSE
		var/first_x = 0
		var/first_y = 0
		var/last_x = 0
		var/last_y = 0

		// Everything following this line is VERY hot. How hot depends on the map format
		// (Yes this does mean dmm is technically faster to parse. shut up)

		// This is the "is this map tgm" check
		if(key_len == line_length)
			// Wanna clear something up about maps, talking in 255x255 here
			// In the tgm format, each gridset contains 255 lines, each line representing one tile, with 255 total gridsets
			// In the dmm format, each gridset contains 255 lines, each line representing one row of tiles, containing 255 * line length characters, with one gridset per z
			// since this is the tgm branch any cutoff of x means we just shouldn't iterate this gridset
			if(!x_step_count || x_starting_skip)
				continue
			for(var/i in 1 + y_starting_skip to line_count - y_ending_skip)
				var/line = gset.gridLines[i]
				if(line == space_key && no_afterchange)
					#ifdef TESTING
						++turfsSkipped
					#endif
					ycrd--
					MAPLOADING_CHECK_TICK
					continue

				var/list/cache = modelCache[line]
				if(!cache)
					SSatoms.map_loader_stop()
					CRASH("Undefined model key in DMM: [line]")
				build_coordinate(cache, locate(true_xcrd, ycrd, zcrd), no_afterchange, placeOnTop)

				// only bother with bounds that actually exist
				if(!first_found)
					first_found = TRUE
					first_y = ycrd
				last_y = ycrd
				ycrd--
				MAPLOADING_CHECK_TICK
			// The x coord never changes, so this is safe
			if(first_found)
				first_x = true_xcrd
				last_x = true_xcrd
		else
			// This is the dmm parser, note the double loop
			for(var/i in 1 + y_starting_skip to line_count - y_ending_skip)
				var/line = gset.gridLines[i]

				var/xcrd = true_xcrd
				for(var/tpos in 1 + x_starting_skip to x_target step key_len)
					var/model_key = copytext(line, tpos, tpos + key_len)
					if(model_key == space_key && no_afterchange)
						#ifdef TESTING
							++turfsSkipped
						#endif
						MAPLOADING_CHECK_TICK
						++xcrd
						continue
					var/list/cache = modelCache[model_key]
					if(!cache)
						SSatoms.map_loader_stop()
						CRASH("Undefined model key in DMM: [model_key]")
					build_coordinate(cache, locate(xcrd, ycrd, zcrd), no_afterchange, placeOnTop)

					// only bother with bounds that actually exist
					if(!first_found)
						first_found = TRUE
						first_x = xcrd
						first_y = ycrd
					last_x = xcrd
					last_y = ycrd
					MAPLOADING_CHECK_TICK
					++xcrd
				ycrd--
				MAPLOADING_CHECK_TICK
		bounds[MAP_MINX] = min(bounds[MAP_MINX], first_x)
		bounds[MAP_MINY] = min(bounds[MAP_MINY], last_y)
		bounds[MAP_MINZ] = min(bounds[MAP_MINZ], zcrd)
		bounds[MAP_MAXX] = max(bounds[MAP_MAXX], last_x)
		bounds[MAP_MAXY] = max(bounds[MAP_MAXY], first_y)
		bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], zcrd)

	// And we are done lads, call it off
	SSatoms.map_loader_stop()
	if(!no_changeturf)
		for(var/turf/T as anything in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]), locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
			//we do this after we load everything in. if we don't; we'll have weird atmos bugs regarding atmos adjacent turfs
			T.AfterChange(CHANGETURF_IGNORE_AIR)

	if(has_expanded_world_maxx || has_expanded_world_maxy)
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_EXPANDED_WORLD_BOUNDS, has_expanded_world_maxx, has_expanded_world_maxy)

	#ifdef TESTING
	if(turfsSkipped)
		testing("Skipped loading [turfsSkipped] default turfs")
	#endif

	return TRUE

GLOBAL_LIST_EMPTY(map_model_default)

/datum/parsed_map/proc/build_cache(no_changeturf, bad_paths=null)
	if(modelCache && !bad_paths)
		return modelCache
	. = modelCache = list()
	var/list/grid_models = src.grid_models
	var/set_space = FALSE
	// Use where a list is needed, but where it will not be modified
	// Used here to remove the cost of needing to make a new list for each fields entry when it's set manually later
	var/static/list/default_list = GLOB.map_model_default
	for(var/model_key in grid_models)
		var/model = grid_models[model_key]
		// This is safe because dmm strings will never actually newline
		// So we can parse things just fine
		var/list/entries = splittext(model, ",\n")
		//will contain all members (paths) in model (in our example : /turf/unsimulated/wall and /area/mine/explored)
		var/list/members = new /list(length(entries))
		//will contain lists filled with corresponding variables, if any (in our example : list(icon_state = "rock") and list())
		//member attributes are rarish, so we could lazyinit this
		var/list/members_attributes = new /list(length(entries))

		/////////////////////////////////////////////////////////
		//Constructing members and corresponding variables lists
		////////////////////////////////////////////////////////

		var/index = 1
		for(var/member_string in entries)
			var/variables_start = 0
			//findtext is a bit expensive, lets only do this if the last char of our string is a } (IE: we know we have vars)
			//this saves about 25 miliseconds on my machine. Not a major optimization
			if(member_string[length(member_string)] == "}")
				variables_start = findtext(member_string, "{")

			var/path_text = TRIM_TEXT(copytext(member_string, 1, variables_start))
			var/atom_def = text2path(path_text) //path definition, e.g /obj/foo/bar

			if(!ispath(atom_def, /atom)) // Skip the item if the path does not exist.  Fix your crap, mappers!
				if(bad_paths)
					LAZYOR(bad_paths[path_text], model_key)
				continue
			members[index] = atom_def

			//transform the variables in text format into a list (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
			var/list/fields = default_list
			if(variables_start)//if there's any variable
				member_string = copytext(member_string, variables_start + length(member_string[variables_start]), -length(copytext_char(member_string, -1))) //removing the last '}'
				fields = readlist(member_string, ";")
				for(var/I in fields)
					var/value = fields[I]
					if(istext(value))
						fields[I] = apply_text_macros(value)

			//then fill the members_attributes list with the corresponding variables
			members_attributes[index++] = fields
			CHECK_TICK

		//check and see if we can just skip this turf
		//So you don't have to understand this horrid statement, we can do this if
		// 1. the space_key isn't set yet
		// 2. no_changeturf is set
		// 3. there are exactly 2 members
		// 4. with no attributes
		// 5. and the members are world.turf and world.area
		// Basically, if we find an entry like this: "XXX" = (/turf/default, /area/default)
		// We can skip calling this proc every time we see XXX
		if(!set_space \
			&& no_changeturf \
			&& members.len == 2 \
			&& members_attributes.len == 2 \
			&& length(members_attributes[1]) == 0 \
			&& length(members_attributes[2]) == 0 \
			&& (world.area in members) \
			&& (world.turf in members))
			set_space = TRUE
			.[SPACE_KEY] = model_key
			continue

		.[model_key] = list(members, members_attributes)

/datum/parsed_map/proc/build_coordinate(list/model, turf/crds, no_changeturf as num, placeOnTop as num)
	// If we don't have a turf, nothing we will do next will actually acomplish anything, so just go back
	// Note, this would actually drop area vvs in the tile, but like, why tho
	if(!crds)
		return
	var/index
	var/list/members = model[1]
	var/list/members_attributes = model[2]

	// We use static lists here because it's cheaper then passing them around
	var/static/list/default_list = GLOB.map_model_default
	var/static/list/area_cache = GLOB.areas_by_type
	////////////////
	//Instanciation
	////////////////

	if(turf_blacklist?[crds])
		return

	//The next part of the code assumes there's ALWAYS an /area AND a /turf on a given tile
	//first instance the /area and remove it from the members list
	index = members.len
	var/atom/instance
	if(members[index] != /area/template_noop)
		if(members_attributes[index] != default_list)
			world.preloader_setup(members_attributes[index], members[index])//preloader for assigning  set variables on atom creation
		instance = area_cache[members[index]]
		if (!instance)
			// Done here because it's cheaper then doing it in the outside check
			var/area_type = members[index]
			instance = new area_type(null)
			if(!instance)
				CRASH("[area_type] failed to be new'd, what'd you do?")
			area_cache[area_type] = instance

		instance.contents.Add(crds)

		if(GLOB.use_preloader)
			world.preloader_load(instance)

	// Index right before /area is /turf
	index--
	//then instance the /turf
	//NOTE: this used to place any turfs before the last "underneath" it using .appearance and underlays
	//We don't actually use this, and all it did was cost cpu, so we don't do this anymore
	if(members[index] != /turf/template_noop)
		if(members_attributes[index] != default_list)
			world.preloader_setup(members_attributes[index], members[index])

		// Note: we make the assertion that the last path WILL be a turf. if it isn't, this will fail.
		if(placeOnTop)
			instance = crds.PlaceOnTop(null, members[index], CHANGETURF_DEFER_CHANGE | (no_changeturf ? CHANGETURF_SKIP : NONE))
		else if(no_changeturf)
			instance = create_atom(members[index], crds)//first preloader pass
		else
			instance = crds.ChangeTurf(members[index], null, CHANGETURF_DEFER_CHANGE)

		if(GLOB.use_preloader && instance)//second preloader pass, for those atoms that don't ..() in New()
			world.preloader_load(instance)
	MAPLOADING_CHECK_TICK

	//finally instance all remainings objects/mobs
	for(var/atom_index in 1 to index-1)
		if(members_attributes[atom_index] != default_list)
			world.preloader_setup(members_attributes[atom_index], members[atom_index])

		// We make the assertion that only /atom s will be in this portion of the code. if that isn't true, this will fail
		instance = create_atom(members[atom_index], crds)//first preloader pass

		if(GLOB.use_preloader && instance)//second preloader pass, for those atoms that don't ..() in New()
			world.preloader_load(instance)
		MAPLOADING_CHECK_TICK

////////////////
//Helpers procs
////////////////

/datum/parsed_map/proc/create_atom(path, crds)
	set waitfor = FALSE
	. = new path (crds)

//find the position of the next delimiter,skipping whatever is comprised between opening_escape and closing_escape
//returns 0 if reached the last delimiter
/datum/parsed_map/proc/find_next_delimiter_position(text as text,initial_position as num, delimiter=",",opening_escape="\"",closing_escape="\"")
	var/position = initial_position
	var/next_delimiter = findtext(text,delimiter,position,0)
	var/next_opening = findtext(text,opening_escape,position,0)

	while((next_opening != 0) && (next_opening < next_delimiter))
		position = findtext(text,closing_escape,next_opening + 1,0)+1
		next_delimiter = findtext(text,delimiter,position,0)
		next_opening = findtext(text,opening_escape,position,0)

	return next_delimiter

//build a list from variables in text form (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
//return the filled list
/datum/parsed_map/proc/readlist(text as text, delimiter=",")
	. = list()
	if (!text)
		return

	// If we're using a semi colon, we can do this as splittext rather then constant calls to find_next_delimiter_position
	// This does make the code a bit harder to read, but saves a good bit of time so suck it up
	var/using_semicolon = delimiter == ";"
	if(using_semicolon)
		var/list/line_entries = splittext(text, ";\n")
		for(var/entry in line_entries)
			// check if this is a simple variable (as in list(var1, var2)) or an associative one (as in list(var1="foo",var2=7))
			var/equal_position = findtext(entry,"=")
			// This could in theory happen if someone inserts an improper newline
			// Let's be nice and kill it here rather then later, it'll save like 0.02 seconds if we don't need to run trims in build_cache
			if(!equal_position)
				continue
			var/trim_left = TRIM_TEXT(copytext(entry,1,equal_position))

			// Associative var, so do the association.
			// Note that numbers cannot be keys - the RHS is dropped if so.
			var/trim_right = TRIM_TEXT(copytext(entry, equal_position + length(entry[equal_position])))
			var/right_constant = parse_constant(trim_right)
			.[trim_left] = right_constant
	else
		var/position
		var/old_position = 1
		while(position != 0)
			// find next delimiter that is not within  "..."
			position = find_next_delimiter_position(text,old_position,delimiter)

			// check if this is a simple variable (as in list(var1, var2)) or an associative one (as in list(var1="foo",var2=7))
			var/equal_position = findtext(text,"=",old_position, position)
			var/trim_left = TRIM_TEXT(copytext(text,old_position,(equal_position ? equal_position : position)))
			var/left_constant = parse_constant(trim_left)
			if(position)
				old_position = position + length(text[position])
			if(!left_constant) // damn newlines man. Exists to provide behavior consistency with the above loop. not a major cost becuase this path is cold
				continue

			if(equal_position && !isnum(left_constant))
				// Associative var, so do the association.
				// Note that numbers cannot be keys - the RHS is dropped if so.
				var/trim_right = TRIM_TEXT(copytext(text, equal_position + length(text[equal_position]), position))
				var/right_constant = parse_constant(trim_right)
				.[left_constant] = right_constant
			else  // simple var
				. += list(left_constant)

/datum/parsed_map/proc/parse_constant(text)
	// number
	var/num = text2num(text)
	if(isnum(num))
		return num

	// string
	if(text[1] == "\"")
		// insert implied locate \" and length("\"") here
		// It's a minimal timesave but it is a timesave
		// Safe becuase we're guarenteed trimmed constants
		return copytext(text, 2, -1)

	// list
	if(copytext(text, 1, 6) == "list(")//6 == length("list(") + 1
		return readlist(copytext(text, 6, -1))

	// typepath
	var/path = text2path(text)
	if(ispath(path))
		return path

	// file
	if(text[1] == "'")
		return file(copytext_char(text, 2, -1))

	// null
	if(text == "null")
		return null

	// not parsed:
	// - pops: /obj{name="foo"}
	// - new(), newlist(), icon(), matrix(), sound()

	// fallback: string
	return text

/datum/parsed_map/Destroy()
	..()
	if(turf_blacklist)
		turf_blacklist.Cut()
	parsed_bounds.Cut()
	bounds.Cut()
	grid_models.Cut()
	gridSets.Cut()
	return QDEL_HINT_HARDDEL_NOW
