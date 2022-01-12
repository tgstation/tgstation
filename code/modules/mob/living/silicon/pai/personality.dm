/*
		name
		key
		description
		role
		comments
		ready = 0
*/

/datum/pai_candidate/proc/savefile_path(mob/user)
	return "data/player_saves/[user.ckey[1]]/[user.ckey]/pai.sav"

/datum/pai_candidate/proc/savefile_save(mob/user)
	if(is_guest_key(user.key))
		to_chat(usr, span_warning("You cannot save pAI information as a guest."))
		return FALSE
	var/savefile/F = new /savefile(src.savefile_path(user))
	WRITE_FILE(F["name"], name)
	WRITE_FILE(F["description"], description)
	WRITE_FILE(F["comments"], comments)
	WRITE_FILE(F["version"], 1)
	to_chat(usr, span_boldnotice("You have saved pAI information locally."))
	return TRUE

// loads the savefile corresponding to the mob's ckey
// if silent=true, report incompatible savefiles
// returns 1 if loaded (or file was incompatible)
// returns 0 if savefile did not exist

/datum/pai_candidate/proc/savefile_load(mob/user, silent = TRUE)
	if (is_guest_key(user.key))
		return 0

	var/path = savefile_path(user)

	if (!fexists(path))
		return 0

	var/savefile/F = new /savefile(path)

	if(!F)
		return //Not everyone has a pai savefile.

	var/version = null
	F["version"] >> version

	if (isnull(version) || version != 1)
		fdel(path)
		if (!silent)
			tgui_alert(user, "Your savefile was incompatible with this version and was deleted.")
		return 0

	F["name"] >> src.name
	F["description"] >> src.description
	F["comments"] >> src.comments
	return 1
