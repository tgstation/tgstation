
/obj/machinery/power/PTL/proc/find_starting_turf()
	var/x_offset = laser_tile_x_offset(dir2text(dir))
	var/y_offset = laser_tile_y_offset(dir2text(dir))
	var/turf/T = get_turt(src)
	var/turf/starting = locate((T.x + x_offset), (T.y + y_offset), T.z)
	return starting

