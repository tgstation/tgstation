/*
All shuttleRotate procs go here

If ever any of these procs are useful for non-shuttles, rename it to proc/rotate and move it to be a generic atom proc
*/

/************************************Base proc************************************/

/atom/proc/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH|ROTATE_OFFSET)
	SendSignal(COMSIG_ATOM_ROTATE, rotation, params)
	
	if(params & ROTATE_DIR)
		//rotate our direction
		setDir(angle2dir(rotation+dir2angle(dir)))

	//resmooth if need be.
	if(smooth && params & ROTATE_SMOOTH)
		queue_smooth(src)

	//rotate the pixel offsets too.
	if((pixel_x || pixel_y) && params & ROTATE_OFFSET)
		if(rotation < 0)
			rotation += 360
		for(var/turntimes=rotation/90;turntimes>0;turntimes--)
			var/oldPX = pixel_x
			var/oldPY = pixel_y
			pixel_x = oldPY
			pixel_y = (oldPX*(-1))

/************************************Turf rotate procs************************************/

/turf/closed/mineral/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH)
	return ..()

/************************************Mob rotate procs************************************/

//override to avoid rotating pixel_xy on mobs
/mob/shuttleRotate(rotation, params=NONE)
	. = ..()
	if(!buckled)
		setDir(angle2dir(rotation+dir2angle(dir)))

/mob/dead/observer/shuttleRotate(rotation, params=NONE)
	. = ..()
	update_icon()

/************************************Structure rotate procs************************************/

/obj/structure/door_assembly/door_assembly_pod/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH|ROTATE_OFFSET)
	. = ..()
	expected_dir = angle2dir(rotation+dir2angle(dir))

/obj/structure/cable/shuttleRotate(rotation, params=ROTATE_SMOOTH|ROTATE_OFFSET)
	. = ..()
	if(d1)
		d1 = angle2dir(rotation+dir2angle(d1))
	if(d2)
		d2 = angle2dir(rotation+dir2angle(d2))

	//d1 should be less than d2 for cable icons to work
	if(d1 > d2)
		var/temp = d1
		d1 = d2
		d2 = temp
	update_icon()

//Fixes dpdir on shuttle rotation
/obj/structure/disposalpipe/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH|ROTATE_OFFSET)
	. = ..()
	var/new_dpdir = 0
	for(var/D in GLOB.cardinals)
		if(dpdir & D)
			new_dpdir = new_dpdir | angle2dir(rotation+dir2angle(D))
	dpdir = new_dpdir

/obj/structure/table/wood/bar/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH|ROTATE_OFFSET)
	. = ..()
	boot_dir = angle2dir(rotation + dir2angle(boot_dir))

/obj/structure/alien/weeds/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH)
	return ..()

/************************************Machine rotate procs************************************/

/obj/machinery/atmospherics/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH|ROTATE_OFFSET)
	var/list/real_node_connect = getNodeConnects()
	for(DEVICE_TYPE_LOOP)
		real_node_connect[I] = angle2dir(rotation+dir2angle(real_node_connect[I]))

	. = ..()
	SetInitDirections()
	var/list/supposed_node_connect = getNodeConnects()
	var/list/nodes_copy = nodes.Copy()

	for(DEVICE_TYPE_LOOP)
		var/new_pos = supposed_node_connect.Find(real_node_connect[I])
		nodes[new_pos] = nodes_copy[I]

//prevents shuttles attempting to rotate this since it messes up sprites
/obj/machinery/gateway/shuttleRotate(rotation, params=NONE)
	return ..()

/obj/machinery/door/airlock/survival_pod/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH|ROTATE_OFFSET)
	expected_dir = angle2dir(rotation+dir2angle(dir))
	return ..()

//prevents shuttles attempting to rotate this since it messes up sprites
/obj/machinery/gravity_generator/shuttleRotate(rotation, params=NONE)
	return ..()