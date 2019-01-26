PROCESSING_SUBSYSTEM_DEF(round_modifiers)
	name = "Round Modifiers"
	init_order = INIT_ORDER_ROUND_MODIFIERS
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME

	var/list/active_modifiers = list()
