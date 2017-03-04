//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//note that corner pieces transfer stuff clockwise when running forward, and anti-clockwise backwards.

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor0"
	name = "conveyor belt"
	desc = "A conveyor belt."
	anchored = 1
	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/forwards		// this is the default (forward) direction, set by the map dir
	var/backwards		// hopefully self-explanatory
	var/movedir			// the actual direction to move stuff in

	var/list/affecting	// the list of all items that will be moved this ptick
	var/id = ""			// the control ID	- must match controller ID
	var/verted = 1		// set to -1 to have the conveyour belt be inverted, so you can use the other corner icons
	speed_process = 1

/obj/machinery/conveyor/centcom_auto
	id = "round_end_belt"


// Auto conveyour is always on unless unpowered

/obj/machinery/conveyor/auto/New(loc, newdir)
	..(loc, newdir)
	operating = 1
	update_move_direction()

/obj/machinery/conveyor/auto/update()
	if(stat & BROKEN)
		icon_state = "conveyor-broken"
		operating = 0
		return
	else if(!operable)
		operating = 0
	else if(stat & NOPOWER)
		operating = 0
	else
		operating = 1
	icon_state = "conveyor[operating * verted]"

// create a conveyor
/obj/machinery/conveyor/New(loc, newdir)
	..(loc)
	if(newdir)
		setDir(newdir)
	update_move_direction()

/obj/machinery/conveyor/proc/update_move_direction()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = EAST
			backwards = SOUTH
		if(NORTHWEST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHEAST)
			forwards = SOUTH
			backwards = WEST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH
	if(verted == -1)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(operating == 1)
		movedir = forwards
	else
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
	icon_state = "conveyor[operating * verted]"

	// machine process
	// move items to the target location
/obj/machinery/conveyor/process()
	if(stat & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	use_power(100)

	affecting = loc.contents - src		// moved items will be all in loc
	sleep(1)
	for(var/atom/movable/A in affecting)
		if(!A.anchored)
			if(A.loc == src.loc) // prevents the object from being affected if it's not currently here.
				step(A,movedir)
		CHECK_TICK

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		user.visible_message("<span class='notice'>[user] struggles to pry up \the [src] with \the [I].</span>", \
		"<span class='notice'>You struggle to pry up \the [src] with \the [I].</span>")
		if(do_after(user, 40*I.toolspeed, target = src))
			if(QDELETED(src))
				return //prevent multiple decontructs
			if(!(stat & BROKEN))
				var/obj/item/conveyor_construct/C = new/obj/item/conveyor_construct(src.loc)
				C.id = id
				transfer_fingerprints_to(C)
			user << "<span class='notice'>You remove the conveyor belt.</span>"
			qdel(src)

	else if(istype(I, /obj/item/weapon/wrench))
		if(!(stat & BROKEN))
			playsound(loc, I.usesound, 50, 1)
			setDir(turn(dir,-45))
			update_move_direction()
			user << "<span class='notice'>You rotate [src].</span>"

	else if(istype(I, /obj/item/weapon/screwdriver))
		if(!(stat & BROKEN))
			verted = verted * -1
			update_move_direction()
			user << "<span class='notice'>You reverse [src]'s direction.</span>"

	else if(user.a_intent != INTENT_HARM)
		if(user.drop_item())
			I.loc = src.loc
	else
		return ..()

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user)
	user.Move_Pulled(src)


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
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
	var/operated = 1			// true if just operated
	var/convdir = 0				// 0 is two way switch, 1 and -1 means one way

	var/id = "" 				// must match conveyor IDs to control them

	var/list/conveyors		// the list of converyors that are controlled by this switch
	anchored = 1
	speed_process = 1



/obj/machinery/conveyor_switch/New(newloc, newid)
	..(newloc)
	if(!id)
		id = newid
	update()

	spawn(5)		// allow map load
		conveyors = list()
		for(var/obj/machinery/conveyor/C in machines)
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
		C.update_move_direction()
		CHECK_TICK

// attack with hand, switch position
/obj/machinery/conveyor_switch/attack_hand(mob/user)
	add_fingerprint(user)
	if(position == 0)
		if(convdir)   //is it a oneway switch
			position = convdir
		else
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
	for(var/obj/machinery/conveyor_switch/S in machines)
		if(S.id == src.id)
			S.position = position
			S.update()
		CHECK_TICK

/obj/machinery/conveyor_switch/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		var/obj/item/conveyor_switch_construct/C = new/obj/item/conveyor_switch_construct(src.loc)
		C.id = id
		transfer_fingerprints_to(C)
		user << "<span class='notice'>You deattach the conveyor switch.</span>"
		qdel(src)

/obj/machinery/conveyor_switch/oneway
	convdir = 1 //Set to 1 or -1 depending on which way you want the convayor to go. (In other words keep at 1 and set the proper dir on the belts.)
	desc = "A conveyor control switch. It appears to only go in one direction."

//
// CONVEYOR CONSTRUCTION STARTS HERE
//

/obj/item/conveyor_construct
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor0"
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly."
	w_class = WEIGHT_CLASS_BULKY
	var/id = "" //inherited by the belt

/obj/item/conveyor_construct/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/conveyor_switch_construct))
		user << "<span class='notice'>You link the switch to the conveyor belt assembly.</span>"
		var/obj/item/conveyor_switch_construct/C = I
		id = C.id

/obj/item/conveyor_construct/afterattack(atom/A, mob/user, proximity)
	if(!proximity || user.stat || !isfloorturf(A) || istype(A, /area/shuttle))
		return
	var/cdir = get_dir(A, user)
	if(A == user.loc)
		user << "<span class='notice'>You cannot place a conveyor belt under yourself.</span>"
		return
	var/obj/machinery/conveyor/C = new/obj/machinery/conveyor(A,cdir)
	C.id = id
	transfer_fingerprints_to(C)
	qdel(src)

/obj/item/conveyor_switch_construct
	name = "conveyor switch assembly"
	desc = "A conveyor control switch assembly."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	w_class = WEIGHT_CLASS_BULKY
	var/id = "" //inherited by the switch

/obj/item/conveyor_switch_construct/New()
	..()
	id = rand() //this couldn't possibly go wrong

/obj/item/conveyor_switch_construct/afterattack(atom/A, mob/user, proximity)
	if(!proximity || user.stat || !isfloorturf(A) || istype(A, /area/shuttle))
		return
	var/found = 0
	for(var/obj/machinery/conveyor/C in view())
		if(C.id == src.id)
			found = 1
			break
	if(!found)
		user << "\icon[src]<span class=notice>The conveyor switch did not detect any linked conveyor belts in range.</span>"
		return
	var/obj/machinery/conveyor_switch/NC = new/obj/machinery/conveyor_switch(A, id)
	transfer_fingerprints_to(NC)
	qdel(src)

/obj/item/weapon/paper/conveyor
	name = "paper- 'Nano-it-up U-build series, #9: Build your very own conveyor belt, in SPACE'"
	info = "<h1>Congratulations!</h1><p>You are now the proud owner of the best conveyor set available for space mail order! We at Nano-it-up know you love to prepare your own structures without wasting time, so we have devised a special streamlined assembly procedure that puts all other mail-order products to shame!</p><p>Firstly, you need to link the conveyor switch assembly to each of the conveyor belt assemblies. After doing so, you simply need to install the belt assemblies onto the floor, et voila, belt built. Our special Nano-it-up smart switch will detected any linked assemblies as far as the eye can see! This convenience, you can only have it when you Nano-it-up. Stay nano!</p>"
