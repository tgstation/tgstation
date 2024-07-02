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
	if(params & ROTATE_SMOOTH && smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
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
	//rotate the physical bounds and offsets for multitile atoms too. Owerride base "rotate the pixel offsets" for multitile atoms.
	//Owerride non zero bound_x, bound_y, pixel_x, pixel_y to zero.
	//Dont take in account starting bound_x, bound_y, pixel_x, pixel_y.
	//So it can unintentionally shift physical bounds of things that starts with non zero bound_x, bound_y.
	if(((bound_height != world.icon_size) || (bound_width != world.icon_size)) && (bound_x == 0) && (bound_y == 0)) //Dont shift things that have non zero bound_x and bound_y, or it move somewhere. Now it BSA and Gateway.
		pixel_x = dir & (NORTH|EAST) ? -bound_width+world.icon_size : 0
		pixel_y = dir & (NORTH|WEST) ? -bound_width+world.icon_size : 0
		bound_x = pixel_x
		bound_y = pixel_y

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
		real_node_connect[i] = angle2dir(rotation+dir2angle(real_node_connect[i]))

	. = ..()
	set_init_directions()
	var/list/supposed_node_connect = get_node_connects()
	var/list/nodes_copy = nodes.Copy()

	for(var/i in 1 to device_type)
		var/new_pos = supposed_node_connect.Find(real_node_connect[i])
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
