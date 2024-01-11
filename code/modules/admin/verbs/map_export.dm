/client/proc/map_export()
	set category = "Debug"
	set name = "Map Export"
	set desc = "Select a part of the map by coordinates and download it."

	var/z_level = tgui_input_number(usr, "Export Which Z-Level?", "Map Exporter", usr.z || 2)
	var/start_x = tgui_input_number(usr, "Start X?", "Map Exporter", usr.x || 1, world.maxx, 1)
	var/start_y = tgui_input_number(usr, "Start Y?", "Map Exporter", usr.y || 1, world.maxy, 1)
	var/end_x = tgui_input_number(usr, "End X?", "Map Exporter", usr.x || 1, world.maxx, 1)
	var/end_y = tgui_input_number(usr, "End Y?", "Map Exporter", usr.y || 1, world.maxy, 1)
	var/date = time2text(world.timeofday, "YYYY-MM-DD_hh-mm-ss")
	var/file_name = sanitize_filename(tgui_input_text(usr, "Filename?", "Map Exporter", "exported_map_[date]"))
	var/confirm = tgui_alert(usr, "Are you sure you want to do this? This will cause extreme lag!", "Map Exporter", list("Yes", "No"))

	if(confirm != "Yes" || !check_rights(R_DEBUG))
		return

	var/map_text = write_map(start_x, start_y, z_level, end_x, end_y, z_level)
	log_admin("Build Mode: [key_name(usr)] is exporting the map area from ([start_x], [start_y], [z_level]) through ([end_x], [end_y], [z_level])")
	send_exported_map(usr, file_name, map_text)

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

/**
 * A procedure for saving non-standard properties of an object.
 * For example, saving ore into a silo, and further spavn by coordinates of metal stacks objects
 */
/obj/proc/on_object_saved()
	return null

// Save resources in silo
/obj/machinery/ore_silo/on_object_saved()
	var/data
	var/datum/component/material_container/material_holder = GetComponent(/datum/component/material_container)
	for(var/each in material_holder.materials)
		var/amount = material_holder.materials[each] / 100
		var/datum/material/material_datum = each
		while(amount > 0)
			var/amount_in_stack = max(1, min(50, amount))
			amount -= amount_in_stack
			data += "[data ? ",\n" : ""][material_datum.sheet_type]{\n\tamount = [amount_in_stack]\n\t}"
	return data

/**Map exporter
* Inputting a list of turfs into convert_map_to_tgm() will output a string
* with the turfs and their objects / areas on said turf into the TGM mapping format
* for .dmm files. This file can then be opened in the map editor or imported
* back into the game.
* ============================
* This has been made semi-modular so you should be able to use these functions
* elsewhere in code if you ever need to get a file in the .dmm format
**/
/atom/proc/get_save_vars()
	return list(
		NAMEOF(src, color),
		NAMEOF(src, dir),
		NAMEOF(src, icon),
		NAMEOF(src, icon_state),
		NAMEOF(src, name),
		NAMEOF(src, pixel_x),
		NAMEOF(src, pixel_y),
	)

/obj/get_save_vars()
	return ..() + NAMEOF(src, req_access)

/obj/item/stack/get_save_vars()
	return ..() + NAMEOF(src, amount)

/obj/docking_port/get_save_vars()
	return ..() + list(
		NAMEOF(src, dheight),
		NAMEOF(src, dwidth),
		NAMEOF(src, height),
		NAMEOF(src, shuttle_id),
		NAMEOF(src, width),
	)
/obj/docking_port/stationary/get_save_vars()
	return ..() + NAMEOF(src, roundstart_template)

/obj/machinery/atmospherics/get_save_vars()
	return ..() + list(
		NAMEOF(src, piping_layer),
		NAMEOF(src, pipe_color),
	)

/obj/item/pipe/get_save_vars()
	return ..() + list(
		NAMEOF(src, piping_layer),
		NAMEOF(src, pipe_color),
	)

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

/proc/to_list_string(list/future_string)
	. = "list("
	var/first_entry = TRUE
	for(var/item in future_string)
		if(!first_entry)
			. += ", "
		if(future_string[item])
			. += hashtag_newlines_and_tabs("[item] = [future_string[item]]", list("{"="", "}"="", "\""="", ";"="", ","=""))
		else
			. += hashtag_newlines_and_tabs("[item]", list("{"="", "}"="", "\""="", ";"="", ","=""))
		first_entry = FALSE
	. += ")"

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
	list/obj_blacklist = list(),
)

	var/width = maxx - minx
	var/height = maxy - miny
	var/depth = maxz - minz

	//Step 0: Calculate the amount of letters we need (26 ^ n > turf count)
	var/turfs_needed = width * height
	var/layers = FLOOR(log(GLOB.save_file_chars.len, turfs_needed) + 0.999,1)

	//Step 1: Run through the area and generate file data
	var/list/header_chars = list() //The characters of the header
	var/list/header_dat = list() //The data of the header, lines up with chars
	var/header = "" //The actual header in text
	var/contents = "" //The contents in text (bit at the end)
	var/index = 1
	for(var/z in 0 to depth)
		for(var/x in 0 to width)
			contents += "\n([x + 1],1,[z + 1]) = {\"\n"
			for(var/y in height to 0 step -1)
				CHECK_TICK
				//====Get turfs Data====
				var/turf/place = locate((minx + x), (miny + y), (minz + z))
				var/area/location
				var/list/objects
				var/area/place_area = get_area(place)
				//If there is nothing there, save as a noop (For odd shapes)
				if(!place)
					place = /turf/template_noop
					location = /area/template_noop
					objects = list()
				//Ignore things in space, must be a space turf
				else if(istype(place, /turf/open/space) && !(save_flag & SAVE_SPACE))
					place = /turf/template_noop
					location = /area/template_noop
				//Stuff to add
				else
					location = place_area.type
					objects = place
					place = place.type
				//====Saving shuttles only / non shuttles only====
				var/is_shuttle_area = istype(location, /area/shuttle)
				if((is_shuttle_area && shuttle_area_flag == SAVE_SHUTTLEAREA_IGNORE) || (!is_shuttle_area && shuttle_area_flag == SAVE_SHUTTLEAREA_ONLY))
					place = /turf/template_noop
					location = /area/template_noop
					objects = list()
				//====For toggling not saving areas and turfs====
				if(!(save_flag & SAVE_AREAS))
					location = /area/template_noop
				if(!(save_flag & SAVE_TURFS))
					place = /turf/template_noop
				//====Generate Header Character====
				var/header_char = calculate_tgm_header_index(index, layers)	//The characters of the header
				var/current_header = "(\n" //The actual stuff inside the header
				//Add objects to the header file
				var/empty = TRUE
				//====SAVING OBJECTS====
				if(save_flag & SAVE_OBJECTS)
					for(var/obj/thing in objects)
						CHECK_TICK
						if(thing.type in obj_blacklist)
							continue
						var/metadata = generate_tgm_metadata(thing)
						current_header += "[empty ? "" : ",\n"][thing.type][metadata]"
						empty = FALSE
						//====SAVING SPECIAL DATA====
						//This is what causes lockers and machines to save stuff inside of them
						if(save_flag & SAVE_OBJECT_PROPERTIES)
							var/custom_data = thing.on_object_saved()
							current_header += "[custom_data ? ",\n[custom_data]" : ""]"
				//====SAVING MOBS====
				if(save_flag & SAVE_MOBS)
					for(var/mob/living/thing in objects)
						CHECK_TICK
						if(istype(thing, /mob/living/carbon)) //Ignore people, but not animals
							continue
						var/metadata = generate_tgm_metadata(thing)
						current_header += "[empty ? "" : ",\n"][thing.type][metadata]"
						empty = FALSE
				current_header += "[empty ? "" : ",\n"][place],\n[location])\n"
				//====Fill the contents file====
				//Compression is done here
				var/position_of_header = header_dat.Find(current_header)
				if(position_of_header)
					//If the header has already been saved, change the character to the other saved header
					header_char = header_chars[position_of_header]
				else
					header += "\"[header_char]\" = [current_header]"
					header_chars += header_char
					header_dat += current_header
					index ++
				contents += "[header_char]\n"
			contents += "\"}"
	return "//[DMM2TGM_MESSAGE]\n[header][contents]"

//vars_to_save = list() to save all vars
/proc/generate_tgm_metadata(atom/object)
	var/dat = ""
	var/data_to_add = list()
	var/list/vars_to_save = object.get_save_vars()
	if(!vars_to_save)
		return
	for(var/variable in object.vars)
		CHECK_TICK
		if(!(variable in vars_to_save))
			continue
		var/value = object.vars[variable]
		if(!value)
			continue
		if(value == initial(object.vars[variable]) || !issaved(object.vars[variable]))
			continue
		if(variable == "icon_state" && object.smoothing_flags)
			continue
		var/symbol = ""
		if(istext(value))
			symbol = "\""
			value = hashtag_newlines_and_tabs(value, list("{"="", "}"="", "\""="", ";"="", ","=""))
		else if(islist(value))
			value = to_list_string(value)
		else if(isicon(value) || isfile(value))
			symbol = "'"
		else if(!(isnum(value) || ispath(value)))
			continue
		//Prevent symbols from being because otherwise you can name something [";},/obj/item/gun/energy/laser/instakill{name="da epic gun] and spawn yourself an instakill gun.
		data_to_add += "[variable] = [symbol][value][symbol]"
	//Process data to add
	var/first = TRUE
	for(var/data in data_to_add)
		dat += "[first ? "" : ";\n"]\t[data]"
		first = FALSE
	if(dat)
		dat = "{\n[dat]\n\t}"
	return dat

/proc/calculate_tgm_header_index(index, layers)
	var/output = ""
	for(var/i in 1 to layers)
		CHECK_TICK
		var/length = GLOB.save_file_chars.len
		var/calculated = FLOOR((index-1) / (length ** (i - 1)), 1)
		calculated = (calculated % length) + 1
		output = "[GLOB.save_file_chars[calculated]][output]"
	return output
