/// Really fast ticking subsystem for ticking /datum/component/movable_physics instances
PROCESSING_SUBSYSTEM_DEF(movable_physics)
	name = "Movable Physics"
	priority = FIRE_PRIORITY_MOVABLE_PHYSICS
	wait = 0.05 SECONDS
	stat_tag = "MPhys"
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
