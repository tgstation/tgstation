//conveyor2 is pretty much like the original, except it supports corners, but not diverters.
//note that corner pieces transfer stuff clockwise when running forward, and anti-clockwise backwards.

// May need to be increased.
#define CONVEYOR_CONTROL_RANGE 30

/obj/machinery/conveyor
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor0"
	name = "conveyor belt"
	desc = "A conveyor belt."
	anchored = 1

	var/operating = 0	// 1 if running forward, -1 if backwards, 0 if off
	var/operable = 1	// true if can operate (no broken segments in this belt run)
	var/in_reverse = 0  // Swap forwards/reverse dirs. (Good for diagonals)
	var/forwards		// this is the default (forward) direction, set by the map dir
	var/backwards		// hopefully self-explanatory
	var/movedir			// the actual direction to move stuff in

	var/list/affecting	// the list of all items that will be moved this ptick
	var/id_tag = ""			// the control ID	- must match controller ID

	var/frequency = 1367
	var/datum/radio_frequency/radio_connection

/obj/machinery/conveyor/centcom_auto
	id_tag = "round_end_belt"

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

	if(newdir)
		dir = newdir

	updateConfig(!building)

/obj/machinery/conveyor/proc/updateConfig(var/startup=0)
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

	if(in_reverse)
		var/next_backwards=forwards
		forwards=backwards
		backwards=next_backwards

	if(!startup) // Need to wait for the radio_controller to wake up.
		initialize()

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
	var/disp_op = operating
	if(in_reverse && disp_op!=0)
		disp_op = -operating
	icon_state = "conveyor[disp_op]"

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
		update_multitool_menu(user)
		return 1
	if(!operating && istype(W, /obj/item/weapon/crowbar))
		user << "\blue You begin prying apart \the [src]..."
		if(do_after(user,50))
			user << "\blue You disassemble \the [src]..."
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
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

/obj/machinery/conveyor/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	//var/obj/item/device/multitool/P = get_multitool(user)
	var/dis_id_tag="-----"
	if(id_tag!=null && id_tag!="")
		dis_id_tag=id_tag
	return {"
	<ul>
		<li><b>Direction:</b>
			<a href="?src=\ref[src];setdir=[NORTH]" title="North">&uarr;</a>
			<a href="?src=\ref[src];setdir=[EAST]" title="East">&rarr;</a>
			<a href="?src=\ref[src];setdir=[SOUTH]" title="South">&darr;</a>
			<a href="?src=\ref[src];setdir=[WEST]" title="West">&larr;</a>
		</li>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=1367">Reset</a>)</li>
		<li><b>ID Tag:</b> <a href="?src=\ref[src];set_id=1">[dis_id_tag]</a></li>
	</ul>"}


/obj/machinery/conveyor/multitool_topic(var/mob/user,var/list/href_list,var/obj/O)
	. = ..()
	if(.) return .
	if("setdir" in href_list)
		operating=0
		dir=text2num(href_list["setdir"])
		updateConfig()
		return MT_UPDATE

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

	/*
	var/obj/machinery/conveyor/C = locate() in get_step(src, dir)
	if(C)
		C.set_operable(dir, id, 0)

	C = locate() in get_step(src, turn(dir,180))
	if(C)
		C.set_operable(turn(dir,180), id, 0)
	*/


//set the operable var if ID matches, propagating in the given direction

/obj/machinery/conveyor/proc/set_operable(stepdir, match_id, op)

	if(id_tag != match_id)
		return
	operable = op

	update()
	var/obj/machinery/conveyor/C = locate() in get_step(src, stepdir)
	if(C)
		C.set_operable(stepdir, id_tag, op)

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

	var/id_tag = "" 			// must match conveyor IDs to control them

	var/frequency = 1367
	var/datum/radio_frequency/radio_connection

	anchored = 1

/obj/machinery/conveyor_switch/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return
	if(src == signal.source) return

	if(id_tag != signal.data["tag"] || !signal.data["command"]) return
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
	update()


/obj/machinery/conveyor_switch/New()
	..()
	update()
	spawn(5)		// allow map load
		updateConfig()

/obj/machinery/conveyor_switch/proc/updateConfig()
	//initialize()

// update the icon depending on the position

/obj/machinery/conveyor_switch/proc/update()
	if(position<0)
		icon_state = "switch-rev"
	else if(position>0)
		icon_state = "switch-fwd"
	else
		icon_state = "switch-off"

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
		usr << "\red Nope."
		return 0
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

	update()

/obj/machinery/conveyor_switch/proc/send_command(var/command)
	if(radio_connection)
		var/datum/signal/signal = new
		signal.source=src
		signal.transmission_method = 1 //radio signal
		signal.data["tag"] = id_tag
		signal.data["timestamp"] = world.time

		signal.data["command"] = command

		radio_connection.post_signal(src, signal, range = CONVEYOR_CONTROL_RANGE)

/obj/machinery/conveyor_switch/attackby(var/obj/item/W, mob/user)
	if(istype(W, /obj/item/device/multitool))
		update_multitool_menu(user)
		return 1
	if(istype(W, /obj/item/weapon/wrench))
		user << "\blue Deconstructing \the [src]..."
		if(do_after(user,50))
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
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
	if(isobserver(usr) && !canGhostWrite(user,src,"toggled"))
		usr << "\red Nope."
		return 0
	if(position == 0)
		position = convdir
		send_command(convdir==1?"forward":"reverse")
	else
		position = 0
		send_command("stop")

	update()


/obj/machinery/conveyor_switch/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	var/dis_id_tag="-----"
	if(id_tag!=null && id_tag!="")
		dis_id_tag=id_tag
	return {"
		<ul>
			<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=1367">Reset</a>)</li>
			<li><b>ID Tag:</b> <a href="?src=\ref[src];set_id=1">[dis_id_tag]</a></li>
		</ul>
	"}

/obj/machinery/conveyor_switch/oneway/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return
	if(src == signal.source) return

	if(id_tag != signal.data["tag"] || !signal.data["command"]) return
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