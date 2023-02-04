ADMIN_VERB(admin, get_server_logs, "Get Server Logs", "View/Retrieve logfiles", R_ADMIN)
	usr.client.holder.browseserverlogs()

ADMIN_VERB(admin, get_current_logs, "Get Current Logs", "View/Retrieve current logfiles", R_ADMIN)
	usr.client.holder.browseserverlogs(current = TRUE)

/datum/admins/proc/browseserverlogs(current = FALSE)
	var/path = owner.browse_files(current ? BROWSE_ROOT_CURRENT_LOGS : BROWSE_ROOT_ALL_LOGS)
	if(!path)
		return

	if(owner.file_spam_check())
		return

	message_admins("[key_name_admin(usr)] accessed file: [path]")
	switch(tgui_alert(usr,"View (in game), Open (in your system's text editor), or Download?", path, list("View", "Open", "Download")))
		if ("View")
			usr << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			usr << run(file(path))
		if ("Download")
			usr << ftp(file(path))
		else
			return
	to_chat(usr, "Attempting to send [path], this may take a fair few minutes if the file is very large.", confidential = TRUE)
