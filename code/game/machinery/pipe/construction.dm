/*CONTENTS
Buildable pipes
Buildable meters
*/

/obj/item/weapon/pipe
	name = "pipe"
	desc = "A pipe"
	var/pipe_type = 0
	var/pipe_dir = 0
	icon = 'pipe-item.dmi'
	icon_state = "straight"
	item_state = "buildpipe"
	flags = TABLEPASS|FPRINT
	w_class = 4
	level = 2

/obj/item/weapon/pipe/New()
	..()
	update()

//update the name and icon of the pipe item depending on the type

/obj/item/weapon/pipe/proc/update()
	var/list/nlist = list("pipe", "bent pipe", "h/e pipe", "bent h/e pipe", "connector", "manifold", "junction", "vent", "valve", "pump", "filter")
	name = nlist[pipe_type+1] + " fitting"
	updateicon()

//update the icon of the item

/obj/item/weapon/pipe/proc/updateicon()

	var/list/islist = list("straight", "bend", "he-straight", "he-bend", "connector", "manifold", "junction", "vent", "valve", "pump", "filter")

	icon_state = islist[pipe_type + 1]

	if(invisibility)				// true if placed under floor
		icon -= rgb(0,0,0,128)		// fade the icon
	else
		icon = initial(icon)		// otherwise reset to inital icon

// called to hide or unhide a pipe
// i=true if hiding

/obj/item/weapon/pipe/hide(var/i)

	invisibility = i ? 101 : 0		// make hidden pipe items invisible
	updateicon()


//called when a turf is attacked with a pipe item
// place the pipe on the turf, setting pipe level to 1 (underfloor) if the turf is not intact

// rotate the pipe item clockwise

/obj/item/weapon/pipe/verb/rotate()
	set name = "Rotate Pipe"
	set src in view(1)

	if ( usr.stat || usr.restrained() )
		return

	switch(pipe_type)
		if(0)
			if(icon_state == "straight")
				pipe_dir = 12
				icon_state = "straight12"
			else if (icon_state == "straight12")
				pipe_dir = 3
				icon_state = "straight"
		if(1)
			if(icon_state == "bend9")
				icon_state = "bend"
				pipe_dir = 10
			else if(icon_state == "bend")
				icon_state = "bend6"
				pipe_dir = 6
			else if(icon_state == "bend6")
				icon_state = "bend5"
				pipe_dir = 5
			else if(icon_state == "bend5")
				icon_state = "bend9"
				pipe_dir = 9

		if(2)
			if(icon_state == "he-straight")
				icon_state = "he-straight12"
				pipe_dir = 12
			else if(icon_state == "he-straight12")
				icon_state = "he-straight"
				pipe_dir = 3

		if(3)
			if(icon_state == "he-bend")
				icon_state = "he-bend9"
				pipe_dir = 9
			else if(icon_state == "he-bend6")
				icon_state = "he-bend"
				pipe_dir = 10
			else if(icon_state == "he-bend5")
				icon_state = "he-bend6"
				pipe_dir = 6
			else if(icon_state == "he-bend9")
				icon_state = "he-bend5"
				pipe_dir = 5

		if(4,7,5,6,7,8,9,10)
			src.dir = turn(src.dir, -90)
	return

// returns the p_dir from the pipe item type and dir

/obj/item/weapon/pipe/proc/get_pdir()

	var/flip = turn(dir, 180)
	var/cw = turn(dir, -90)
	var/acw = turn(dir, 90)

	switch(pipe_type)
		if(0)
			if(pipe_dir == 0)
				pipe_dir = 3
			return pipe_dir
		if(1)
			if(pipe_dir == 0)
				pipe_dir = 10
			return pipe_dir
		if(2,3)
			return 0
		if(4,7,10)
			return dir
		if(5)
			return dir|cw|acw
		if(6)
			return flip
	return 0

// return the h_dir (heat-exchange pipes) from the type and the dir

/obj/item/weapon/pipe/proc/get_hdir()

//	var/flip = turn(dir, 180)
//	var/cw = turn(dir, -90)

	switch(pipe_type)
		if(0,1,4,5,7,10)
			return 0
		if(2)
			if(pipe_dir == 0)
				pipe_dir = 3
			return pipe_dir
		if(3)
			if(pipe_dir == 0)
				pipe_dir = 10
			return pipe_dir
		if(6)
			return dir

	return 0

/obj/item/weapon/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	/*
	if (istype(W, /obj/item/weapon/wrench))

		var/pipedir = src.get_pdir()|src.get_hdir()		// all possible pipe dirs including h/e#

		for(var/obj/machinery/M in src.loc)
			if(M.level == src.level)		// only on same level
				if( (M.p_dir & pipedir) || (M.h_dir & pipedir) )	// matches at least one direction on either type of pipe
					user << "There is already a pipe at that location."
					return
		playsound(src.loc, 'Ratchet.ogg', 50, 1)

		// no conflicts found

		// 0	  1			   2			3				4			  5			 6			7		 8		  9		  10
		//"pipe", "bent pipe", "h/e pipe", "bent h/e pipe", "connector", "manifold", "junction", "vent", "valve", "pump", "filter inlet"

		var/obj/machinery/pipes/P

		switch(pipe_type)
			if(0,1)		// straight or bent pipe
				P = new/obj/machinery/pipes( src.loc )
				P.p_dir = get_pdir()
				P.icon_state = get_pdir()
				P.level = level
				P.update()

				var/list/dirs = P.get_dirs()

				P.node1 = get_machine(P.level, P.loc, dirs[1])
				P.node2 = get_machine(P.level, P.loc, dirs[2])

			if(2,3)		// straight or bent h/e pipe
				P = new/obj/machinery/pipes/heat_exch( src.loc )
				P.h_dir = get_hdir()
				P.icon_state = get_hdir()
				P.level = 2
				P.update()

				var/list/dirs = P.get_dirs()

				P.node1 = get_he_machine(P.level, P.loc, dirs[1])
				P.node2 = get_he_machine(P.level, P.loc, dirs[2])

			if(4)		// connector
				var/obj/machinery/connector/C = new( src.loc )
				C.dir = src.dir
				C.p_dir = src.dir
				C.level = level

				C.buildnodes()

				setlineterm(C.node, C.vnode)


			if(5)		//manifold
				var/obj/machinery/manifold/M = new( src.loc )
				M.dir = dir
				M.p_dir = pipedir
				M.level = level
				M.buildnodes()
				setlineterm(M.node1, M.vnode1)
				setlineterm(M.node2, M.vnode2)
				setlineterm(M.node3, M.vnode3)

			if(6)		//junctions
				var/obj/machinery/junction/J = new( src.loc )
				J.dir = dir
				J.p_dir = src.get_pdir()
				J.h_dir = src.get_hdir()
				J.level = 2

				J.buildnodes()
				setlineterm(J.node1, J.vnode1)
				setlineterm(J.node2, J.vnode2)

			if(7)		// vent
				var/obj/machinery/vent/V = new( src.loc )
				V.dir = src.dir
				V.p_dir = src.dir
				V.level = level

				V.buildnodes()

				setlineterm(V.node, V.vnode)

			if(8)		//valve
				var/obj/machinery/valve/mvalve/V = new( src.loc)
				V.dir = src.dir
				switch(dir)
					if(1, 2)
						V.p_dir = 3
					if(4,8)
						V.p_dir = 12
				V.buildnodes()
				setlineterm(V.node1, V.vnode1)
				setlineterm(V.node2, V.vnode2)

			if(9)		//Pipe pump
				var/obj/machinery/oneway/pipepump/PP = new(src.loc)

				PP.dir = src.dir
				PP.p_dir = dir|turn(dir, 180)

				PP.buildnodes()

				setlineterm(PP.node1, PP.vnode1)
				setlineterm(PP.node2, PP.vnode2)

			if(10)		//filter inlet
				var/obj/machinery/inlet/filter/F = new(src.loc)
				F.dir = src.dir
				F.p_dir = src.dir
				F.level = level

				F.buildnodes()

				setlineterm(F.node, F.vnode)

		// for pipe objects, now do updating of pipelines if needed
		switch(pipe_type)
			if(0,1,2,3)		// new regular or or h/e pipe

				// number of pipes connected to P
				var/pipecon =  (P.node1 && P.node1.ispipe()) + (P.node2 && P.node2.ispipe())

				if(Debug) world << "Pipecon [pipecon]"

				if(!pipecon)		// simplest case - no connection pipes (but may be machines)
					var/obj/machinery/pipeline/PL = new()	// create a new pipeline
					P.buildnodes(++linenums)				// set new pipe to use new pl
					P.pl = PL
					P.plnum = linenums
					PL.linenumber = linenums		// set new pipe to use new pl
					PL.nodes += P					// and add it
					PL.numnodes = 1
					PL.capmult = 2
					plines += PL					// and new pipeline to the global list
					PL.setterm()					// and ensure any connections to machines are made
					PL.name = "pipeline #[plines.Find(PL)]"		// set the name

				else if(pipecon == 1)		// single connected pipe

					var/obj/machinery/pipes/CP		// the connected pipe

					if(P.node1 && P.node1.ispipe())	// find the connected pipe
						CP = P.node1
					else
						CP = P.node2

					var/obj/machinery/pipeline/PL = CP.pl	// the pipeline we connected to
					P.pl = PL

					P.buildnodes(PL.linenumber)			// set the pipeline and nodes of any adjoining pipes

					if(PL.nodes[1] == CP)		// if the connected pipe is at start of line nodes list
						PL.nodes.Insert(1, P)	// insert new pipe into start of node list
					else
						PL.nodes += P			// otherwise, insert it at end
					PL.numnodes++
					PL.capmult++
					PL.setterm()				// connect to any machines

					CP.termination = 0			// connected pipe no longer terminal

				else //(pipecon==2)

					var/obj/machinery/pipes/CP1 = P.node1
					var/obj/machinery/pipes/CP2 = P.node2

					var/obj/machinery/pipeline/PL1 = CP1.pl
					var/obj/machinery/pipeline/PL2 = CP2.pl

					P.pl = PL1

					if(PL1 == PL2)		// special case - completing a loop
						// make sure to check if this works properly
						P.buildnodes(PL1.linenumber)

						PL1.nodes += P
						PL1.numnodes++
						PL1.capmult++
						PL1.setterm()

						CP1.termination = 0
						CP2.termination = 0

						PL1.vnode1 = PL1		// link pipeline to self
						PL1.vnode2 = PL1

					else		// separate pipelines

						P.buildnodes(PL1.linenumber)

						CP1.termination = 0
						CP2.termination = 0

						var/list/plist
						if(PL1.nodes[1] == CP1)
							plist = pipelist(null, PL1.nodes[PL1.nodes.len])
						else
							plist = pipelist(null, PL1.nodes[1])

						PL1.gas.transfer_from(PL2.gas, -1)
						PL1.ngas.transfer_from(PL2.ngas, -1)

						plines -= PL2
						for(var/obj/machinery/pipes/OP in PL2.nodes)
							OP.pl = PL1
							OP.plnum = PL1.linenumber
						PL1.nodes = plist
						PL1.numnodes = plist.len
						PL1.capmult = plist.len+1


						PL1.setterm()

						del(PL2)


		user << "You have fastened the pipe"
		del(src)	// remove the pipe item

	return
	*/ //TODO: DEFERRED

// ensure that setterm() is called for a newly connected pipeline

/proc/setlineterm(var/obj/machinery/node, var/obj/machinery/vnode)

	if(vnode)
		if( istype(vnode, /obj/machinery/pipeline) )


			var/obj/machinery/pipeline/PL = vnode
			node.buildnodes(PL.linenumber)
			PL.setterm()
		else
			node.buildnodes()



/obj/item/weapon/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes"
	icon = 'pipe-item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	flags = TABLEPASS|FPRINT
	w_class = 4

/obj/item/weapon/pipe_meter/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)

	if (istype(W, /obj/item/weapon/wrench))
		if(locate(/obj/machinery/pipes, src.loc))
			new/obj/machinery/meter( src.loc )
			playsound(src.loc, 'Ratchet.ogg', 50, 1)
			user << "You have fastened the meter to the pipe"
			del(src)
		else
			user << "You need to fasten it to a pipe"
	return

/obj/item/weapon/filter_control
	name = "filter control"
	desc = "A switch to control filter inlets"
	icon = 'pipe-item.dmi'
	icon_state = "filter_control"
	item_state = "buildpipe"
	flags = TABLEPASS|FPRINT
	w_class = 4
	var/control = null

/obj/item/weapon/filter_control/verb/set_control()
	set src in usr
	src.control = input("Enter the name of the control?.", "Control", "")

/obj/item/weapon/filter_control/proc/wall_place(turf/simulated/F, mob/user)

	if(!isturf(user.loc))
		return

	if(get_dist(F,user) > 1)
		user << "You can't place the control on from this distance."
		return

	else
		var/dirn

		if(user.loc != F)
			dirn = get_dir(F, user)
		else
			user << "Cannot place the filter control like this"

		if(locate(/obj/machinery, F))
			user << "There's already a piece of machinery in this position."
			return

		var/obj/machinery/filter_control/FC = new(src.loc)

		switch(dirn)
			if(NORTH)
				FC.pixel_y = 22
			if(SOUTH)
				FC.pixel_y = -22
			if(EAST)
				FC.pixel_x = 22
			if(WEST)
				FC.pixel_x = -22
			if(NORTHEAST)
				FC.pixel_y = 22
				FC.pixel_x = 22
			if(NORTHWEST)
				FC.pixel_y = 22
				FC.pixel_x = -22
			if(SOUTHEAST)
				FC.pixel_y = -22
				FC.pixel_x = 22
			if(SOUTHWEST)
				FC.pixel_y = -22
				FC.pixel_x = -22
			else
				world << "Invalid direction [dirn], [src.x], [src.y], [src.z]. Please report this."

		FC.control = src.control
		FC.add_fingerprint(user)
		FC.updateicon()
		del(src)