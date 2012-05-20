//this computer displays status and remotely activates multiple shutters / blast doors
//todo: lock / electrify specified area doors? might be a bit gamebreaking

/obj/machinery/computer/lockdown
	//for reference
	/*name = "Lockdown Control"
	desc = "Used to control blast doors."
	icon_state = "lockdown"
	circuit = "/obj/item/weapon/circuitboard/lockdown"
	var/connectedDoorIds[0][0]
	var/department = ""
	var/connected_doors[0][0]
	var/connected_doors[0][0]
	var/department*/

	New()
		..()
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

		//loop through the world, grabbing all the relevant doors
		spawn(1)
			for(var/obj/machinery/door/poddoor/D in world)
				if(D.lockdownNetwork in connected_doors)
					var/list/L = connected_doors[D.lockdownNetwork]
					L.Add(D)

	attack_ai(mob/user)
		attack_hand(user)

	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)

	power_change()
		if(stat & BROKEN)
			icon_state = "broken"
		else
			if( powered() )
				icon_state = initial(icon_state)
				stat &= ~NOPOWER
			else
				spawn(rand(0, 15))
					src.icon_state = "c_unpowered"
					stat |= NOPOWER

	Topic(href, href_list)
		..()
		if( href_list["close"] )
			usr << browse(null, "window=lockdown")
			usr.machine = null
			return

		if( href_list["openDoor"] )
			var/obj/machinery/door/poddoor/D = href_list["door"]
			if(D.density)
				D.open()
			src.updateDialog()
			return

		if( href_list["closeDoor"] )
			var/obj/machinery/door/poddoor/D = href_list["door"]
			if(!D.density)
				D.close()
			src.updateDialog()
			return

		if( href_list["close_all"] )
			if(href_list["networkTag"] == "all")
				for(var/netTag in connected_doors)
					for(var/obj/machinery/door/poddoor/D in connected_doors[netTag])
						if(D.doorTag == href_list["doorTag"])
							if(!D.density)
								spawn(0)
									D.close()
			else if(href_list["networkTag"] in connected_doors)
				for(var/obj/machinery/door/poddoor/D in connected_doors[href_list["networkTag"]])
					if(D.doorTag == href_list["doorTag"])
						if(!D.density)
							spawn(0)
								D.close()
			src.updateDialog()
			return

		if( href_list["open_all"] )
			if(href_list["networkTag"] == "all")
				for(var/netTag in connected_doors)
					for(var/obj/machinery/door/poddoor/D in connected_doors[netTag])
						if(D.doorTag == href_list["doorTag"])
							if(D.density)
								spawn(0)
									D.open()
			else if(href_list["networkTag"] in connected_doors)
				for(var/obj/machinery/door/poddoor/D in connected_doors[href_list["networkTag"]])
					if(D.doorTag == href_list["doorTag"])
						if(D.density)
							spawn(0)
								D.open()
			src.updateDialog()
			return

		if(href_list["update"])
			src.updateDialog()
			return

	proc
		interact(mob/user)
			if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
				if (!istype(user, /mob/living/silicon))
					user.machine = null
					user << browse(null, "window=lockdown")
					return
			var/t = "<B>Lockdown Control</B><BR>"
			t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
			t += "<table border=1>"
			for(var/curNetId in connected_doors)
				var/list/L = connected_doors[curNetId]
				if(!L || L.len == 0)
					continue
				t += "<tr>"
				t += "<td><b>" + curNetId + "<b></td>"
				t += "<td><b><a href='?src=\ref[src];open_all=1;networkTag=[curNetId]'>Open All</a> / <a href='?src=\ref[src];close_all=1;networkTag=[curNetId]'>Close All</a></b></td>"
				t += "</tr>"

				for(var/obj/machinery/door/poddoor/D in connected_doors[curNetId])
					if(D.id == curNetId )
						t += "<tr>"
						t += "<td>	[D.networkTag]</td>"
						if(D.density)
							t += "<td><a href='?src=\ref[D];open=1'>Open</a> - Close</td>"
						else
							t += "<td>Open - <a href='?src=\ref[D];close=1'>Close</a></td>"
						t += "</tr>"
			t += "</table>"
			t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
			user << browse(t, "window=lockdown;size=500x800")
			onclose(user, "lockdown")
