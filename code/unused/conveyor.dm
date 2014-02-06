// converyor belt

// moves items/mobs/movables in set direction every ptick


/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor0"
	name = "conveyor belt"
	desc = "A conveyor belt."
	anchored = 1
	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/basedir			// this is the default (forward) direction, set by the map dir
						// note dir var can vary when the direction changes

	var/list/affecting	// the list of all items that will be moved this ptick
	var/id = ""			// the control ID	- must match controller ID
	// following two only used if a diverter is present
	var/divert = 0 		// if non-zero, direction to divert items
	var/divdir = 0		// if diverting, will be conveyer dir needed to divert (otherwise dense)



	// create a conveyor

/obj/machinery/conveyor/New()
	..()
	basedir = dir
	setdir()

	// set the dir and target turf depending on the operating direction

/obj/machinery/conveyor/proc/setdir()
	if(operating == -1)
		dir = turn(basedir,180)
	else
		dir = basedir
	update()


	// update the icon depending on the operating condition

/obj/machinery/conveyor/proc/update()
	if(stat & BROKEN)
		icon_state = "conveyor-b"
		operating = 0
		return
	if(!operable)
		operating = 0
	icon_state = "conveyor[(operating != 0) && !(stat & NOPOWER)]"


	// machine process
	// move items to the target location
/obj/machinery/conveyor/process()
	if(stat & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	use_power(100)

	var/movedir = dir	// base movement dir
	if(divert && dir==divdir)	// update if diverter present
		movedir = divert


	affecting = loc.contents - src		// moved items will be all in loc
	spawn(1)	// slight delay to prevent infinite propagation due to map order
		var/items_moved = 0
		for(var/atom/movable/A in affecting)
			if(!A.anchored)
				if(isturf(A.loc)) // this is to prevent an ugly bug that forces a player to drop what they're holding if they recently pick it up from the conveyer belt
					if(ismob(A))
						var/mob/M = A
						if(M.buckled == src)
							var/obj/machinery/conveyor/C = locate() in get_step(src, dir)
							M.buckled = null
							step(M,dir)
							if(C)
								M.buckled = C
							else
								new/obj/item/stack/cable_coil/cut(M.loc)
						else
							step(M,movedir)
					else
						step(A,movedir)
						items_moved++
			if(items_moved >= 10)
				break

// attack with item, place item on conveyor

/obj/machinery/conveyor/attackby(var/obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/grab))	// special handling if grabbing a mob
		var/obj/item/weapon/grab/G = I
		G.affecting.Move(src.loc)
		del(G)
		return
	else if(istype(I, /obj/item/stack/cable_coil))	// if cable, see if a mob is present
		var/mob/M = locate() in src.loc
		if(M)
			if (M == user)
				src.visible_message("\blue [M] ties \himself to the conveyor.")
				// note don't check for lying if self-tying
			else
				if(M.lying)
					user.visible_message("\blue [M] has been tied to the conveyor by [user].", "\blue You tie [M] to the converyor!")
				else
					user << "\blue [M] must be lying down to be tied to the converyor!"
					return
			M.buckled = src
			src.add_fingerprint(user)
			I:use(1)
			M.lying = 1
			return

			// else if no mob in loc, then allow coil to be placed

	else if(istype(I, /obj/item/weapon/wirecutters))
		var/mob/M = locate() in src.loc
		if(M && M.buckled == src)
			M.buckled = null
			src.add_fingerprint(user)
			if (M == user)
				src.visible_message("\blue [M] cuts \himself free from the conveyor.")
			else
				src.visible_message("\blue [M] had been cut free from the conveyor by [user].")
			return

	if(isrobot(user))
		return

	// otherwise drop and place on conveyor
	user.drop_item()
	if(I && I.loc)	I.loc = src.loc
	return

// attack with hand, move pulled object onto conveyor

/obj/machinery/conveyor/attack_hand(mob/user as mob)
	user.Move_Pulled(src)


// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	stat |= BROKEN
	update()

	var/obj/machinery/conveyor/C = locate() in get_step(src, basedir)
	if(C)
		C.set_operable(basedir, id, 0)

	C = locate() in get_step(src, turn(basedir,180))
	if(C)
		C.set_operable(turn(basedir,180), id, 0)


//set the operable var if ID matches, propagating in the given direction

/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)

	if(id != match_id)
		return
	operable = op

	update()
	var/obj/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
		C.set_operable(stepdir, id, op)

/*
/obj/machinery/conveyor/verb/destroy()
	set src in view()
	src.broken()
*/

/obj/machinery/conveyor/power_change()
	..()
	update()


// converyor diverter
// extendable arm that can be switched so items on the conveyer are diverted sideways
// situate in same turf as conveyor
// only works if belts is running proper direction
//
//
/obj/machinery/diverter
	icon = 'icons/obj/recycling.dmi'
	icon_state = "diverter0"
	name = "diverter"
	desc = "A diverter arm for a conveyor belt."
	anchored = 1
	layer = FLY_LAYER
	var/obj/machinery/conveyor/conv // the conveyor this diverter works on
	var/deployed = 0	// true if diverter arm is extended
	var/operating = 0	// true if arm is extending/contracting
	var/divert_to	// the dir that diverted items will be moved
	var/divert_from // the dir items must be moving to divert


// create a diverter
// set up divert_to and divert_from directions depending on dir state
/obj/machinery/diverter/New()

	..()

	switch(dir)
		if(NORTH)
			divert_to = WEST			// stuff will be moved to the west
			divert_from = NORTH			// if entering from the north
		if(SOUTH)
			divert_to = EAST
			divert_from = NORTH
		if(EAST)
			divert_to = EAST
			divert_from = SOUTH
		if(WEST)
			divert_to = WEST
			divert_from = SOUTH
		if(NORTHEAST)
			divert_to = NORTH
			divert_from = EAST
		if(NORTHWEST)
			divert_to = NORTH
			divert_from = WEST
		if(SOUTHEAST)
			divert_to = SOUTH
			divert_from = EAST
		if(SOUTHWEST)
			divert_to = SOUTH
			divert_from = WEST
	spawn(2)
		// wait for map load then find the conveyor in this turf
		conv = locate() in src.loc
		if(conv)	// divert_from dir must match possible conveyor movement
			if(conv.basedir != divert_from && conv.basedir != turn(divert_from,180) )
				del(src)	// if no dir match, then delete self
		set_divert()
		update()

// update the icon state depending on whether the diverter is extended
/obj/machinery/diverter/proc/update()
	icon_state = "diverter[deployed]"

// call to set the diversion vars of underlying conveyor
/obj/machinery/diverter/proc/set_divert()
	if(conv)
		if(deployed)
			conv.divert = divert_to
			conv.divdir = divert_from
		else
			conv.divert= 0


// *** TESTING click to toggle
/obj/machinery/diverter/Click()
	toggle()


// toggle between arm deployed and not deployed, showing animation
//
/obj/machinery/diverter/proc/toggle()
	if( stat & (NOPOWER|BROKEN))
		return

	if(operating)
		return

	use_power(50)
	operating = 1
	if(deployed)
		flick("diverter10",src)
		icon_state = "diverter0"
		sleep(10)
		deployed = 0
	else
		flick("diverter01",src)
		icon_state = "diverter1"
		sleep(10)
		deployed = 1
	operating = 0
	update()
	set_divert()

// don't allow movement into the 'backwards' direction if deployed
/obj/machinery/diverter/CanPass(atom/movable/O, var/turf/target)
	var/direct = get_dir(O, target)
	if(direct == divert_to)	// prevent movement through body of diverter
		return 0
	if(!deployed)
		return 1
	return(direct != turn(divert_from,180))

// don't allow movement through the arm if deployed
/obj/machinery/diverter/CheckExit(atom/movable/O, var/turf/target)
	var/direct = get_dir(O, target)
	if(direct == turn(divert_to,180))	// prevent movement through body of diverter
		return 0
	if(!deployed)
		return 1
	return(direct != divert_from)





// the conveyor control switch
//
//

/obj/machinery/conveyor_switch

	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
	var/operated = 1			// true if just operated

	var/id = "" 				// must match conveyor IDs to control them

	var/list/conveyors		// the list of converyors that are controlled by this switch
	anchored = 1



/obj/machinery/conveyor_switch/New()
	..()
	update()

	spawn(5)		// allow map load
		conveyors = list()
		for(var/obj/machinery/conveyor/C in world)
			if(C.id == id)
				conveyors += C

// update the icon depending on the position

/obj/machinery/conveyor_switch/proc/update()
	if(position<0)
		icon_state = "switch-rev"
	else if(position>0)
		icon_state = "switch-fwd"
	else
		icon_state = "switch-off"


// timed process
// if the switch changed, update the linked conveyors

/obj/machinery/conveyor_switch/process()
	if(!operated)
		return
	operated = 0

	for(var/obj/machinery/conveyor/C in conveyors)
		C.operating = position
		C.setdir()

// attack with hand, switch position
/obj/machinery/conveyor_switch/attack_hand(mob/user)
	if(position == 0)
		if(last_pos < 0)
			position = 1
			last_pos = 0
		else
			position = -1
			last_pos = 0
	else
		last_pos = position
		position = 0

	operated = 1
	update()

	// find any switches with same id as this one, and set their positions to match us
	for(var/obj/machinery/conveyor_switch/S in world)
		if(S.id == src.id)
			S.position = position
			S.update()
