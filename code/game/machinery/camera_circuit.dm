
//the researchable camera circuit that can connect to any camera network

/obj/item/weapon/circuitboard/camera
	//name = "Circuit board (Camera)"
	var/secured = 1
	var/authorised = 0
	var/possibleNets[0]
	var/network = ""
	build_path = 0

//when adding a new camera network, you should only need to update these two procs
	New()
		possibleNets["Engineering"] = ACCESS_CE
		possibleNets["SS13"] = ACCESS_HOS
		possibleNets["Mining"] = ACCESS_MINING
		possibleNets["Cargo"] = ACCESS_QM
		possibleNets["Research"] = ACCESS_RD
		possibleNets["Medbay"] = ACCESS_CMO

	proc/updateBuildPath()
		build_path = ""
		if(authorised && secured)
			switch(network)
				if("SS13")
					build_path = "/obj/machinery/computer/security"
				if("Engineering")
					build_path = "/obj/machinery/computer/security/engineering"
				if("Mining")
					build_path = "/obj/machinery/computer/security/mining"
				if("Research")
					build_path = "/obj/machinery/computer/security/research"
				if("Medbay")
					build_path = "/obj/machinery/computer/security/medbay"
				if("Cargo")
					build_path = "/obj/machinery/computer/security/cargo"

	attackby(var/obj/item/I, var/mob/user)//if(health > 50)
		..()
		if(istype(I,/obj/item/weapon/card/emag))
			if(network)
				var/obj/item/weapon/card/emag/E = I
				if(E.uses)
					E.uses--
				else
					return
				authorised = 1
				user << "\blue You authorised the circuit network!"
				updateDialog()
			else
				user << "\blue You must select a camera network circuit!"
		else if(istype(I,/obj/item/weapon/screwdriver))
			secured = !secured
			user.visible_message("\blue The [src] can [secured ? "no longer" : "now"] be modified.")
			updateBuildPath()
		return

	attack_self(var/mob/user)
		if(!secured && ishuman(user))
			user.machine = src
			interact(user, 0)

	proc/interact(var/mob/user, var/ai=0)
		if(secured)
			return
		if (!ishuman(user))
			return ..(user)
		var/t = "<B>Circuitboard Console - Camera Monitoring Computer</B><BR>"
		t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		t += "<hr> Please select a camera network:<br>"

		for(var/curNet in possibleNets)
			if(network == curNet)
				t += "- [curNet]<br>"
			else
				t += "- <A href='?src=\ref[src];net=[curNet]'>[curNet]</A><BR>"
		t += "<hr>"
		if(network)
			if(authorised)
				t += "Authenticated <A href='?src=\ref[src];removeauth=1'>(Clear Auth)</A><BR>"
			else
				t += "<A href='?src=\ref[src];auth=1'><b>*Authenticate*</b></A> (Requires an appropriate access ID)<br>"
		else
			t += "<A href='?src=\ref[src];auth=1'>*Authenticate*</A> (Requires an appropriate access ID)<BR>"
		t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
		user << browse(t, "window=camcircuit;size=500x400")
		onclose(user, "camcircuit")

	Topic(href, href_list)
		..()
		if( href_list["close"] )
			usr << browse(null, "window=camcircuit")
			usr.machine = null
			return
		else if(href_list["net"])
			network = href_list["net"]
			authorised = 0
		else if( href_list["auth"] )
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.equipped()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(ACCESS_CAPTAIN in I.access)
					authorised = 1
				else if (possibleNets[network] in I.access)
					authorised = 1
			if(istype(I,/obj/item/weapon/card/emag))
				if(network)
					var/obj/item/weapon/card/emag/E = I
					if(E.uses)
						E.uses--
					else
						return
					authorised = 1
					usr << "\blue You authorised the circuit network!"
					updateDialog()
				else
					usr << "\blue You must select a camera network circuit!"
		else if( href_list["removeauth"] )
			authorised = 0
		updateDialog()

	updateDialog()
		if(istype(src.loc,/mob))
			attack_self(src.loc)