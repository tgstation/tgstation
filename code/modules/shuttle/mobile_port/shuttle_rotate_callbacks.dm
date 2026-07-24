/*
All shuttleRotate procs go here

If ever any of these procs are useful for non-shuttles, rename it to proc/rotate and move it to be a generic atom proc
*/

/************************************Base proc************************************/

/atom/proc/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH|ROTATE_OFFSET)
	if(params & ROTATE_DIR)
		//rotate our direction
		setDir(angle2dir(rotation+dir2angle(dir)))

	//resmooth if need be.
	if(params & ROTATE_SMOOTH && smoothing_flags & USES_SMOOTHING)
		QUEUE_SMOOTH(src)

	//rotate the pixel offsets too.
	if((pixel_x || pixel_y) && (params & ROTATE_OFFSET))
		if(rotation < 0)
			rotation += 360
		for(var/turntimes=rotation/90;turntimes>0;turntimes--)
			var/oldPX = pixel_x
			var/oldPY = pixel_y
			pixel_x = oldPY
			pixel_y = (oldPX*(-1))

/************************************Base /atom/movable proc************************************/

/atom/movable/shuttleRotate(rotation, params)
	. = ..()
	// Dont shift things that have non-zero bound_x and bound_y.
	if(((bound_height != ICON_SIZE_Y) || (bound_width != ICON_SIZE_X)) && (bound_x == 0) && (bound_y == 0))
		if(rotation < 0)
			rotation += 360
		switch(rotation) // Move the atom such that its one "actual" loc is always its bottom left corner.
			if(90)
				y -= (bound_height - ICON_SIZE_Y) / ICON_SIZE_Y
			if(180)
				y -= (bound_height - ICON_SIZE_Y) / ICON_SIZE_Y
				x -= (bound_width - ICON_SIZE_X) / ICON_SIZE_X
			if(270)
				x -= (bound_width - ICON_SIZE_X) / ICON_SIZE_X

/************************************Turf rotate procs************************************/

/turf/closed/mineral/shuttleRotate(rotation, params)
	params &= ~ROTATE_OFFSET
	return ..()

/************************************Mob rotate procs************************************/

//override to avoid rotating pixel_xy on mobs
/mob/shuttleRotate(rotation, params)
	params = NONE
	. = ..()
	if(!buckled)
		setDir(angle2dir(rotation+dir2angle(dir)))

/mob/dead/observer/shuttleRotate(rotation, params)
	. = ..()
	update_appearance()

/************************************Structure rotate procs************************************/

//Fixes dpdir on shuttle rotation
/obj/structure/disposalpipe/shuttleRotate(rotation, params)
	. = ..()
	var/new_dpdir = 0
	for(var/D in GLOB.cardinals)
		if(dpdir & D)
			new_dpdir = new_dpdir | angle2dir(rotation+dir2angle(D))
	dpdir = new_dpdir

/obj/structure/table/wood/shuttle_bar/shuttleRotate(rotation, params)
	. = ..()
	boot_dir = angle2dir(rotation + dir2angle(boot_dir))

/obj/structure/alien/weeds/shuttleRotate(rotation, params)
	params &= ~ROTATE_OFFSET
	return ..()

/************************************Machine rotate procs************************************/

/obj/machinery/atmospherics/shuttleRotate(rotation, params)
	var/list/real_node_connect = get_node_connects()
	for(var/i in 1 to device_type)
		var/node_dir = real_node_connect[i]
		if(isnull(node_dir))
			continue

		real_node_connect[i] = turn(node_dir, -rotation)

	. = ..()
	set_init_directions()
	var/list/supposed_node_connect = get_node_connects()
	var/list/nodes_copy = nodes.Copy()

	for(var/i in 1 to device_type)
		var/node_dir = real_node_connect[i]
		if(isnull(node_dir))
			continue

		var/new_pos = supposed_node_connect.Find(node_dir)
		nodes[new_pos] = nodes_copy[i]

//prevents shuttles attempting to rotate this since it messes up sprites
/obj/machinery/gateway/shuttleRotate(rotation, params)
	params = NONE
	return ..()

/obj/machinery/door/airlock/shuttleRotate(rotation, params)
	. = ..()
	if(cyclelinkeddir && (params & ROTATE_DIR))
		cyclelinkeddir = angle2dir(rotation+dir2angle(cyclelinkeddir))
		// If we update the linked airlock here, the partner airlock might
		// not be present yet, so don't do that. Just assume we're still
		// partnered with the same airlock as before.

/obj/machinery/porta_turret/shuttleRotate(rotation, params)
	. = ..()
	if(wall_turret_direction && (params & ROTATE_DIR))
		wall_turret_direction = turn(wall_turret_direction,rotation)
