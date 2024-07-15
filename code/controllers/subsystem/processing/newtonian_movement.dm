/// The subsystem is intended to tick things related to space/newtonian movement, such as constant sources of inertia
PROCESSING_SUBSYSTEM_DEF(newtonian_movement)
	name = "Newtonian Movement"
	flags = SS_NO_INIT|SS_BACKGROUND
	wait = 0.1 SECONDS
