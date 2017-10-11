/*
All shuttleRotate procs go here

If ever any of these procs are useful for non-shuttles, rename it to proc/rotate and move it to be a generic atom proc
*/

/************************************Base proc************************************/

/atom/proc/shuttleRotate(rotation)
	//rotate our direction
	setDir(angle2dir(rotation+dir2angle(dir)))

	//resmooth if need be.
	if(smooth)
		queue_smooth(src)

	//rotate the pixel offsets too.
	if (pixel_x || pixel_y)
		if (rotation < 0)
			rotation += 360
		for (var/turntimes=rotation/90;turntimes>0;turntimes--)
			var/oldPX = pixel_x
			var/oldPY = pixel_y
			pixel_x = oldPY
			pixel_y = (oldPX*(-1))

/************************************Turf rotate procs************************************/

/turf/closed/mineral/shuttleRotate(rotation)
	setDir(angle2dir(rotation+dir2angle(dir)))
	queue_smooth(src)

/************************************Mob rotate procs************************************/

//override to avoid rotating pixel_xy on mobs
/mob/shuttleRotate(rotation)
	if(!buckled)
		setDir(angle2dir(rotation+dir2angle(dir)))

/mob/dead/observer/shuttleRotate(rotation)
	. = ..()
	update_icon()

/************************************Structure rotate procs************************************/

/obj/structure/door_assembly/door_assembly_pod/shuttleRotate(rotation)
	. = ..()
	expected_dir = angle2dir(rotation+dir2angle(dir))

/obj/structure/cable/shuttleRotate(rotation)
	//..() is not called because wires are not supposed to have a non-default direction
	//Rotate connections
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
/obj/structure/disposalpipe/shuttleRotate(rotation)
	. = ..()
	var/new_dpdir = 0
	for(var/D in GLOB.cardinals)
		if(dpdir & D)
			new_dpdir = new_dpdir | angle2dir(rotation+dir2angle(D))
	dpdir = new_dpdir

/obj/structure/table/wood/bar/shuttleRotate(rotation)
	. = ..()
	boot_dir = angle2dir(rotation + dir2angle(boot_dir))

/obj/structure/alien/weeds/shuttleRotate(rotation)
	return

/************************************Machine rotate procs************************************/

/obj/machinery/atmospherics/shuttleRotate(rotation)
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
/obj/machinery/gateway/shuttleRotate()
	return

/obj/machinery/door/airlock/survival_pod/shuttleRotate(rotation)
	expected_dir = angle2dir(rotation+dir2angle(dir))
	return ..()

//prevents shuttles attempting to rotate this since it messes up sprites
/obj/machinery/gravity_generator/shuttleRotate()
	return