/**********************Mineral stacking unit console**************************/

/obj/machinery/computer/stacking_unit
	name = "stacking machine console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_generic"
	light_color = LIGHT_COLOR_GREEN
	circuit = "/obj/item/weapon/circuitboard/stacking_machine_console"

	var/stacker_tag//The ID of the stacker this console should control
	var/frequency = FREQ_DISPOSAL
	var/datum/radio_frequency/radio_connection

	var/list/stacker_data

/obj/machinery/computer/stacking_unit/New()
	. = ..()
	if(ticker)
		initialize()

/obj/machinery/computer/stacking_unit/attack_ai(mob/user)
	add_hiddenprint(user)
	interact(user)

/obj/machinery/computer/stacking_unit/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/computer/stacking_unit/interact(mob/user)
	if(stat & (NOPOWER | BROKEN))
		return

	if(!stacker_data)
		request_status()
		if(!stacker_data) //Still no data.
			to_chat(user, "<span class='warning'>Unable to find a stacking machine.</span>")
			user.unset_machine(src)
			return

	user.set_machine(src)

	var/dat = ""

	for(var/typepath in stacker_data["stacks"])
		var/list/stack = stacker_data["stacks"][typepath]
		if(stack && stack["amount"])
			dat += "[stack["name"]]: [stack["amount"]] <A href='?src=\ref[src];release=[typepath]'>Release</A><br>"

	dat += text("<br>Stacking: []", stacker_data["stack_amt"])

	var/datum/browser/popup = new(user, "stacking_machine_console", name, 200, 200, src)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/stacking_unit/Topic(href, href_list)
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine(src)
		return 1

	. = ..()
	if(.)
		return

	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["release"])
		var/list/signal_data = list("release" = href_list["release"])
		send_signal(signal_data)

		updateUsrDialog()
		return 1

/obj/machinery/computer/stacking_unit/proc/send_signal(var/list/data)
	if(!radio_connection)
		return

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.source = src
	signal.transmission_method = 1 //radio signal
	signal.data["tag"] = stacker_tag
	signal.data += data

	radio_connection.post_signal(src, signal)

/obj/machinery/computer/stacking_unit/initialize()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/computer/stacking_unit/proc/set_frequency(var/new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency)

/obj/machinery/computer/stacking_unit/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!signal.data["tag"] || signal.data["tag"] != stacker_tag)
		return

	stacker_data = signal.data //Get dat data
	updateUsrDialog()

/obj/machinery/computer/stacking_unit/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
		<ul>
			<li><b>Frequency: </b><a href='?src=\ref[src];set_freq=-1'>[format_frequency(frequency)]</a></li>
			<li>[format_tag("Stacker ID Tag","stacker_tag")]</li>
		</ul>
	"}

/obj/machinery/computer/stacking_unit/proc/request_status()
	stacker_data = null
	send_signal(list("sigtype" = "status"))

/**********************Mineral stacking unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = 1
	anchored = 1

	machine_flags = SCREWTOGGLE | CROWDESTROY | MULTITOOL_MENU | EJECTNOTDEL

//What were these even, they were unused.
//	var/stk_types = list()
//	var/stk_amt   = list()

	var/atom/movable/mover //Virtual atom used to check passing ability on the out turf.

	var/in_dir = NORTH
	var/out_dir = SOUTH

	var/list/stacks = list()

	var/stack_amt = 50 //amount to stack before releassing.
	var/max_moved = 100

	var/id_tag//The ID of the stacker this console should control
	var/frequency = FREQ_DISPOSAL
	var/datum/radio_frequency/radio_connection

/obj/machinery/mineral/stacking_machine/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/bin in component_parts)
		T += bin.rating
	max_moved = initial(max_moved) * (T / 3)

	T = 0 //reusing T here because muh RAM.
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating - 1
	idle_power_usage = initial(idle_power_usage) - (T * (initial(idle_power_usage) / 4))//25% power usage reduction for an advanced capacitor, 50% for a super one.

/obj/machinery/mineral/stacking_machine/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/stacking_unit,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor
	)

	RefreshParts()

	mover = new

	if(ticker)
		initialize()

/obj/machinery/mineral/stacking_machine/update_icon()
	if(stat & (NOPOWER | BROKEN))
		icon_state = "stacker_o"
	else
		icon_state = "stacker"

/obj/machinery/mineral/stacking_machine/power_change()
	. = ..()

	update_icon()

/obj/machinery/mineral/stacking_machine/process()
	var/turf/in_T = get_step(src, in_dir)
	var/turf/out_T = get_step(src, out_dir)

	if(!in_T.CanPass(mover, in_T) || !in_T.Enter(mover) || !out_T.CanPass(mover, out_T) || !out_T.Enter(mover))
		return

	var/obj/item/stack/stack
	var/moved = 0
	for(var/atom/movable/A in in_T.contents)
		if(A.anchored)
			continue

		if(istype(A, /obj/item/stack))
			var/obj/item/stack/stackA = A

			if(!("[stackA.type]" in stacks))
				stack = getFromPool(stackA.type, src)
				stack.amount = stackA.amount
			else
				stack = stacks["[stackA.type]"]
				stack.amount += stackA.amount

			stacks["[stackA.type]"] = stack
			returnToPool(stackA)
		//else if (istype(O, /obj/item/weapon/ore/slag))
		//	returnToPool(O)
		else
			A.forceMove(out_T)

		moved ++
		if(moved >= max_moved)
			break

	for(var/typepath in stacks)
		stack = stacks[typepath]
		if(stack.amount >= stack_amt)
			release_stack(typepath)

	broadcast_status()

/obj/machinery/mineral/stacking_machine/proc/release_stack(var/typepath, var/forced = 0)
	if(!(typepath in stacks)) //What, we don't even have this stack
		return

	var/turf/out_T = get_step(src, out_dir)

	if(out_T.density && !forced)//forced is here so we can eject the stacks during decon
		return

	var/obj/item/stack/stack = stacks[typepath]
	var/obj/item/stack/stacked = getFromPool(stack.type)

	var/release_amount = min(stack.amount, stack_amt)

	stacked.amount = release_amount
	stacked.forceMove(out_T)
	stack.amount -= release_amount

	if(stack.amount == 0)
		stacks.Remove(typepath)
		returnToPool(stack)

/obj/machinery/mineral/stacking_machine/proc/send_signal(list/data)
	if(!radio_connection)
		return

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.source = src
	signal.transmission_method = 1 //radio signal
	signal.data["tag"] = id_tag
	signal.data += data

	radio_connection.post_signal(src, signal)

/obj/machinery/mineral/stacking_machine/proc/broadcast_status()
	var/list/data = list()
	var/list/stack_data[stacks.len]

	for(var/stack_id in stacks)
		var/obj/item/stack/stack = stacks[stack_id]
		stack_data[stack_id] = list(
			"amount" = stack.amount,
			"name" = stack.name
			)

	data["stacks"] = stack_data
	data["stack_amt"] = stack_amt

	send_signal(data)

/obj/machinery/mineral/stacking_machine/initialize()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/mineral/stacking_machine/proc/set_frequency(var/new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency)

/obj/machinery/mineral/stacking_machine/receive_signal(var/datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!signal.data["tag"] || signal.data["tag"] != id_tag)
		return

	if(signal.data["release"])
		release_stack(signal.data["release"])
		broadcast_status()
		return 1

/obj/machinery/mineral/stacking_machine/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
		<ul>
			<li><b>Frequency: </b><a href='?src=\ref[src];set_freq=-1'>[format_frequency(frequency)]</a></li>
			<li>[format_tag("ID Tag","id_tag")]</li>
			<li><b>Input: </b><a href='?src=\ref[src];changedir=1'>[capitalize(dir2text(in_dir))]</a></li>
			<li><b>Output: </b><a href='?src=\ref[src];changedir=2'>[capitalize(dir2text(out_dir))]</a></li>
		</ul>
	"}

//For the purposes of this proc, 1 = in, 2 = out.
//Yes the implementation is overkill but I felt bad for hardcoding it with gigantic if()s and shit.
/obj/machinery/mineral/stacking_machine/multitool_topic(mob/user, list/href_list, obj/item/device/multitool/P)
	if("changedir" in href_list)
		var/changingdir = text2num(href_list["changedir"])
		changingdir = Clamp(changingdir, 1, 2)//No runtimes from HREF exploits.

		var/newdir = input("Select the new direction", name, "North") as null|anything in list("North", "South", "East", "West")
		if(!newdir)
			return 1
		newdir = text2dir(newdir)

		var/list/dirlist = list(in_dir, out_dir) //Behold the idea I got on how to do this.
		var/olddir = dirlist[changingdir] //Store this for future reference before wiping it next line.
		dirlist[changingdir] = -1 //Make the dir that's being changed -1 so it doesn't see itself.

		var/conflictingdir = dirlist.Find(newdir) //Check if the dir is conflicting with another one
		if(conflictingdir) //Welp, it is.
			dirlist[conflictingdir] = olddir //Set it to the olddir of the dir we're changing.

		dirlist[changingdir] = newdir //Set the changindir to the selected dir.

		in_dir = dirlist[1]
		out_dir = dirlist[2]

		return MT_UPDATE
		//Honestly I didn't expect that to fit in, what, 10 lines of code?

	return ..()

/obj/machinery/mineral/stacking_machine/Destroy()
	id_tag = null

	qdel(mover)
	mover = null

	. = ..()
