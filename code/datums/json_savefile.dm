/**
 * A savefile implementation that handles all data using json.
 * Also saves it using JSON too, fancy.
 * If you pass in a null path, it simply acts as a memory tree instead, and cannot be saved.
 */
/datum/json_savefile
	var/path = ""
	VAR_PRIVATE/list/tree
	/// If this is set to true, calling set_entry or remove_entry will automatically call save(), this does not catch modifying a sub-tree, nor do I know how to do that
	var/auto_save = FALSE
	/// Cooldown that tracks the time between attempts to download the savefile.
	COOLDOWN_DECLARE(download_cooldown)

GENERAL_PROTECT_DATUM(/datum/json_savefile)

/datum/json_savefile/New(path)
	src.path = path
	tree = list()
	if(path && fexists(path))
		load()

/**
 * Gets an entry from the json tree, with an optional default value.
 * If no key is specified it throws the entire tree at you instead
 */
/datum/json_savefile/proc/get_entry(key, default_value)
	if(!key)
		return tree
	return (key in tree) ? tree[key] : default_value

/// Sets an entry in the tree to the given value
/datum/json_savefile/proc/set_entry(key, value)
	tree[key] = value
	if(auto_save)
		save()

/// Removes the given key from the tree
/datum/json_savefile/proc/remove_entry(key)
	if(key)
		tree -= key
	if(auto_save)
		save()

/// Wipes the entire tree
/datum/json_savefile/proc/wipe()
	tree?.Cut()

/datum/json_savefile/proc/load()
	if(!path || !fexists(path))
		return FALSE
	try
		tree = json_decode(rustg_file_read(path))
		return TRUE
	catch(var/exception/err)
		stack_trace("failed to load json savefile at '[path]': [err]")
		return FALSE

/datum/json_savefile/proc/save()
	if(path)
		rustg_file_write(json_encode(tree), path)

/datum/json_savefile/serialize_list(list/options)
	return tree.Copy()

/// Traverses the entire dir tree of the given savefile and dynamically assembles the tree from it
/datum/json_savefile/proc/import_byond_savefile(savefile/savefile)
	tree.Cut()
	var/list/dirs_to_go = list("/" = tree)
	while(length(dirs_to_go))
		var/dir = dirs_to_go[1]
		var/list/region = dirs_to_go[dir]
		dirs_to_go.Cut(1, 2)
		savefile.cd = dir
		for(var/entry in savefile.dir)
			var/entry_value
			savefile.cd = "[dir]/[entry]"
			//eof refers to the path you are cd'ed into, not the savefile as a whole. being false right after cding into an entry means this entry has no buffer, which only happens with nested save file directories
			if (savefile.eof)
				region[entry] = list()
				dirs_to_go["[dir]/[entry]"] = region[entry]
				continue
			READ_FILE(savefile, entry_value) //we are cd'ed to the entry, so we don't need to specify a path to read from
			region[entry] = entry_value

/// Proc that handles generating a JSON file (prettified if 515 and over!) of a user's preferences and showing it to them.
/// Requester is passed in to the ftp() and tgui_alert() procs, and account_name is just used to generate the filename.
/// We don't _need_ to pass in account_name since this is reliant on the json_savefile datum already knowing what we correspond to, but it's here to help people keep track of their stuff.
/datum/json_savefile/proc/export_json_to_client(mob/requester, account_name)
	if(!istype(requester) || !path)
		return

	if(!json_export_checks(requester))
		return

	COOLDOWN_START(src, download_cooldown, (CONFIG_GET(number/seconds_cooldown_for_preferences_export) * (1 SECONDS)))
	var/file_name = "[account_name ? "[account_name]_" : ""]preferences_[time2text(world.timeofday, "MMM_DD_YYYY_hh-mm-ss")].json"
	var/temporary_file_storage = "data/preferences_export_working_directory/[file_name]"

#if DM_VERSION >= 515
	if(!text2file(json_encode(tree, JSON_PRETTY_PRINT), temporary_file_storage))
		tgui_alert(requester, "Failed to export preferences to JSON! You might need to try again later.", "Export Preferences JSON")
		return
#else
	if(!text2file(json_encode(tree), temporary_file_storage))
		tgui_alert(requester, "Failed to export preferences to JSON! You might need to try again later.", "Export Preferences JSON")
		return
#endif

	var/exportable_json = file(temporary_file_storage)

	DIRECT_OUTPUT(requester, ftp(exportable_json, file_name))
	fdel(temporary_file_storage)

/// Proc that just handles all of the checks for exporting a preferences file, returns TRUE if all checks are passed, FALSE otherwise.
/// Just done like this to make the code in the export_json_to_client() proc a bit cleaner.
/datum/json_savefile/proc/json_export_checks(mob/requester)
	if(!COOLDOWN_FINISHED(src, download_cooldown))
		tgui_alert(requester, "You must wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, download_cooldown))] before exporting your preferences again!", "Export Preferences JSON")
		return FALSE

	if(tgui_alert(requester, "Are you sure you want to export your preferences as a JSON file? This will save to a file on your computer.", "Export Preferences JSON", list("Cancel", "Yes")) == "Yes")
		return TRUE

	return FALSE
