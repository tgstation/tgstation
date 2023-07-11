PROCESSING_SUBSYSTEM_DEF(icts_transport)
	name = "ICTS"
	wait = 0.5
	/// only used on maps with trams, so only enabled by such.
	can_fire = FALSE

	///associative list of the form: list(lift_id = list(all lift_master datums attached to lifts of that type))
	var/list/transports_by_type
	var/list/nav_beacons
	///how much time a tram can take per movement before we notify admins and slow down the tram. in milliseconds
	var/max_time = 15
	///how many times the tram can move costing over max_time milliseconds before it gets slowed down
	var/max_exceeding_moves = 5
	///how many times the tram can move costing less than half max_time milliseconds before we speed it back up again.
	///is only used if the tram has been slowed down for exceeding max_time
	var/max_cheap_moves = 5
