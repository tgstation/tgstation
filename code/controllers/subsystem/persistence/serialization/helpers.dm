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

/proc/generate_tgm_metadata(atom/object)
	var/list/data_to_add = list()
	var/list/vars_to_save = object.get_save_vars()
	var/list/custom_vars = object.get_custom_save_vars()
	// Tracks variables handled by get_custom_save_vars() This ensures the default variable saving loop
	// correctly skips these names. A separate list is necessary because custom_vars can contain null or FALSE values.
	var/list/custom_var_names = list()

	for(var/variable in custom_vars)
		CHECK_TICK
		var/custom_value = custom_vars[variable]
		TGM_ENCODE(custom_value)
		if(!custom_value)
			continue
		data_to_add += "[variable] = [custom_value]"
		custom_var_names[variable] = TRUE

	while(vars_to_save.len)
		var/variable = vars_to_save[vars_to_save.len]
		vars_to_save.len--
		CHECK_TICK
		if(custom_var_names[variable]) // skip variables that use custom serialization
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
		data_to_add += "[variable] = [value]"

	if(!length(data_to_add))
		return
	return "{\n\t[data_to_add.Join(";\n\t")]\n\t}"

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
		if(isnum(item) || !build_from[item])
			TGM_ENCODE(item)
			build_into += "[item]"
		else
			TGM_ENCODE(item)
			TGM_ENCODE(build_from[item])
			build_into += "[item] = [build_from[item]]"
		first_entry = FALSE
	build_into += ")"
	return build_into.Join("")
