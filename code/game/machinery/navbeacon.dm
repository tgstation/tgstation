// Navigation beacon for AI robots
// Functions as a transponder: looks for incoming signal matching

/obj/machinery/navbeacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0-f"
	name = "navigation beacon"
	desc = "A radio beacon used for bot navigation."
	level = 1		// underfloor
	layer = 2.5
	anchored = 1

	var/open = 0		// true if cover is open
	var/locked = 1		// true if controls are locked
	var/freq = 1445		// radio frequency
	var/location = ""	// location response text
	var/list/codes		// assoc. list of transponder codes
	var/codes_txt = ""	// codes as set on map: "tag1;tag2" or "tag1=value;tag2=value"

	req_access = list(access_engine)

	New()
		..()

		set_codes()

		var/turf/T = loc
		hide(T.intact)

		spawn(5)	// must wait for map loading to finish
			if(radio_controller)
				radio_controller.add_object(src, freq, RADIO_NAVBEACONS)

	// set the transponder codes assoc list from codes_txt
	proc/set_codes()
		if(!codes_txt)
			return

		codes = new()

		var/list/entries = text2list(codes_txt, ";")	// entries are separated by semicolons

		for(var/e in entries)
			var/index = findtext(e, "=")		// format is "key=value"
			if(index)
				var/key = copytext(e, 1, index)
				var/val = copytext(e, index+1)
				codes[key] = val
			else
				codes[e] = "1"


	// called when turf state changes
	// hide the object if turf is intact
	hide(var/intact)
		invisibility = intact ? 101 : 0
		updateicon()

	// update the icon_state
	proc/updateicon()
		var/state="navbeacon[open]"

		if(invisibility)
			icon_state = "[state]-f"	// if invisible, set icon to faded version
										// in case revealed by T-scanner
		else
			icon_state = "[state]"


	// look for a signal of the form "findbeacon=X"
	// where X is any
	// or the location
	// or one of the set transponder keys
	// if found, return a signal
	receive_signal(datum/signal/signal)

		var/request = signal.data["findbeacon"]
		if(request && ((request in codes) || request == "any" || request == location))
			spawn(1)
				post_signal()

	// return a signal giving location and transponder codes

	proc/post_signal()

		var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

		if(!frequency) return

		var/datum/signal/signal = new()
		signal.source = src
		signal.transmission_method = 1
		signal.data["beacon"] = location

		for(var/key in codes)
			signal.data[key] = codes[key]

		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)


	attackby(var/obj/item/I, var/mob/user)
		var/turf/T = loc
		if(T.intact)
			return		// prevent intraction when T-scanner revealed

		if(istype(I, /obj/item/weapon/screwdriver))
			open = !open

			user.visible_message("[user] [open ? "opens" : "closes"] the beacon's cover.", "You [open ? "open" : "close"] the beacon's cover.")

			updateicon()

		else if (istype(I, /obj/item/weapon/card/id)||istype(I, /obj/item/device/pda))
			if(open)
				if (src.allowed(user))
					src.locked = !src.locked
					user << "Controls are now [src.locked ? "locked." : "unlocked."]"
				else
					user << "\red Access denied."
				updateDialog()
			else
				user << "You must open the cover first!"
		return

	attack_ai(var/mob/user)
		interact(user, 1)

	attack_paw()
		return

	attack_hand(var/mob/user)
		interact(user, 0)

	proc/interact(var/mob/user, var/ai = 0)
		var/turf/T = loc
		if(T.intact)
			return		// prevent intraction when T-scanner revealed

		if(!open && !ai)	// can't alter controls if not open, unless you're an AI
			user << "The beacon's control cover is closed."
			return


		var/t

		if(locked && !ai)
			t = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to unlock controls)</i><BR>
Frequency: [format_frequency(freq)]<BR><HR>
Location: [location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

			for(var/key in codes)
				t += "<LI>[key] ... [codes[key]]"
			t+= "<UL></TT>"

		else

			t = {"<TT><B>Navigation Beacon</B><HR><BR>
<i>(swipe card to lock controls)</i><BR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A>
[format_frequency(freq)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
<HR>
Location: <A href='byond://?src=\ref[src];locedit=1'>[location ? location : "(none)"]</A><BR>
Transponder Codes:<UL>"}

			for(var/key in codes)
				t += "<LI>[key] ... [codes[key]]"
				t += " <small><A href='byond://?src=\ref[src];edit=1;code=[key]'>(edit)</A>"
				t += " <A href='byond://?src=\ref[src];delete=1;code=[key]'>(delete)</A></small><BR>"
			t += "<small><A href='byond://?src=\ref[src];add=1;'>(add new)</A></small><BR>"
			t+= "<UL></TT>"

		user << browse(t, "window=navbeacon")
		onclose(user, "navbeacon")
		return

	Topic(href, href_list)
		..()
		if (usr.stat)
			return
		if ((in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
			if(open && !locked)
				usr.machine = src

				if (href_list["freq"])
					freq = sanitize_frequency(freq + text2num(href_list["freq"]))
					updateDialog()

				else if(href_list["locedit"])
					var/newloc = copytext(sanitize(input("Enter New Location", "Navigation Beacon", location) as text|null),1,MAX_MESSAGE_LEN)
					if(newloc)
						location = newloc
						updateDialog()

				else if(href_list["edit"])
					var/codekey = href_list["code"]

					var/newkey = input("Enter Transponder Code Key", "Navigation Beacon", codekey) as text|null
					if(!newkey)
						return

					var/codeval = codes[codekey]
					var/newval = input("Enter Transponder Code Value", "Navigation Beacon", codeval) as text|null
					if(!newval)
						newval = codekey
						return

					codes.Remove(codekey)
					codes[newkey] = newval

					updateDialog()

				else if(href_list["delete"])
					var/codekey = href_list["code"]
					codes.Remove(codekey)
					updateDialog()

				else if(href_list["add"])

					var/newkey = input("Enter New Transponder Code Key", "Navigation Beacon") as text|null
					if(!newkey)
						return

					var/newval = input("Enter New Transponder Code Value", "Navigation Beacon") as text|null
					if(!newval)
						newval = "1"
						return

					if(!codes)
						codes = new()

					codes[newkey] = newval

					updateDialog()




