PROCESSING_SUBSYSTEM_DEF(priority_effects)
	name = "Priority Status Effects"
	flags = SS_KEEP_TIMING | SS_NO_INIT
	wait = 0.2 SECONDS // Same as SSfastprocess, but can be anything, assuming you refactor all high-priority status effect intervals and durations to be a multiple of it.
	priority = FIRE_PRIORITY_PRIORITY_EFFECTS
	stat_tag = "PEFF"
