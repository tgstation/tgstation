//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//note that corner pieces transfer stuff clockwise when running forward, and anti-clockwise backwards.
//cael - added fix for diverters, not sure if tg has them

/obj/machinery/conveyor
	icon = 'recycling.dmi'
	icon_state = "conveyor0"
	name = "conveyor belt"
	desc = "A conveyor belt."
	anchored = 1
	layer = 2.97
	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/forwards		// this is the default (forward) direction, set by the map dir, can be 0
	var/backwards		// hopefully self-explanatory, can be 0
	var/movedir			// the actual direction to move stuff in

	var/list/affecting	// the list of all items that will be moved this ptick
	var/id = ""			// the control ID	- must match controller ID

	//these ones below for backwards compatibility

	// following two only used if a diverter is present
	var/divert_from = 0 		// if non-zero, direction to divert items
	var/divert_to = 0			// if diverting, will be conveyer dir needed to divert (otherwise dense)
	var/basedir					// this is the default (forward) direction, set by the map dir
								// note dir var can vary when the direction changes

	//cael - corner icon bug that needs a manual fix
	//note: for now, the sprites/anis and their directions are mostly independant from the actual conveyor move directions
	//if no conveyor move directions are specified, they are calculated from the sprite dir
	var/reverseSpriteMoveDir = 0

	// create a conveyor
/obj/machinery/conveyor/New()
	..()
	//added these to allow for custom conveyor dirs defined in map
	if(!forwards)
		switch(dir)
			if(NORTH)
				forwards = NORTH
			if(SOUTH)
				forwards = SOUTH
			if(EAST)
				forwards = EAST
			if(WEST)
				forwards = WEST
			if(NORTHEAST)
				forwards = EAST
			if(NORTHWEST)
				forwards = WEST
			if(SOUTHEAST)
				forwards = EAST
			if(SOUTHWEST)
				forwards = WEST
	if(!backwards)
		switch(dir)
			if(NORTH)
				backwards = SOUTH
			if(SOUTH)
				backwards = NORTH
			if(EAST)
				backwards = WEST
			if(WEST)
				backwards = EAST
			if(NORTHEAST)
				backwards = SOUTH
			if(NORTHWEST)
				backwards = SOUTH
			if(SOUTHEAST)
				backwards = NORTH
			if(SOUTHWEST)
				backwards = NORTH
	if(operating > 0)
		movedir = forwards
	else if(operating < 0)
		movedir = backwards

/obj/machinery/conveyor/proc/setmove()
	if(operating > 0)
		movedir = forwards
	else if(operating < 0)
		movedir = backwards
	update()

/obj/machinery/conveyor/proc/update()
	if(stat & BROKEN)
		icon_state = "conveyor-broken"
		operating = 0
		return
	if(!operable)
		operating = 0
	if(stat & NOPOWER)
		operating = 0
	icon_state = "conveyor[operating * (reverseSpriteMoveDir?-1:1)]"

	// machine process
	// move items to the target location
/obj/machinery/conveyor/process()
	if(stat & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	use_power(100)

	// update if diverter present
	// if movedir == forwards, therefore if divert_to != 0 and divert_from == backwards, then set movedir = divert_to
	// if movedir == backwards, therefore if divert_to != 0 and divert_from == forwards, then set movedir = divert_to
	//if(divert_to && divert_from == (movedir == backwards ? forwards : backwards ) )
		//movedir = divert_to
	if(divert_to)
		if( movedir == forwards && divert_from == backwards )
			movedir = divert_to
		else if( movedir == backwards && divert_from == forwards )
			movedir = divert_to

	affecting = loc.contents - src		// moved items will be all in loc
	spawn(1)	// slight delay to prevent infinite propagation due to map order
		for(var/atom/movable/A in affecting)
			if(!A.anchored)
				if(isturf(A.loc)) // this is to prevent an ugly bug that forces a player to drop what they're holding if they recently pick it up from the conveyer belt
					if(!step(A,movedir))
						//if it's a crate, move the item into the crate
						var/turf/T = get_step(A,movedir)
						for(var/obj/structure/closet/crate/C in T)
							if(C && C.opened && !istype(A, /obj/structure/closet/crate))
								A.loc = C.loc
								break

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(var/obj/item/I, mob/user)
	if(isrobot(user))	return //Carn: fix for borgs dropping their modules on conveyor belts
	user.drop_item()
	if(I && I.loc)	I.loc = src.loc
	return

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user as mob)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.pulling = null
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.pulling = null
	return


// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	stat |= BROKEN
	update()

	var/obj/machinery/conveyor/C = locate() in get_step(src, dir)
	if(C)
		C.set_operable(dir, id, 0)

	C = locate() in get_step(src, turn(dir,180))
	if(C)
		C.set_operable(turn(dir,180), id, 0)


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

// the conveyor control switch
//
//

/obj/machinery/conveyor_switch

	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'recycling.dmi'
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
		C.setmove()

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

/obj/machinery/conveyor_switch/oneway
	var/convdir = 1 //Set to 1 or -1 depending on which way you want the convayor to go. (In other words keep at 1 and set the proper dir on the belts.)
	desc = "A conveyor control switch. It appears to only go in one direction."

// attack with hand, switch position
/obj/machinery/conveyor_switch/oneway/attack_hand(mob/user)
	if(position == 0)
		position = convdir
	else
		position = 0

	operated = 1
	update()

	// find any switches with same id as this one, and set their positions to match us
	for(var/obj/machinery/conveyor_switch/S in world)
		if(S.id == src.id)
			S.position = position
			S.update()

// converyor diverter
// extendable arm that can be switched so items on the conveyer are diverted sideways
// situate in same turf as conveyor
// only works if belts is running proper direction
//
//
/obj/machinery/diverter
	icon = 'recycling.dmi'
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
	//cael - the icon states are all derped, so these won't make sense.
	//just place the diverter according to which icon state is correct
	switch(dir)
		if(NORTH)
			divert_to = WEST//
			divert_from = SOUTH//
		if(SOUTH)
			divert_to = EAST//
			divert_from = SOUTH//NORTH
		if(EAST)
			divert_to = EAST//
			divert_from = NORTH//SOUTH
		if(WEST)
			divert_to = WEST//
			divert_from = NORTH//
		if(NORTHEAST)
			divert_to = NORTH//
			divert_from = WEST//EAST
		if(NORTHWEST)
			divert_to = NORTH//
			divert_from = EAST//WEST
		if(SOUTHEAST)
			divert_to = SOUTH//
			divert_from = WEST//EAST
		if(SOUTHWEST)
			divert_to = SOUTH//
			divert_from = EAST//WEST
	spawn(2)
		// wait for map load then find the conveyor in this turf
		conv = locate() in src.loc
		if(conv)	// divert_from dir must match possible conveyor movement
			if(conv.backwards != divert_from && conv.backwards != turn(divert_from,180) )
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
			conv.divert_to = divert_to
			conv.divert_from = divert_from
		else
			conv.divert_to = 0
			conv.divert_from = 0
		conv.setmove()


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
	return(direct != divert_from)

// don't allow movement through the arm if deployed
/obj/machinery/diverter/CheckExit(atom/movable/O, var/turf/target)
	var/direct = get_dir(O, target)
	if(direct == turn(divert_to,180))	// prevent movement through body of diverter
		return 0
	if(!deployed)
		return 1
	return(direct != turn(divert_from,180))

	//divert_to = NORTH
	//divert_from = EAST