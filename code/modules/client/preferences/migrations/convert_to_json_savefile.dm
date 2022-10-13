/datum/preferences/proc/try_savefile_type_migration()
	load_path(parent.ckey, "preferences.sav") // old save file
	var/old_path = path
	load_path(parent.ckey)
	if(!fexists(old_path))
		return
	var/datum/json_savefile/json_savefile = new(path)
	json_savefile.import_byond_savefile(new /savefile(old_path))
	json_savefile.save()
	return TRUE
