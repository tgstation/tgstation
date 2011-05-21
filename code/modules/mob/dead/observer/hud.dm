/obj/hud/proc/ghost_hud()
	station_explosion = new h_type( src )
	station_explosion.icon = 'station_explosion.dmi'
	station_explosion.icon_state = "start"
	station_explosion.layer = 20
	station_explosion.mouse_opacity = 0
	station_explosion.screen_loc = "1,3"
	return