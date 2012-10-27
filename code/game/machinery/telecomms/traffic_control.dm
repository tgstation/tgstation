//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32





/obj/machinery/computer/telecomms/traffic
	name = "Telecommunications Traffic Control"
	icon_state = "computer_generic"

	var/screen = 0				// the screen number:
	var/list/servers = list()	// the servers located by the computer
	var/mob/editingcode
	var/mob/lasteditor
	var/list/viewingcode = list()
	var/obj/machinery/telecomms/server/SelectedServer

	var/network = "NULL"		// the network to probe
	var/temp = ""				// temporary feedback messages

	var/storedcode = ""			// code stored


	proc/update_ide()

		// loop if there's someone manning the keyboard
		while(editingcode)
			if(!editingcode.client)
				editingcode = null
				break

			// For the typer, the input is enabled. Buffer the typed text
			if(editingcode)
				storedcode = "[winget(editingcode, "tcscode", "text")]"
			if(editingcode) // double if's to work around a runtime error
				winset(editingcode, "tcscode", "is-disabled=false")

			// If the player's not manning the keyboard anymore, adjust everything
			if( (!(editingcode in range(1, src)) && !issilicon(editingcode)) || (editingcode.machine != src && !issilicon(editingcode)))
				if(editingcode)
					winshow(editingcode, "Telecomms IDE", 0) // hide the window!
				editingcode = null
				break

			// For other people viewing the typer type code, the input is disabled and they can only view the code
			// (this is put in place so that there's not any magical shenanigans with 50 people inputting different code all at once)

			if(length(viewingcode))
				// This piece of code is very important - it escapes quotation marks so string aren't cut off by the input element
				var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
				showcode = replacetext(storedcode, "\"", "\\\"")

				for(var/mob/M in viewingcode)

					if( (M.machine == src && M in view(1, src) ) || issilicon(M))
						winset(M, "tcscode", "is-disabled=true")
						winset(M, "tcscode", "text=\"[showcode]\"")
					else
						viewingcode.Remove(M)
						winshow(M, "Telecomms IDE", 0) // hide the window!

			sleep(5)

		if(length(viewingcode) > 0)
			editingcode = pick(viewingcode)
			viewingcode.Remove(editingcode)
			update_ide()



	req_access = list(access_tcomsat)

	attack_hand(mob/user as mob)
		if(stat & (BROKEN|NOPOWER))
			return
		user.set_machine(src)
		var/dat = "<TITLE>Telecommunication Traffic Control</TITLE><center><b>Telecommunications Traffic Control</b></center>"

		switch(screen)


		  // --- Main Menu ---

			if(0)
				dat += "<br>[temp]<br>"
				dat += "<br>Current Network: <a href='?src=\ref[src];network=1'>[network]</a><br>"
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
				dat += "<br><a href='?src=\ref[src];operation=editcode'>\[Edit Code\]</a>"
				dat += "<br>Signal Execution: "
				if(SelectedServer.autoruncode)
					dat += "<a href='?src=\ref[src];operation=togglerun'>ALWAYS</a>"
				else
					dat += "<a href='?src=\ref[src];operation=togglerun'>NEVER</a>"


		user << browse(dat, "window=traffic_control;size=575x400")
		onclose(user, "server_control")

		temp = ""
		return


	Topic(href, href_list)
		if(..())
			return


		add_fingerprint(usr)
		usr.set_machine(src)
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
						temp = "<font color = #D70B00>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font color>"

					else
						for(var/obj/machinery/telecomms/server/T in range(25, src))
							if(T.network == network)
								servers.Add(T)

						if(!servers.len)
							temp = "<font color = #D70B00>- FAILED: UNABLE TO LOCATE SERVERS IN \[[network]\] -</font color>"
						else
							temp = "<font color = #336699>- [servers.len] SERVERS PROBED & BUFFERED -</font color>"

						screen = 0

				if("editcode")
					if(editingcode == usr) return
					if(usr in viewingcode) return

					if(!editingcode)
						lasteditor = usr
						editingcode = usr
						winshow(editingcode, "Telecomms IDE", 1) // show the IDE
						winset(editingcode, "tcscode", "is-disabled=false")
						winset(editingcode, "tcscode", "text=\"\"")
						var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
						showcode = replacetext(storedcode, "\"", "\\\"")
						winset(editingcode, "tcscode", "text=\"[showcode]\"")
						spawn()
							update_ide()

					else
						viewingcode.Add(usr)
						winshow(usr, "Telecomms IDE", 1) // show the IDE
						winset(usr, "tcscode", "is-disabled=true")
						winset(editingcode, "tcscode", "text=\"\"")
						var/showcode = replacetext(storedcode, "\"", "\\\"")
						winset(usr, "tcscode", "text=\"[showcode]\"")

				if("togglerun")
					SelectedServer.autoruncode = !(SelectedServer.autoruncode)

		if(href_list["network"])

			var/newnet = input(usr, "Which network do you want to view?", "Comm Monitor", network) as null|text

			if(newnet && ((usr in range(1, src) || issilicon(usr))))
				if(length(newnet) > 15)
					temp = "<font color = #D70B00>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font color>"

				else

					network = newnet
					screen = 0
					servers = list()
					temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font color>"

		updateUsrDialog()
		return

	attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
		if(istype(D, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					new /obj/item/weapon/shard( src.loc )
					var/obj/item/weapon/circuitboard/comm_traffic/M = new /obj/item/weapon/circuitboard/comm_traffic( A )
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
					var/obj/item/weapon/circuitboard/comm_traffic/M = new /obj/item/weapon/circuitboard/comm_traffic( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					del(src)
		else if(istype(D, /obj/item/weapon/card/emag) && !emagged)
			playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
			emagged = 1
			user << "\blue You you disable the security protocols"
		src.updateUsrDialog()
		return
