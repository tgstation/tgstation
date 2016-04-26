// For modular plugins.
//  Mostly used to initialize the plugins in a timely manner.
/plugin
	var/name=""
	var/desc=""
	var/version=""

/plugin/proc/on_world_loaded()
	// Do init stuff here
