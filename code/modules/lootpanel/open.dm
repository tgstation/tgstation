
/// Helper to open the panel
/datum/lootpanel/proc/open(turf/tile)
	source_turf = tile

#ifndef OPENDREAM
	var/build = owner.byond_build
	var/version = owner.byond_version
	if(!notified)
		if(build < 515 || (build == 515 && version < 1635))
			to_chat(owner.mob, examine_block(span_info("\
				<span class='bolddanger'>Your version of Byond doesn't support fast image loading.</span>\n\
				Detected: [version].[build]\n\
				Required version for this feature: <b>515.1635</b> or later.\n\
				Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.\n\
			")))

			notified = TRUE
#endif

	populate_contents()
	ui_interact(owner.mob)
