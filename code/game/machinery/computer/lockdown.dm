//this computer displays status and remotely activates multiple shutters / blast doors
//might even make it able to lock / electrify area doors, later

/obj/machinery/computer/lockdown
	name = "Lockdown Control"
	desc = "Used to control blast doors."
	icon_state = "lockdown"
	circuit = "/obj/item/weapon/circuitboard/lockdown"
	var/connectedDoorIds[0][0]
	var/department = ""
	var/connected_doors[0][0]
	///obj/machinery/door/poddoor

	New()
		..()

		//only load blast doors for map-defined departments for the moment
		switch(department)
			if("Engineering")
				connectedDoorIds.Add("Engineering Primary Access")
				connectedDoorIds.Add("Engineering Secondary Access")
				connectedDoorIds.Add("Fore Maintenance Access")
				connectedDoorIds.Add("Aft Maintenance Access")
				connectedDoorIds.Add("Particle Accelerator Rad Shielding")
				connectedDoorIds.Add("Foreward Emitter Array Rad Shielding")
				connectedDoorIds.Add("Aftward Emitter Array Rad Shielding")
				connectedDoorIds.Add("Starboard Observation Rad Shielding")
				connectedDoorIds.Add("Atmospheric Storage Rad Shielding")
				connectedDoorIds.Add("Construction Storage Rad Shielding")
				connectedDoorIds.Add("Engineering Secure Storage")
			if("RustEngineering-Antiqua")
				connectedDoorIds.Add("Port vessel entry")
				connectedDoorIds.Add("Starboard vessel entry")
				connectedDoorIds.Add("Central aft shell access")
				connectedDoorIds.Add("Port aft shell access")
				connectedDoorIds.Add("Starboard aft shell access")
			if("Medbay")
				connectedDoorIds.Add("Genetics Outer Shutters")
				connectedDoorIds.Add("Genetics Inner Shutters")
				connectedDoorIds.Add("Chemistry Outer Shutters")
				connectedDoorIds.Add("Observation Shutters")
				connectedDoorIds.Add("Patient Room 1 Shutters")
				connectedDoorIds.Add("Patient Room 2 Shutters")
				connectedDoorIds.Add("Patient Room 3 Shutters")

		//loop through the world, grabbing all the relevant doors
		spawn(1)
			for(var/networkId in connectedDoorIds)
				//world << "\blue Creating [networkId]"
				for(var/obj/machinery/door/poddoor/D in world)
					if(D.id == networkId)
						connected_doors.Add(D)
						//world << "\blue 	Added [D]"

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
			for(var/obj/machinery/door/poddoor/D in connected_doors)
				if(D.id == href_list["netId"])
					if(!D.density)
						spawn(0)
							D.close()
			src.updateDialog()
			return

		if( href_list["open_all"] )
			for(var/obj/machinery/door/poddoor/D in connected_doors)
				if(D.id == href_list["netId"])
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
			for(var/curNetId in connectedDoorIds)
				t += "<tr>"
				t += "<td><b>" + curNetId + "<b></td>"
				t += "<td><b><a href='?src=\ref[src];open_all=1;netId=[curNetId]'>Open All</a> / <a href='?src=\ref[src];close_all=0;netId=[curNetId]'>Close All</a></b></td>"
				t += "</tr>"
				for(var/obj/machinery/door/poddoor/D in connected_doors)
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