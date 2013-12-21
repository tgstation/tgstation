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

/obj/machinery/conveyor/centcom_auto
	id = "round_end_belt"

// Auto conveyour is always on unless unpowered

/obj/machinery/conveyor/auto/New(loc, newdir)
	..(loc, newdir)
	operating = 1
	setmove()

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
	icon_state = "conveyor[operating]"

	// create a conveyor
/obj/machinery/conveyor/New(loc, newdir)
	..(loc)
	if(newdir)
		dir = newdir
	component_parts = list()
	component_parts += new /obj/item/weapon/cable_coil(src,2)
	component_parts += new /obj/item/stack/rods(src,4)
	RefreshParts()
	updateConfig()

/obj/machinery/conveyor/proc/updateConfig()
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
			forwards = SOUTH
			backwards = WEST
		if(SOUTHEAST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH

/obj/machinery/conveyor/proc/setmove()
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
	icon_state = "conveyor[operating]"

	// machine process
	// move items to the target location
/obj/machinery/conveyor/process()
	if(stat & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	use_power(100)

	affecting = loc.contents - src		// moved items will be all in loc
	spawn(1)	// slight delay to prevent infinite propagation due to map order	//TODO: please no spawn() in process(). It's a very bad idea
		var/items_moved = 0
		for(var/atom/movable/A in affecting)
			if(!A.anchored)
				if(A.loc == src.loc) // prevents the object from being affected if it's not currently here.
					step(A,movedir)
					items_moved++
			if(items_moved >= 10)
				break

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(var/obj/item/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		interact(user)
		return 1
	if(!operating && istype(W, /obj/item/weapon/crowbar))
		user << "\blue You begin prying apart \the [src]..."
		if(do_after(user,50))
			user << "\blue You disassemble \the [src]..."
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			del(src)
		return 1
	if(isrobot(user))	return //Carn: fix for borgs dropping their modules on conveyor belts
	user.drop_item()
	if(W && W.loc)	W.loc = src.loc
	return

/obj/machinery/conveyor/interact(mob/user as mob)
	//var/obj/item/device/multitool/P = get_multitool(user)
	var/dat = {"<html>
	<head>
		<title>[name] Access</title>
		<style type="text/css">
html,body {
	font-family:courier;
	background:#999999;
	color:#333333;
}

a {
	color:#000000;
	text-decoration:none;
	border-bottom:1px solid black;
}
		</style>
	</head>
	<body>
		<h3>[name]</h3>
		<ul>
			<li><b>Direction:</b>
				<a href="?src=\ref[src];setdir=[NORTH]" title="North">&uarr;</a>
				<a href="?src=\ref[src];setdir=[EAST]" title="East">&rarr;</a>
				<a href="?src=\ref[src];setdir=[SOUTH]" title="South">&darr;</a>
				<a href="?src=\ref[src];setdir=[WEST]" title="West">&larr;</a>
			</li>
			<li><b>ID Tag:</b> <a href="?src=\ref[src];set_tag=1">[id]</a></li>
		</ul>
"}
	dat += "</body></html>"

	user << browse(dat, "window=conveyorcfg")
	onclose(user, "conveyorcfg")


/obj/machinery/conveyor/Topic(href, href_list)
	if(..())
		return

	if(!issilicon(usr))
		if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
			return

	var/obj/item/device/multitool/P = get_multitool(usr)

	if("set_id" in href_list)
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, id) as null|text),1,MAX_MESSAGE_LEN)
		if(newid)
			for(var/obj/machinery/conveyor_switch/S in world)
				if(S.id == id)
					S.conveyors -= src
			id = newid
			for(var/obj/machinery/conveyor_switch/S in world)
				if(S.id == id)
					S.conveyors += src
			update()

	if("setdir" in href_list)
		operating=0
		dir=text2num(href_list["setdir"])
		update()

	if(href_list["unlink"])
		P.visible_message("\The [P] buzzes in an annoying tone.","You hear a buzz.")

	if(href_list["link"])
		P.visible_message("\The [P] buzzes in an annoying tone.","You hear a buzz.")

	if(href_list["buffer"])
		P.buffer = src

	if(href_list["flush"])
		P.buffer = null

	usr.set_machine(src)
	updateUsrDialog()
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
		M.stop_pulling()
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.stop_pulling()
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
		user.stop_pulling()
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
		updateConfig()

/obj/machinery/conveyor_switch/proc/updateConfig()
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

/obj/machinery/conveyor_switch/attackby(var/obj/item/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		interact(user)
		return 1
	if(istype(W, /obj/item/weapon/wrench))
		user << "\blue Deconstructing \the [src]..."
		if(do_after(user,50))
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			user << "\blue You disassemble \the [src]."
			var/turf/T=get_turf(src)
			new /obj/item/device/assembly/signaler(T)
			new /obj/item/stack/rods(T,1)
			del(src)
		return 1
	return ..()

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


/obj/machinery/conveyor_switch/interact(mob/user as mob)
	//var/obj/item/device/multitool/P = get_multitool(user)
	var/dat = {"<html>
	<head>
		<title>[name] Access</title>
		<style type="text/css">
html,body {
	font-family:courier;
	background:#999999;
	color:#333333;
}

a {
	color:#000000;
	text-decoration:none;
	border-bottom:1px solid black;
}
		</style>
	</head>
	<body>
		<h3>[name]</h3>
		<ul>
			<li><b>ID Tag:</b> <a href="?src=\ref[src];set_tag=1">[id]</a></li>
		</ul>
"}
	dat += "</body></html>"

	user << browse(dat, "window=conveyorcfg")
	onclose(user, "conveyorcfg")


/obj/machinery/conveyor_switch/Topic(href, href_list)
	if(..())
		return

	if(!issilicon(usr))
		if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
			return

	var/obj/item/device/multitool/P = get_multitool(usr)

	if("set_id" in href_list)
		var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID tag for this machine", src, id) as null|text),1,MAX_MESSAGE_LEN)
		if(newid)
			id = newid
			updateConfig()

	if(href_list["unlink"])
		P.visible_message("\The [P] buzzes in an annoying tone.","You hear a buzz.")

	if(href_list["link"])
		P.visible_message("\The [P] buzzes in an annoying tone.","You hear a buzz.")

	if(href_list["buffer"])
		P.buffer = src

	if(href_list["flush"])
		P.buffer = null

	usr.set_machine(src)
	updateUsrDialog()