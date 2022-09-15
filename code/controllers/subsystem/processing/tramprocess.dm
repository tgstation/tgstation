PROCESSING_SUBSYSTEM_DEF(tramprocess)
	name = "Tram Process"
	wait = 0.5
	/// only used on maps with trams, so only enabled by such.
	can_fire = FALSE

	///how much time a tram can take per movement before we notify admins and slow down the tram. in milliseconds
	var/max_time = 15

	///how many times the tram can move costing over max_time milliseconds before it gets slowed down
	var/max_exceeding_moves = 5

	///how many times the tram can move costing less than half max_time milliseconds before we speed it back up again.
	///is only used if the tram has been slowed down for exceeding max_time
	var/max_cheap_moves = 5
