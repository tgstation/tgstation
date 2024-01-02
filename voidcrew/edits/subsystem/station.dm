/**
 * We early return this to prevent station traits from rolling
 * This is because it adds inconsistencies we don't want, or at worst it breaks things (such as overflow).
 */
/datum/controller/subsystem/processing/station/SetupTraits()
	return
