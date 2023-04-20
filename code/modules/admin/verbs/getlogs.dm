
ADMIN_VERB(view_logs, "Get Server Logs", "View/Retrieve logfiles.", R_ADMIN, VERB_CATEGORY_ADMIN)
	user.browseserverlogs()

ADMIN_VERB(view_logs_cirremt, "Get Current Logs", "View/Retrieve logfiles for the current round.", R_ADMIN, VERB_CATEGORY_ADMIN)
	user.browseserverlogs(current = TRUE)

/client/proc/browseserverlogs(current = FALSE)
	if(IsAdminAdvancedProcCall() || !check_rights_for(src, R_ADMIN))
		return

	var/path = browse_files(current ? BROWSE_ROOT_CURRENT_LOGS : BROWSE_ROOT_ALL_LOGS)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(tgui_alert(usr,"View (in game), Open (in your system's text editor), or Download?", path, list("View", "Open", "Download")))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.", confidential = TRUE)
	return
