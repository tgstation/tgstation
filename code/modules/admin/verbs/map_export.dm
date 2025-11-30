ADMIN_VERB_VISIBILITY(map_export, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(map_export, R_DEBUG, "Map Export", "Select a part of the map by coordinates and download it.", ADMIN_CATEGORY_MAPPING)
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
	var/list/replacement_characters = list("\n"="", "\t"="", "/"="", "\\"="", "?"="", "%"="", "*"="", ":"="", "|"="", "\""="", "<"="", ">"="")
	HASHTAG_NEWLINES_AND_TABS(text, replacement_characters)
	return text
