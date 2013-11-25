var/global/obj/effect/overlay/plmaster = null // atmospheric overlay for plasma
var/global/obj/effect/overlay/slmaster = null // atmospheric overlay for sleeping gas


// nanomanager, the manager for Nano UIs
var/datum/nanomanager/nanomanager = new()


	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0

