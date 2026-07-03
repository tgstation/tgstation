/datum/modpack
	/// A string name for the modpack. Used for looking up other modpacks in init.
	var/name
	/// A string desc for the modpack. Can be used for modpack verb list as description.
	var/desc
	/// A string with authors of this modpack.
	var/author

/datum/modpack/proc/pre_initialize()
	if(!name)
		return "Modpack name is unset."

/datum/modpack/proc/initialize()
	return

/datum/modpack/proc/post_initialize()
	return
