/obj/machinery/computer/telecomms/server
	name = "Telecommunications Server Monitor"
	icon_state = "comm_logs"

	var
		screen = 0				// the screen number:
		list/servers = list()	// the servers located by the computer
		var/obj/machinery/telecomms/server/SelectedServer

		network = "NULL"		// the network to probe
		temp = ""				// temporary feedback messages

		universal_translate = 0 // set to 1 if it can translate nonhuman speech

	req_access = list(access_engine)

	attack_hand(mob/user as mob)
		if(stat & (BROKEN|NOPOWER))
			return
		user.machine = src
		var/dat = "<TITLE>Telecommunication Server Monitor</TITLE><center><b>Telecommunications Server Monitor</b></center>"

		switch(screen)


		  // --- Main Menu ---

			if(0)
				dat += "<br>[temp]<br>"
				dat += "<br>Current Network: <a href='?src=\ref[src];input=network'>[network]</a><br>"
				if(servers.len)
					dat += "<br>Detected Telecommunication Servers:<ul>"
					for(var/obj/machinery/telecomms/T in servers)
						dat += "<li><a href='?src=\ref[src];viewserver=[T.id]'>\ref[T] [T.name]</a> ([T.id])</li>"
					dat += "</ul>"
					dat += "<br><a href='?src=\ref[src];operation=release'>\[Flush Buffer\]</a>"

				else
					dat += "<br>No servers detected. Scan for servers: <a href='?src=\ref[src];operation=scan'>\[Scan\]</a>"


		  // --- Viewing Server ---

			if(1)
				dat += "<br>[temp]<br>"
				dat += "<center><a href='?src=\ref[src];operation=mainmenu'>\[Main Menu\]</a>     <a href='?src=\ref[src];operation=refresh'>\[Refresh\]</a></center>"
				dat += "<br>Current Network: [network]"
				dat += "<br>Selected Server: [SelectedServer.id]<br><br>"
				dat += "Stored Logs: <ol>"

				var/i = 0
				for(var/datum/comm_log_entry/C in SelectedServer.log_entries)
					i++

					dat += "<li><font color = #008F00>[C.name]</font color>  <font color = #FF0000><a href='?src=\ref[src];delete=[i]'>\[X\]</a></font color><br>"

					// -- Determine race of orator --

					var/race			   // The actual race of the mob
					var/language = "Human" // MMIs, pAIs, Cyborgs and humans all speak Human
					var/mobtype = "[C.parameters["mobtype"]]"
					switch(mobtype)

						if("/mob/living/carbon/human")
							race = "Human"

						if("/mob/living/carbon/monkey")
							race = "Monkey"
							language = race

						if("/mob/living/carbon/metroid")
							race = "Metroid"
							language = race

						if("/mob/living/carbon/alien")
							race = "Alien"
							language = race

					if(findtext("C.parameters["mobtype"]", "/mob/living/silicon"))
						race = "Artificial Life"

					// -- If the orator is a human, or universal translate is active, OR mob has universal speech on --

					if(language == "Human" || universal_translate || C.parameters["uspeech"])
						dat += "<u><font color = #18743E>Data type</font color></u>: [C.input_type]<br>"
						dat += "<u><font color = #18743E>Orator</font color></u>: [C.parameters["name"]] (Job: [C.parameters["job"]])<br>"
						dat += "<u><font color = #18743E>Race</font color></u>: [race]<br>"
						dat += "<u><font color = #18743E>Contents</font color></u>: \"[C.parameters["message"]]\"<br>"


					// -- Orator is not human and universal translate not active --

					else
						dat += "<u><font color = #18743E>Data type</font color></u>: Audio File<br>"
						dat += "<u><font color = #18743E>Source</font color></u>: <i>Unidentifiable</i><br>"
						dat += "<u><font color = #18743E>Race</font color></u>: [race]<br>"
						dat += "<u><font color = #18743E>Contents</font color></u>: <i>Unintelligble</i><br>"

					dat += "</li><br>"

				dat += "</ol>"



		user << browse(dat, "window=comm_monitor;size=575x400")
		onclose(user, "server_control")

		temp = ""
		return


	Topic(href, href_list)
		if(..())
			return


		add_fingerprint(usr)
		usr.machine = src
		if(!src.allowed(usr) && !emagged)
			usr << "\red ACCESS DENIED."
			return

		if(href_list["viewserver"])
			screen = 1
			for(var/obj/machinery/telecomms/T in servers)
				if(T.id == href_list["viewserver"])
					SelectedServer = T
					break

		if(href_list["operation"])
			switch(href_list["operation"])

				if("release")
					servers = list()
					screen = 0

				if("mainmenu")
					screen = 0

				if("scan")
					if(servers.len > 0)
						temp = "- FAILED: CANNOT PROBE WHEN BUFFER FULL -"

					else
						for(var/obj/machinery/telecomms/server/T in range(25, src))
							if(T.network == network)
								servers.Add(T)

						if(!servers.len)
							temp = "- FAILED: UNABLE TO LOCATE SERVERS IN \[[network]\] -"
						else
							temp = "- [servers.len] SERVERS PROBED & BUFFERED -"

						screen = 0

		if(href_list["delete"])
			if(SelectedServer)

				var/datum/comm_log_entry/D = SelectedServer.log_entries[text2num(href_list["delete"])]

				temp = "- DELETED ENTRY: [D.name] -"

				SelectedServer.log_entries.Remove(D)
				del(D)


		if(href_list["input"])

			var/newnet = input(usr, "Which network do you want to view?", "Comm Monitor", network) as null|text
			if(newnet && usr in range(1, src))
				network = newnet
				screen = 0
				machines = list()
				temp = "- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -"

		updateUsrDialog()
		return

	attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
		if(istype(D, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					new /obj/item/weapon/shard( src.loc )
					var/obj/item/weapon/circuitboard/comm_server/M = new /obj/item/weapon/circuitboard/comm_server( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					del(src)
				else
					user << "\blue You disconnect the monitor."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					var/obj/item/weapon/circuitboard/comm_server/M = new /obj/item/weapon/circuitboard/comm_server( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					del(src)
		else if(istype(D, /obj/item/weapon/card/emag) && !emagged)
			playsound(src.loc, 'sparks4.ogg', 75, 1)
			emagged = 1
			user << "\blue You you disable the security protocols"
		src.updateUsrDialog()
		return