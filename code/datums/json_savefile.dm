#define JSON_SAVEFILE_PARSE_CUTOFF_FLAG "||__||__||"
#define JSON_SAVEFILE_PARSE_REPLACE_COMMA "|||_|||"

/json_savefile
	var/path
	VAR_PRIVATE/list/tree
	var/auto_save = FALSE

/json_savefile/New(path)
	src.path = path
	tree = list()
	if(fexists(path))
		load()

/json_savefile/proc/get_entry(key, default_value)
	if(!key)
		return tree
	return (key in tree) ? tree[key] : default_value

/json_savefile/proc/set_entry(key, value)
	tree[key] = value
	if(auto_save)
		save()

/json_savefile/proc/clear(key)
	if(key)
		tree -= key
	else
		tree.Cut()
	if(auto_save)
		save()

/json_savefile/proc/load()
	if(!fexists(path))
		return FALSE
	try
		tree = json_decode(file2text(path))
		return TRUE
	catch(var/exception/err)
		stack_trace("failed to load json savefile at '[path]': [err]")
		return FALSE

/json_savefile/proc/save()
	if(fexists(path))
		fdel(path)
	rustg_file_write(json_encode(tree), path)

/json_savefile/proc/decode_line_value(line)
	var/list_index = findlasttext(line, "list(")
	while(list_index)
		var/target_char_index = list_index
		while(copytext(line, target_char_index, target_char_index + 1) != ")")\
			target_char_index++
		var/work = copytext(line, list_index + 5, target_char_index)
		var/finished = ""
		if(findtext(work, " = "))
			finished = "{"
			for(var/entree in splittext(work, ","))
				var/key_value_pair = splittext(entree, " = ")
				if(length(key_value_pair)==1)
					key_value_pair += "null"
				finished += "[key_value_pair[1]]:[key_value_pair[2]][JSON_SAVEFILE_PARSE_REPLACE_COMMA]"
			finished = copytext(finished, 1, -length(JSON_SAVEFILE_PARSE_REPLACE_COMMA))
			finished += "}"
		else
			finished = "\[" + replacetext(work, ",", JSON_SAVEFILE_PARSE_REPLACE_COMMA) + "\]"
		line = copytext(line, 1, list_index) + finished + copytext(line, target_char_index + 1)
		list_index = findlasttext(line, "list(")
	return json_decode(replacetext(line, JSON_SAVEFILE_PARSE_REPLACE_COMMA, ","))

/json_savefile/proc/import_byond_savefile(savefile/savefile)
	var/list/data = splittext(savefile.ExportText("/"), "\n")
	var/list/savefile_data = list()
	var/list/region = savefile_data
	var/tab_last
	var/line_concat
	var/concat_tab
	data += JSON_SAVEFILE_PARSE_CUTOFF_FLAG
	while(data.len)
		var/line = popleft(data)
		var/tab = findlasttext(line, "\t")
		line = copytext(line, tab + 1)

		if(!line)
			continue

		if(copytext(line, length(line))== ",")
			if(!line_concat)
				concat_tab = tab
			line_concat += line
			continue

		if(line_concat)
			line = line_concat + line
			tab = concat_tab
			line_concat = null

		if(tab_last > tab)
			var/down = tab_last - tab
			while(down)
				down--
				var/next = region[".."]
				region -= ".."
				region = next

		if(line == JSON_SAVEFILE_PARSE_CUTOFF_FLAG)
			break

		var/list/line_data = splittext(line, " = ")
		var/header = line_data[1]
		var/list/line_data_copy = line_data.Copy(2)
		var/line_value = line_data_copy.Join(" = ")

		if(line_data.len == 1)
			var/new_region = list()
			var/old = region
			region[line] = new_region
			region = new_region
			region[".."] = old
		else
			region[header] = decode_line_value(line_value)
		tab_last = tab
	tree = savefile_data

#undef JSON_SAVEFILE_PARSE_CUTOFF_FLAG
#undef JSON_SAVEFILE_PARSE_REPLACE_COMMA
