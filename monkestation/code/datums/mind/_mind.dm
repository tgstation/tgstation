/datum/mind
	/// The crew manifest entry for this crew member, if any.
	var/datum/record/crew/crewfile
	/// The locked manifest entry for this crew member, if any.
	var/datum/record/locked/lockfile

/datum/mind/proc/add_to_manifest(crew = TRUE, locked = FALSE)
	if(crew && !QDELETED(crewfile))
		GLOB.manifest.general |= crewfile
	if(locked && !QDELETED(lockfile))
		GLOB.manifest.locked |= lockfile

/datum/mind/proc/remove_from_manifest(crew = TRUE, locked = FALSE)
	if(crew && !QDELETED(crewfile))
		GLOB.manifest.general -= crewfile
	if(locked && !QDELETED(lockfile))
		GLOB.manifest.locked -= lockfile
