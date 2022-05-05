PROCESSING_SUBSYSTEM_DEF(tramprocess)
	name = "Tram Process"
	wait = 0.5
	/// only used on maps with trams, so only enabled by such.
	can_fire = FALSE

	///how much time a tram can take per movement before we notify admins and slow down the tram. in milliseconds
	var/max_time = 10
