GLOBAL_LIST(debug_logfile_names)
GLOBAL_PROTECT(debug_logfile_names)

/client/proc/getserverlogs_debug()
	set name = "Get Server Logs (Debug)"
	set desc = "View/retrieve debug-related logfiles."
	set category = "Debug"
	if(!check_rights_for(src, R_DEBUG))
		return
	get_debug_logfiles()
	if(!GLOB.debug_logfile_names)
		return
	browseserverlogs(whitelist = GLOB.debug_logfile_names, allow_folder = FALSE)

/client/proc/getcurrentlogs_debug()
	set name = "Get Current Logs (Debug)"
	set desc = "View/retrieve debug-related logfiles for the current round."
	set category = "Debug"
	if(!check_rights_for(src, R_DEBUG))
		return
	get_debug_logfiles()
	if(!GLOB.debug_logfile_names)
		return
	browseserverlogs(current = TRUE, whitelist = GLOB.debug_logfile_names, allow_folder = FALSE)

/client/proc/browseserverlogs(current = FALSE, list/whitelist = null, allow_folder = TRUE)
	var/path = browse_files(current ? BROWSE_ROOT_CURRENT_LOGS : BROWSE_ROOT_ALL_LOGS, whitelist = whitelist, allow_folder = allow_folder)
	if(!path || !fexists(path))
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(tgui_alert(usr, "View (in game), Open (in your system's text editor), or Download?", path, list("View", "Open", "Download")))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
	to_chat(src, span_boldnotice("Attempting to send [path], this may take a fair few minutes if the file is very large."), confidential = TRUE)
	return

/proc/get_debug_logfiles()
	if(!logger.initialized || GLOB.debug_logfile_names)
		return
	for(var/datum/log_category/category as anything in logger.log_categories)
		category = logger.log_categories[category]
		if(is_category_debug_visible(category))
			LAZYOR(GLOB.debug_logfile_names, get_category_logfile(category))
