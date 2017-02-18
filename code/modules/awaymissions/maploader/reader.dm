///////////////////////////////////////////////////////////////
//SS13 Optimized Map loader
//////////////////////////////////////////////////////////////

//global datum that will preload variables on atoms instanciation
var/global/use_preloader = FALSE
var/global/dmm_suite/preloader/_preloader = new

/dmm_suite
		// /"([a-zA-Z]+)" = \(((?:.|\n)*?)\)\n(?!\t)|\((\d+),(\d+),(\d+)\) = \{"([a-zA-Z\n]*)"\}/g
	var/static/regex/dmmRegex = new/regex({""(\[a-zA-Z]+)" = \\(((?:.|\n)*?)\\)\n(?!\t)|\\((\\d+),(\\d+),(\\d+)\\) = \\{"(\[a-zA-Z\n]*)"\\}"}, "g")
		// /^[\s\n]+"?|"?[\s\n]+$|^"|"$/g
	var/static/regex/trimQuotesRegex = new/regex({"^\[\\s\n]+"?|"?\[\\s\n]+$|^"|"$"}, "g")
		// /^[\s\n]+|[\s\n]+$/
	var/static/regex/trimRegex = new/regex("^\[\\s\n]+|\[\\s\n]+$", "g")
	var/static/list/modelCache = list()

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
/dmm_suite/load_map(dmm_file as file, x_offset as num, y_offset as num, z_offset as num, cropMap as num, measureOnly as num)
	var/tfile = dmm_file//the map file we're creating
	if(isfile(tfile))
		tfile = file2text(tfile)

	if(!x_offset)
		x_offset = 1
	if(!y_offset)
		y_offset = 1
	if(!z_offset)
		z_offset = world.maxz + 1

	var/list/bounds = list(1.#INF, 1.#INF, 1.#INF, -1.#INF, -1.#INF, -1.#INF)
	var/list/grid_models = list()
	var/key_len = 0

	var/stored_index = 1
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
					throw EXCEPTION("Inconsistant key length in DMM")
			if(!measureOnly)
				grid_models[key] = dmmRegex.group[2]

		// (1,1,1) = {"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}
		else if(dmmRegex.group[3]) // Coords
			if(!key_len)
				throw EXCEPTION("Coords before model definition in DMM")

			var/xcrdStart = text2num(dmmRegex.group[3]) + x_offset - 1
			//position of the currently processed square
			var/xcrd
			var/ycrd = text2num(dmmRegex.group[4]) + y_offset - 1
			var/zcrd = text2num(dmmRegex.group[5]) + z_offset - 1

			if(zcrd > world.maxz)
				if(cropMap)
					continue
				else
					world.maxz = zcrd //create a new z_level if needed

			bounds[MAP_MINX] = min(bounds[MAP_MINX], xcrdStart)
			bounds[MAP_MINZ] = min(bounds[MAP_MINZ], zcrd)
			bounds[MAP_MAXZ] = max(bounds[MAP_MAXZ], zcrd)

			var/list/gridLines = splittext(dmmRegex.group[6], "\n")

			var/leadingBlanks = 0
			while(leadingBlanks < gridLines.len && gridLines[++leadingBlanks] == "")
			if(leadingBlanks > 1)
				gridLines.Cut(1, leadingBlanks) // Remove all leading blank lines.

			if(!gridLines.len) // Skip it if only blank lines exist.
				continue

			if(gridLines.len && gridLines[gridLines.len] == "")
				gridLines.Cut(gridLines.len) // Remove only one blank line at the end.

			bounds[MAP_MINY] = min(bounds[MAP_MINY], ycrd)
			ycrd += gridLines.len - 1 // Start at the top and work down

			if(!cropMap && ycrd > world.maxy)
				if(!measureOnly)
					world.maxy = ycrd // Expand Y here.  X is expanded in the loop below
				bounds[MAP_MAXY] = max(bounds[MAP_MAXY], ycrd)
			else
				bounds[MAP_MAXY] = max(bounds[MAP_MAXY], min(ycrd, world.maxy))

			var/maxx = xcrdStart
			if(measureOnly)
				for(var/line in gridLines)
					maxx = max(maxx, xcrdStart + length(line) / key_len - 1)
			else
				for(var/line in gridLines)
					if(ycrd <= world.maxy && ycrd >= 1)
						xcrd = xcrdStart
						for(var/tpos = 1 to length(line) - key_len + 1 step key_len)
							if(xcrd > world.maxx)
								if(cropMap)
									break
								else
									world.maxx = xcrd

							if(xcrd >= 1)
								var/model_key = copytext(line, tpos, tpos + key_len)
								if(!grid_models[model_key])
									throw EXCEPTION("Undefined model key in DMM.")
								parse_grid(grid_models[model_key], xcrd, ycrd, zcrd)
								CHECK_TICK

							maxx = max(maxx, xcrd)
							++xcrd
					--ycrd

			bounds[MAP_MAXX] = max(bounds[MAP_MAXX], cropMap ? min(maxx, world.maxx) : maxx)

		CHECK_TICK

	if(bounds[1] == 1.#INF) // Shouldn't need to check every item
		return null
	else
		if(!measureOnly)
			for(var/t in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]), locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
				var/turf/T = t
				//we do this after we load everything in. if we don't; we'll have weird atmos bugs regarding atmos adjacent turfs
				T.AfterChange(TRUE)
		return bounds

/**
 * Fill a given tile with its area/turf/objects/mobs
 * Variable model is one full map line (e.g /turf/unsimulated/wall{icon_state = "rock"},/area/mine/explored)
 *
 * WORKING :
 *
 * 1) Read the model string, member by member (delimiter is ',')
 *
 * 2) Get the path of the atom and store it into a list
 *
 * 3) a) Check if the member has variables (text within '{' and '}')
 *
 * 3) b) Construct an associative list with found variables, if any (the atom index in members is the same as its variables in members_attributes)
 *
 * 4) Instanciates the atom with its variables
 *
 */
/dmm_suite/proc/parse_grid(model as text,xcrd as num,ycrd as num,zcrd as num)
	/*Method parse_grid()
	- Accepts a text string containing a comma separated list of type paths of the
		same construction as those contained in a .dmm file, and instantiates them.
	*/

	var/list/members //will contain all members (paths) in model (in our example : /turf/unsimulated/wall and /area/mine/explored)
	var/list/members_attributes //will contain lists filled with corresponding variables, if any (in our example : list(icon_state = "rock") and list())
	var/list/cached = modelCache[model]
	var/index

	if(cached)
		members = cached[1]
		members_attributes = cached[2]
	else

		/////////////////////////////////////////////////////////
		//Constructing members and corresponding variables lists
		////////////////////////////////////////////////////////

		members = list()
		members_attributes = list()
		index = 1

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

			//then fill the members_attributes list with the corresponding variables
			members_attributes.len++
			members_attributes[index++] = fields

			CHECK_TICK
		while(dpos != 0)

		modelCache[model] = list(members, members_attributes)


	////////////////
	//Instanciation
	////////////////

	//The next part of the code assumes there's ALWAYS an /area AND a /turf on a given tile

	//first instance the /area and remove it from the members list
	index = members.len
	if(members[index] != /area/template_noop)
		var/atom/instance
		_preloader.setup(members_attributes[index])//preloader for assigning  set variables on atom creation

		instance = locate(members[index])
		var/turf/crds = locate(xcrd,ycrd,zcrd)
		if(crds)
			instance.contents.Add(crds)

		if(use_preloader && instance)
			_preloader.load(instance)

	//then instance the /turf and, if multiple tiles are presents, simulates the DMM underlays piling effect

	var/first_turf_index = 1
	while(!ispath(members[first_turf_index],/turf)) //find first /turf object in members
		first_turf_index++

	//turn off base new Initialization until the whole thing is loaded
	SSobj.map_loader_begin()
	//instanciate the first /turf
	var/turf/T
	if(members[first_turf_index] != /turf/template_noop)
		T = instance_atom(members[first_turf_index],members_attributes[first_turf_index],xcrd,ycrd,zcrd)

	if(T)
		//if others /turf are presents, simulates the underlays piling effect
		index = first_turf_index + 1
		while(index <= members.len - 1) // Last item is an /area
			var/underlay = T.appearance
			T = instance_atom(members[index],members_attributes[index],xcrd,ycrd,zcrd)//instance new turf
			T.underlays += underlay
			index++

	//finally instance all remainings objects/mobs
	for(index in 1 to first_turf_index-1)
		instance_atom(members[index],members_attributes[index],xcrd,ycrd,zcrd)

		//custom CHECK_TICK here because we don't want things created while we're sleeping to not initialize
		if(world.tick_usage > CURRENT_TICKLIMIT)
			SSobj.map_loader_stop()
			stoplag()
			SSobj.map_loader_begin()
	//Restore initialization to the previous value
	SSobj.map_loader_stop()

////////////////
//Helpers procs
////////////////

//Instance an atom at (x,y,z) and gives it the variables in attributes
/dmm_suite/proc/instance_atom(path,list/attributes, x, y, z)
	var/atom/instance
	_preloader.setup(attributes, path)

	var/turf/T = locate(x,y,z)
	if(T)
		if(ispath(path, /turf))
			T.ChangeTurf(path, TRUE)
			instance = T
		else
			instance = new path (T)//first preloader pass

	if(use_preloader && instance)//second preloader pass, for those atoms that don't ..() in New()
		_preloader.load(instance)

	return instance

//text trimming (both directions) helper proc
//optionally removes quotes before and after the text (for variable name)
/dmm_suite/proc/trim_text(what as text,trim_quotes=0)
	if(trim_quotes)
		return trimQuotesRegex.Replace(what, "")
	else
		return trimRegex.Replace(what, "")


//find the position of the next delimiter,skipping whatever is comprised between opening_escape and closing_escape
//returns 0 if reached the last delimiter
/dmm_suite/proc/find_next_delimiter_position(text as text,initial_position as num, delimiter=",",opening_escape=quote,closing_escape=quote)
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
/dmm_suite/proc/readlist(text as text, delimiter=",")

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
			if(findtext(trim_right,quote,1,2))
				trim_right = copytext(trim_right,2,findtext(trim_right,quote,3,0))

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

/dmm_suite/Destroy()
	..()
	return QDEL_HINT_HARDDEL_NOW

//////////////////
//Preloader datum
//////////////////

/dmm_suite/preloader
	parent_type = /datum
	var/list/attributes
	var/target_path

/dmm_suite/preloader/proc/setup(list/the_attributes, path)
	if(the_attributes.len)
		use_preloader = TRUE
		attributes = the_attributes
		target_path = path

/dmm_suite/preloader/proc/load(atom/what)
	for(var/attribute in attributes)
		var/value = attributes[attribute]
		if(islist(value))
			value = deepCopyList(value)
		what.vars[attribute] = value
	use_preloader = FALSE

/area/template_noop
	name = "Area Passthrough"

/turf/template_noop
	name = "Turf Passthrough"
