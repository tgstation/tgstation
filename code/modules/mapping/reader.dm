///////////////////////////////////////////////////////////////
//SS13 Optimized Map loader
//////////////////////////////////////////////////////////////
#define SPACE_KEY "space"
//global datum that will preload variables on atoms instanciation
GLOBAL_VAR_INIT(use_preloader, FALSE)
GLOBAL_DATUM_INIT(_preloader, /datum/map_preloader, new)

/datum/grid_set
	var/xcrd
	var/ycrd
	var/zcrd
	var/xcrdStart
	var/gridLines

/datum/parsed_map
	var/list/grid_models = list()
	var/list/gridSets = list()
	var/list/bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)
	var/key_len = 0

/datum/parsed_map/proc/initTemplateBounds()
	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/atoms = list()

	var/list/turfs = block(	locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
							locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ]))
	var/list/border = block(locate(max(bounds[MAP_MINX]-1, 1),			max(bounds[MAP_MINY]-1, 1),			 bounds[MAP_MINZ]),
							locate(min(bounds[MAP_MAXX]+1, world.maxx),	min(bounds[MAP_MAXY]+1, world.maxy), bounds[MAP_MAXZ])) - turfs
	for(var/L in turfs)
		var/turf/B = L
		atoms += B
		for(var/A in B)
			atoms += A
			if(istype(A, /obj/structure/cable))
				cables += A
				continue
			if(istype(A, /obj/machinery/atmospherics))
				atmos_machines += A
	for(var/L in border)
		var/turf/T = L
		T.air_update_turf(TRUE) //calculate adjacent turfs along the border to prevent runtimes

	SSatoms.InitializeAtoms(atoms)
	SSmachines.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)

/datum/maploader
		// /"([a-zA-Z]+)" = \(((?:.|\n)*?)\)\n(?!\t)|\((\d+),(\d+),(\d+)\) = \{"([a-zA-Z\n]*)"\}/g
	var/static/regex/dmmRegex = new/regex({""(\[a-zA-Z]+)" = \\(((?:.|\n)*?)\\)\n(?!\t)|\\((\\d+),(\\d+),(\\d+)\\) = \\{"(\[a-zA-Z\n]*)"\\}"}, "g")
		// /^[\s\n]+"?|"?[\s\n]+$|^"|"$/g
	var/static/regex/trimQuotesRegex = new/regex({"^\[\\s\n]+"?|"?\[\\s\n]+$|^"|"$"}, "g")
		// /^[\s\n]+|[\s\n]+$/
	var/static/regex/trimRegex = new/regex("^\[\\s\n]+|\[\\s\n]+$", "g")
	#ifdef TESTING
	var/turfsSkipped
	#endif

/**
 * Construct the model map and control the loading process
 *
 * WORKING :
 *
 * 1) Makes an associative mapping of model_keys with model
 *		e.g aa = /turf/unsimulated/wall{icon_state = "rock"}
 * 2) Read the map line by line, parsing the result (using parse_grid)
 *
 */
/datum/maploader/load_map(dmm_file as file, x_offset as num, y_offset as num, z_offset as num, cropMap as num, measureOnly as num, no_changeturf as num, lower_crop_x as num,  lower_crop_y as num, upper_crop_x as num, upper_crop_y as num, placeOnTop as num)
	//How I wish for RAII
	Master.StartLoadingMap()
	#ifdef TESTING
	turfsSkipped = 0
	#endif
	. = load_map_impl(dmm_file, x_offset, y_offset, z_offset, cropMap, measureOnly, no_changeturf, lower_crop_x, upper_crop_x, lower_crop_y, upper_crop_y, placeOnTop)
	#ifdef TESTING
	if(turfsSkipped)
		testing("Skipped loading [turfsSkipped] default turfs")
	#endif
	Master.StopLoadingMap()

/datum/parsed_map/New(tfile, x_offset, y_offset, z_offset, x_lower, x_upper, y_lower, y_upper, measureOnly, regex/dmmRegex, cropMap)
	var/stored_index = 1

	//multiz lool
	while(dmmRegex.Find(tfile, stored_index))
		stored_index = dmmRegex.next

		// "aa" = (/type{vars=blah})
		if(dmmRegex.group[1]) // Model
			var/key = dmmRegex.group[1]
			if(grid_models[key]) // Duplicate model keys are ignored in DMMs
				continue
			if(key_len != length(key))
				if(!key_len)
					key_len = length(key)
				else
					CRASH("Inconsistent key length in DMM")
			if(!measureOnly)
				grid_models[key] = dmmRegex.group[2]

		// (1,1,1) = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
		else if(dmmRegex.group[3]) // Coords
			if(!key_len)
				CRASH("Coords before model definition in DMM")

			var/curr_x = text2num(dmmRegex.group[3])

			if(curr_x < x_lower || curr_x > x_upper)
				continue

			var/datum/grid_set/gridSet = new

			gridSet.xcrdStart = curr_x + x_offset - 1
			//position of the currently processed square
			gridSet.ycrd = text2num(dmmRegex.group[4]) + y_offset - 1
			gridSet.zcrd = text2num(dmmRegex.group[5]) + z_offset - 1

			bounds[MAP_MINX] = min(bounds[MAP_MINX], CLAMP(gridSet.xcrdStart, x_lower, x_upper))
			bounds[MAP_MINZ] = min(bounds[MAP_MINZ], gridSet.zcrd)
			bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], gridSet.zcrd)

			var/list/gridLines = splittext(dmmRegex.group[6], "\n")
			gridSet.gridLines = gridLines

			var/leadingBlanks = 0
			while(leadingBlanks < gridLines.len && gridLines[++leadingBlanks] == "")
			if(leadingBlanks > 1)
				gridLines.Cut(1, leadingBlanks) // Remove all leading blank lines.

			if(!gridLines.len) // Skip it if only blank lines exist.
				continue

			gridSets += gridSet

			if(gridLines.len && gridLines[gridLines.len] == "")
				gridLines.Cut(gridLines.len) // Remove only one blank line at the end.

			bounds[MAP_MINY] = min(bounds[MAP_MINY], CLAMP(gridSet.ycrd, y_lower, y_upper))
			gridSet.ycrd += gridLines.len - 1 // Start at the top and work down

			if(!cropMap && gridSet.ycrd > world.maxy)
				bounds[MAP_MAXY] = max(bounds[MAP_MAXY], CLAMP(gridSet.ycrd, y_lower, y_upper))
			else
				bounds[MAP_MAXY] = max(bounds[MAP_MAXY], CLAMP(min(gridSet.ycrd, world.maxy), y_lower, y_upper))

			var/maxx = gridSet.xcrdStart
			if(gridLines.len) //Not an empty map
				maxx = max(maxx, gridSet.xcrdStart + length(gridLines[1]) / key_len - 1)

			bounds[MAP_MAXX] = CLAMP(max(bounds[MAP_MAXX], cropMap ? min(maxx, world.maxx) : maxx), x_lower, x_upper)
		CHECK_TICK

/datum/maploader/proc/load_map_impl(dmm_file, x_offset, y_offset, z_offset, cropMap, measureOnly, no_changeturf, x_lower = -INFINITY, x_upper = INFINITY, y_lower = -INFINITY, y_upper = INFINITY, placeOnTop = FALSE)
	var/tfile = dmm_file//the map file we're creating
	if(isfile(tfile))
		tfile = file2text(tfile)

	if(!x_offset)
		x_offset = 1
	if(!y_offset)
		y_offset = 1
	if(!z_offset)
		z_offset = world.maxz + 1

	var/datum/parsed_map/parsed = new(tfile, x_offset, y_offset, z_offset, x_lower, x_upper, y_lower, y_upper, measureOnly, dmmRegex, cropMap)

	var/list/modelCache
	var/space_key
	if(!measureOnly)
		modelCache = build_cache(parsed, no_changeturf)
		space_key = modelCache[SPACE_KEY]

	for(var/I in parsed.gridSets)
		var/datum/grid_set/gset = I
		if(!cropMap && !measureOnly && gset.ycrd > world.maxy)
			world.maxy = gset.ycrd // Expand Y here.  X is expanded in the loop below
		var/zexpansion = gset.zcrd > world.maxz
		if(zexpansion && !measureOnly)
			if(cropMap)
				continue
			else
				while (gset.zcrd > world.maxz) //create a new z_level if needed
					world.incrementMaxZ()
			if(!no_changeturf)
				WARNING("Z-level expansion occurred without no_changeturf set, this may cause problems when /turf/AfterChange is called")

		var/maxx = gset.xcrdStart
		if(!measureOnly)
			for(var/line in gset.gridLines)
				if((gset.ycrd - y_offset + 1) < y_lower || (gset.ycrd - y_offset + 1) > y_upper)				//Reverse operation and check if it is out of bounds of cropping.
					--gset.ycrd
					continue
				if(gset.ycrd <= world.maxy && gset.ycrd >= 1)
					gset.xcrd = gset.xcrdStart
					for(var/tpos = 1 to length(line) - parsed.key_len + 1 step parsed.key_len)
						if((gset.xcrd - x_offset + 1) < x_lower || (gset.xcrd - x_offset + 1) > x_upper)			//Same as above.
							++gset.xcrd
							continue								//X cropping.
						if(gset.xcrd > world.maxx)
							if(cropMap)
								break
							else
								world.maxx = gset.xcrd

						if(gset.xcrd >= 1)
							var/model_key = copytext(line, tpos, tpos + parsed.key_len)
							var/no_afterchange = no_changeturf || zexpansion
							if(!no_afterchange || (model_key != space_key))
								var/list/cache = modelCache[model_key]
								if(!cache)
									CRASH("Undefined model key in DMM: [model_key]")
								build_coordinate(cache, gset.xcrd, gset.ycrd, gset.zcrd, no_afterchange, placeOnTop)
							#ifdef TESTING
							else
								++turfsSkipped
							#endif
							CHECK_TICK
						maxx = max(maxx, gset.xcrd)
						++gset.xcrd
				--gset.ycrd

		CHECK_TICK

	var/list/bounds = parsed.bounds
	if(bounds[1] == 1.#INF) // Shouldn't need to check every item
		parsed.bounds = null
	else if(!measureOnly && !no_changeturf)
		for(var/t in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]), locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
			var/turf/T = t
			//we do this after we load everything in. if we don't; we'll have weird atmos bugs regarding atmos adjacent turfs
			T.AfterChange(CHANGETURF_IGNORE_AIR)
	return parsed

/datum/maploader/proc/build_cache(datum/parsed_map/parsed, no_changeturf)
	. = list()
	var/list/grid_models = parsed.grid_models
	for(var/model_key in grid_models)
		var/model = grid_models[model_key]
		var/list/members = list() //will contain all members (paths) in model (in our example : /turf/unsimulated/wall and /area/mine/explored)
		var/list/members_attributes = list() //will contain lists filled with corresponding variables, if any (in our example : list(icon_state = "rock") and list())

		/////////////////////////////////////////////////////////
		//Constructing members and corresponding variables lists
		////////////////////////////////////////////////////////

		var/index = 1
		var/old_position = 1
		var/dpos

		do
			//finding next member (e.g /turf/unsimulated/wall{icon_state = "rock"} or /area/mine/explored)
			dpos = find_next_delimiter_position(model, old_position, ",", "{", "}") //find next delimiter (comma here) that's not within {...}

			var/full_def = trim_text(copytext(model, old_position, dpos)) //full definition, e.g : /obj/foo/bar{variables=derp}
			var/variables_start = findtext(full_def, "{")
			var/atom_def = text2path(trim_text(copytext(full_def, 1, variables_start))) //path definition, e.g /obj/foo/bar
			old_position = dpos + 1

			if(!atom_def) // Skip the item if the path does not exist.  Fix your crap, mappers!
				continue
			members.Add(atom_def)

			//transform the variables in text format into a list (e.g {var1="derp"; var2; var3=7} => list(var1="derp", var2, var3=7))
			var/list/fields = list()

			if(variables_start)//if there's any variable
				full_def = copytext(full_def,variables_start+1,length(full_def))//removing the last '}'
				fields = readlist(full_def, ";")
				if(fields.len)
					if(!trim(fields[fields.len]))
						--fields.len
					for(var/I in fields)
						var/value = fields[I]
						if(istext(value))
							fields[I] = apply_text_macros(value)

			//then fill the members_attributes list with the corresponding variables
			members_attributes.len++
			members_attributes[index++] = fields

			CHECK_TICK
		while(dpos != 0)

		//check and see if we can just skip this turf
		//So you don't have to understand this horrid statement, we can do this if
		// 1. no_changeturf is set
		// 2. the space_key isn't set yet
		// 3. there are exactly 2 members
		// 4. with no attributes
		// 5. and the members are world.turf and world.area
		// Basically, if we find an entry like this: "XXX" = (/turf/default, /area/default)
		// We can skip calling this proc every time we see XXX
		if(no_changeturf \
			&& !(.[SPACE_KEY]) \
			&& members.len == 2 \
			&& members_attributes.len == 2 \
			&& length(members_attributes[1]) == 0 \
			&& length(members_attributes[2]) == 0 \
			&& (world.area in members) \
			&& (world.turf in members))

			.[SPACE_KEY] = model_key
			continue


		.[model_key] = list(members, members_attributes)

/datum/maploader/proc/build_coordinate(list/model, xcrd as num, ycrd as num, zcrd as num, no_changeturf as num, placeOnTop as num)
	var/index
	var/list/members = model[1]
	var/list/members_attributes = model[2]

	////////////////
	//Instanciation
	////////////////

	//The next part of the code assumes there's ALWAYS an /area AND a /turf on a given tile
	var/turf/crds = locate(xcrd,ycrd,zcrd)

	//first instance the /area and remove it from the members list
	index = members.len
	if(members[index] != /area/template_noop)
		var/atom/instance
		GLOB._preloader.setup(members_attributes[index])//preloader for assigning  set variables on atom creation
		var/atype = members[index]
		for(var/area/A in world)
			if(A.type == atype)
				instance = A
				break
		if(!instance)
			instance = new atype(null)
		if(crds)
			instance.contents.Add(crds)

		if(GLOB.use_preloader && instance)
			GLOB._preloader.load(instance)

	//then instance the /turf and, if multiple tiles are presents, simulates the DMM underlays piling effect

	var/first_turf_index = 1
	while(!ispath(members[first_turf_index], /turf)) //find first /turf object in members
		first_turf_index++

	//turn off base new Initialization until the whole thing is loaded
	SSatoms.map_loader_begin()
	//instanciate the first /turf
	var/turf/T
	if(members[first_turf_index] != /turf/template_noop)
		T = instance_atom(members[first_turf_index],members_attributes[first_turf_index],crds,no_changeturf,placeOnTop)

	if(T)
		//if others /turf are presents, simulates the underlays piling effect
		index = first_turf_index + 1
		while(index <= members.len - 1) // Last item is an /area
			var/underlay = T.appearance
			T = instance_atom(members[index],members_attributes[index],crds,no_changeturf,placeOnTop)//instance new turf
			T.underlays += underlay
			index++

	//finally instance all remainings objects/mobs
	for(index in 1 to first_turf_index-1)
		instance_atom(members[index],members_attributes[index],crds,no_changeturf,placeOnTop)
	//Restore initialization to the previous value
	SSatoms.map_loader_stop()

////////////////
//Helpers procs
////////////////

//Instance an atom at (x,y,z) and gives it the variables in attributes
/datum/maploader/proc/instance_atom(path,list/attributes, turf/crds, no_changeturf, placeOnTop)
	GLOB._preloader.setup(attributes, path)

	if(crds)
		if(ispath(path, /turf))
			if(placeOnTop)
				. = crds.PlaceOnTop(null, path, CHANGETURF_DEFER_CHANGE | (no_changeturf ? CHANGETURF_SKIP : NONE))
			else if(!no_changeturf)
				. = crds.ChangeTurf(path, null, CHANGETURF_DEFER_CHANGE)
			else
				. = create_atom(path, crds)//first preloader pass
		else
			. = create_atom(path, crds)//first preloader pass

	if(GLOB.use_preloader && .)//second preloader pass, for those atoms that don't ..() in New()
		GLOB._preloader.load(.)

	//custom CHECK_TICK here because we don't want things created while we're sleeping to not initialize
	if(TICK_CHECK)
		SSatoms.map_loader_stop()
		stoplag()
		SSatoms.map_loader_begin()

/datum/maploader/proc/create_atom(path, crds)
	set waitfor = FALSE
	. = new path (crds)

//text trimming (both directions) helper proc
//optionally removes quotes before and after the text (for variable name)
/datum/maploader/proc/trim_text(what as text,trim_quotes=0)
	if(trim_quotes)
		return trimQuotesRegex.Replace(what, "")
	else
		return trimRegex.Replace(what, "")


//find the position of the next delimiter,skipping whatever is comprised between opening_escape and closing_escape
//returns 0 if reached the last delimiter
/datum/maploader/proc/find_next_delimiter_position(text as text,initial_position as num, delimiter=",",opening_escape="\"",closing_escape="\"")
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
/datum/maploader/proc/readlist(text as text, delimiter=",")

	var/list/to_return = list()

	var/position
	var/old_position = 1

	do
		//find next delimiter that is not within  "..."
		position = find_next_delimiter_position(text,old_position,delimiter)

		//check if this is a simple variable (as in list(var1, var2)) or an associative one (as in list(var1="foo",var2=7))
		var/equal_position = findtext(text,"=",old_position, position)

		var/trim_left = trim_text(copytext(text,old_position,(equal_position ? equal_position : position)),1)//the name of the variable, must trim quotes to build a BYOND compliant associatives list
		old_position = position + 1

		if(equal_position)//associative var, so do the association
			var/trim_right = trim_text(copytext(text,equal_position+1,position))//the content of the variable

			//Check for string
			if(findtext(trim_right,"\"",1,2))
				trim_right = copytext(trim_right,2,findtext(trim_right,"\"",3,0))

			//Check for number
			else if(isnum(text2num(trim_right)))
				trim_right = text2num(trim_right)

			//Check for null
			else if(trim_right == "null")
				trim_right = null

			//Check for list
			else if(copytext(trim_right,1,5) == "list")
				trim_right = readlist(copytext(trim_right,6,length(trim_right)))

			//Check for file
			else if(copytext(trim_right,1,2) == "'")
				trim_right = file(copytext(trim_right,2,length(trim_right)))

			//Check for path
			else if(ispath(text2path(trim_right)))
				trim_right = text2path(trim_right)

			to_return[trim_left] = trim_right

		else//simple var
			to_return[trim_left] = null

	while(position != 0)

	return to_return

/datum/maploader/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

//////////////////
//Preloader datum
//////////////////

/datum/map_preloader
	parent_type = /datum
	var/list/attributes
	var/target_path

/datum/map_preloader/proc/setup(list/the_attributes, path)
	if(the_attributes.len)
		GLOB.use_preloader = TRUE
		attributes = the_attributes
		target_path = path

/datum/map_preloader/proc/load(atom/what)
	for(var/attribute in attributes)
		var/value = attributes[attribute]
		if(islist(value))
			value = deepCopyList(value)
		what.vars[attribute] = value
	GLOB.use_preloader = FALSE

/area/template_noop
	name = "Area Passthrough"

/turf/template_noop
	name = "Turf Passthrough"
	icon_state = "noop"
	bullet_bounce_sound = null
