/area/greytopia
	name = "\improper Greytopia"
	icon_state = "away"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = TRUE
	valid_territory = FALSE

/obj/machinery/scannerright
	name = "mysterious scanner"
	desc = "Why would this level of security be justified?"
	icon = 'icons/obj/machines/greytopia.dmi'
	icon_state = "right"
	anchored = TRUE
	dir = 1

/obj/machinery/scannerleft
	name = "mysterious scanner"
	desc = "None of this makes any sense..."
	icon = 'icons/obj/machines/greytopia.dmi'
	icon_state = "left"
	anchored = TRUE
	dir = 1

/obj/machinery/doorscanner
	name = "mysterious scanner"
	desc = "What are assistants doing with this kind of technology?"
	icon = 'icons/obj/machines/greytopia.dmi'
	icon_state = "center"
	anchored = TRUE
	var/obj/machinery/door/airlock/vault/scanner/gate
	var/working = FALSE
	dir = 1

/obj/machinery/doorscanner/Initialize()
	..()
	for(var/obj/machinery/door/airlock/vault/scanner/check in range(3, loc))
		gate = check
		break
	if(!gate)
		qdel(src)

/obj/machinery/doorscanner/Crossed(atom/movable/AM)
	if(!gate)
		return
	if(ishuman(AM) && !working)
		var/mob/living/carbon/human/H = AM
		if(gate.approved.Find(H))
			playsound(src, 'sound/machines/synth_yes.ogg', 50, 0)
			return
		working = TRUE
		var/obj/effect/overlay/holoray/scanray/S = new(get_turf(src))
		if(do_after(H, 100, target = H))
			if(H.wear_id && (H.wear_id.GetJobName() == "Assistant") && H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/color/grey) && H.shoes && istype(H.shoes, /obj/item/clothing/shoes/sneakers/black))
				playsound(src, 'sound/machines/microwave/microwave-end.ogg', 75, 0)
				gate.approved += H
				qdel(S)
				working = FALSE
				return
		S.color = "red"
		playsound(src, 'sound/machines/buzz-two.ogg', 100, 0)
		sleep(20)
		qdel(S)
		working = FALSE

/obj/machinery/door/airlock/vault/scanner
	name = "inner gate of greytopia"
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 50, bio = 100, rad = 100, fire = 100, acid = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	heat_proof = TRUE
	air_tight = TRUE
	aiControlDisabled = TRUE
	hackProof = TRUE
	normalspeed = FALSE
	safe = FALSE
	var/list/approved = list()

/obj/machinery/door/airlock/vault/scanner/CollidedWith(atom/movable/AM)
	if(isliving(AM) && approved.Find(AM))
		open()
	return !density && ..()

/obj/machinery/door/airlock/vault/scanner/try_to_activate_door(mob/living/user)
	if(approved.Find(user))
		open()
	else
		do_animate("deny")
		var/atom/throwtarget
		throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(user, src)))
		user.Knockdown(40)
		user.throw_at(throwtarget, 5, 1, src)

/obj/machinery/door/airlock/vault/scanner/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	return FALSE

/obj/machinery/door/airlock/vault/scanner/emag_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	return FALSE

/obj/machinery/door/airlock/vault/scanner/emp_act(severity)
	return

/obj/machinery/door/password/voice/greytopia
	name = "outer gate of greytopia"
	autoclose = TRUE
	safe = FALSE

/obj/machinery/door/password/voice/greytopia/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating)
		return
	if(density)
		do_animate("deny")

/obj/machinery/door/password/voice/greytopia/Initialize()
	. = ..()
	password = pick("greytide","condom","rules","everything","toolbox")
	desc = "An imposing door with a message etched into its surface: 'Utter the word to complete the phrase:'<br>"
	switch(password)
		if("greytide")
			desc += "<b>________ worldwide!!</b>"
		if("condom")
			desc += "<b>Captain is a ______!!</b>"
		if("rules")
			desc += "<b>No captain, No _____!!</b>"
		if("everything")
			desc += "<b>Nothing is true, _________ is permitted.</b>"
		if("toolbox")
			desc += "<b>There isn't a problem you can't solve with a _______ to the head.</b>"


/obj/effect/overlay/holoray/scanray
	name = "scanning beam"
	icon_state = "scanray"
	pixel_x = -32
	pixel_y = -8


/datum/map_template/shelter/greytopia
	name = "Greytopia"
	shelter_id = "shelter_grey"
	description = "Greyshirt legends tells of a place where assistants \
		can roam freely and unoppressed. They say it is the place where \
		the chosen one will rise and usher in a grey tide that will topple \
		the galactic kleptocracy and all who serve it."
	mappath = "_maps/templates/greytopia.dmm"

/datum/map_template/shelter/grey/New()
	..()
	blacklisted_turfs = list()

/obj/effect/landmark/greytopia
	name = "Greytopia spawner"
	var/datum/map_template/shelter/grey/template
	var/static/spawned = FALSE
	invisibility = 0
	dir = 4

/obj/effect/landmark/greytopia/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/greytopia/LateInitialize()
	..()
	if(spawned)
		qdel(src)
		return
	template = SSmapping.shelter_templates["shelter_grey"]
	if(!template)
		throw EXCEPTION("Shelter template (shelter_grey) not found!")
		qdel(src)
		return
	if(prob(100))
		template.load(get_turf(src), centered = TRUE, orientation = dir)
		//spawned = TRUE
	//qdel(src)
 /*
///////////////////////////////////////////////////////////////
//SS13 Optimized Map loader
//////////////////////////////////////////////////////////////

//global datum that will preload variables on atoms instanciation
GLOBAL_VAR_INIT(use_preloader, FALSE)
GLOBAL_DATUM_INIT(_preloader, /dmm_suite/preloader, new)

/dmm_suite
		// /"([a-zA-Z]+)" = \(((?:.|\n)*?)\)\n(?!\t)|\((\d+),(\d+),(\d+)\) = \{"([a-zA-Z\n]*)"\}/g
	var/static/regex/dmmRegex = new/regex({""(\[a-zA-Z]+)" = \\(((?:.|\n)*?)\\)\n(?!\t)|\\((\\d+),(\\d+),(\\d+)\\) = \\{"(\[a-zA-Z\n]*)"\\}"}, "g")
		// /^[\s\n]+"?|"?[\s\n]+$|^"|"$/g
	var/static/regex/trimQuotesRegex = new/regex({"^\[\\s\n]+"?|"?\[\\s\n]+$|^"|"$"}, "g")
		// /^[\s\n]+|[\s\n]+$/
	var/static/regex/trimRegex = new/regex("^\[\\s\n]+|\[\\s\n]+$", "g")
	var/static/list/modelCache = list()
	var/static/space_key
	#ifdef TESTING
	var/static/turfsSkipped
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
/dmm_suite/load_map(dmm_file as file, x_offset as num, y_offset as num, z_offset as num, cropMap as num, measureOnly as num, no_changeturf as num, lower_crop_x as num,  lower_crop_y as num, upper_crop_x as num, upper_crop_y as num, placeOnTop as num, dir as num)
	//How I wish for RAII
	Master.StartLoadingMap()
	space_key = null
	#ifdef TESTING
	turfsSkipped = 0
	#endif
	. = load_map_impl(dmm_file, x_offset, y_offset, z_offset, cropMap, measureOnly, no_changeturf, lower_crop_x, upper_crop_x, lower_crop_y, upper_crop_y, placeOnTop, dir)
	#ifdef TESTING
	if(turfsSkipped)
		testing("Skipped loading [turfsSkipped] default turfs")
	#endif
	Master.StopLoadingMap()

/dmm_suite/proc/load_map_impl(dmm_file, x_offset, y_offset, z_offset, cropMap, measureOnly, no_changeturf, x_lower = -INFINITY, x_upper = INFINITY, y_lower = -INFINITY, y_upper = INFINITY, placeOnTop = FALSE, dir = 1)
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

	var/firstx = 0
	var/finalx = 1
	if(dir != 1)
		var/max_index = 1
		while(dmmRegex.Find(tfile, max_index))
			max_index = dmmRegex.next
		if(dmmRegex.group[3])
			finalx = text2num(dmmRegex.group[3]) + x_offset - 1
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

			var/curr_x = text2num(dmmRegex.group[3])
			if(curr_x < x_lower || curr_x > x_upper)
				continue
			if(!firstx)
				firstx = curr_x + x_offset - 1
			var/xcrdStart = curr_x + x_offset - 1
			//position of the currently processed square
			var/xcrd
			var/ycrd = text2num(dmmRegex.group[4]) + y_offset - 1
			var/zcrd = text2num(dmmRegex.group[5]) + z_offset - 1

			var/zexpansion = zcrd > world.maxz
			if(zexpansion)
				if(cropMap)
					continue
				else
					while (zcrd > world.maxz) //create a new z_level if needed
						world.incrementMaxZ()
				if(!no_changeturf)
					WARNING("Z-level expansion occurred without no_changeturf set, this may cause problems when /turf/AfterChange is called")

			bounds[MAP_MINX] = min(bounds[MAP_MINX], CLAMP(xcrdStart, x_lower, x_upper))
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

			bounds[MAP_MINY] = min(bounds[MAP_MINY], CLAMP(ycrd, y_lower, y_upper))

			var/maxx = xcrdStart
			if(measureOnly)
				for(var/line in gridLines)
					maxx = max(maxx, xcrdStart + length(line) / key_len - 1)
			else
				switch(dir)
					if(1)
						ycrd += gridLines.len - 1 // Start at the top and work down
						if(!cropMap && ycrd > world.maxy)
							if(!measureOnly)
								world.maxy = ycrd // Expand Y here.  X is expanded in the loop below
							bounds[MAP_MAXY] = max(bounds[MAP_MAXY], CLAMP(ycrd, y_lower, y_upper))
						else
							bounds[MAP_MAXY] = max(bounds[MAP_MAXY], CLAMP(min(ycrd, world.maxy), y_lower, y_upper))
						for(var/line in gridLines)
							if((ycrd - y_offset + 1) < y_lower || (ycrd - y_offset + 1) > y_upper)				//Reverse operation and check if it is out of bounds of cropping.
								--ycrd
								continue
							if(ycrd <= world.maxy && ycrd >= 1)
								xcrd = xcrdStart
								for(var/tpos = 1 to length(line) - key_len + 1 step key_len)
									if((xcrd - x_offset + 1) < x_lower || (xcrd - x_offset + 1) > x_upper)			//Same as above.
										++xcrd
										continue								//X cropping.
									if(xcrd > world.maxx)
										if(cropMap)
											break
										else
											world.maxx = xcrd

									if(xcrd >= 1)
										var/model_key = copytext(line, tpos, tpos + key_len)
										var/no_afterchange = no_changeturf || zexpansion
										if(!no_afterchange || (model_key != space_key))
											if(!grid_models[model_key])
												throw EXCEPTION("Undefined model key in DMM.")
											parse_grid(grid_models[model_key], model_key, xcrd, ycrd, zcrd, no_changeturf || zexpansion)
										#ifdef TESTING
										else
											++turfsSkipped
										#endif
										CHECK_TICK
									maxx = max(maxx, xcrd)
									++xcrd
							--ycrd
					if(2)
						ycrd += gridLines.len - 1
						if(!cropMap && ycrd > world.maxy)
							if(!measureOnly)
								world.maxy = ycrd // Expand Y here.  X is expanded in the loop below
							bounds[MAP_MAXY] = max(bounds[MAP_MAXY], CLAMP(ycrd, y_lower, y_upper))
						else
							bounds[MAP_MAXY] = max(bounds[MAP_MAXY], CLAMP(min(ycrd, world.maxy), y_lower, y_upper))
						ycrd -= gridLines.len - 1 //Had to find the top for bounds, but we work from the bottom for this "upside down" load
						for(var/line in gridLines)
							if((ycrd - y_offset + 1) < y_lower || (ycrd - y_offset + 1) > y_upper)				//Reverse operation and check if it is out of bounds of cropping.
								++ycrd
								continue
							if(ycrd <= world.maxy && ycrd >= 1)
								xcrd = firstx + (finalx - xcrdStart)
								for(var/tpos = 1 to length(line) - key_len + 1 step key_len)
									if((xcrd - x_offset + 1) < x_lower || (xcrd - x_offset + 1) > x_upper)			//Same as above.
										++xcrd
										continue								//X cropping.
									if(xcrd > world.maxx)
										if(cropMap)
											break
										else
											world.maxx = xcrd

									if(xcrd >= 1)
										var/model_key = copytext(line, tpos, tpos + key_len)
										var/no_afterchange = no_changeturf || zexpansion
										if(!no_afterchange || (model_key != space_key))
											if(!grid_models[model_key])
												throw EXCEPTION("Undefined model key in DMM.")
											parse_grid(grid_models[model_key], model_key, xcrd, ycrd, zcrd, no_changeturf || zexpansion)
										#ifdef TESTING
										else
											++turfsSkipped
										#endif
										CHECK_TICK
									maxx = max(maxx, xcrd)
									++xcrd
							++ycrd
					if(4)
						ycrd += finalx - firstx  // Oh shit we're facing east now, the top of the Y-column is now as "tall" as the width of the X-row
						if(!cropMap && ycrd > world.maxy)
							if(!measureOnly)
								world.maxy = ycrd // Expand Y here.  X is expanded in the loop below
							bounds[MAP_MAXY] = max(bounds[MAP_MAXY], CLAMP(ycrd, y_lower, y_upper))
						else
							bounds[MAP_MAXY] = max(bounds[MAP_MAXY], CLAMP(min(ycrd, world.maxy), y_lower, y_upper))
						for(var/line in gridLines)
							if((ycrd - y_offset + 1) < y_lower || (ycrd - y_offset + 1) > y_upper)				//Reverse operation and check if it is out of bounds of cropping.
								--ycrd
								continue
							if(ycrd <= world.maxy && ycrd >= 1)
								xcrd = xcrdStart + gridLines.len - 1 // Facing east means the "end" of the X-row is now as "deep" as the height of the Y-column
								for(var/tpos = 1 to length(line) - key_len + 1 step key_len)
									if((xcrd - x_offset + 1) < x_lower || (xcrd - x_offset + 1) > x_upper)			//Same as above.
										--xcrd
										continue								//X cropping.
									if(xcrd > world.maxx)
										if(cropMap)
											break
										else
											world.maxx = xcrd

									if(xcrd >= 1)
										var/model_key = copytext(line, tpos, tpos + key_len)
										var/no_afterchange = no_changeturf || zexpansion
										if(!no_afterchange || (model_key != space_key))
											if(!grid_models[model_key])
												throw EXCEPTION("Undefined model key in DMM.")
											parse_grid(grid_models[model_key], model_key, xcrd, ycrd, zcrd, no_changeturf || zexpansion)
										#ifdef TESTING
										else
											++turfsSkipped
										#endif
										CHECK_TICK
									maxx = max(maxx, xcrd)
									--xcrd
							--ycrd

			bounds[MAP_MAXX] = CLAMP(max(bounds[MAP_MAXX], cropMap ? min(maxx, world.maxx) : maxx), x_lower, x_upper)

		CHECK_TICK

	if(bounds[1] == 1.#INF) // Shouldn't need to check every item
		return null
	else
		if(!measureOnly)
			if(!no_changeturf)
				for(var/t in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]), locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
					var/turf/T = t
					//we do this after we load everything in. if we don't; we'll have weird atmos bugs regarding atmos adjacent turfs
					T.AfterChange(TRUE)
		return bounds

/**
 * Fill a given tile with its area/turf/objects/mobs
 * Variable model is one full map line (e.g /turf/unsimulated/wall{icon_state = "rock"}, /area/mine/explored)
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
/dmm_suite/proc/parse_grid(model as text, model_key as text, xcrd as num,ycrd as num,zcrd as num, no_changeturf as num, placeOnTop as num, orientation as num)
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
		if(no_changeturf && !space_key && members.len == 2 && members_attributes.len == 2 && length(members_attributes[1]) == 0 && length(members_attributes[2]) == 0 && (world.area in members) && (world.turf in members))
			space_key = model_key
			return


		modelCache[model] = list(members, members_attributes)


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
/dmm_suite/proc/instance_atom(path,list/attributes, turf/crds, no_changeturf, placeOnTop)
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

/dmm_suite/proc/create_atom(path, crds)
	set waitfor = FALSE
	. = new path (crds)

//text trimming (both directions) helper proc
//optionally removes quotes before and after the text (for variable name)
/dmm_suite/proc/trim_text(what as text,trim_quotes=0)
	if(trim_quotes)
		return trimQuotesRegex.Replace(what, "")
	else
		return trimRegex.Replace(what, "")


//find the position of the next delimiter,skipping whatever is comprised between opening_escape and closing_escape
//returns 0 if reached the last delimiter
/dmm_suite/proc/find_next_delimiter_position(text as text,initial_position as num, delimiter=",",opening_escape="\"",closing_escape="\"")
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
		GLOB.use_preloader = TRUE
		attributes = the_attributes
		target_path = path

/dmm_suite/preloader/proc/load(atom/what)
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
*/