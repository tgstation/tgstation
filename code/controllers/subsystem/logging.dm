SUBSYSTEM_DEF(logging)
	name = "Logging"
	init_order = INIT_ORDER_LOGGING
	flags = SS_NO_FIRE
	var/list/entries
	var/list/entry_dir_map
	var/list/pending_entries

/datum/controller/subsystem/logging/Initialize()
	. = ..()
	entries = list()
	entry_dir_map = list()
	for(var/datum/log_entry/entry_type as anything in subtypesof(/datum/log_entry))
		var/entry_category = initial(entry_type.category)
		if(!entries[entry_category])
			entries[entry_category] = list()
			var/log_file = "[GLOB.log_directory]/[lowertext(entry_category)]"
			entry_dir_map[entry_category] = log_file
	process_pending()

/datum/controller/subsystem/logging/Recover()
	. = ..()
	entries = SSlogging.entries
	entry_dir_map = SSlogging.entry_dir_map
	pending_entries = SSlogging.pending_entries
	process_pending()

/datum/controller/subsystem/logging/proc/append_entry(datum/log_entry/entry)
	if(!entries)
		LAZYADD(pending_entries, entry)
		return

	LAZYADDASSOC(entries, entry.category, entry)
	var/category_file_id = replacetext(lowertext(entry.category), " ", "_")
	var/target_file = "[category_file_id]-entry-[length(entries[entry.category])].json"
	rustg_file_write(entry.to_json(), "[entry_dir_map[entry.category]]/[target_file]")

/datum/controller/subsystem/logging/proc/process_pending()
	if(!pending_entries)
		return
	for(var/datum/log_entry/entry as anything in pending_entries)
		append_entry(entry)
	pending_entries = null

/datum/controller/subsystem/logging/proc/view_logs(mob/user)
	if(istype(user, /client)) // we are nice and allow you to pass in a client
		var/client/client = user
		user = client.mob
	if(IsAdminAdvancedProcCall() || !check_rights_for(user, R_ADMIN))
		return
	var/choice = tgui_input_list(user, "Select a log category", "View Logs", src.entries)
	if(!choice)
		return
	var/list/entries = src.entries[choice]
	if(!entries)
		to_chat(user, span_warning("No entries found for that category."))
		return
	var/list/data = list()
	for(var/datum/log_entry/entry as anything in entries)
		var/entry_text = entry.to_text()
		var/inspect_text = "(<a href='?src=[REF(src)];[HrefToken()];inspect=[REF(entry)]'>Inspect</a>) "
		data += "[inspect_text][entry_text]"
	user << browse(data.Join("<br>"), "window=logs;size=600x400")
	onclose(user, "logs")

/datum/controller/subsystem/logging/Topic(href, href_list)
	if(href_list["inspect"])
		var/datum/log_entry/entry = locate(href_list["inspect"])
		if(entry)
			entry.inspect(usr)
	return ..()
