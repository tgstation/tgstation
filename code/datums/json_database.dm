/// Represents a json file being used as a database in the data/ folder.
/// Changes made here will save back to the associated file, with recovery.
/// Will defer writes until later if multiple happen in the same tick.
/// Do not add an extra cache on top of this. This IS your cache.
/datum/json_database
	VAR_PRIVATE
		filepath
		backup_filepath

		cached_data
		save_queued = FALSE

		static/existing_json_database = list()

/datum/json_database/New(filepath)
	if (IsAdminAdvancedProcCall())
		to_chat(usr, "<span class='admin prefix'>json_database creation, linking to [html_encode(filepath)], was blocked.</span>", confidential = TRUE)
		return

	ASSERT(isnull(existing_json_database[filepath]), "[filepath] already has an associated json_database. You must expose it somehow and use that instead of making a new one.")

	existing_json_database[filepath] = TRUE

	src.filepath = filepath
	backup_filepath = "[filepath].savebac"

	if (fexists(filepath))
		cached_data = safe_json_decode(file2text(filepath))
		if (isnull(cached_data))
			var/scenario = "[filepath] existed, but did not have valid JSON"

			if (fexists(backup_filepath))
				load_backup(scenario)
			else
				stack_trace("[scenario]. No backup could be found.")
				cached_data = list()
	else
		if (fexists(backup_filepath))
			load_backup("[filepath] didn't exist")
		else
			cached_data = list()

/datum/json_database/Destroy()
	if (save_queued)
		save()

	existing_json_database -= filepath

	return ..()

/// Returns the cached data.
/// Be careful on holding onto this data for too long, as it can mutate when other stuff changes it.
/// Do not mutate it yourself.
/datum/json_database/proc/get()
	return cached_data

/// Returns the data with the given key.
/// For arrays, this is a number.
/// Be careful on holding onto this data for too long, as it can mutate when other stuff changes it.
/// Do not mutate it yourself.
/datum/json_database/proc/get_key(key)
	return cached_data[key]

/// Picks the data of a random key and then removes that key from the database.
/// Since the list is no longer inside the database, you can mutate and use it as you like.
/datum/json_database/proc/pick_and_take_key()
	if(!length(cached_data))
		return null
	var/key = pick(cached_data)
	. =  cached_data[key]
	cached_data -= key
	queue_save()

/// Sets the data at the key to the value, and queues a save.
/datum/json_database/proc/set_key(key, value)
	cached_data[key] = value
	queue_save()

/// Removes the data at the given item, and queues a save.
/// For dictionaries, this can be the key.
/// For arrays, this can be the value.
/datum/json_database/proc/remove(item)
	UNTYPED_LIST_REMOVE(cached_data, item)
	queue_save()

/// Inserts the data at the end of what is assumed to be an array, and queues a save.
/datum/json_database/proc/insert(value)
	UNTYPED_LIST_ADD(cached_data, value)
	queue_save()

/// Replaces the cache with the new data completely, and queues a save.
/// Do not touch the new data after passing it in.
/datum/json_database/proc/replace(list/new_data)
	cached_data = new_data
	queue_save()

/datum/json_database/proc/queue_save()
	PRIVATE_PROC(TRUE)

	if (save_queued)
		return

	addtimer(CALLBACK(src, PROC_REF(save)), 0)

/datum/json_database/proc/save()
	PRIVATE_PROC(TRUE)

	save_queued = FALSE

	if (fexists(filepath))
		rustg_file_write(file2text(filepath), backup_filepath)

	rustg_file_write(json_encode(cached_data, JSON_PRETTY_PRINT), filepath)

	ASSERT(!isnull(safe_json_decode(file2text(filepath))), "JSON written to [filepath] was not valid. Backup will be preserved.")

	fdel(backup_filepath)

/datum/json_database/proc/load_backup(scenario)
	PRIVATE_PROC(TRUE)

	var/cached_contents = file2text(backup_filepath)
	var/list/backed_up_data = safe_json_decode(cached_contents)

	if (isnull(backed_up_data))
		stack_trace("[scenario]. Backup existed, but also did not have valid JSON.")
		cached_data = list()
	else
		stack_trace("[scenario]. Backup existed and was used instead. The JSON file has been updated.")
		cached_data = backed_up_data
		rustg_file_write(cached_contents, filepath)

/datum/json_database/vv_edit_var(var_name, var_value)
	switch (var_name)
		if (nameof(filepath), nameof(backup_filepath))
			return FALSE
		else
			return ..()
