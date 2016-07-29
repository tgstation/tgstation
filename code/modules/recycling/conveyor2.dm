//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//note that corner pieces transfer stuff clockwise when running forward, and anti-clockwise backwards.

<<<<<<< HEAD
=======
// May need to be increased.
#define CONVEYOR_CONTROL_RANGE 30

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor0"
	name = "conveyor belt"
	desc = "A conveyor belt."
	anchored = 1
<<<<<<< HEAD
	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
=======

	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/in_reverse = 0  // Swap forwards/reverse dirs. (Good for diagonals)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/forwards		// this is the default (forward) direction, set by the map dir
	var/backwards		// hopefully self-explanatory
	var/movedir			// the actual direction to move stuff in

	var/list/affecting	// the list of all items that will be moved this ptick
<<<<<<< HEAD
	var/id = ""			// the control ID	- must match controller ID
	var/verted = 1		// set to -1 to have the conveyour belt be inverted, so you can use the other corner icons
	speed_process = 1

/obj/machinery/conveyor/centcom_auto
	id = "round_end_belt"

=======
	var/id_tag = ""			// the control ID	- must match controller ID

	var/frequency = 1367
	var/datum/radio_frequency/radio_connection

	var/max_moved = 25

	machine_flags = SCREWTOGGLE | CROWDESTROY | MULTITOOL_MENU

/obj/machinery/conveyor/centcom_auto
	id_tag = "round_end_belt"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

// Auto conveyour is always on unless unpowered

/obj/machinery/conveyor/auto/New(loc, newdir)
	..(loc, newdir)
	operating = 1
<<<<<<< HEAD
	update_move_direction()
=======
	setmove()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

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
<<<<<<< HEAD
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
=======
	icon_state = "conveyor[operating]"

/obj/machinery/conveyor/initialize()
	if(frequency)
		set_frequency(frequency)
	update()

/obj/machinery/conveyor/proc/set_frequency(var/new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CONVEYORS)

/obj/machinery/conveyor/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	if(id_tag != signal.data["tag"] || !signal.data["command"]) return
	switch(signal.data["command"])
		if("forward")
			operating = 1
			setmove()
			return 1
		if("reverse")
			operating = -1
			setmove()
			return 1
		if("stop")
			operating = 0
			update()
			return 1
		else
			testing("Got unknown command \"[signal.data["command"]]\" from [src]!")


/*
 * Create a conveyor.
 */
/obj/machinery/conveyor/New(loc, newdir = null, building = 0)
	. = ..(loc)

	//Gotta go fast!
	machines -= src
	fast_machines += src

	if(newdir)
		dir = newdir

	component_parts = newlist(/obj/item/weapon/circuitboard/conveyor)

	updateConfig(!building)

	if(!id_tag) //Without an ID tag we'll never work, so let's try to copy it from one of our neighbors.
		copy_radio_from_neighbors()

/obj/machinery/conveyor/proc/copy_radio_from_neighbors()
	var/obj/machinery/conveyor_switch/lever = locate() in orange(src,1)
	if(lever && lever.id_tag)
		id_tag = lever.id_tag
		frequency = lever.frequency
		spawn(5) // Need to wait for the radio_controller to wake up.
			updateConfig()
		return
	//We didn't find any levers close so let's just try to copy any conveyors nearby
	for(var/direction in cardinal)
		var/obj/machinery/conveyor/domino = locate() in get_step(src, direction)
		if(domino && domino.id_tag)
			id_tag = domino.id_tag
			frequency = domino.frequency
			spawn(5) // Yeah I copied this twice so what
				updateConfig()
			return

/proc/conveyor_directions(var/dir, var/reverse = 0)
	var/list/dirs = list()
	switch(dir)
		if(NORTH) dirs = list(NORTH, SOUTH)
		if(SOUTH) dirs = list(SOUTH, NORTH)
		if(EAST)  dirs = list(EAST, WEST)
		if(WEST)  dirs = list(WEST, EAST)
		if(NORTHEAST) dirs = list(EAST, SOUTH)
		if(NORTHWEST) dirs = list(SOUTH, WEST)
		if(SOUTHEAST) dirs = list(NORTH, EAST)
		if(SOUTHWEST) dirs = list(WEST, NORTH)
	if(reverse)
		dirs.Swap(1,2)
	return dirs

/obj/machinery/conveyor/proc/updateConfig(var/startup=0)
	var/list/dirs = conveyor_directions(dir, in_reverse)
	forwards = dirs[1]
	backwards = dirs[2]

	if(!startup) // Need to wait for the radio_controller to wake up.
		initialize()

/obj/machinery/conveyor/proc/setmove()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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
<<<<<<< HEAD
	icon_state = "conveyor[operating * verted]"
=======
	var/disp_op = operating
	if(in_reverse && disp_op!=0)
		disp_op = -operating
	icon_state = "conveyor[disp_op]"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	// machine process
	// move items to the target location
/obj/machinery/conveyor/process()
	if(stat & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	use_power(100)

	affecting = loc.contents - src		// moved items will be all in loc
<<<<<<< HEAD
	sleep(1)
	for(var/atom/movable/A in affecting)
		if(!A.anchored)
			if(A.loc == src.loc) // prevents the object from being affected if it's not currently here.
				step(A,movedir)
		CHECK_TICK

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		if(!(stat & BROKEN))
			var/obj/item/conveyor_construct/C = new/obj/item/conveyor_construct(src.loc)
			C.id = id
			transfer_fingerprints_to(C)
		user << "<span class='notice'>You remove the conveyor belt.</span>"
		qdel(src)

	else if(istype(I, /obj/item/weapon/wrench))
		if(!(stat & BROKEN))
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			setDir(turn(dir,-45))
			update_move_direction()
			user << "<span class='notice'>You rotate [src].</span>"

	else if(user.a_intent != "harm")
		if(user.drop_item())
			I.loc = src.loc
	else
		return ..()

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user)
	user.Move_Pulled(src)


=======
	spawn(1)	// slight delay to prevent infinite propagation due to map order	//TODO: please no spawn() in process(). It's a very bad idea
		var/items_moved = 0
		for(var/atom/movable/A in affecting)
			if(!A.anchored)
				if(A.loc == src.loc) // prevents the object from being affected if it's not currently here.
					step(A,movedir)
					items_moved++
			if(items_moved >= max_moved)
				break

/obj/machinery/conveyor/togglePanelOpen(var/obj/item/toggle_item, mob/user)
	if(operating)
		to_chat(user, "You can't reach \the [src]'s panel through the moving machinery.")
		return -1
	return ..()

/obj/machinery/conveyor/crowbarDestroy(mob/user)
	if(operating)
		to_chat(user, "You can't reach \the [src]'s panel through the moving machinery.")
		return -1
	return ..()

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(var/obj/item/W, mob/user)
	. = ..()
	if(.)
		return .
	user.drop_item(W, src.loc)
	return 0

/obj/machinery/conveyor/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	//var/obj/item/device/multitool/P = get_multitool(user)
	var/dis_id_tag="-----"
	if(id_tag!=null && id_tag!="")
		dis_id_tag=id_tag
	return {"
	<ul>
		<li><b>Direction:</b>
			<a href="?src=\ref[src];setdir=[NORTH]" title="North">[src.in_reverse ? "&darr;" : "&uarr;"]</a>
			<a href="?src=\ref[src];setdir=[EAST]" title="East">[src.in_reverse ? "&larr;" : "&rarr;"]</a>
			<a href="?src=\ref[src];setdir=[SOUTH]" title="South">[src.in_reverse ? "&uarr;" : "&darr;"]</a>
			<a href="?src=\ref[src];setdir=[WEST]" title="West">[src.in_reverse ? "&rarr;" : "&larr;"]</a>
			<a href="?src=\ref[src];setdir=[NORTHEAST]" title="Northeast">[src.in_reverse ? "&#8601;" : "&#8599;"]</a>
			<a href="?src=\ref[src];setdir=[NORTHWEST]" title="Northwest">[src.in_reverse ? "&#8598;" : "&#8600;"]</a>
			<a href="?src=\ref[src];setdir=[SOUTHEAST]" title="Southeast">[src.in_reverse ? "&#8600;" : "&#8598;"]</a>
			<a href="?src=\ref[src];setdir=[SOUTHWEST]" title="Southwest">[src.in_reverse ? "&#8599;" : "&#8601;"]</a>
			<a href="?src=\ref[src];reverse" title="Reverse Direction">&#8644;</a>
		</li>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=1367">Reset</a>)</li>
		<li><b>ID Tag:</b> <a href="?src=\ref[src];set_id=1">[dis_id_tag]</a></li>

		<li>To quickly copy configuration: Add a Conveyor or a Conveyor Switch into buffer, activate the Multitool in your hand to enable Cloning Mode, then use it on another Conveyor.</li>
		<li><i>Cloning from a Conveyor Switch will only copy the Frequency and ID Tag, not direction.</i></li>
		<li>To make counter-clockwise corners: Use the Reverse Direction button in this menu.</li>
	</ul>"}


/obj/machinery/conveyor/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	. = ..()
	if(.) return .
	if("setdir" in href_list)
		operating=0
		dir=text2num(href_list["setdir"])
		updateConfig()
		return MT_UPDATE
	if("reverse" in href_list)
		operating=0
		in_reverse=!in_reverse
		updateConfig()
		return MT_UPDATE

/obj/machinery/conveyor/canClone(var/obj/machinery/O)
	return is_type_in_list(O, list(/obj/machinery/conveyor_switch, /obj/machinery/conveyor))

/obj/machinery/conveyor/clone(var/obj/machinery/O)
	if(istype(O, /obj/machinery/conveyor))
		var/obj/machinery/conveyor/it = O
		dir = it.dir
		in_reverse = it.in_reverse
		operating = 0
		id_tag = it.id_tag
		frequency = it.frequency
	else if(istype(O, /obj/machinery/conveyor_switch))
		var/obj/machinery/conveyor_switch/it = O
		id_tag = it.id_tag
		frequency = it.frequency
	updateConfig()
	return 1

// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user as mob)
	user.Move_Pulled(src)

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
// make the conveyor broken
// also propagate inoperability to any connected conveyor with the same ID
/obj/machinery/conveyor/proc/broken()
	stat |= BROKEN
	update()

<<<<<<< HEAD
=======
	/*
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/obj/machinery/conveyor/C = locate() in get_step(src, dir)
	if(C)
		C.set_operable(dir, id, 0)

	C = locate() in get_step(src, turn(dir,180))
	if(C)
		C.set_operable(turn(dir,180), id, 0)
<<<<<<< HEAD
=======
	*/
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488


//set the operable var if ID matches, propagating in the given direction

/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)
<<<<<<< HEAD

	if(id != match_id)
=======
	if(id_tag != match_id)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		return
	operable = op

	update()
	var/obj/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
<<<<<<< HEAD
		C.set_operable(stepdir, id, op)
=======
		C.set_operable(stepdir, id_tag, op)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/*
/obj/machinery/conveyor/verb/destroy()
	set src in view()
	src.broken()
*/

/obj/machinery/conveyor/power_change()
	..()
	update()

<<<<<<< HEAD
=======
/obj/machinery/conveyor/dropFrame()
	new /obj/machinery/conveyor_assembly(src.loc, src.dir)

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
// the conveyor control switch
//
//

/obj/machinery/conveyor_switch
<<<<<<< HEAD

=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	var/position = 0			// 0 off, -1 reverse, 1 forward
	var/last_pos = -1			// last direction setting
<<<<<<< HEAD
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
=======
	var/convdir = 0 			// lock to one direction. -1 = reverse, 0 = not locked, 1 = forward
	var/operated = 1			// true if just operated

	var/id_tag = "" 			// must match conveyor IDs to control them

	var/frequency = 1367
	var/datum/radio_frequency/radio_connection
	machine_flags = MULTITOOL_MENU

	anchored = 1

/obj/machinery/conveyor_switch/oneway //Use these instances for mapping
	convdir = 1

/obj/machinery/conveyor_switch/oneway/reverse
	convdir = -1

/obj/machinery/conveyor_switch/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return
	if(src == signal.source) return

	if(id_tag != signal.data["tag"] || !signal.data["command"]) return
	if(!convdir)
		switch(signal.data["command"])
			if("forward")
				position = 1
				last_pos = 0
			if("reverse")
				position = -1
				last_pos = 0
			if("stop")
				last_pos = position
				position = 0
			else
				testing("Got unknown command \"[signal.data["command"]]\" from [src]!")
				return
	else
		switch(signal.data["command"])
			if("forward")
				if(convdir==1)
					position = 1
			if("reverse")
				if(convdir==-1)
					position = -1
			if("stop")
				position = 0
			else
				testing("Got unknown command \"[signal.data["command"]]\" from [src]!")
				return
	update()

/obj/machinery/conveyor_switch/New()
	..()
	if(!id_tag)
		id_tag = "[rand(9999)]"
		set_frequency(frequency) //I tried just assigning the ID tag during initialize(), but that didn't work somehow, probably because it makes TOO MUCH SENSE
	update()
	spawn(5)		// allow map load
		updateConfig()

/obj/machinery/conveyor_switch/proc/updateConfig()
	//initialize()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

// update the icon depending on the position

/obj/machinery/conveyor_switch/proc/update()
	if(position<0)
		icon_state = "switch-rev"
	else if(position>0)
		icon_state = "switch-fwd"
	else
		icon_state = "switch-off"

<<<<<<< HEAD

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
	w_class = 4
	var/id = "" //inherited by the belt

/obj/item/conveyor_construct/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/conveyor_switch_construct))
		user << "<span class='notice'>You link the switch to the conveyor belt assembly.</span>"
		var/obj/item/conveyor_switch_construct/C = I
		id = C.id

/obj/item/conveyor_construct/afterattack(atom/A, mob/user, proximity)
	if(!proximity || user.stat || !istype(A, /turf/open/floor) || istype(A, /area/shuttle))
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
	w_class = 4
	var/id = "" //inherited by the switch

/obj/item/conveyor_switch_construct/New()
	..()
	id = rand() //this couldn't possibly go wrong

/obj/item/conveyor_switch_construct/afterattack(atom/A, mob/user, proximity)
	if(!proximity || user.stat || !istype(A, /turf/open/floor) || istype(A, /area/shuttle))
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
=======
/obj/machinery/conveyor_switch/initialize()
	if(frequency)
		set_frequency(frequency)
	update()

/obj/machinery/conveyor_switch/proc/set_frequency(var/new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_CONVEYORS)

// attack with hand, switch position
/obj/machinery/conveyor_switch/attack_hand(mob/user)
	if(isobserver(usr) && !canGhostWrite(user,src,"toggled"))
		to_chat(usr, "<span class='warning'>Nope.</span>")
		return 0
	if(!convdir)
		if(position == 0)
			if(last_pos < 0)
				position = 1
				last_pos = 0
				send_command("forward")
			else
				position = -1
				last_pos = 0
				send_command("reverse")
		else
			last_pos = position
			position = 0
			send_command("stop")
	else
		if(position == 0)
			position = convdir
			send_command(convdir==1?"forward":"reverse")
		else
			position = 0
			send_command("stop")

	update()

/obj/machinery/conveyor_switch/proc/send_command(var/command)
	if(radio_connection)
		var/datum/signal/signal = getFromPool(/datum/signal)
		signal.source=src
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time

		signal.data["command"] = command

		radio_connection.post_signal(src, signal, range = CONVEYOR_CONTROL_RANGE)

/obj/machinery/conveyor_switch/attackby(var/obj/item/W, mob/user)
	. = ..()
	if(.)
		return .
	if(iswrench(W))
		to_chat(user, "<span class='notice'>Deconstructing \the [src]...</span>")
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
		if(do_after(user, src,50))
			to_chat(user, "<span class='notice'>You disassemble \the [src].</span>")
			var/turf/T=get_turf(src)
			new /obj/item/device/assembly/signaler(T)
			new /obj/item/stack/rods(T,1)
			qdel(src)
		return 1

/obj/machinery/conveyor_switch/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	var/dis_id_tag="-----"
	if(id_tag!=null && id_tag!="")
		dis_id_tag=id_tag
	return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=1367">Reset</a>)</li>
			<li><b>ID Tag:</b> <a href="?src=\ref[src];set_id=1">[dis_id_tag]</a></li>
			<li><b>Restrict Pulling: </b>
				[convdir == -1 ? "<b>&larr;</b>" : {"<a href="?src=\ref[src];setconvdir=-1">&larr;</a>"}]
				[convdir ==  0 ? "<b>No</b>" 	 : {"<a href="?src=\ref[src];setconvdir= 0">No</a>"}]
				[convdir ==  1 ? "<b>&rarr;</b>" : {"<a href="?src=\ref[src];setconvdir= 1">&rarr;</a>"}]
			</li>
			<li>To quickly copy configuration: Add a Conveyor or a Conveyor Switch into buffer, activate the Multitool in your hand to enable Cloning Mode, then use it on another Conveyor.</li>
			<li><i>Cloning from a Conveyor Switch will only copy the Frequency and ID Tag, not direction.</i></li>
		</ul>"}

/obj/machinery/conveyor_switch/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	. = ..()
	if(.) return
	if("setconvdir" in href_list)
		convdir = text2num(href_list["setconvdir"])
		updateConfig()
		return MT_UPDATE
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
