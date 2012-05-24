
/*

	All telecommunications interactions:

*/

/obj/machinery/telecomms
	var
		temp = "" // output message
		construct_op = 0



	attackby(obj/item/P as obj, mob/user as mob)

		// Using a multitool lets you access the receiver's interface
		if(istype(P, /obj/item/device/multitool))
			attack_hand(user)

		switch(construct_op)
			if(0)
				if(istype(P, /obj/item/weapon/screwdriver))
					user << "You unfasten the bolts."
					playsound(src.loc, 'Screwdriver.ogg', 50, 1)
					construct_op ++
			if(1)
				if(istype(P, /obj/item/weapon/screwdriver))
					user << "You fasten the bolts."
					playsound(src.loc, 'Screwdriver.ogg', 50, 1)
					construct_op --
				if(istype(P, /obj/item/weapon/wrench))
					user << "You dislodge the external plating."
					playsound(src.loc, 'Ratchet.ogg', 75, 1)
					construct_op ++
			if(2)
				if(istype(P, /obj/item/weapon/wrench))
					user << "You secure the external plating."
					playsound(src.loc, 'Ratchet.ogg', 75, 1)
					construct_op --
				if(istype(P, /obj/item/weapon/wirecutters))
					playsound(src.loc, 'wirecutter.ogg', 50, 1)
					user << "You remove the cables."
					construct_op ++
					var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( user.loc )
					A.amount = 5
					stat |= BROKEN // the machine's been borked!
			if(3)
				if(istype(P, /obj/item/weapon/cable_coil))
					var/obj/item/weapon/cable_coil/A = P
					if(A.amount >= 5)
						user << "You insert the cables."
						A.amount -= 5
						if(A.amount <= 0)
							user.drop_item()
							del(A)
						construct_op --
						stat &= ~BROKEN // the machine's not borked anymore!
				if(istype(P, /obj/item/weapon/crowbar))
					user << "You begin prying out the circuit board other components..."
					playsound(src.loc, 'Crowbar.ogg', 50, 1)
					if(do_after(user,60))
						user << "You finish prying out the components."

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
									if(istype(P, /obj/item/weapon/cable_coil))
										var/obj/item/weapon/cable_coil/A = P
										A.amount = 1

							// Drop a circuit board too
							C.loc = user.loc

						// Create a machine frame and delete the current machine
						var/obj/machinery/constructable_frame/machine_frame/F = new
						F.loc = src.loc
						del(src)


	attack_ai(var/mob/user as mob)
		attack_hand(user)

	attack_hand(var/mob/user as mob)

		// You need a multitool to use this, or be silicon
		if(!issilicon(user))
			if(user.equipped())
				if(!istype(user.equipped(), /obj/item/device/multitool))
					return
			else
				return

		if(stat & (BROKEN|NOPOWER) || !on)
			return

		var/obj/item/device/multitool/P = null
		if(!issilicon(user))
			P = user.equipped()

		user.machine = src
		var/dat
		dat = "<font face = \"Courier\"><HEAD><TITLE>[src.name]</TITLE></HEAD><center><H3>[src.name] Access</H3></center>"
		dat += "<br>[temp]<br>"

		if(id != "" && id)
			dat += "<br>Identification String: <a href='?src=\ref[src];input=id'>[id]</a>"
		else
			dat += "<br>Identification String: <a href='?src=\ref[src];input=id'>NULL</a>"
		dat += "<br>Network: <a href='?src=\ref[src];input=network'>[network]</a>"
		dat += "<br>Prefabrication: [autolinkers.len ? "TRUE" : "FALSE"]"
		dat += "<br>Linked Network Entities: <ol>"

		var/i = 0
		for(var/obj/machinery/telecomms/T in links)
			i++
			dat += "<li>\ref[T] [T.name] ([T.id])  <a href='?src=\ref[src];unlink=[i]'>\[X\]</a></li>"
		dat += "</ol>"

		dat += "<br>Filtering Frequencies: "

		i = 0
		if(length(freq_listening))
			for(var/x in freq_listening)
				i++
				if(i < length(freq_listening))
					dat += "[format_frequency(x)] GHz<a href='?src=\ref[src];delete=[i]'>\[X\]</a>; "
				else
					dat += "[format_frequency(x)] GHz<a href='?src=\ref[src];delete=[i]'>\[X\]</a>"
		else
			dat += "NONE"

		dat += "<br>  <a href='?src=\ref[src];input=freq'>\[Add Filter\]</a>"
		dat += "<hr>"

		if(P)
			if(P.buffer)
				dat += "<br><br>MULTITOOL BUFFER: [P.buffer] ([P.buffer.id]) <a href='?src=\ref[src];link=1'>\[Link\]</a> <a href='?src=\ref[src];flush=1'>\[Flush\]"
			else
				dat += "<br><br>MULTITOOL BUFFER: <a href='?src=\ref[src];buffer=1'>\[Add Machine\]</a>"

		dat += "</font>"
		temp = ""
		user << browse(dat, "window=tcommachine;size=520x500;can_resize=0")
		onclose(user, "dormitory")

	Topic(href, href_list)

		if(!issilicon(usr))
			if(usr.equipped())
				if(!istype(usr.equipped(), /obj/item/device/multitool))
					return
			else
				return

		if(stat & (BROKEN|NOPOWER) || !on)
			return

		var/obj/item/device/multitool/P = null
		if(!issilicon(usr))
			P = usr.equipped()

		if(href_list["input"])
			switch(href_list["input"])

				if("id")
					var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID for this machine", src, id) as null|text),1,MAX_MESSAGE_LEN)
					if(newid && usr in range(1, src))
						id = newid
						temp = "<font color = #666633>-% New ID assigned: \"[id]\" %-</font color>"

				if("network")
					var/newnet = input(usr, "Specify the new network for this machine. This will break all current links.", src, network) as null|text
					if(newnet && usr in range(1, src))

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
					if(newfreq && usr in range(1, src))
						if(!(newfreq in freq_listening))

							if(findtext(num2text(newfreq), "."))
								newfreq *= 10 // shift the decimal one place

							freq_listening.Add(newfreq)
							temp = "<font color = #666633>-% New frequency filter assigned: \"[newfreq] GHz\" %-</font color>"

		if(href_list["delete"])

			var/x = freq_listening[text2num(href_list["delete"])]
			temp = "<font color = #666633>-% Removed frequency filter [x] %-</font color>"
			freq_listening.Remove(x)

		if(href_list["unlink"])

			if(text2num(href_list["unlink"]) <= length(links))
				var/obj/machinery/telecomms/T = links[text2num(href_list["unlink"])]
				temp = "<font color = #666633>-% Removed \ref[T] [T.name] from linked entities. %-</font color>"

				// Remove link entries from both T and src.
				if(src in T.links)
					T.links.Remove(src)
				links.Remove(T)

		if(href_list["link"])

			if(P)

				if(P.buffer)
					if(!(src in P.buffer.links))
						P.buffer.links.Add(src)

					if(!(P.buffer in src.links))
						src.links.Add(P.buffer)

					temp = "<font color = #666633>-% Successfully linked with \ref[P.buffer] [P.buffer.name] %-</font color>"

				else
					temp = "<font color = #666633>-% Unable to acquire buffer %-</font color>"

		if(href_list["buffer"])

			P.buffer = src
			temp = "<font color = #666633>-% Successfully stored \ref[P.buffer] [P.buffer.name] in buffer %-</font color>"


		if(href_list["flush"])

			temp = "<font color = #666633>-% Buffer successfully flushed. %-</font color>"
			P.buffer = null


		usr.machine = src
		src.add_fingerprint(usr)

		updateUsrDialog()


