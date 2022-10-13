/**
 * A savefile implementation that handles all data using json
 * also saves it using JSON too, fancy
 */
/datum/json_savefile
	var/path
	VAR_PRIVATE/list/tree
	var/auto_save = FALSE

/datum/json_savefile/New(path)
	src.path = path
	tree = list()
	if(fexists(path))
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

/// Removes the given key from the tree, if no key is given it clears the entire tree
/datum/json_savefile/proc/clear(key)
	if(key)
		tree -= key
	else
		tree.Cut()
	if(auto_save)
		save()

/datum/json_savefile/proc/load()
	if(!fexists(path))
		return FALSE
	try
		tree = json_decode(file2text(path))
		return TRUE
	catch(var/exception/err)
		stack_trace("failed to load json savefile at '[path]': [err]")
		return FALSE

/datum/json_savefile/proc/save()
	if(fexists(path))
		fdel(path)
	rustg_file_write(json_encode(tree), path)

/// Traverses the entire dir tree of the given savefile and dynamically assembles the tree from it
/datum/json_savefile/proc/import_byond_savefile(savefile/savefile)
	tree.Cut()
	var/list/dirs_to_go = list("/" = tree)
	while(length(dirs_to_go))
		var/dir = dirs_to_go[1]
		var/list/region = dirs_to_go[dir]
		dirs_to_go.Cut(1, 2)
		savefile.cd = dir
		for(var/entry in savefile)
			var/entry_value
			savefile[entry] >> entry_value
			if(!isnull(entry_value))
				region[entry] = entry_value
			else
				region[entry] = list()
				dirs_to_go["[dir]/[entry]"] = region[entry]
