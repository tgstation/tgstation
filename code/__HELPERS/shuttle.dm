/// Helper proc that tests to ensure all whiteship templates can spawn at their docking port, and logs their sizes
/// This should be a unit test, but too much of our other code breaks during shuttle movement, so not yet, not yet.
/proc/test_whiteship_sizes()
	var/obj/docking_port/stationary/port_type = /obj/docking_port/stationary/picked/whiteship
	var/datum/turf_reservation/docking_yard = SSmapping.request_turf_block_reservation(
		initial(port_type.width),
		initial(port_type.height),
		1,
	)
	var/turf/bottom_left = docking_yard.bottom_left_turfs[1]
	var/turf/spawnpoint = locate(
		bottom_left.x + initial(port_type.dwidth),
		bottom_left.y + initial(port_type.dheight),
		bottom_left.z,
	)

	var/obj/docking_port/stationary/picked/whiteship/port = new(spawnpoint)
	var/list/ids = port.shuttlekeys
	var/height = 0
	var/width = 0
	var/dheight = 0
	var/dwidth = 0
	var/delta_height = 0
	var/delta_width = 0
	for(var/id in ids)
		var/datum/map_template/shuttle/our_template = SSmapping.shuttle_templates[id]
		// We do a standard load here so any errors will properly runtimes
		var/obj/docking_port/mobile/ship = SSshuttle.action_load(our_template, port)
		if(ship)
			ship.jumpToNullSpace()
			ship = null
		// Yes this is very hacky, but we need to both allow loading a template that's too big to be an error state
		// And actually get the sizing information from every shuttle
		SSshuttle.load_template(our_template)
		var/obj/docking_port/mobile/theoretical_ship = SSshuttle.preview_shuttle
		if(theoretical_ship)
			height = max(theoretical_ship.height, height)
			width = max(theoretical_ship.width, width)
			dheight = max(theoretical_ship.dheight, dheight)
			dwidth = max(theoretical_ship.dwidth, dwidth)
			delta_height = max(theoretical_ship.height - theoretical_ship.dheight, delta_height)
			delta_width = max(theoretical_ship.width - theoretical_ship.dwidth, delta_width)
			theoretical_ship.jumpToNullSpace()
	qdel(port, TRUE)
	log_world("Whiteship sizing information. Use this to set the docking port, and the map size\n\
		Max Height: [height] \n\
		Max Width: [width] \n\
		Max DHeight: [dheight] \n\
		Max DWidth: [dwidth] \n\
		The following are the safest bet for map sizing. Anything smaller then this could in the worst case not fit in the docking port\n\
		Max Combined Width: [height + dheight] \n\
		Max Combinded Height [width + dwidth]")
