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

// If SAVE_OBJECTS_VARIABLES flag is omitted, these are the default variables that should save regardless
GLOBAL_LIST_INIT(default_save_vars, list("dir", "pixel_x", "pixel_y"))

/proc/generate_tgm_metadata(atom/object, save_flags=ALL)
	var/list/data_to_add

	var/list/vars_to_save
	var/alist/custom_vars
	if(save_flags & SAVE_OBJECTS_VARIABLES)
		vars_to_save = GLOB.map_export_save_vars_cache[object.type] || object.get_save_vars(save_flags)
		custom_vars = object.get_custom_save_vars(save_flags)
	else
		vars_to_save = GLOB.default_save_vars

	// Tracks variables handled by get_custom_save_vars() This ensures the default variable saving loop
	// correctly skips these names. A separate list is necessary because custom_vars can contain null or FALSE values.
	var/list/custom_var_names

	for(var/custom_variable, custom_value in custom_vars)
		TGM_ENCODE(custom_value)
		if(!custom_value)
			continue
		LAZYADD(data_to_add, TGM_VAR_LINE(custom_variable, custom_value))
		LAZYSET(custom_var_names, custom_variable, TRUE)

	for(var/variable in vars_to_save)
		if(LAZYACCESS(custom_var_names, variable)) // skip variables that use custom serialization
			continue

		var/value = object.vars[variable]
		if(value == initial(object.vars[variable]) || !issaved(object.vars[variable]))
			continue
		if(variable == "icon_state" && object.smoothing_flags)
			continue
		if(variable == "icon" && object.smoothing_flags)
			continue

		TGM_ENCODE(value)
		if(!value)
			continue

		LAZYADD(data_to_add, TGM_VAR_LINE(variable, value))

	if(!length(data_to_add))
		return

	return TGM_VARS_BLOCK(data_to_add.Join(";\n\t"))

/proc/generate_tgm_typepath_metadata(list/data_to_seralize)
	var/list/data_to_add = list()

	for(var/variable in data_to_seralize)
		var/value = data_to_seralize[variable]

		TGM_ENCODE(value)
		if(!value)
			continue
		data_to_add += TGM_VAR_LINE(variable, value)

	if(!length(data_to_add))
		return

	return TGM_VARS_BLOCK(data_to_add.Join(";\n\t"))

// cannot macro this due to infinite recursion TGM_ENCODE & TO_LIST_STRING call each other
// also handles converting nested lists into strings
/proc/to_list_string(list/build_from)
	var/list/build_into = list()
	build_into += "list("
	var/first_entry = TRUE
	for(var/item in build_from)
		CHECK_TICK
		if(!first_entry)
			build_into += ", "

		// We must check build_from[item] before TGM_ENCODE(item) as the macro converts
		// item typepaths/objects to strings, breaking associative list lookups
		// (list[typepath] becomes list["string"]).
		var/encoded_item = item
		TGM_ENCODE(encoded_item)
		if(isnum(item) || !build_from[item])
			build_into += "[encoded_item]"
		else
			var/encoded_value = build_from[item]
			TGM_ENCODE(encoded_value)
			build_into += "[encoded_item] = [encoded_value]"
		first_entry = FALSE
	build_into += ")"
	return build_into.Join("")
