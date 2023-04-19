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
