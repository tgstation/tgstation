/client/proc/browse_files(root_type = BROWSE_ROOT_ALL_LOGS, max_iterations = 10, list/valid_extensions = list("txt", "log", "htm", "html", "gz", "json"), list/whitelist = null, allow_folder = TRUE)
	var/regex/valid_ext_regex = new("\\.(?:[regex_quote_list(valid_extensions)])$", "i")
	var/regex/whitelist_regex
	if(whitelist)
		// try not to look at it too hard. yes i wrote this by hand.
		whitelist_regex = new("(?:\[\\/\\\\\]$|(?:^|\\\\|\\/)(?:[regex_quote_list(whitelist)])\\.(?:[regex_quote_list(valid_extensions)])$)", "i")

	// wow why was this ever a parameter
	var/root = "data/logs/"
	switch(root_type)
		if(BROWSE_ROOT_ALL_LOGS)
			root = "data/logs/"
		if(BROWSE_ROOT_CURRENT_LOGS)
			root = "[GLOB.log_directory]/"
	var/path = root

	for(var/i in 1 to max_iterations)
		var/list/choices
		if(whitelist_regex)
			choices = list()
			for(var/listed_path in flist(path))
				if(whitelist_regex.Find(listed_path))
					choices += listed_path
		else
			choices = flist(path)
		if(path != root)
			choices.Insert(1, "/")
		choices = sort_list(choices)
		if(allow_folder)
			choices += "Download Folder"

		var/choice = tgui_input_list(src, "Choose a file to access", "Download", choices)
		if(!choice)
			return
		switch(choice)
			if("/")
				path = root
				continue
			if("Download Folder")
				if(!allow_folder)
					return
				var/list/comp_flist = flist(path)
				var/confirmation = input(src, "Are you SURE you want to download all the files in this folder? (This will open [length(comp_flist)] prompt[length(comp_flist) == 1 ? "" : "s"])", "Confirmation") in list("Yes", "No")
				if(confirmation != "Yes")
					continue
				for(var/file in comp_flist)
					src << ftp(path + file)
				return
		path += choice

		if(copytext_char(path, -1) != "/") //didn't choose a directory, no need to iterate again
			break
	if(!fexists(path) || !valid_ext_regex.Find(path))
		to_chat(src, "<font color='red'>Error: browse_files(): File not found/Invalid file([path]).</font>")
		return

	return path

/proc/regex_quote_list(list/input) as text
	var/list/sanitized = list()
	for(var/thingy in input)
		sanitized += REGEX_QUOTE(thingy)
	return jointext(sanitized, "|")
