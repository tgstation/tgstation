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

	New()
		..()
		connected_doors = new/list()
		//only load blast doors for map-defined departments for the moment
		//door networks are hardcoded here.
		switch(department)
			if("Engineering")
				//Antiqua SinguloEngineering
				connected_doors.Add("Engineering Primary Access")
				connected_doors.Add("Engineering Secondary Access")
				connected_doors.Add("Fore Maintenance Access")
				connected_doors.Add("Aft Maintenance Access")
				connected_doors.Add("Particle Accelerator Rad Shielding")
				connected_doors.Add("Foreward Emitter Array Rad Shielding")
				connected_doors.Add("Aftward Emitter Array Rad Shielding")
				connected_doors.Add("Starboard Observation Rad Shielding")
				connected_doors.Add("Atmospheric Storage Rad Shielding")
				connected_doors.Add("Construction Storage Rad Shielding")
				connected_doors.Add("Engineering Secure Storage")
				//Antiqua RustEngineering
				connected_doors.Add("Port vessel entry")
				connected_doors.Add("Starboard vessel entry")
				connected_doors.Add("Central aft shell access")
				connected_doors.Add("Port aft shell access")
				connected_doors.Add("Starboard aft shell access")
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
			world << "network: [net]"

		//loop through the world, grabbing all the relevant doors
		spawn(1)
			for(var/obj/machinery/door/poddoor/D in world)
				if(D.id in connected_doors)
					var/list/L = connected_doors[D.id]
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
		t += "<A href='?src=\ref[src];close=1'>Close</A><hr>"
		t += "<table border=1>"
		var/empty = 1
		for(var/curNetId in connected_doors)
			var/list/L = connected_doors[curNetId]
			if(!L || L.len == 0)
				continue
			empty = 0
			t += "<tr>"
			t += "<td><b>" + curNetId + "<b></td>"
			t += "<td><b><a href='?src=\ref[src];open_net=[curNetId]'>Disable lockdown</a> / <a href='?src=\ref[src];close_net=[curNetId]'>Enable lockdown</a></b></td>"
			t += "</tr>"

			for(var/obj/machinery/door/poddoor/D in connected_doors[curNetId])
				t += "<tr>"
				if(istype(D,/obj/machinery/door/poddoor/shutters))
					t += "<td>	Shutter</td>"
				else
					t += "<td>	Blast door</td>"
				if(D.density)
					//t += "<td><a href='?src=\ref[D];open=1'>Open</a> - Close</td>"
					t += "Closed"
				else
					//t += "<td>Open - <a href='?src=\ref[D];close=1'>Close</a></td>"
					t += "Open"
				t += "</tr>"
		t += "</table>"
		if(empty)
			t += "\red No networks connected.<br>"
		t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		user << browse(t, "window=lockdown;size=500x800")
		onclose(user, "lockdown")

	Topic(href, href_list)
		..()
		if( href_list["close"] )
			usr << browse(null, "window=lockdown")
			usr.machine = null
			return

		if( href_list["open_net"] )
			var/netTag = href_list["open_net"]
			for(var/obj/machinery/door/poddoor/D in connected_doors[netTag])
				if(D.density)	//for some reason, there's no var saying whether the door is open or not >.>
					spawn(0)
						D.open()
			src.updateDialog()
			return

		if( href_list["close_net"] )
			var/netTag = href_list["close_net"]
			for(var/obj/machinery/door/poddoor/D in connected_doors[netTag])
				if(!D.density)
					spawn(0)
						D.close()
			src.updateDialog()
			return

		if( href_list["close_all"] )
			for(var/netTag in connected_doors)
				for(var/obj/machinery/door/poddoor/D in connected_doors[netTag])
					if(!D.density)
						spawn(0)
							D.close()
			src.updateDialog()
			return

		if( href_list["open_all"] )
			for(var/netTag in connected_doors)
				for(var/obj/machinery/door/poddoor/D in connected_doors[netTag])
					if(D.density)
						spawn(0)
							D.open()
			src.updateDialog()
			return

		src.updateDialog()
