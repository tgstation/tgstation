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
		var/text_value = tgm_encode(custom_value)
		if(!text_value)
			continue
		data_to_add += "[variable] = [text_value]"
		custom_var_names[variable] = TRUE

	for(var/variable in vars_to_save)
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
