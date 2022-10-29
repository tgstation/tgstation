SUBSYSTEM_DEF(logging)
	name = "Logging"
	init_order = INIT_ORDER_LOGGING
	flags = SS_NO_FIRE
	var/list/entries
	var/list/entries_by_key
	var/list/entry_dir_map
	var/list/pending_entries

/datum/controller/subsystem/logging/Initialize()
	. = ..()
	entries = list()
	entries_by_key = list()
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
	entries_by_key[entry.key] = entry
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
	if(IsAdminAdvancedProcCall() || !check_rights_for(user.client, R_ADMIN))
		return
	ui_interact(user)

/datum/controller/subsystem/logging/ui_state(mob/user)
	return GLOB.admin_state

/datum/controller/subsystem/logging/ui_status(mob/user, datum/ui_state/state)
	if(!check_rights_for(user.client, R_ADMIN))
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/controller/subsystem/logging/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LogViewer")
		ui.open()

/datum/controller/subsystem/logging/ui_static_data(mob/user)
	. = list(
		"entries" = list(),
	)
	// entries -> (category -> entry[])[]
	for(var/category in entries)
		.["entries"][category] = list()
		for(var/datum/log_entry/entry as anything in entries[category])
			.["entries"][category][UNLINT(entry.key)] = entry.final_list()

/datum/controller/subsystem/logging/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/entry_key = params["entry"]
	var/datum/log_entry/entry = entries_by_key[entry_key]
	switch(action)
		if("refresh")
			SStgui.update_static_data(usr, ui)
			return TRUE
		if("inspect")
			entry?.inspect(usr)
			return TRUE
