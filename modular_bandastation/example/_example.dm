/datum/modpack/example
	/// A string name for the modpack. Used for looking up other modpacks in init.
	name = "Example modpack"
	/// A string desc for the modpack. Can be used for modpack verb list as description.
	desc = "its useless"
	/// A string with authors of this modpack.
	author = "furior"

/datum/modpack/example/pre_initialize()
	. = ..()

/datum/modpack/example/initialize()
	. = ..()

/datum/modpack/example/post_initialize()
	. = ..()
