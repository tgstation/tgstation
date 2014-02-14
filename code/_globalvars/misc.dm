var/global/obj/effect/overlay/plmaster = null // atmospheric overlay for plasma
var/global/obj/effect/overlay/slmaster = null // atmospheric overlay for sleeping gas
var/admin_notice = "" // Admin notice that all clients see when joining the server


// nanomanager, the manager for Nano UIs
var/datum/nanomanager/nanomanager = new()

var/timezoneOffset = 0 // The difference betwen midnight (of the host computer) and 0 world.ticks.

	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0

