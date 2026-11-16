PROCESSING_SUBSYSTEM_DEF(timed_actions)
	name = "Timed Actions"
	priority = FIRE_PRIORITY_TIMED_ACTIONS
	ss_flags = SS_TICKER|SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 1
