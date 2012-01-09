
/*

	All telecommunications interactions:

*/

/obj/machinery/telecomms
	var
		temp = "" // output message



	attackby(obj/item/P as obj, mob/user as mob)

		// Using a multitool lets you access the receiver's interface
		if(istype(P, /obj/item/device/multitool))
			attack_hand(user)

	attack_hand(var/mob/user as mob)

		// You need a multitool to use this.
		if(user.equipped())
			if(!istype(user.equipped(), /obj/item/device/multitool))
				return
		else
			return

		if(stat & (BROKEN|NOPOWER))
			return

		var/obj/item/device/multitool/P = user.equipped()

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
		for(var/obj/machinery/telecomms/T in links)
			dat += "<li>\ref[T] [T.name] ([T.id])</li>"
		dat += "</ol>"

		dat += "<br>Filtering Frequencies: "
		var/i = 0

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
		if(P.buffer)
			dat += "<br><br>MULTITOOL BUFFER: \ref[P.buffer] [P.buffer] <a href='?src=\ref[src];link=1'>\[Link\]</a> <a href='?src=\ref[src];flush=1'>\[Flush\]"
		else
			dat += "<br><br>MULTITOOL BUFFER: <a href='?src=\ref[src];buffer=1'>\[Add Machine\]</a>"

		dat += "</font>"
		temp = ""
		user << browse(dat, "window=[src.name];size=520x500;can_resize=0")
		onclose(user, "dormitory")

	Topic(href, href_list)

		if(usr.equipped())
			if(!istype(usr.equipped(), /obj/item/device/multitool))
				return
		else
			return

		if(stat & (BROKEN|NOPOWER))
			return

		var/obj/item/device/multitool/P = usr.equipped()

		if(href_list["input"])
			switch(href_list["input"])

				if("id")
					var/newid = input(usr, "Specify the new ID for this machine", src, id) as null|text
					if(newid && usr in range(1, src))
						id = newid
						temp = "<font color = #666633>-% New ID assigned: \"[id]\" %-</font color>"

				if("network")
					var/newnet = input(usr, "Specify the new network for this machine. This will break all current links.", src, network) as null|text
					if(newnet && usr in range(1, src) && newnet != network)

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

		if(href_list["link"])

			if(P.buffer)
				if(!(src in P.buffer.links))
					P.buffer.links.Add(src)

				if(!(P.buffer in src.links))
					src.links.Add(P.buffer)

				temp = "<font color = #666633>-% Successfully linked with \ref[P.buffer] [P.buffer.name] %-</font color>"

			else
				temp = "<font color = #666633>-% Unable to acquire buffer %-</font color>"

		if(href_list["buffer"])

			temp = "<font color = #666633>-% Successfully stored \ref[P.buffer] [P.buffer.name] in buffer %-</font color>"
			P.buffer = src


		if(href_list["flush"])

			temp = "<font color = #666633>-% Buffer successfully flushed. %-</font color>"
			P.buffer = null


		usr.machine = src
		src.add_fingerprint(usr)

		updateUsrDialog()


