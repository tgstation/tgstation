
#define SSMOOD_DT 1

PROCESSING_SUBSYSTEM_DEF(mood)
	name = "Mood"
	flags = SS_NO_INIT | SS_BACKGROUND
	priority = 20
	wait = SSMOOD_DT SECONDS
