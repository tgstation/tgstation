PROCESSING_SUBSYSTEM_DEF(priority_process)
	name = "High Priority Processing"
	priority = FIRE_PRIORITY_HIGHPROCESS
	wait = 1
	stat_tag = "HPP"
	flags = SS_TICKER|SS_KEEP_TIMING|SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
