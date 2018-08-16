
GLOBAL_LIST(custom_item_list)
//Layered list in form of custom_item_list[ckey][job][items][amounts]
//ckey is key, job is specific jobs, or "ALL" for all jobs, items for items, amounts for amount of item.

//File should be in the format of ckey|exact job name/exact job name/or put ALL instead of any job names|/path/to/item=amount;/path/to/item=amount
//Each ckey should be in a different line
//if there's multiple entries of a single ckey the later ones will add to the earlier definitions.

/proc/reload_custom_roundstart_items_list(custom_filelist)
	if(!custom_filelist)
		custom_filelist = "config/custom_roundstart_items.txt"
	GLOB.custom_item_list = list()
	var/list/file_lines = world.file2list(custom_filelist)
	for(var/line in file_lines)
		if(length(line) == 0)	//Emptyline, no one cares.
			continue
		if(copytext(line,1,3) == "//")	//Commented line, ignore.
			continue
		var/ckey_str_sep = findtext(line, "|")						//Process our stuff..
		var/char_str_sep = findtext(line, "|", ckey_str_sep+1)
		var/job_str_sep = findtext(line, "|", char_str_sep+1)
		var/item_str_sep = findtext(line, "|", job_str_sep+1)
		var/ckey_str = ckey(copytext(line, 1, ckey_str_sep))
		var/char_str = copytext(line, ckey_str_sep+1, char_str_sep)
		var/job_str = copytext(line, char_str_sep+1, job_str_sep)
		var/item_str = copytext(line, job_str_sep+1, item_str_sep)
		if(!ckey_str || !char_str || !job_str || !item_str || !length(ckey_str) || !length(char_str) || !length(job_str) || !length(item_str))
			log_admin("Errored custom_items_whitelist line: [line] - Component/separator missing!")
		if(!islist(GLOB.custom_item_list[ckey_str]))
			GLOB.custom_item_list[ckey_str] = list()	//Initialize list for this ckey if it isn't initialized..
		var/list/characters = splittext(char_str, "/")
		for(var/character in characters)
			if(!islist(GLOB.custom_item_list[ckey_str][character]))
				GLOB.custom_item_list[ckey_str][character] = list()
		var/list/jobs = splittext(job_str, "/")
		for(var/job in jobs)
			for(var/character in characters)
				if(!islist(GLOB.custom_item_list[ckey_str][character][job]))
					GLOB.custom_item_list[ckey_str][character][job] = list()		//Initialize item list for this job of this ckey if not already initialized.
		var/list/item_strings = splittext(item_str, ";")			//Get item strings in format of /path/to/item=amount
		for(var/item_string in item_strings)
			var/path_str_sep = findtext(item_string, "=")
			var/path = copytext(item_string, 1, path_str_sep)	//Path to spawn
			var/amount = copytext(item_string, path_str_sep+1)	//Amount to spawn
			//world << "DEBUG: Item string [item_string] processed"
			amount = text2num(amount)
			path = text2path(path)
			if(!ispath(path) || !isnum(amount))
				log_admin("Errored custom_items_whitelist line: [line] - Path/number for item missing or invalid.")
			for(var/character in characters)
				for(var/job in jobs)
					if(!GLOB.custom_item_list[ckey_str][character][job][path])		//Doesn't exist, make it exist!
						GLOB.custom_item_list[ckey_str][character][job][path] = amount
					else
						GLOB.custom_item_list[ckey_str][character][job][path] += amount	//Exists, we want more~
	return GLOB.custom_item_list

/proc/parse_custom_roundstart_items(ckey, char_name = "ALL", job_name = "ALL", special_role)
	var/list/ret = list()
	if(GLOB.custom_item_list[ckey])
		for(var/char in GLOB.custom_item_list[ckey])
			if((char_name == char) || (char_name == "ALL") || (char == "ALL"))
				for(var/job in GLOB.custom_item_list[ckey][char])
					if((job_name == job) || (job == "ALL") || (job_name == "ALL") || (special_role && (job == special_role)))
						for(var/item_path in GLOB.custom_item_list[ckey][char][job])
							if(ret[item_path])
								ret[item_path] += GLOB.custom_item_list[ckey][char][job][item_path]
							else
								ret[item_path] = GLOB.custom_item_list[ckey][char][job][item_path]
	return ret
