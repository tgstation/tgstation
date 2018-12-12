#define INVESTIGATE_NOTES "notes, memos, watchlist" // Not a real investigation category
#define INVESTIGATE_FILE(subject) file("[GLOB.log_directory]/[subject].html")

/atom/proc/investigate_log(message, subject)
	if(!message || !subject)
		return
	var/F = INVESTIGATE_FILE(subject)
	WRITE_FILE(F, "<small>[time_stamp()] [REF(src)] ([x],[y],[z])</small> || [src] [message]<br>")

/client/proc/investigate_show()
	set name = "Investigate"
	set category = "Admin"
	if(!holder)
		return

	var/list/investigates = list(INVESTIGATE_RESEARCH, INVESTIGATE_EXONET, INVESTIGATE_PORTAL, INVESTIGATE_SINGULO, INVESTIGATE_WIRES, INVESTIGATE_TELESCI, INVESTIGATE_GRAVITY, INVESTIGATE_RECORDS, INVESTIGATE_CARGO, INVESTIGATE_SUPERMATTER, INVESTIGATE_ATMOS, INVESTIGATE_EXPERIMENTOR, INVESTIGATE_BOTANY, INVESTIGATE_HALLUCINATIONS, INVESTIGATE_RADIATION, INVESTIGATE_CIRCUIT, INVESTIGATE_NANITES)

	var/list/logs_present = list(INVESTIGATE_NOTES)
	var/list/logs_missing = list("---")

	for(var/subject in investigates)
		var/temp_file = INVESTIGATE_FILE(subject)
		if(fexists(temp_file))
			logs_present += subject
		else
			logs_missing += "[subject] (empty)"

	var/list/combined = logs_present + logs_missing

	var/selected = input("Investigate what?", "Investigate") as null|anything in combined

	if(!selected in combined)
		// no.
		return

	selected = replacetext(selected, " (empty)", "")

	if(selected == "---")
		return

	if(selected == INVESTIGATE_NOTES && check_rights(R_ADMIN))
		browse_messages()
		return

	var/F = INVESTIGATE_FILE(selected)
	if(!fexists(F))
		to_chat(src, "<span class='danger'>No [selected] logfile was found.</span>")
		return
	src << browse(F,"window=investigate[selected];size=800x300")
