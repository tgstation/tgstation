
#define SSOBJ_DT 2

PROCESSING_SUBSYSTEM_DEF(obj)
	name = "Objects"
	priority = FIRE_PRIORITY_OBJ
	flags = SS_NO_INIT
	wait = SSOBJ_DT SECONDS
