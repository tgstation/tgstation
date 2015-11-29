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

	var/max_moved = 25

	machine_flags = SCREWTOGGLE | CROWDESTROY | MULTITOOL_MENU

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

	//Gotta go fast!
	machines -= src
	fast_machines += src

	if(newdir)
		dir = newdir

	component_parts = newlist(/obj/item/weapon/circuitboard/conveyor)

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
// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user as mob)
	user.Move_Pulled(src)


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
	machine_flags = MULTITOOL_MENU

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
		to_chat(usr, "<span class='warning'>Nope.</span>")
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
	if(istype(W, /obj/item/weapon/wrench))
		to_chat(user, "<span class='notice'>Deconstructing \the [src]...</span>")
		if(do_after(user, src,50))
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
			to_chat(user, "<span class='notice'>You disassemble \the [src].</span>")
			var/turf/T=get_turf(src)
			new /obj/item/device/assembly/signaler(T)
			new /obj/item/stack/rods(T,1)
			del(src)
		return 1

/obj/machinery/conveyor_switch/oneway
	var/convdir = 1 //Set to 1 or -1 depending on which way you want the conveyor to go. (In other words keep at 1 and set the proper dir on the belts.)
	desc = "A conveyor control switch. It appears to only go in one direction."

// attack with hand, switch position
/obj/machinery/conveyor_switch/oneway/attack_hand(mob/user)
	if(isobserver(usr) && !canGhostWrite(user,src,"toggled"))
		to_chat(usr, "<span class='warning'>Nope.</span>")
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