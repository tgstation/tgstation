// For modular plugins.
//  Mostly used to initialize the plugins in a timely manner.
/plugin
	var/name=""
	var/desc=""
	var/version=""

/plugin/proc/on_world_loaded()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/plugin/proc/on_world_loaded() called tick#: [world.time]")
	// Do init stuff here
