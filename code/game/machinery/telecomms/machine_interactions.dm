
/*

	All telecommunications interactions:

*/

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

	// You need a multitool to use this, or be silicon
	if(!issilicon(user))
		// istype returns false if the value is null
		if(!istype(user.get_active_held_item(), /obj/item/device/multitool))
			return

	if(stat & (BROKEN|NOPOWER))
		return

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

		//Show additional options for certain machines.
		dat += Options_Menu()

		dat += "<br>Linked Network Entities: <ol>"

		var/i = 0
		for(var/obj/machinery/telecomms/T in links)
			i++
			if(T.hide && !src.hide)
				continue
			dat += "<li>\ref[T] [T.name] ([T.id])  <a href='?src=\ref[src];unlink=[i]'>\[X\]</a></li>"
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


// Off-Site Relays
//
// You are able to send/receive signals from the station's z level (changeable in the STATION_Z #define) if
// the relay is on the telecomm satellite (changable in the TELECOMM_Z #define)


/obj/machinery/telecomms/relay/proc/toggle_level()

	var/turf/position = get_turf(src)

	// Toggle on/off getting signals from the station or the current Z level
	if(src.listening_level == STATION_Z) // equals the station
		src.listening_level = position.z
		return 1
	else if(position.z == TELECOMM_Z)
		src.listening_level = STATION_Z
		return 1
	return 0

// Returns a multitool from a user depending on their mobtype.

/obj/machinery/telecomms/proc/get_multitool(mob/user)

	var/obj/item/device/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_held_item(), /obj/item/device/multitool))
		P = user.get_active_held_item()
	else if(isAI(user))
		var/mob/living/silicon/ai/U = user
		P = U.aiMulti
	else if(iscyborg(user) && in_range(user, src))
		if(istype(user.get_active_held_item(), /obj/item/device/multitool))
			P = user.get_active_held_item()
	return P

// Additional Options for certain machines. Use this when you want to add an option to a specific machine.
// Example of how to use below.

/obj/machinery/telecomms/proc/Options_Menu()
	return ""

// The topic for Additional Options. Use this for checking href links for your specific option.
// Example of how to use below.
/obj/machinery/telecomms/proc/Options_Topic(href, href_list)
	return

// RELAY

/obj/machinery/telecomms/relay/Options_Menu()
	var/dat = ""
	if(src.z == TELECOMM_Z)
		dat += "<br>Signal Locked to Station: <A href='?src=\ref[src];change_listening=1'>[listening_level == STATION_Z ? "TRUE" : "FALSE"]</a>"
	dat += "<br>Broadcasting: <A href='?src=\ref[src];broadcast=1'>[broadcasting ? "YES" : "NO"]</a>"
	dat += "<br>Receiving:    <A href='?src=\ref[src];receive=1'>[receiving ? "YES" : "NO"]</a>"
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
			temp = "<font color = #666633>-% [src] could not lock its signal onto the station. Two broadcasters or receivers required.</font color>"

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
		if(!istype(usr.get_active_held_item(), /obj/item/device/multitool))
			return

	var/obj/item/device/multitool/P = get_multitool(usr)

	if(href_list["input"])
		switch(href_list["input"])

			if("toggle")

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
				var/newnet = stripped_input(usr, "Specify the new network for this machine. This will break all current links.", src, network)
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
					if(newfreq == SYND_FREQ)
						temp = "<font color = #FF0000>-% Error: Interference preventing filtering frequency: \"[newfreq] GHz\" %-</font color>"
					else
						if(!(newfreq in freq_listening) && newfreq < 10000)
							freq_listening.Add(newfreq)
							temp = "<font color = #666633>-% New frequency filter assigned: \"[newfreq] GHz\" %-</font color>"

	if(href_list["delete"])

		// changed the layout about to workaround a pesky runtime -- Doohl

		var/x = text2num(href_list["delete"])
		temp = "<font color = #666633>-% Removed frequency filter [x] %-</font color>"
		freq_listening.Remove(x)

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
