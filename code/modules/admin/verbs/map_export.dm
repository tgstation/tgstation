/client/proc/map_export()
	set category = "Debug"
	set name = "Export Map"
	set desc = "Select a part of the map by coordinates and download it."
	
	if(!check_rights(R_DEBUG))
		return

	var/z_level = input("Export Which Z-Level?", "Map Exporter", 2) as num
	var/start_x = input("Start X?", "Map Exporter", 1) as num
	var/start_y = input("Start Y?", "Map Exporter", 1) as num
	var/end_x = input("End X?", "Map Exporter", world.maxx-1) as num
	var/end_y = input("End Y?", "Map Exporter", world.maxy-1) as num
	var/date = time2text(world.timeofday, "YYYY-MM-DD_hh-mm-ss")
	var/file_name = sanitize_filename(input("Filename?", "Map Exporter", "exportedmap_[date]") as text)
	var/confirm = tgui_alert(usr, "Are you sure you want to do this? This will cause extreme lag!", "Map Exporter", list("Yes", "No"))

	if(confirm != "Yes")
		return

	var map_text = write_map(start_x, start_y, z_level, end_x, end_y, z_level)
	text2file(map_text, "data/[file_name].dmm")
	usr << ftp("data/[file_name].dmm", "[file_name].dmm")

/proc/sanitize_filename(t)
	return hashtag_newlines_and_tabs(t, list("\n"="", "\t"="", "/"="", "\\"="", "?"="", "%"="", "*"="", ":"="", "|"="", "\""="", "<"="", ">"=""))

/proc/hashtag_newlines_and_tabs(text, list/repl_chars = list("\n"="#","\t"="#"))
	for(var/char in repl_chars)
		var/index = findtext(text, char)
		while(index)
			text = copytext(text, 1, index) + repl_chars[char] + copytext(text, index + length(char))
			index = findtext(text, char, index + length(char))
	return text

/obj/proc/on_object_saved(var/depth = 0)
	return ""

// Save resources in silo
/obj/machinery/ore_silo/on_object_saved(var/depth = 0)
	if(depth >= 10)
		return ""
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
	return list("pixel_x",
				"pixel_y",
				"dir",
				"name",
				"req_access",
				"piping_layer", 
				"color", 
				"icon", 
				"icon_state", 
				"pipe_color", 
				"amount", 
				"dwidth",
				"dheight", 
				"height", 
				"width", 
				"roundstart_template", 
				"shuttle_id"
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
	"Y","Z"
))

/proc/to_list_string(list/l)
	. = "list("
	var/first_entry = TRUE
	for(var/item in l)
		if(!first_entry)
			. += ", "
		if(l[item])
			. += hashtag_newlines_and_tabs("[item] = [l[item]]", list("{"="", "}"="", "\""="", ";"="", ","=""))
		else
			. += hashtag_newlines_and_tabs("[item]", list("{"="", "}"="", "\""="", ";"="", ","=""))
		first_entry = FALSE
	. += ")"

//Converts a list of turfs into TGM file format
/proc/write_map(minx as num, \
				miny as num, \
				minz as num, \
				maxx as num, \
				maxy as num, \
				maxz as num, \
				save_flag = SAVE_ALL, \
				shuttle_area_flag = SAVE_SHUTTLEAREA_DONTCARE, \
				list/obj_blacklist = list())

	var/width = maxx - minx
	var/height = maxy - miny
	var/depth = maxz - minz

	//Step 0: Calculate the amount of letters we need (26 ^ n > turf count)
	var/turfsNeeded = width * height
	var/layers = FLOOR(log(GLOB.save_file_chars.len, turfsNeeded) + 0.999,1)

	//Step 1: Run through the area and generate file data
	var/list/header_chars	= list()	//The characters of the header
	var/list/header_dat 	= list()	//The data of the header, lines up with chars
	var/header				= ""		//The actual header in text
	var/contents			= ""		//The contents in text (bit at the end)
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
				var/current_header = "(\n"										//The actual stuff inside the header
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
						if(istype(thing, /mob/living/carbon))		//Ignore people, but not animals
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
	return "//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE\n[header][contents]"

//vars_to_save = list() to save all vars
/proc/generate_tgm_metadata(atom/O)
	var/dat = ""
	var/data_to_add = list()
	var/list/vars_to_save = O.get_save_vars()
	if(!vars_to_save)
		return
	for(var/V in O.vars)
		CHECK_TICK
		if(!(V in vars_to_save))
			continue
		var/value = O.vars[V]
		if(!value)
			continue
		if(value == initial(O.vars[V]) || !issaved(O.vars[V]))
			continue
		if(V == "icon_state" && O.smoothing_flags)
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
		data_to_add += "[V] = [symbol][value][symbol]"
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
		output = "[GLOB.save_file_chars[c]][output]"
	return output
