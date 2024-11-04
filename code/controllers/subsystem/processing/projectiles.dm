PROCESSING_SUBSYSTEM_DEF(projectiles)
	name = "Projectiles"
	wait = 1
	stat_tag = "PP"
	flags = SS_NO_INIT|SS_TICKER
	// 5 tiles, in case of overrun
	var/max_pixels_per_tick = ICON_SIZE_ALL * 5
	var/pixels_per_decisecond = 16
