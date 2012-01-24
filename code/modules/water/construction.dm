/obj/machinery/pipedispenser/water
	name = "Water Pipe Dispenser"

/obj/machinery/pipedispenser/water/attack_hand(user as mob)
	if(..())
		return

	var/dat = {"
<b>Regular pipes:</b><BR>
<A href='?src=\ref[src];wmake=0;dir=1'>Pipe</A><BR>
<A href='?src=\ref[src];wmake=1;dir=5'>Bent Pipe</A><BR>
<A href='?src=\ref[src];wmake=3;dir=1'>Manifold</A><BR>
<A href='?src=\ref[src];wmake=5;dir=1'>Manual Valve</A><BR>
<b>Devices:</b><BR>
<A href='?src=\ref[src];wmake=2;dir=1'>Beaker Connection</A><BR>
<A href='?src=\ref[src];wmake=9;dir=1'>Portables Connection</A><BR>
<A href='?src=\ref[src];wmake=6;dir=1'>Water Pump</A><BR>
<A href='?src=\ref[src];wmakemeter=1'>Water Meter</A><BR>
<A href='?src=\ref[src];wmake=8;dir=1'>Water Filter</A><BR>
<A href='?src=\ref[src];wmake=7;dir=1'>Fixture Connection</A><BR>
<A href='?src=\ref[src];wmake=4;dir=1'>Sprinkler</A><BR>
"}

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return

/obj/machinery/pipedispenser/water/Topic(href, href_list)
	if(..())
		return
	if(unwrenched)
		usr << browse(null, "window=pipedispenser")
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["wmake"])
		if(!wait)
			var/p_type = text2num(href_list["wmake"])
			var/p_dir = text2num(href_list["dir"])
			var/obj/item/water_pipe/P = new (/*usr.loc*/ src.loc, pipe_type=p_type, dir=p_dir)
			P.update()
			wait = 1
			spawn(10)
				wait = 0
	if(href_list["makemeter"])
		if(!wait)
			new /obj/item/water_pipe_meter(/*usr.loc*/ src.loc)
			wait = 1
			spawn(15)
				wait = 0
	return

#define PIPE_SIMPLE_STRAIGHT	0
#define PIPE_SIMPLE_BENT		1
#define PIPE_GLASS_CONNECTOR	2
#define PIPE_MANIFOLD			3
#define PIPE_SPRINKLER			4
#define PIPE_MVALVE				5
#define PIPE_PUMP				6
#define PIPE_FIXTURE			7
#define PIPE_FILTER				8
#define PIPE_CONNECTOR			9

/obj/item/water_pipe
	name = "water pipe"
	desc = "A pipe"
	var/pipe_type = 0
	//var/pipe_dir = 0
	var/pipename
	icon = 'water_pipe_item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	flags = TABLEPASS|FPRINT
	w_class = 4
	level = 2

/obj/item/water_pipe/New(var/loc, var/pipe_type as num, var/dir as num, var/obj/machinery/water/make_from = null)
	..()
	if (make_from)
		src.dir = make_from.dir
		src.pipename = make_from.name
		var/is_bent
		if  (make_from.initialize_directions in list(NORTH|SOUTH, WEST|EAST))
			is_bent = 0
		else
			is_bent = 1

		if(istype(make_from, /obj/machinery/water/pipe/simple))
			src.pipe_type = PIPE_SIMPLE_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/water/glass_connector))
			src.pipe_type = PIPE_GLASS_CONNECTOR
		else if(istype(make_from, /obj/machinery/water/portables_connector))
			src.pipe_type = PIPE_CONNECTOR
		else if(istype(make_from, /obj/machinery/water/pipe/manifold))
			src.pipe_type = PIPE_MANIFOLD
		else if(istype(make_from, /obj/machinery/water/unary/sprinkler))
			src.pipe_type = PIPE_SPRINKLER
		else if(istype(make_from, /obj/machinery/water/valve))
			src.pipe_type = PIPE_MVALVE
		else if(istype(make_from, /obj/machinery/water/binary/pump))
			src.pipe_type = PIPE_PUMP
		else if(istype(make_from, /obj/machinery/water/binary/fixture))
			src.pipe_type = PIPE_FIXTURE
		else if(istype(make_from, /obj/machinery/water/trinary/filter))
			src.pipe_type = PIPE_FILTER
	else
		src.pipe_type = pipe_type
		src.dir = dir
	//src.pipe_dir = get_pipe_dir()
	update()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

//update the name and icon of the pipe item depending on the type

/obj/item/water_pipe/proc/update()
	var/list/nlist = list( \
		"pipe", \
		"bent pipe", \
		"glass connector", \
		"manifold", \
		"sprinkler", \
		"mvalve", \
		"pump", \
		"fixture connection", \
		"liquid filter", \
		"connector", \
	)
	name = nlist[pipe_type+1] + " fitting"
	var/list/islist = list( \
		"simple", \
		"simple", \
		"gconnector", \
		"manifold", \
		"sprinkler", \
		"mvalve", \
		"pump", \
		"fixture", \
		"filter", \
		"connector", \
	)
	icon_state = islist[pipe_type + 1]

//called when a turf is attacked with a pipe item
// place the pipe on the turf, setting pipe level to 1 (underfloor) if the turf is not intact

// rotate the pipe item clockwise

/obj/item/water_pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() )
		return

	src.dir = turn(src.dir, -90)

	if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_MVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	//src.pipe_dir = get_pipe_dir()
	return

/obj/item/water_pipe/Move()
	..()
	if ((pipe_type in list (PIPE_SIMPLE_BENT)) \
		&& (src.dir in cardinal))
		src.dir = src.dir|turn(src.dir, 90)
	else if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_MVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	return

// returns all pipe's endpoints

/obj/item/water_pipe/proc/get_pipe_dir()
	if (!dir)
		return 0
	var/flip = turn(dir, 180)
	var/cw = turn(dir, -90)
	var/acw = turn(dir, 90)

	switch(pipe_type)
		if(	PIPE_SIMPLE_STRAIGHT, \
			PIPE_PUMP ,\
			PIPE_MVALVE, \
			PIPE_FIXTURE \
		)
			return dir|flip
		if(PIPE_SIMPLE_BENT)
			return dir //dir|acw
		if(PIPE_GLASS_CONNECTOR, PIPE_CONNECTOR, PIPE_SPRINKLER)
			return dir
		if(PIPE_MANIFOLD)
			return flip|cw|acw
		if(PIPE_FILTER)
			return dir|flip|cw
	return 0

/obj/item/water_pipe/proc/get_pdir() //endpoints for regular pipes
	return get_pipe_dir()

/obj/item/water_pipe/attack_self(mob/user as mob)
	return rotate()

/obj/item/water_pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	..()
	//*
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!isturf(src.loc))
		return 1
	if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_MVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	var/pipe_dir = get_pipe_dir()

	for(var/obj/machinery/water/M in src.loc)
		if(M.initialize_directions & pipe_dir)	// matches at least one direction on either type of pipe
			user << "\red There is already a pipe at that location."
			return 1
	// no conflicts found

	var/pipefailtext = "\red There's nothing to connect this pipe section to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"

	switch(pipe_type)
		if(PIPE_SIMPLE_STRAIGHT, PIPE_SIMPLE_BENT)
			var/obj/machinery/water/pipe/simple/P = new( src.loc )
			P.dir = src.dir
			P.initialize_directions = pipe_dir
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			if (!P)
				usr << pipefailtext
				return 1
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()

		if(PIPE_GLASS_CONNECTOR)		// glass connector
			var/obj/machinery/water/glass_connector/C = new( src.loc )
			C.dir = dir
			C.initialize_directions = pipe_dir
			if (pipename)
				C.name = pipename
			C.initialize()
			C.build_network()
			if (C.node)
				C.node.initialize()
				C.node.build_network()

		if(PIPE_CONNECTOR)		// portables connector
			var/obj/machinery/water/portables_connector/C = new( src.loc )
			C.dir = dir
			C.initialize_directions = pipe_dir
			if (pipename)
				C.name = pipename
			var/turf/T = C.loc
			C.level = T.intact ? 2 : 1
			C.initialize()
			C.build_network()
			if (C.node)
				C.node.initialize()
				C.node.build_network()


		if(PIPE_MANIFOLD)		//manifold
			var/obj/machinery/water/pipe/manifold/M = new( src.loc )
			M.dir = dir
			M.initialize_directions = pipe_dir
			//M.New()
			var/turf/T = M.loc
			M.level = T.intact ? 2 : 1
			M.initialize()
			if (!M)
				usr << "There's nothing to connect this manifold to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"
				return 1
			M.build_network()
			if (M.node1)
				M.node1.initialize()
				M.node1.build_network()
			if (M.node2)
				M.node2.initialize()
				M.node2.build_network()
			if (M.node3)
				M.node3.initialize()
				M.node3.build_network()

		if(PIPE_SPRINKLER)		//sprinkler
			var/obj/machinery/water/unary/sprinkler/V = new( src.loc )
			V.dir = dir
			V.initialize_directions = pipe_dir
			if (pipename)
				V.name = pipename
			var/turf/T = V.loc
			V.level = T.intact ? 2 : 1
			V.initialize()
			V.build_network()
			if (V.node)
				V.node.initialize()
				V.node.build_network()

		if(PIPE_FIXTURE)		//fixture connection
			var/obj/machinery/water/binary/fixture/V = new( src.loc )
			V.dir = dir
			V.initialize_directions = pipe_dir
			if (pipename)
				V.name = pipename
			var/turf/T = V.loc
			V.level = T.intact ? 2 : 1
			V.initialize()
			V.build_network()
			if (V.node1)
				V.node1.initialize()
				V.node1.build_network()
			if (V.node2)
				V.node2.initialize()
				V.node2.build_network()


		if(PIPE_MVALVE)		//manual valve
			var/obj/machinery/water/valve/V = new( src.loc)
			V.dir = dir
			V.initialize_directions = pipe_dir
			if (pipename)
				V.name = pipename
			var/turf/T = V.loc
			V.level = T.intact ? 2 : 1
			V.initialize()
			V.build_network()
			if (V.node1)
//					world << "[V.node1.name] is connected to valve, forcing it to update its nodes."
				V.node1.initialize()
				V.node1.build_network()
			if (V.node2)
//					world << "[V.node2.name] is connected to valve, forcing it to update its nodes."
				V.node2.initialize()
				V.node2.build_network()

		if(PIPE_PUMP)		//gas pump
			var/obj/machinery/water/binary/pump/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()

		if(PIPE_FILTER)		//liquid filter
			var/obj/machinery/water/trinary/filter/P = new(src.loc)
			P.dir = dir
			P.initialize_directions = pipe_dir
			if (pipename)
				P.name = pipename
			var/turf/T = P.loc
			P.level = T.intact ? 2 : 1
			P.initialize()
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()
			if (P.node3)
				P.node3.initialize()
				P.node3.build_network()

	playsound(src.loc, 'Ratchet.ogg', 50, 1)
	user.visible_message( \
		"[user] fastens the [src].", \
		"\blue You have fastened the [src].", \
		"You hear ratchet.")
	del(src)	// remove the pipe item

	return
	 //TODO: DEFERRED

// ensure that setterm() is called for a newly connected pipeline



/obj/item/water_pipe_meter
	name = "water meter"
	desc = "A meter that can be laid on water pipes"
	icon = 'water_pipe_item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	flags = TABLEPASS|FPRINT
	w_class = 4

/obj/item/water_pipe_meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	..()

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(!locate(/obj/machinery/water/pipe, src.loc))
		user << "\red You need to fasten it to a pipe"
		return 1
	new/obj/machinery/water_meter( src.loc )
	playsound(src.loc, 'Ratchet.ogg', 50, 1)
	user << "\blue You have fastened the meter to the pipe"
	del(src)

#undef PIPE_SIMPLE_STRAIGHT
#undef PIPE_SIMPLE_BENT
#undef PIPE_GLASS_CONNECTOR
#undef PIPE_MANIFOLD
#undef PIPE_SPRINKLER
#undef PIPE_MVALVE
#undef PIPE_PUMP
#undef PIPE_FIXTURE
#undef PIPE_FILTER
#undef PIPE_CONNECTOR