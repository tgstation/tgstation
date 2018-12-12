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

	var/list/copy = investigates.Copy()

	for(var/subject in copy)
		var/temp_file = INVESTIGATE_FILE(subject)
		if(!fexists(temp_file))
			investigates -= subject

	investigates.Insert(1, INVESTIGATE_NOTES)

	var/selected = input("Investigate what?", "Investigate") as null|anything in investigates

	if(!selected)
		return

	if(selected == INVESTIGATE_NOTES && check_rights(R_ADMIN))
		browse_messages()
		return

	var/F = INVESTIGATE_FILE(selected)
	if(!fexists(F))
		to_chat(src, "<span class='danger'>No [selected] logfile was found. Did it just get deleted?</span>")
		return
	src << browse(F,"window=investigate[selected];size=800x300")
