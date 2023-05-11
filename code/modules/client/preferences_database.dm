/datum/preferences/proc/load_from_database(silent = FALSE)
	if(!SSdbcore.Connect())
		if(!silent)
			to_chat(parent, span_warning("Unable to establish a database connection. Preferences could not be loaded from database storage."))
		return
	load_mutes_from_database()

/datum/preferences/proc/save_to_database(silent = FALSE)
	if(!SSdbcore.Connect())
		if(!silent)
			to_chat(parent, span_warning("Unable to establish a database connection. Preferences will not be saved to database storage."))
		return
	// nothing here yet

/datum/preferences/proc/load_mutes_from_database()
	var/datum/db_query/mute_flags_query = SSdbcore.NewQuery({"
		SELECT muted_flag FROM [format_table_name("muted")]
		WHERE ckey = :ckey
		AND deleted = 0
	"}, list("ckey" = parent.ckey))
	if(mute_flags_query.Execute(async = FALSE))
		muted = NONE
		while(mute_flags_query.NextRow())
			muted |= mute_flags_query.item[1]
	qdel(mute_flags_query)
