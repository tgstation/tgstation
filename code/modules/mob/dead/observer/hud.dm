/obj/hud/proc/ghost_hud()
	src.station_explosion = new src.h_type( src )
	src.station_explosion.icon = 'station_explosion.dmi'
	src.station_explosion.icon_state = "start"
	src.station_explosion.layer = 20
	src.station_explosion.mouse_opacity = 0
	src.station_explosion.screen_loc = "1,3"
	return