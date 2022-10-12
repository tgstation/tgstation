/datum/preferences/proc/try_savefile_type_migration()
	load_path(parent.ckey, "preferences.sav") // old save file
	var/old_path = path
	load_path(parent.ckey)
	if(!fexists(old_path))
		return
	var/json_savefile/jsf = new(path)
	jsf.Import(new /savefile(old_path))
	jsf.Save()
	return TRUE
