/*CONTENTS
Buildable pipes
Buildable meters
*/
#define PIPE_SIMPLE_STRAIGHT	0
#define PIPE_SIMPLE_BENT		1
#define PIPE_HE_STRAIGHT		2
#define PIPE_HE_BENT			3
#define PIPE_CONNECTOR			4
#define PIPE_MANIFOLD			5
#define PIPE_JUNCTION			6
#define PIPE_UVENT				7
#define PIPE_MVALVE				8
#define PIPE_PUMP				9
#define PIPE_SCRUBBER			10
#define PIPE_INSULATED_STRAIGHT	11
#define PIPE_INSULATED_BENT		12
#define PIPE_GAS_FILTER			13
#define PIPE_GAS_MIXER			14
#define PIPE_PASSIVE_GATE       15
#define PIPE_VOLUME_PUMP        16
#define PIPE_HEAT_EXCHANGE      17

/obj/item/pipe
	name = "pipe"
	desc = "A pipe"
	var/pipe_type = 0
	//var/pipe_dir = 0
	var/pipename
	force = 7
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	flags = TABLEPASS|FPRINT
	w_class = 3
	level = 2

/obj/item/pipe/New(var/loc, var/pipe_type as num, var/dir as num, var/obj/machinery/atmospherics/make_from = null)
	..()
	if (make_from)
		src.dir = make_from.dir
		src.pipename = make_from.name
		var/is_bent
		if  (make_from.initialize_directions in list(NORTH|SOUTH, WEST|EAST))
			is_bent = 0
		else
			is_bent = 1
		if     (istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction))
			src.pipe_type = PIPE_JUNCTION
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
			src.pipe_type = PIPE_HE_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple/insulated))
			src.pipe_type = PIPE_INSULATED_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/simple))
			src.pipe_type = PIPE_SIMPLE_STRAIGHT + is_bent
		else if(istype(make_from, /obj/machinery/atmospherics/portables_connector))
			src.pipe_type = PIPE_CONNECTOR
		else if(istype(make_from, /obj/machinery/atmospherics/pipe/manifold))
			src.pipe_type = PIPE_MANIFOLD
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_pump))
			src.pipe_type = PIPE_UVENT
		else if(istype(make_from, /obj/machinery/atmospherics/valve))
			src.pipe_type = PIPE_MVALVE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/pump))
			src.pipe_type = PIPE_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/filter))
			src.pipe_type = PIPE_GAS_FILTER
		else if(istype(make_from, /obj/machinery/atmospherics/trinary/mixer))
			src.pipe_type = PIPE_GAS_MIXER
		else if(istype(make_from, /obj/machinery/atmospherics/unary/vent_scrubber))
			src.pipe_type = PIPE_SCRUBBER
		else if(istype(make_from, /obj/machinery/atmospherics/binary/passive_gate))
			src.pipe_type = PIPE_PASSIVE_GATE
		else if(istype(make_from, /obj/machinery/atmospherics/binary/volume_pump))
			src.pipe_type = PIPE_VOLUME_PUMP
		else if(istype(make_from, /obj/machinery/atmospherics/unary/heat_exchanger))
			src.pipe_type = PIPE_HEAT_EXCHANGE
	else
		src.pipe_type = pipe_type
		src.dir = dir
	//src.pipe_dir = get_pipe_dir()
	update()
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

//update the name and icon of the pipe item depending on the type

/obj/item/pipe/proc/update()
	var/list/nlist = list( \
		"pipe", \
		"bent pipe", \
		"h/e pipe", \
		"bent h/e pipe", \
		"connector", \
		"manifold", \
		"junction", \
		"uvent", \
		"mvalve", \
		"pump", \
		"scrubber", \
		"insulated pipe", \
		"bent insulated pipe", \
		"gas filter", \
		"gas mixer", \
		"passive gate", \
		"volume pump", \
		"heat exchanger", \
	)
	name = nlist[pipe_type+1] + " fitting"
	var/list/islist = list( \
		"simple", \
		"simple", \
		"he", \
		"he", \
		"connector", \
		"manifold", \
		"junction", \
		"uvent", \
		"mvalve", \
		"pump", \
		"scrubber", \
		"insulated", \
		"insulated", \
		"filter", \
		"mixer", \
		"passivegate", \
		"volumepump", \
		"heunary", \
	)
	icon_state = islist[pipe_type + 1]

//called when a turf is attacked with a pipe item
// place the pipe on the turf, setting pipe level to 1 (underfloor) if the turf is not intact

// rotate the pipe item clockwise

/obj/item/pipe/verb/rotate()
	set category = "Object"
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() )
		return

	src.dir = turn(src.dir, -90)

	if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	//src.pipe_dir = get_pipe_dir()
	return

/obj/item/pipe/Move()
	..()
	if ((pipe_type in list (PIPE_SIMPLE_BENT, PIPE_HE_BENT, PIPE_INSULATED_BENT)) \
		&& (src.dir in cardinal))
		src.dir = src.dir|turn(src.dir, 90)
	else if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	return

// returns all pipe's endpoints

/obj/item/pipe/proc/get_pipe_dir()
	if (!dir)
		return 0
	var/flip = turn(dir, 180)
	var/cw = turn(dir, -90)
	var/acw = turn(dir, 90)

	switch(pipe_type)
		if(	PIPE_SIMPLE_STRAIGHT, \
			PIPE_INSULATED_STRAIGHT, \
			PIPE_HE_STRAIGHT, \
			PIPE_JUNCTION ,\
			PIPE_PUMP ,\
			PIPE_VOLUME_PUMP ,\
			PIPE_PASSIVE_GATE ,\
			PIPE_MVALVE \
		)
			return dir|flip
		if(PIPE_SIMPLE_BENT, PIPE_INSULATED_BENT, PIPE_HE_BENT)
			return dir //dir|acw
		if(PIPE_CONNECTOR,PIPE_UVENT,PIPE_SCRUBBER,PIPE_HEAT_EXCHANGE)
			return dir
		if(PIPE_MANIFOLD)
			return flip|cw|acw
		if(PIPE_GAS_FILTER, PIPE_GAS_MIXER)
			return dir|flip|cw
	return 0

/obj/item/pipe/proc/get_pdir() //endpoints for regular pipes

	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)
//	var/acw = turn(dir, 90)

	if (!(pipe_type in list(PIPE_HE_STRAIGHT, PIPE_HE_BENT, PIPE_JUNCTION)))
		return get_pipe_dir()
	switch(pipe_type)
		if(PIPE_HE_STRAIGHT,PIPE_HE_BENT)
			return 0
		if(PIPE_JUNCTION)
			return flip
	return 0

// return the h_dir (heat-exchange pipes) from the type and the dir

/obj/item/pipe/proc/get_hdir() //endpoints for h/e pipes

//	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)

	switch(pipe_type)
		if(PIPE_HE_STRAIGHT)
			return get_pipe_dir()
		if(PIPE_HE_BENT)
			return get_pipe_dir()
		if(PIPE_JUNCTION)
			return dir
		else
			return 0

/obj/item/pipe/attack_self(mob/user as mob)
	return rotate()

/obj/item/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	..()
	//*
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if (!isturf(src.loc))
		return 1
	if (pipe_type in list (PIPE_SIMPLE_STRAIGHT, PIPE_HE_STRAIGHT, PIPE_INSULATED_STRAIGHT, PIPE_MVALVE))
		if(dir==2)
			dir = 1
		else if(dir==8)
			dir = 4
	var/pipe_dir = get_pipe_dir()

	for(var/obj/machinery/atmospherics/M in src.loc)
		if(M.initialize_directions & pipe_dir)	// matches at least one direction on either type of pipe
			user << "\red There is already a pipe at that location."
			return 1
	// no conflicts found

	var/pipefailtext = "\red There's nothing to connect this pipe section to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"

	switch(pipe_type)
		if(PIPE_SIMPLE_STRAIGHT, PIPE_SIMPLE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/P = new( src.loc )
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

		if(PIPE_HE_STRAIGHT, PIPE_HE_BENT)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/P = new ( src.loc )
			P.dir = src.dir
			P.initialize_directions = 0
			P.initialize_directions_he = pipe_dir
			//var/turf/T = P.loc
			//P.level = T.intact ? 2 : 1
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

		if(PIPE_CONNECTOR)		// connector
			var/obj/machinery/atmospherics/portables_connector/C = new( src.loc )
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
			var/obj/machinery/atmospherics/pipe/manifold/M = new( src.loc )
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

		if(PIPE_JUNCTION)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/P = new ( src.loc )
			P.dir = src.dir
			P.initialize_directions = src.get_pdir()
			P.initialize_directions_he = src.get_hdir()
			//var/turf/T = P.loc
			//P.level = T.intact ? 2 : 1
			P.initialize()
			if (!P)
				usr << "There's nothing to connect this junction to! (with how the pipe code works, at least one end needs to be connected to something, otherwise the game deletes the segment)"
				return 1
			P.build_network()
			if (P.node1)
				P.node1.initialize()
				P.node1.build_network()
			if (P.node2)
				P.node2.initialize()
				P.node2.build_network()

		if(PIPE_UVENT)		//unary vent
			var/obj/machinery/atmospherics/unary/vent_pump/V = new( src.loc )
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


		if(PIPE_MVALVE)		//manual valve
			var/obj/machinery/atmospherics/valve/V = new( src.loc)
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
			var/obj/machinery/atmospherics/binary/pump/P = new(src.loc)
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

		if(PIPE_GAS_FILTER)		//gas filter
			var/obj/machinery/atmospherics/trinary/filter/P = new(src.loc)
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

		if(PIPE_GAS_MIXER)		//gas filter
			var/obj/machinery/atmospherics/trinary/mixer/P = new(src.loc)
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

		if(PIPE_SCRUBBER)		//scrubber
			var/obj/machinery/atmospherics/unary/vent_scrubber/S = new(src.loc)
			S.dir = dir
			S.initialize_directions = pipe_dir
			if (pipename)
				S.name = pipename
			var/turf/T = S.loc
			S.level = T.intact ? 2 : 1
			S.initialize()
			S.build_network()
			if (S.node)
				S.node.initialize()
				S.node.build_network()

		if(PIPE_INSULATED_STRAIGHT, PIPE_INSULATED_BENT)
			var/obj/machinery/atmospherics/pipe/simple/insulated/P = new( src.loc )
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

		if(PIPE_PASSIVE_GATE)		//passive gate
			var/obj/machinery/atmospherics/binary/passive_gate/P = new(src.loc)
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

		if(PIPE_VOLUME_PUMP)		//volume pump
			var/obj/machinery/atmospherics/binary/volume_pump/P = new(src.loc)
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

		if(PIPE_HEAT_EXCHANGE)		// heat exchanger
			var/obj/machinery/atmospherics/unary/heat_exchanger/C = new( src.loc )
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

	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user.visible_message( \
		"[user] fastens the [src].", \
		"\blue You have fastened the [src].", \
		"You hear ratchet.")
	del(src)	// remove the pipe item

	return
	 //TODO: DEFERRED

// ensure that setterm() is called for a newly connected pipeline



/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes"
	icon = 'icons/obj/pipe-item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	flags = TABLEPASS|FPRINT
	w_class = 4

/obj/item/pipe_meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	..()

	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	if(!locate(/obj/machinery/atmospherics/pipe, src.loc))
		user << "\red You need to fasten it to a pipe"
		return 1
	new/obj/machinery/meter( src.loc )
	playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
	user << "\blue You have fastened the meter to the pipe"
	del(src)

#undef PIPE_SIMPLE_STRAIGHT
#undef PIPE_SIMPLE_BENT
#undef PIPE_HE_STRAIGHT
#undef PIPE_HE_BENT
#undef PIPE_CONNECTOR
#undef PIPE_MANIFOLD
#undef PIPE_JUNCTION
#undef PIPE_UVENT
#undef PIPE_MVALVE
#undef PIPE_PUMP
#undef PIPE_SCRUBBER
#undef PIPE_INSULATED_STRAIGHT
#undef PIPE_INSULATED_BENT
#undef PIPE_GAS_FILTER
#undef PIPE_GAS_MIXER
#undef PIPE_PASSIVE_GATE
#undef PIPE_VOLUME_PUMP
#undef PIPE_OUTLET_INJECT