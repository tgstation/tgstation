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

/**
 * A procedure for saving non-standard properties of an object.
 * Examples:
 * Saving material stacks (ie. ore in a silo)
 * Saving variables that can be shown as mapping helpers (ie. welded airlock mapping helper)
 * Saving objects inside of another object (ie. paper inside a noticeboard)
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
	. = list()
	. += NAMEOF(src, color)
	. += NAMEOF(src, dir)
	. += NAMEOF(src, icon)
	. += NAMEOF(src, icon_state)
	. += NAMEOF(src, name)
	. += NAMEOF(src, pixel_x)
	. += NAMEOF(src, pixel_y)
	. += NAMEOF(src, density)
	. += NAMEOF(src, opacity)

	if(uses_integrity)
		if(atom_integrity != max_integrity) // Only save if atom_integrity differs from max_integrity to avoid redundant saving
			. += NAMEOF(src, atom_integrity)
		. += NAMEOF(src, max_integrity)
		. += NAMEOF(src, integrity_failure)
		. += NAMEOF(src, damage_deflection)
		. += NAMEOF(src, resistance_flags)

	return .

/atom/movable/get_save_vars()
	. = ..()
	. += NAMEOF(src, anchored)
	return .

/turf/open/get_save_vars()
	. = ..()
	var/datum/gas_mixture/turf_gasmix = return_air()
	initial_gas_mix = turf_gasmix.to_string()
	. += NAMEOF(src, initial_gas_mix)
	return .

/obj/get_save_vars()
	. = ..()
	. += NAMEOF(src, req_access)
	. += NAMEOF(src, id_tag)
	return .

/obj/item/stack/get_save_vars()
	. = ..()
	. += NAMEOF(src, amount)
	return .

/obj/docking_port/get_save_vars()
	. = ..()
	. += NAMEOF(src, dheight)
	. += NAMEOF(src, dwidth)
	. += NAMEOF(src, height)
	. += NAMEOF(src, shuttle_id)
	. += NAMEOF(src, width)
	return .

/obj/machinery/atmospherics/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	return .

/obj/item/pipe/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)
	return .

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

/proc/to_list_string(list/build_from)
	var/list/build_into = list()
	build_into += "list("
	var/first_entry = TRUE
	for(var/item in build_from)
		CHECK_TICK
		if(!first_entry)
			build_into += ", "
		if(isnum(item) || !build_from[item])
			build_into += "[tgm_encode(item)]"
		else
			build_into += "[tgm_encode(item)] = [tgm_encode(build_from[item])]"
		first_entry = FALSE
	build_into += ")"
	return build_into.Join("")

/// Takes a constant, encodes it into a TGM valid string
/proc/tgm_encode(value)
	if(istext(value))
		//Prevent symbols from being because otherwise you can name something
		// [";},/obj/item/gun/energy/laser/instakill{name="da epic gun] and spawn yourself an instakill gun.
		return "\"[hashtag_newlines_and_tabs("[value]", list("{"="", "}"="", "\""="", ","=""))]\""
	if(isnum(value) || ispath(value))
		return "[value]"
	if(islist(value))
		return to_list_string(value)
	if(isnull(value))
		return "null"
	if(isicon(value) || isfile(value))
		return "'[value]'"
	// not handled:
	// - pops: /obj{name="foo"}
	// - new(), newlist(), icon(), matrix(), sound()

	// fallback: string
	return tgm_encode("[value]")

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
	list/obj_blacklist,
)
	var/width = maxx - minx
	var/height = maxy - miny
	var/depth = maxz - minz

	if(obj_blacklist && !islist(obj_blacklist))
		CRASH("Non-list being used as object blacklist for map writing")

	// we want to keep decals from crayon writings, blood splatters, cobwebs, etc.
	// most landmarks get deleted except for latejoin arrivals shuttle
	var/static/list/default_blacklist = typecacheof(list(/obj/effect, /obj/projectile)) - typecacheof(list(/obj/effect/decal, /obj/effect/turf_decal, /obj/effect/landmark))
	if(!obj_blacklist)
		obj_blacklist = default_blacklist

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
				//====SAVING OBJECTS====
				if(save_flag & SAVE_OBJECTS)
					for(var/obj/thing in pull_from)
						CHECK_TICK
						if(obj_blacklist[thing.type])
							continue
						if(thing.flags_1 & HOLOGRAM_1)
							continue
						if(is_multi_tile_object(thing) && (thing.loc != pull_from))
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
					for(var/mob/living/thing in pull_from)
						CHECK_TICK
						if(istype(thing, /mob/living/carbon)) //Ignore people, but not animals
							continue
						var/metadata = generate_tgm_metadata(thing)
						current_header += "[empty ? "" : ",\n"][thing.type][metadata]"
						empty = FALSE
				current_header += "[empty ? "" : ",\n"][place]"
				//====SAVING ATMOS====
				if((save_flag & SAVE_TURFS) && (save_flag & SAVE_ATMOS) && !isspaceturf(pull_from))
					var/metadata = generate_tgm_metadata(pull_from)
					current_header += "[metadata]"
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

/proc/generate_tgm_metadata(atom/object)
	var/list/data_to_add = list()
	var/list/vars_to_save = object.get_save_vars()

	for(var/variable in vars_to_save)
		CHECK_TICK
		var/value = object.vars[variable]
		if(value == initial(object.vars[variable]) || !issaved(object.vars[variable]))
			continue
		if(variable == "icon_state" && object.smoothing_flags)
			continue
		if(variable == "icon" && object.smoothing_flags)
			continue

		var/text_value = tgm_encode(value)
		if(!text_value)
			continue
		data_to_add += "[variable] = [text_value]"

	if(!length(data_to_add))
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
