<<<<<<< HEAD
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/*

	All telecommunications interactions:

*/

<<<<<<< HEAD
#define STATION_Z 1
#define TELECOMM_Z 3

/obj/machinery/telecomms
	var/temp = "" // output message


/obj/machinery/telecomms/attackby(obj/item/P, mob/user, params)

	var/icon_closed = initial(icon_state)
	var/icon_open = "[initial(icon_state)]_o"
	if(!on)
		icon_closed = "[initial(icon_state)]_off"
		icon_open = "[initial(icon_state)]_o_off"

	if(default_deconstruction_screwdriver(user, icon_open, icon_closed, P))
		return

	else if(exchange_parts(user, P))
		return

	// Using a multitool lets you access the receiver's interface
	else if(istype(P, /obj/item/device/multitool))
		attack_hand(user)

	else if(default_deconstruction_crowbar(P))
		return
	else
		return ..()


/obj/machinery/telecomms/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/telecomms/attack_hand(mob/user)

=======
/obj/machinery/telecomms
	var/temp = "" // output message
	var/construct_op = 0
	machine_flags = MULTITOOL_MENU


/obj/machinery/telecomms/attackby(obj/item/P as obj, mob/user as mob)

	// Using a multitool lets you access the receiver's interface
	. = ..()
	if(.)
		return .

	switch(construct_op)
		if(0)
			if(isscrewdriver(P))
				to_chat(user, "You unfasten the bolts.")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				construct_op ++
		if(1)
			if(isscrewdriver(P))
				to_chat(user, "You fasten the bolts.")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				construct_op --
			if(iswrench(P))
				to_chat(user, "You dislodge the external plating.")
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
				construct_op ++
		if(2)
			if(iswrench(P))
				to_chat(user, "You secure the external plating.")
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
				construct_op --
			if(iswirecutter(P))
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
				to_chat(user, "You remove the cables.")
				construct_op ++
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( user.loc )
				A.amount = 5
				stat |= BROKEN // the machine's been borked!
		if(3)
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/A = P
				if(A.amount >= 5)
					to_chat(user, "You insert the cables.")
					A.amount -= 5
					if(A.amount <= 0)
						user.drop_item(A, force_drop = 1)
						returnToPool(A)
					construct_op --
					stat &= ~BROKEN // the machine's not borked anymore!
				else
					to_chat(user, "You need more cable")
			if(iscrowbar(P))
				to_chat(user, "You begin prying out the circuit board and components...")
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				if(do_after(user, src,60))
					to_chat(user, "You finish prying out the components.")

					// Drop all the component stuff
					if(contents.len > 0)
						for(var/obj/x in src)
							x.loc = user.loc
					else

						// If the machine wasn't made during runtime, probably doesn't have components:
						// manually find the components and drop them!
						var/newpath = text2path(circuitboard)
						var/obj/item/weapon/circuitboard/C = new newpath
						for(var/I in C.req_components)
							for(var/i = 1, i <= C.req_components[I], i++)
								newpath = text2path(I)
								var/obj/item/s = new newpath
								s.loc = user.loc
								if(istype(s, /obj/item/stack/cable_coil))
									var/obj/item/stack/cable_coil/A = s
									A.amount = 1

						// Drop a circuit board too
						C.loc = user.loc

					// Create a machine frame and delete the current machine
					var/obj/machinery/constructable_frame/machine_frame/F = new
					F.set_build_state(2)
					F.loc = src.loc
					qdel(src)


/obj/machinery/telecomms/attack_ai(var/mob/user as mob)
	src.add_hiddenprint(user)
	attack_hand(user)

/obj/machinery/telecomms/attack_hand(var/mob/user as mob)
	update_multitool_menu(user)

/obj/machinery/telecomms/proc/formatInput(var/label,var/varname, var/input)
	var/value = vars[varname]
	if(!value || value=="")
		value="-----"
	return "<b>[label]:</b> <a href=\"?src=\ref[src];input=[varname]\">[value]</a>"

/obj/machinery/telecomms/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	// You need a multitool to use this, or be silicon
	if(!issilicon(user))
		// istype returns false if the value is null
		if(!istype(user.get_active_hand(), /obj/item/device/multitool))
			return

	if(stat & (BROKEN|NOPOWER))
		return

<<<<<<< HEAD
	var/obj/item/device/multitool/P = get_multitool(user)

	user.set_machine(src)
	var/dat
	dat = "<font face = \"Courier\"><HEAD><TITLE>[src.name]</TITLE></HEAD><center><H3>[src.name] Access</H3></center>"
	dat += "<br>[temp]<br>"
	dat += "<br>Power Status: <a href='?src=\ref[src];input=toggle'>[src.toggled ? "On" : "Off"]</a>"
	if(on && toggled)
		if(id != "" && id)
			dat += "<br>Identification String: <a href='?src=\ref[src];input=id'>[id]</a>"
		else
			dat += "<br>Identification String: <a href='?src=\ref[src];input=id'>NULL</a>"
		dat += "<br>Network: <a href='?src=\ref[src];input=network'>[network]</a>"
		dat += "<br>Prefabrication: [autolinkers.len ? "TRUE" : "FALSE"]"
		if(hide) dat += "<br>Shadow Link: ACTIVE</a>"
=======
	var/dat

	dat = {"
		<p>[temp]</p>
		<p><b>Power Status:</b> <a href='?src=\ref[src];input=toggle'>[src.toggled ? "On" : "Off"]</a></p>"}
	if(on && toggled)
		dat += {"
			<p>[formatInput("Identification String","id","id")]</p>
			<p>[formatInput("Network","network","network")]</p>
			<p><b>Prefabrication:</b> [autolinkers.len ? "TRUE" : "FALSE"]</p>
		"}
		if(hide)
			dat += "<p>Shadow Link: ACTIVE</p>"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

		//Show additional options for certain machines.
		dat += Options_Menu()

<<<<<<< HEAD
		dat += "<br>Linked Network Entities: <ol>"

=======
		dat += {"<h2>Linked Network Entities:</h2> <ol>"}
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		var/i = 0
		for(var/obj/machinery/telecomms/T in links)
			i++
			if(T.hide && !src.hide)
				continue
			dat += "<li>\ref[T] [T.name] ([T.id])  <a href='?src=\ref[src];unlink=[i]'>\[X\]</a></li>"
<<<<<<< HEAD
		dat += "</ol>"

		dat += "<br>Filtering Frequencies: "

		i = 0
		if(length(freq_listening))
			for(var/x in freq_listening)
				i++
				if(i < length(freq_listening))
					dat += "[format_frequency(x)] GHz<a href='?src=\ref[src];delete=[x]'>\[X\]</a>; "
				else
					dat += "[format_frequency(x)] GHz<a href='?src=\ref[src];delete=[x]'>\[X\]</a>"
		else
			dat += "NONE"

		dat += "<br>  <a href='?src=\ref[src];input=freq'>\[Add Filter\]</a>"
		dat += "<hr>"

		if(P)
			var/obj/machinery/telecomms/T = P.buffer
			if(istype(T))
				dat += "<br><br>MULTITOOL BUFFER: [T] ([T.id]) <a href='?src=\ref[src];link=1'>\[Link\]</a> <a href='?src=\ref[src];flush=1'>\[Flush\]"
			else
				dat += "<br><br>MULTITOOL BUFFER: <a href='?src=\ref[src];buffer=1'>\[Add Machine\]</a>"

	dat += "</font>"
	temp = ""
	user << browse(dat, "window=tcommachine;size=520x500;can_resize=0")
	onclose(user, "dormitory")

=======

		dat += {"</ol>
			<h2>Filtering Frequencies:</h2>"}
		i = 0
		if(length(freq_listening))
			dat += "<ul>"
			for(var/x in freq_listening)
				dat += "<li>[format_frequency(x)] GHz<a href='?src=\ref[src];delete=[x]'>\[X\]</a></li>"
			dat += "</ul>"
		else
			dat += "<li>NONE</li>"


		dat += {"<p><a href='?src=\ref[src];input=freq'>\[Add Filter\]</a></p>
			<hr />"}

	return dat

/obj/machinery/telecomms/canLink(var/obj/O)
	return istype(O,/obj/machinery/telecomms)

/obj/machinery/telecomms/isLinkedWith(var/obj/O)
	return O != null && O in links

/obj/machinery/telecomms/getLink(var/idx)
	return (idx >= 1 && idx <= links.len) ? links[idx] : null
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

// Off-Site Relays
//
// You are able to send/receive signals from the station's z level (changeable in the STATION_Z #define) if
// the relay is on the telecomm satellite (changable in the TELECOMM_Z #define)


/obj/machinery/telecomms/relay/proc/toggle_level()

<<<<<<< HEAD
=======

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/turf/position = get_turf(src)

	// Toggle on/off getting signals from the station or the current Z level
	if(src.listening_level == STATION_Z) // equals the station
		src.listening_level = position.z
		return 1
	else if(position.z == TELECOMM_Z)
		src.listening_level = STATION_Z
		return 1
	return 0

<<<<<<< HEAD
// Returns a multitool from a user depending on their mobtype.

/obj/machinery/telecomms/proc/get_multitool(mob/user)

	var/obj/item/device/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_hand(), /obj/item/device/multitool))
		P = user.get_active_hand()
	else if(isAI(user))
		var/mob/living/silicon/ai/U = user
		P = U.aiMulti
	else if(isrobot(user) && in_range(user, src))
		if(istype(user.get_active_hand(), /obj/item/device/multitool))
			P = user.get_active_hand()
	return P

=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
// Additional Options for certain machines. Use this when you want to add an option to a specific machine.
// Example of how to use below.

/obj/machinery/telecomms/proc/Options_Menu()
	return ""

<<<<<<< HEAD
=======
/*
// Add an option to the processor to switch processing mode. (COMPRESS -> UNCOMPRESS or UNCOMPRESS -> COMPRESS)
/obj/machinery/telecomms/processor/Options_Menu()
	var/dat = "<br>Processing Mode: <A href='?src=\ref[src];process=1'>[process_mode ? "UNCOMPRESS" : "COMPRESS"]</a>"
	return dat
*/
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
// The topic for Additional Options. Use this for checking href links for your specific option.
// Example of how to use below.
/obj/machinery/telecomms/proc/Options_Topic(href, href_list)
	return

<<<<<<< HEAD
=======
/*
/obj/machinery/telecomms/processor/Options_Topic(href, href_list)

	if(href_list["process"])
		temp = "<font color = #666633>-% Processing mode changed. %-</font color>"
		src.process_mode = !src.process_mode
*/

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
// RELAY

/obj/machinery/telecomms/relay/Options_Menu()
	var/dat = ""
	if(src.z == TELECOMM_Z)
		dat += "<br>Signal Locked to Station: <A href='?src=\ref[src];change_listening=1'>[listening_level == STATION_Z ? "TRUE" : "FALSE"]</a>"
<<<<<<< HEAD
	dat += "<br>Broadcasting: <A href='?src=\ref[src];broadcast=1'>[broadcasting ? "YES" : "NO"]</a>"
	dat += "<br>Receiving:    <A href='?src=\ref[src];receive=1'>[receiving ? "YES" : "NO"]</a>"
=======

	dat += {"<br>Broadcasting: <A href='?src=\ref[src];broadcast=1'>[broadcasting ? "YES" : "NO"]</a>
		<br>Receiving:    <A href='?src=\ref[src];receive=1'>[receiving ? "YES" : "NO"]</a>"}
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return dat

/obj/machinery/telecomms/relay/Options_Topic(href, href_list)

	if(href_list["receive"])
		receiving = !receiving
		temp = "<font color = #666633>-% Receiving mode changed. %-</font color>"
	if(href_list["broadcast"])
		broadcasting = !broadcasting
		temp = "<font color = #666633>-% Broadcasting mode changed. %-</font color>"
	if(href_list["change_listening"])
		//Lock to the station OR lock to the current position!
		//You need at least two receivers and two broadcasters for this to work, this includes the machine.
		var/result = toggle_level()
		if(result)
			temp = "<font color = #666633>-% [src]'s signal has been successfully changed.</font color>"
		else
			temp = "<font color = #666633>-% [src] could not lock it's signal onto the station. Two broadcasters or receivers required.</font color>"

// BUS

/obj/machinery/telecomms/bus/Options_Menu()
	var/dat = "<br>Change Signal Frequency: <A href='?src=\ref[src];change_freq=1'>[change_frequency ? "YES ([change_frequency])" : "NO"]</a>"
	return dat

/obj/machinery/telecomms/bus/Options_Topic(href, href_list)

	if(href_list["change_freq"])

		var/newfreq = input(usr, "Specify a new frequency for new signals to change to. Enter null to turn off frequency changing. Decimals assigned automatically.", src, network) as null|num
		if(canAccess(usr))
			if(newfreq)
				if(findtext(num2text(newfreq), "."))
					newfreq *= 10 // shift the decimal one place
				if(newfreq < 10000)
					change_frequency = newfreq
					temp = "<font color = #666633>-% New frequency to change to assigned: \"[newfreq] GHz\" %-</font color>"
			else
				change_frequency = 0
				temp = "<font color = #666633>-% Frequency changing deactivated %-</font color>"


/obj/machinery/telecomms/Topic(href, href_list)
	if(..())
		return

	if(!issilicon(usr))
		if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
			return

	var/obj/item/device/multitool/P = get_multitool(usr)
<<<<<<< HEAD
=======
	if(!istype(P))
		testing("get_multitool returned [P].")
		return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	if(href_list["input"])
		switch(href_list["input"])

			if("toggle")
<<<<<<< HEAD

=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
				src.toggled = !src.toggled
				temp = "<font color = #666633>-% [src] has been [src.toggled ? "activated" : "deactivated"].</font color>"
				update_power()

			/*
			if("hide")
				src.hide = !hide
				temp = "<font color = #666633>-% Shadow Link has been [src.hide ? "activated" : "deactivated"].</font color>"
			*/

			if("id")
				var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID for this machine", src, id) as null|text),1,MAX_MESSAGE_LEN)
				if(newid && canAccess(usr))
					id = newid
					temp = "<font color = #666633>-% New ID assigned: \"[id]\" %-</font color>"

			if("network")
<<<<<<< HEAD
				var/newnet = stripped_input(usr, "Specify the new network for this machine. This will break all current links.", src, network)
=======
				var/newnet = input(usr, "Specify the new network for this machine. This will break all current links.", src, network) as null|text
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
				if(newnet && canAccess(usr))

					if(length(newnet) > 15)
						temp = "<font color = #666633>-% Too many characters in new network tag %-</font color>"

					else
						for(var/obj/machinery/telecomms/T in links)
							T.links.Remove(src)

						network = newnet
						links = list()
						temp = "<font color = #666633>-% New network tag assigned: \"[network]\" %-</font color>"


			if("freq")
				var/newfreq = input(usr, "Specify a new frequency to filter (GHz). Decimals assigned automatically.", src, network) as null|num
				if(newfreq && canAccess(usr))
					if(findtext(num2text(newfreq), "."))
						newfreq *= 10 // shift the decimal one place
<<<<<<< HEAD
					if(newfreq == SYND_FREQ)
						temp = "<font color = #FF0000>-% Error: Interference preventing filtering frequency: \"[newfreq] GHz\" %-</font color>"
					else
						if(!(newfreq in freq_listening) && newfreq < 10000)
							freq_listening.Add(newfreq)
							temp = "<font color = #666633>-% New frequency filter assigned: \"[newfreq] GHz\" %-</font color>"
=======
					if(!(newfreq in freq_listening) && newfreq < 10000)
						freq_listening.Add(newfreq)
						temp = "<font color = #666633>-% New frequency filter assigned: \"[newfreq] GHz\" %-</font color>"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	if(href_list["delete"])

		// changed the layout about to workaround a pesky runtime -- Doohl

		var/x = text2num(href_list["delete"])
		temp = "<font color = #666633>-% Removed frequency filter [x] %-</font color>"
		freq_listening.Remove(x)

<<<<<<< HEAD
	if(href_list["unlink"])

		if(text2num(href_list["unlink"]) <= length(links))
			var/obj/machinery/telecomms/T = links[text2num(href_list["unlink"])]
			if(T)
				temp = "<font color = #666633>-% Removed \ref[T] [T.name] from linked entities. %-</font color>"

				// Remove link entries from both T and src.

				if(T.links)
					T.links.Remove(src)
				links.Remove(T)

			else
				temp = "<font color = #666633>-% Unable to locate machine to unlink from, try again. %-</font color>"

	if(href_list["link"])

		if(P)
			var/obj/machinery/telecomms/T = P.buffer
			if(istype(T) && T != src)
				if(!(src in T.links))
					T.links.Add(src)

				if(!(T in src.links))
					src.links.Add(T)

				temp = "<font color = #666633>-% Successfully linked with \ref[T] [T.name] %-</font color>"

			else
				temp = "<font color = #666633>-% Unable to acquire buffer %-</font color>"

	if(href_list["buffer"])

		P.buffer = src
		temp = "<font color = #666633>-% Successfully stored \ref[P.buffer] [P.buffer.name] in buffer %-</font color>"


	if(href_list["flush"])

		temp = "<font color = #666633>-% Buffer successfully flushed. %-</font color>"
		P.buffer = null

	src.Options_Topic(href, href_list)

	usr.set_machine(src)

	updateUsrDialog()

/obj/machinery/telecomms/proc/canAccess(mob/user)
	if(issilicon(user) || in_range(user, src))
		return 1
	return 0

#undef TELECOMM_Z
#undef STATION_Z
=======
	src.Options_Topic(href, href_list)
	usr.set_machine(src)
	updateUsrDialog()

/obj/machinery/telecomms/unlinkFrom(var/mob/user, var/mob/O)
	if(O && O in links)
		var/obj/machinery/telecomms/T=O
		if(T.links)
			T.links.Remove(src)
		links.Remove(O)
		temp = "<font color = #666633>-% Removed \ref[T] [T.name] from linked entities. %-</font color>"
		return 1
	else
		temp = "<font color = #666633>-% Unable to locate machine to unlink from, try again. %-</font color>"
		return 0

/obj/machinery/telecomms/linkWith(var/mob/user, var/mob/O)
	if(O && O != src && istype(O, /obj/machinery/telecomms))
		var/obj/machinery/telecomms/T=O
		if(!(src in T.links))
			T.links.Add(src)

		if(!(T in src.links))
			src.links.Add(T)

		temp = "<font color = #666633>-% Successfully linked with \ref[O] [O.name] %-</font color>"
		return 1
	else if (O == src)
		temp = "<font color = #666633>-% This machine can't be linked with itself %-</font color>"
		return 0
	else
		temp = "<font color = #666633>-% Unable to acquire buffer %-</font color>"
		return 0

/obj/machinery/telecomms/proc/canAccess(var/mob/user)
	if(issilicon(user) || in_range(src,user))
		return 1
	return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
