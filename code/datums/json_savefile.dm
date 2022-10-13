#define SF_CUTOFF_FLAG "||__||__||"
#define SF_REPLACE_COMMA "|||_|||"

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
		stack_trace("failed to load json savefile: [err]")
		return FALSE

/json_savefile/proc/save()
	if(fexists(path))
		fdel(path)
	rustg_file_write(json_encode(tree), path)

/json_savefile/proc/decode_line_value(line)
	var/list_idx = findlasttext(line, "list(")
	while(list_idx)
		var/pos = list_idx
		while(copytext(line, pos, pos + 1) != ")")\
			pos++
		var/work = copytext(line, list_idx + 5, pos)
		var/finished = ""
		if(findtext(work, " = "))
			finished = "{"
			for(var/entree in splittext(work, ","))
				var/kvp = splittext(entree, " = ")
				if(length(kvp)==1)
					kvp += "null"
				finished += "[kvp[1]]:[kvp[2]][SF_REPLACE_COMMA]"
			finished = copytext(finished, 1, -length(SF_REPLACE_COMMA))
			finished += "}"
		else
			finished = "\[" + replacetext(work, ",", SF_REPLACE_COMMA) + "\]"
		line = copytext(line, 1, list_idx) + finished + copytext(line, pos + 1)
		list_idx = findlasttext(line, "list(")
	return json_decode(replacetext(line, SF_REPLACE_COMMA, ","))

/json_savefile/proc/import_byond_savefile(savefile/sfile)
	var/list/data = splittext(sfile.ExportText("/"), "\n")
	var/list/sf_data = list()
	var/list/region = sf_data
	var/tab_last
	var/line_concat
	var/concat_tab
	data += SF_CUTOFF_FLAG
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

		if(line == SF_CUTOFF_FLAG)
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
	tree = sf_data

#undef SF_CUTOFF_FLAG
#undef SF_REPLACE_COMMA
