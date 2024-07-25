PROCESSING_SUBSYSTEM_DEF(fastprocess)
	name = "Fast Processing"
	wait = 0.2 SECONDS
	stat_tag = "FP"

PROCESSING_SUBSYSTEM_DEF(actualfastprocess)
	name = "Actual Fast Processing"
	wait = 0.1 SECONDS
	priority = FIRE_PRIORITY_TICKER
	stat_tag = "AFP"

PROCESSING_SUBSYSTEM_DEF(pathogen_processing)
	name = "Pathogen Cloud Processing"
	wait = 1 SECONDS
	stat_tag = "PC"
