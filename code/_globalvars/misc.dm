var/admin_notice = "" // Admin notice that all clients see when joining the server

var/timezoneOffset = 0 // The difference betwen midnight (of the host computer) and 0 world.ticks.

	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0

var/TAB = "&nbsp;&nbsp;&nbsp;&nbsp;"