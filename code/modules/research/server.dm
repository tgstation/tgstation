/obj/machinery/r_n_d/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	var
		datum/research/files
		health = 100
		list
			id_with_upload = list()		//List of R&D consoles with upload to server access.
			id_with_download = list()	//List of R&D consoles with download from server access.
		id_with_upload_string = ""		//String versions for easy editing in map editor.
		id_with_download_string = ""
		server_id = 0
		heat_gen = 100
		heating_power = 40000
		delay = 10
	req_access = list(access_rd) //Only the R&D can change server settings.

	New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/circuitboard/rdserver(src)
		component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
		component_parts += new /obj/item/weapon/cable_coil(src)
		component_parts += new /obj/item/weapon/cable_coil(src)
		RefreshParts()
		src.initialize(); //Agouri

	Del()
		griefProtection()
		..()

	RefreshParts()
		var/tot_rating = 0
		for(var/obj/item/weapon/stock_parts/SP in src)
			tot_rating += SP.rating
		heat_gen /= max(1, tot_rating)

	initialize()
		if(!files) files = new /datum/research(src)
		var/list/temp_list
		if(!id_with_upload.len)
			temp_list = list()
			temp_list = dd_text2list(id_with_upload_string, ";")
			for(var/N in temp_list)
				id_with_upload += text2num(N)
		if(!id_with_download.len)
			temp_list = list()
			temp_list = dd_text2list(id_with_download_string, ";")
			for(var/N in temp_list)
				id_with_download += text2num(N)

	process()
		var/datum/gas_mixture/environment = loc.return_air()
		switch(environment.temperature)
			if(0 to T0C)
				health = min(100, health + 1)
			if(T0C to (T20C + 20))
				health = between(0, health, 100)
			if((T20C + 20) to (T0C + 70))
				health = max(0, health - 1)
		if(health <= 0)
			griefProtection() //I dont like putting this in process() but it's the best I can do without re-writing a chunk of rd servers.
			files.known_designs = list()
			for(var/datum/tech/T in files.known_tech)
				if(prob(1))
					T.level--
			files.RefreshResearch()
		if(delay)
			delay--
		else
			produce_heat(heat_gen)
			delay = initial(delay)

	meteorhit(var/obj/O as obj)
		griefProtection()
		..()


	emp_act(severity)
		griefProtection()
		..()


	ex_act(severity)
		griefProtection()
		..()


	blob_act()
		griefProtection()
		..()


	proc
		//Backup files to centcomm to help admins recover data after greifer attacks
		griefProtection()
			for(var/obj/machinery/r_n_d/server/centcom/C in world)
				for(var/datum/tech/T in files.known_tech)
					C.files.AddTech2Known(T)
				for(var/datum/design/D in files.known_designs)
					C.files.AddDesign2Known(D)
				C.files.RefreshResearch()

		produce_heat(heat_amt)
			if(!(stat & (NOPOWER|BROKEN))) //Blatently stolen from space heater.
				var/turf/simulated/L = loc
				if(istype(L))
					var/datum/gas_mixture/env = L.return_air()
					if(env.temperature < (heat_amt+T0C))

						var/transfer_moles = 0.25 * env.total_moles()

						var/datum/gas_mixture/removed = env.remove(transfer_moles)

						if(removed)

							var/heat_capacity = removed.heat_capacity()
							if(heat_capacity == 0 || heat_capacity == null)
								heat_capacity = 1
							removed.temperature = min((removed.temperature*heat_capacity + heating_power)/heat_capacity, 1000)

						env.merge(removed)

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (disabled)
			return
		if (shocked)
			shock(user,50)
		if (istype(O, /obj/item/weapon/screwdriver))
			if (!opened)
				opened = 1
				icon_state = "server_o"
				user << "You open the maintenance hatch of [src]."
			else
				opened = 0
				icon_state = "server"
				user << "You close the maintenance hatch of [src]."
			return
		if (opened)
			if(istype(O, /obj/item/weapon/crowbar))
				griefProtection()
				playsound(src.loc, 'Crowbar.ogg', 50, 1)
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 2
				M.icon_state = "box_1"
				for(var/obj/I in component_parts)
					if(I.reliability != 100 && crit_fail)
						I.crit_fail = 1
					I.loc = src.loc
				del(src)
				return 1

	attack_hand(mob/user as mob)
		if (disabled)
			return
		if (shocked)
			shock(user,50)
		if(ishuman(user))
			if(istype(user:gloves, /obj/item/clothing/gloves/space_ninja)&&user:gloves:candrain&&!user:gloves:draining)
				call(/obj/item/clothing/gloves/space_ninja/proc/drain)("RESEARCH",src,user:wear_suit)
		return

/obj/machinery/r_n_d/server/centcom
	name = "Centcom Central R&D Database"
	server_id = -1

	initialize()
		..()
		var/list/no_id_servers = list()
		var/list/server_ids = list()
		for(var/obj/machinery/r_n_d/server/S in world)
			switch(S.server_id)
				if(-1)
					continue
				if(0)
					no_id_servers += S
				else
					server_ids += S.server_id

		for(var/obj/machinery/r_n_d/server/S in no_id_servers)
			var/num = 1
			while(!S.server_id)
				if(num in server_ids)
					num++
				else
					S.server_id = num
					server_ids += num
			no_id_servers -= S

	process()
		return

/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	icon_state = "rdcomp"
	var
		screen = 0
		obj/machinery/r_n_d/server/temp_server
		list
			servers = list()
			consoles = list()
		badmin = 0

	Topic(href, href_list)
		if(..())
			return

		add_fingerprint(usr)
		usr.machine = src
		if(!src.allowed(usr) && !emagged)
			usr << "\red You do not have the required access level"
			return

		if(href_list["main"])
			screen = 0

		else if(href_list["access"] || href_list["data"] || href_list["transfer"])
			temp_server = null
			consoles = list()
			servers = list()
			for(var/obj/machinery/r_n_d/server/S in world)
				if(S.server_id == text2num(href_list["access"]) || S.server_id == text2num(href_list["data"]) || S.server_id == text2num(href_list["transfer"]))
					temp_server = S
					break
			if(href_list["access"])
				screen = 1
				for(var/obj/machinery/computer/rdconsole/C in world)
					if(C.sync)
						consoles += C
			else if(href_list["data"])
				screen = 2
			else if(href_list["transfer"])
				screen = 3
				for(var/obj/machinery/r_n_d/server/S in world)
					if(S == src)
						continue
					servers += S

		else if(href_list["upload_toggle"])
			var/num = text2num(href_list["upload_toggle"])
			if(num in temp_server.id_with_upload)
				temp_server.id_with_upload -= num
			else
				temp_server.id_with_upload += num

		else if(href_list["download_toggle"])
			var/num = text2num(href_list["download_toggle"])
			if(num in temp_server.id_with_download)
				temp_server.id_with_download -= num
			else
				temp_server.id_with_download += num

		else if(href_list["reset_tech"])
			var/choice = alert("Technology Data Rest", "Are you sure you want to reset this technology to its default data? Data lost cannot be recovered.", "Continue", "Cancel")
			if(choice == "Continue")
				for(var/datum/tech/T in temp_server.files.known_tech)
					if(T.id == href_list["reset_tech"])
						T.level = 1
						break
			temp_server.files.RefreshResearch()

		else if(href_list["reset_design"])
			var/choice = alert("Design Data Deletion", "Are you sure you want to delete this design? If you still have the prerequisites for the design, it'll reset to its base reliability. Data lost cannot be recovered.", "Continue", "Cancel")
			if(choice == "Continue")
				for(var/datum/design/D in temp_server.files.known_designs)
					if(D.id == href_list["reset_design"])
						D.reliability_mod = 0
						temp_server.files.known_designs -= D
						break
			temp_server.files.RefreshResearch()

		updateUsrDialog()
		return

	attack_hand(mob/user as mob)
		if(stat & (BROKEN|NOPOWER))
			return
		user.machine = src
		var/dat = ""

		switch(screen)
			if(0) //Main Menu
				dat += "Connected Servers:<BR><BR>"

				for(var/obj/machinery/r_n_d/server/S in world)
					if(istype(S, /obj/machinery/r_n_d/server/centcom) && !badmin)
						continue
					dat += "[S.name] || "
					dat += "<A href='?src=\ref[src];access=[S.server_id]'> Access Rights</A> | "
					dat += "<A href='?src=\ref[src];data=[S.server_id]'>Data Management</A>"
					if(badmin) dat += " | <A href='?src=\ref[src];transfer=[S.server_id]'>Server-to-Server Transfer</A>"
					dat += "<BR>"

			if(1) //Access rights menu
				dat += "[temp_server.name] Access Rights<BR><BR>"
				dat += "Consoles with Upload Access<BR>"
				for(var/obj/machinery/computer/rdconsole/C in consoles)
					var/turf/console_turf = get_turf(C)
					dat += "* <A href='?src=\ref[src];upload_toggle=[C.id]'>[console_turf.loc]" //FYI, these are all numeric ids, eventually.
					if(C.id in temp_server.id_with_upload)
						dat += " (Remove)</A><BR>"
					else
						dat += " (Add)</A><BR>"
				dat += "Consoles with Download Access<BR>"
				for(var/obj/machinery/computer/rdconsole/C in consoles)
					var/turf/console_turf = get_turf(C)
					dat += "* <A href='?src=\ref[src];download_toggle=[C.id]'>[console_turf.loc]"
					if(C.id in temp_server.id_with_download)
						dat += " (Remove)</A><BR>"
					else
						dat += " (Add)</A><BR>"
				dat += "<HR><A href='?src=\ref[src];main=1'>Main Menu</A>"

			if(2) //Data Management menu
				dat += "[temp_server.name] Data ManagementP<BR><BR>"
				dat += "Known Technologies<BR>"
				for(var/datum/tech/T in temp_server.files.known_tech)
					dat += "* [T.name] "
					dat += "<A href='?src=\ref[src];reset_tech=[T.id]'>(Reset)</A><BR>" //FYI, these are all strings.
				dat += "Known Designs<BR>"
				for(var/datum/design/D in temp_server.files.known_designs)
					dat += "* [D.name] "
					dat += "<A href='?src=\ref[src];reset_design=[D.id]'>(Delete)</A><BR>"
				dat += "<HR><A href='?src=\ref[src];main=1'>Main Menu</A>"

			if(3) //Server Data Transfer
				dat += "[temp_server.name] Server to Server Transfer<BR><BR>"
				dat += "Send Data to what server?<BR>"
				for(var/obj/machinery/r_n_d/server/S in servers)
					dat += "[S.name] <A href='?src=\ref[src];send_to=[S.server_id]'> (Transfer)</A><BR>"
				dat += "<HR><A href='?src=\ref[src];main=1'>Main Menu</A>"
		user << browse("<TITLE>R&D Server Control</TITLE><HR>[dat]", "window=server_control;size=575x400")
		onclose(user, "server_control")
		return

	attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
		if(istype(D, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					new /obj/item/weapon/shard( src.loc )
					var/obj/item/weapon/circuitboard/rdservercontrol/M = new /obj/item/weapon/circuitboard/rdservercontrol( A )
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
					var/obj/item/weapon/circuitboard/rdservercontrol/M = new /obj/item/weapon/circuitboard/rdservercontrol( A )
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

/obj/machinery/r_n_d/server/robotics
	name = "Robotics R&D Server"
	id_with_upload_string = "1;2"
	id_with_download_string = "1;2"
	server_id = 2

/obj/machinery/r_n_d/server/core
	name = "Core R&D Server"
	id_with_upload_string = "1"
	id_with_download_string = "1"
	server_id = 1