/atom/proc/investigate_log(message, subject)
	if(!message || !subject)
		return
	var/F = file("[GLOB.log_directory]/[subject].html")
	WRITE_FILE(F, "<small>[time_stamp()] [REF(src)] ([x],[y],[z])</small> || [src] [message]<br>")

/client/proc/investigate_show(subject in list("notes, memos, watchlist", INVESTIGATE_RESEARCH, INVESTIGATE_EXONET, INVESTIGATE_PORTAL, INVESTIGATE_SINGULO, INVESTIGATE_WIRES, INVESTIGATE_TELESCI, INVESTIGATE_GRAVITY, INVESTIGATE_RECORDS, INVESTIGATE_CARGO, INVESTIGATE_SUPERMATTER, INVESTIGATE_ATMOS, INVESTIGATE_EXPERIMENTOR, INVESTIGATE_BOTANY, INVESTIGATE_HALLUCINATIONS, INVESTIGATE_RADIATION, INVESTIGATE_CIRCUIT, INVESTIGATE_NANITES) )
	set name = "Investigate"
	set category = "Admin"
	if(!holder)
		return
	switch(subject)
		if("notes, memos, watchlist")
			if(!check_rights(R_ADMIN))
				return
			browse_messages()
		else
			var/F = file("[GLOB.log_directory]/[subject].html")
			if(!fexists(F))
				to_chat(src, "<span class='danger'>No [subject] logfile was found.</span>")
				return
			src << browse(F,"window=investigate[subject];size=800x300")
