var/admin_notice = "" // Admin notice that all clients see when joining the server

var/timezoneOffset = 0 // The difference betwen midnight (of the host computer) and 0 world.ticks.

	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0

var/TAB = "&nbsp;&nbsp;&nbsp;&nbsp;"



var/map_ready = 0
/*
	basically, this will be used to avoid initialize() being called twice for objects
	initialize() is necessary because the map is instanced on a turf-by-turf basis
	i.e. all obj on a turf are instanced, then all mobs on that turf, before moving to the next turf (starting bottom-left)
	This means if we want to say, get any neighbouring objects in New(), only objects to the south and west will exist yet.
	Therefore, we'd need to use spawn() inside New() to wait for the surrounding turf contents to be instanced
	However, using lots of spawn() has a severe performance impact, and often results in spaghetti-code
	map_ready will be set to 1 when world/New() is called (which happens just after the map is instanced)
*/