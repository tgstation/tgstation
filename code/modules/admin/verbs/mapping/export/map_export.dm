///Id ref for an exported object
GLOBAL_VAR_INIT(object_export_id, 1)
///Area coords
GLOBAL_LIST_INIT(save_file_chars, list(
	"a","b","c","d","e",
	"f","g","h","i","j",
	"k","l","m","n","o",
	"p","q","r","s","t",
	"u","v","w","x","y",
	"z","A","B","C","D",
	"E","F","G","H","I",
	"J","K","L","M","N",
	"O","P","Q","R","S",
	"T","U","V","W","X",
	"Y","Z",
))


ADMIN_VERB(map_export, R_DEBUG, "Map Export", "Select a part of the map by coordinates and download it.", ADMIN_CATEGORY_DEBUG)
	var/user_x = user.mob.x
	var/user_y = user.mob.y
	var/user_z = user.mob.z
	var/z_level = tgui_input_number(user, "Export Which Z-Level?", "Map Exporter", user_z || 2)
	var/start_x = tgui_input_number(user, "Start X?", "Map Exporter", user_x || 1, world.maxx, 1)
	var/start_y = tgui_input_number(user, "Start Y?", "Map Exporter", user_y || 1, world.maxy, 1)
	var/end_x = tgui_input_number(user, "End X?", "Map Exporter", user_x || 1, world.maxx, 1)
	var/end_y = tgui_input_number(user, "End Y?", "Map Exporter", user_y || 1, world.maxy, 1)
	var/date = time2text(world.timeofday, "YYYY-MM-DD_hh-mm-ss", TIMEZONE_UTC)
	var/file_name = sanitize_filename(tgui_input_text(user, "Filename?", "Map Exporter", "exported_map_[date]"))
	var/confirm = tgui_alert(user, "Are you sure you want to do this? This will cause extreme lag!", "Map Exporter", list("Yes", "No"))

	if(confirm != "Yes")
		return

	var/map_text = write_map(start_x, start_y, z_level, end_x, end_y, z_level)
	log_admin("Build Mode: [key_name(user)] is exporting the map area from ([start_x], [start_y], [z_level]) through ([end_x], [end_y], [z_level])")
	send_exported_map(user, file_name, map_text)

/**
 * A procedure for saving DMM text to a file and then sending it to the user.
 * Arguments:
 * * user - a user which get map
 * * name - name of file + .dmm
 * * map - text with DMM format
 */
/proc/send_exported_map(user, name, map)
	var/file_path = "data/[name].dmm"
	rustg_file_write(map, file_path)
	DIRECT_OUTPUT(user, ftp(file_path, "[name].dmm"))
	var/file_to_delete = file(file_path)
	fdel(file_to_delete)

/proc/sanitize_filename(text)
	return hashtag_newlines_and_tabs(text, list("\n"="", "\t"="", "/"="", "\\"="", "?"="", "%"="", "*"="", ":"="", "|"="", "\""="", "<"="", ">"=""))

/proc/hashtag_newlines_and_tabs(text, list/repl_chars = list("\n"="#","\t"="#"))
	for(var/char in repl_chars)
		var/index = findtext(text, char)
		while(index)
			text = copytext(text, 1, index) + repl_chars[char] + copytext(text, index + length(char))
			index = findtext(text, char, index + length(char))
	return text

/**Map exporter
* Inputting a list of turfs into convert_map_to_tgm() will output a string
* with the turfs and their objects / areas on said turf into the TGM mapping format
* for .dmm files. This file can then be opened in the map editor or imported
* back into the game.
* ============================
* This has been made semi-modular so you should be able to use these functions
* elsewhere in code if you ever need to get a file in the .dmm format
**/

/proc/to_list_string(list/build_from, list/obj/obj_refs)
	var/list/build_into = list()
	build_into += "list("
	var/first_entry = TRUE
	for(var/item in build_from)
		CHECK_TICK
		if(!first_entry)
			build_into += ", "
		if(isnum(item) || isnull(build_from[item]))
			build_into += "[tgm_encode(item, obj_refs)]"
		else
			build_into += "[tgm_encode(item, obj_refs)] = [tgm_encode(build_from[item], obj_refs)]"
		first_entry = FALSE
	build_into += ")"
	return build_into.Join("")

/// Takes a constant, encodes it into a TGM valid string
/proc/tgm_encode(value, list/obj/obj_refs)
	if(istext(value))
		//Prevent symbols from being because otherwise you can name something
		// [";},/obj/item/gun/energy/laser/instakill{name="da epic gun] and spawn yourself an instakill gun.
		return "\"[hashtag_newlines_and_tabs("[value]", list("{"="", "}"="", "\""="", ";"="", ","=""))]\""
	if(isnum(value) || ispath(value))
		return "[value]"
	if(islist(value))
		return to_list_string(value, obj_refs)
	if(isnull(value))
		return "null"
	if(isicon(value) || isfile(value))
		return "'[value]'"
	if(isobj(value))
		var/ref_id = "%[GLOB.object_export_id]%"
		obj_refs[ref_id] = value
		GLOB.object_export_id += 1
		return ref_id
	// not handled:
	// - pops: /obj{name="foo"}
	// - new(), newlist(), icon(), matrix(), sound()

	// fallback: string
	return tgm_encode("[value]", obj_refs)

/**
 *Procedure for converting a coordinate-selected part of the map into text for the .dmi format
 */
/proc/write_map(
	minx,
	miny,
	minz,
	maxx,
	maxy,
	maxz,
	save_flag = ALL,
	shuttle_area_flag = SAVE_SHUTTLEAREA_DONTCARE,
	list/obj_blacklist = typecacheof(/obj/effect),
)
	GLOB.object_export_id = 0

	var/width = maxx - minx
	var/height = maxy - miny
	var/depth = maxz - minz

	if(!islist(obj_blacklist))
		CRASH("Non-list being used as object blacklist for map writing")

	// we want to keep crayon writings, blood splatters, cobwebs, etc.
	obj_blacklist -= typecacheof(/obj/effect/decal)
	obj_blacklist -= typecacheof(/obj/effect/turf_decal)
	obj_blacklist -= typecacheof(/obj/effect/landmark) // most landmarks get deleted except for latejoin arrivals shuttle

	//Step 0: Calculate the amount of letters we need (26 ^ n > turf count)
	var/turfs_needed = width * height
	var/layers = FLOOR(log(GLOB.save_file_chars.len, turfs_needed) + 0.999,1)

	//Step 1: Run through the area and generate file data
	var/list/header_data = list() //holds the data of a header -> to its key
	var/list/header = list() //The actual header in text
	var/list/contents = list() //The contents in text (bit at the end)
	var/key_index = 1 // How many keys we've generated so far
	for(var/z in 0 to depth)
		for(var/x in 0 to width)
			contents += "\n([x + 1],1,[z + 1]) = {\"\n"
			for(var/y in height to 0 step -1)
				CHECK_TICK
				//====Get turfs Data====
				var/turf/place
				var/area/location
				var/turf/pull_from = locate((minx + x), (miny + y), (minz + z))
				//If there is nothing there, save as a noop (For odd shapes)
				if(isnull(pull_from))
					place = /turf/template_noop
					location = /area/template_noop
				//Ignore things in space, must be a space turf
				else if(istype(pull_from, /turf/open/space) && !(save_flag & SAVE_SPACE))
					place = /turf/template_noop
					location = /area/template_noop
					pull_from = null
				//Stuff to add
				else
					var/area/place_area = get_area(pull_from)
					location = place_area.type
					place = pull_from.type

				//====Saving shuttles only / non shuttles only====
				var/is_shuttle_area = ispath(location, /area/shuttle)
				if((is_shuttle_area && shuttle_area_flag == SAVE_SHUTTLEAREA_IGNORE) || (!is_shuttle_area && shuttle_area_flag == SAVE_SHUTTLEAREA_ONLY))
					place = /turf/template_noop
					location = /area/template_noop
					pull_from = null
				//====Saving holodeck areas====
				// All hologram objects get skipped and floor tiles get replaced with empty plating
				if(ispath(location, /area/station/holodeck) && istype(place, /turf/open/floor/holofloor))
					place = /turf/open/floor/holofloor/plating
				//====For toggling not saving areas and turfs====
				if(!(save_flag & SAVE_AREAS))
					location = /area/template_noop
				if(!(save_flag & SAVE_TURFS))
					place = /turf/template_noop
				//====Generate Header Character====
				// Info that describes this turf and all its contents
				// Unique, will be checked for existing later
				var/list/current_header = list()
				current_header += "(\n"
				//Add objects to the header file
				var/empty = TRUE
				var/list/stuff = pull_from.contents.Copy(1)
				var/list/obj/obj_refs = list()
				while(stuff.len)
					var/ref = stuff[1]
					stuff -= ref

					var/atom/thing = ref
					if(istext(thing))
						thing = obj_refs[thing]

					//====SAVING OBJECTS====
					if(isobj(thing))
						var/obj/obj_thing = thing
						if(!(save_flag & SAVE_OBJECTS))
							continue
						if(obj_blacklist[thing.type])
							continue
						if(thing.flags_1 & HOLOGRAM_1)
							continue
						if((thing in pull_from.contents) && is_multi_tile_object(obj_thing) && (thing.loc != pull_from))
							continue
					//====SAVING MOBS====
					else
						if(!isliving(thing))
							continue
						if(istype(thing, /mob/living/carbon)) //Ignore people, but not animals
							continue
						if(!(save_flag & SAVE_MOBS))
							continue

					//generate metadata
					var/list/obj/local_refs = list()
					current_header += "[empty ? "" : ",\n"][istext(ref) ? ref : ""][thing.type][generate_tgm_metadata(thing, local_refs)]"
					empty = FALSE

					//save any object references on the object
					for(var/obj_id in local_refs)
						obj_refs[obj_id] = local_refs[obj_id]
						stuff += obj_id

				current_header += "[empty ? "" : ",\n"][place]"
				//====SAVING ATMOS====
				if((save_flag & SAVE_TURFS) && (save_flag & SAVE_ATMOS) && !isspaceturf(pull_from))
					current_header += "[generate_tgm_metadata(pull_from)]"
				current_header += ",\n[location])\n"
				//====Fill the contents file====
				var/textiftied_header = current_header.Join()
				// If we already know this header just use its key, otherwise we gotta make a new one
				var/key = header_data[textiftied_header]
				if(!key)
					key = calculate_tgm_header_index(key_index, layers)
					key_index++
					header += "\"[key]\" = [textiftied_header]"
					header_data[textiftied_header] = key
				contents += "[key]\n"
			contents += "\"}"
	return "//[DMM2TGM_MESSAGE]\n[header.Join()][contents.Join()]"

/proc/generate_tgm_metadata(atom/object, list/obj/obj_refs)
	var/list/data_to_add = list()
	var/list/vars_to_save = object.get_save_vars()

	for(var/variable in vars_to_save)
		CHECK_TICK

		var/value
		if(islist(variable)) //custom var to be restored
			var/list/custom_attribute = variable
			variable = custom_attribute[1]
			value = custom_attribute[variable]
			variable = "#[variable]" //# tells the map reader its a custom var & must be parsed differently
		else
			value = object.vars[variable]
			if(value == initial(object.vars[variable]) || !issaved(object.vars[variable]))
				continue

		if(variable == "icon_state" && object.smoothing_flags)
			continue
		if(variable == "icon" && object.smoothing_flags)
			continue
		if(variable == "contents")
			value = object.contents.Copy(1) //otherwise this would error in tgm_encode_list() with bad index cause its protected
		else if(islist(value))
			if(locate(/atom) in value) //no list that contains atoms is allowed except the contents list cause we can't keep track of their locs
				continue

		var/text_value = tgm_encode(value, obj_refs)
		if(!text_value)
			continue
		data_to_add += "[variable] = [text_value]"

	if(!data_to_add.len)
		return
	return "{\n\t[data_to_add.Join(";\n\t")]\n\t}"

// Could be inlined, not a massive cost tho so it's fine
/// Generates a key matching our index
/proc/calculate_tgm_header_index(index, key_length)
	var/list/output = list()
	// We want to stick the first one last, so we walk backwards
	var/list/pull_from = GLOB.save_file_chars
	var/length = length(pull_from)
	for(var/i in key_length to 1 step -1)
		var/calculated = FLOOR((index-1) / (length ** (i - 1)), 1)
		calculated = (calculated % length) + 1
		output += pull_from[calculated]
	return output.Join()
