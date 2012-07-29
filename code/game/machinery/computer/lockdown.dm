//this computer displays status and remotely activates multiple shutters / blast doors
//todo: lock / electrify specified area doors? might be a bit gamebreaking

/obj/machinery/computer/lockdown
	//for reference
	/*name = "Lockdown Control"
	desc = "Used to control blast doors."
	icon_state = "lockdown"
	circuit = "/obj/item/weapon/circuitboard/lockdown"
	var/connected_doors
	var/department*/
	var/list/displayedNetworks

	New()
		..()
		connected_doors = new/list()
		displayedNetworks  = new/list()
		//only load blast doors for map-defined departments for the moment
		//door networks are hardcoded here.
		switch(department)
			if("Engineering")
				connected_doors.Add("Engineering")
				//Antiqua Engineering
				connected_doors.Add("Reactor core")
				connected_doors.Add("Control Room")
				connected_doors.Add("Vent Seal")
				connected_doors.Add("Rig Storage")
				connected_doors.Add("Fore Port Shutters")
				connected_doors.Add("Fore Starboard Shutters")
				connected_doors.Add("Electrical Storage Shutters")
				connected_doors.Add("Locker Room Shutters")
				connected_doors.Add("Breakroom Shutters")
				connected_doors.Add("Observation Shutters")
				//exodus engineering
			if("Medbay")
				//Exodus Medbay
				connected_doors.Add("Genetics Outer Shutters")
				connected_doors.Add("Genetics Inner Shutters")
				connected_doors.Add("Chemistry Outer Shutters")
				connected_doors.Add("Observation Shutters")
				connected_doors.Add("Patient Room 1 Shutters")
				connected_doors.Add("Patient Room 2 Shutters")
				connected_doors.Add("Patient Room 3 Shutters")

		for(var/net in connected_doors)
			connected_doors[net] = new/list()

		//loop through the world, grabbing all the relevant doors
		spawn(1)
			ConnectDoors()

	proc/ConnectDoors()
		for(var/list/L in connected_doors)
			for(var/item in L)
				L.Remove(item)
		//
		for(var/obj/machinery/door/poddoor/D in world)
			if(D.network in connected_doors)
				var/list/L = connected_doors[D.network]
				L.Add(D)

	attack_ai(mob/user)
		attack_hand(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			return

		if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
			if (!istype(user, /mob/living/silicon))
				user.machine = null
				user << browse(null, "window=lockdown")
				return

		var/t = "<B>Lockdown Control</B><BR>"
		t += "<A href='?src=\ref[src];refresh=1'>Refresh</A><BR>"
		t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		t += "<table border=1>"
		var/empty = 1
		for(var/curNetId in connected_doors)
			var/list/L = connected_doors[curNetId]
			if(!L || L.len == 0)
				continue
			empty = 0
			t += "<tr>"
			if(curNetId in displayedNetworks)
				t += "<td><a href='?src=\ref[src];hide_net=[curNetId]'>\[-\]</a><b> " + curNetId + "<b></td>"
				t += "<td colspan=\"2\"><b><a href='?src=\ref[src];open_net=[curNetId]'>Open all</a> / <a href='?src=\ref[src];close_net=[curNetId]'>Close all</a></b></td>"
				t += "</tr>"

				for(var/obj/machinery/door/poddoor/D in connected_doors[curNetId])
					t += "<tr>"
					t += "<td>[D.id]</td>"

					if(istype(D,/obj/machinery/door/poddoor/shutters))
						t += "<td>Shutter ([D.density ? "Closed" : "Open"])</td>"
					else
						t += "<td>Blast door ([D.density ? "Closed" : "Open"])</td>"
					t += "<td><b><a href='?src=\ref[D];toggle=1'>Toggle</a></b></td>"
					t += "</tr>"
			else
				t += "<td><a href='?src=\ref[src];show_net=[curNetId]'>\[+\]</a> <b>" + curNetId + "<b></td>"
		t += "</table>"
		if(empty)
			t += "\red No networks connected.<br>"
		t += "<A href='?src=\ref[src];refresh=1'>Refresh</A><BR>"
		t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		user << browse(t, "window=lockdown;size=550x600")
		onclose(user, "lockdown")

	Topic(href, href_list)
		..()

		if( href_list["close"] )
			usr << browse(null, "window=lockdown")
			usr.machine = null

		if( href_list["show_net"] )
			displayedNetworks.Add(href_list["show_net"])
			updateDialog()

		if( href_list["hide_net"] )
			if(href_list["hide_net"] in displayedNetworks)
				displayedNetworks.Remove(href_list["hide_net"])
				updateDialog()

		if( href_list["toggle_id"] )
			var/idTag = href_list["toggle_id"]
			for(var/net in connected_doors)
				for(var/obj/machinery/door/poddoor/D in connected_doors[net])
					if(D.id == idTag)
						if(D.density)
							D.open()
						else
							D.close()
						break

		if( href_list["open_net"] )
			var/netTag = href_list["open_net"]
			for(var/obj/machinery/door/poddoor/D in connected_doors[netTag])
				if(D.density)	//for some reason, there's no var saying whether the door is open or not >.>
					spawn(0)
						D.open()

		if( href_list["close_net"] )
			var/netTag = href_list["close_net"]
			for(var/obj/machinery/door/poddoor/D in connected_doors[netTag])
				if(!D.density)
					spawn(0)
						D.close()

		src.updateDialog()
