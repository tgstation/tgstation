//Fires five times every second.

#define SSFASTPROCESS_DT 0.2

PROCESSING_SUBSYSTEM_DEF(fastprocess)
	name = "Fast Processing"
	wait = SSFASTPROCESS_DT SECONDS
	stat_tag = "FP"
