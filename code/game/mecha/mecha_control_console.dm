/obj/machinery/computer/mecha
	name = "Exosuit Control"
	icon = 'computer.dmi'
	icon_state = "mecha"
	req_access = list(access_robotics)
	var/list/located = list()
	var/screen = 0
	var/stored_data

	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/computerframe/A = new /obj/computerframe( src.loc )
					new /obj/item/weapon/shard( src.loc )
					var/obj/item/weapon/circuitboard/mecha_control/M = new /obj/item/weapon/circuitboard/mecha_control( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					del(src)
				else
					user << "\blue You disconnect the monitor."
					var/obj/computerframe/A = new /obj/computerframe( src.loc )
					var/obj/item/weapon/circuitboard/mecha_control/M = new /obj/item/weapon/circuitboard/mecha_control( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					del(src)
		return

	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)

	attack_paw(var/mob/user as mob)
		return src.attack_hand(user)

	attack_hand(var/mob/user as mob)
		if(..())
			return
		user.machine = src
		var/dat = "<html><head><title>[src.name]</title><style>h3 {margin: 0px; padding: 0px;}</style></head><body>"
		if(screen == 0)
			dat += "<h3>Tracking beacons data</h3>"
			for(var/obj/item/mecha_tracking/TR in world)
				var/answer = TR.get_mecha_info()
				if(answer)
					dat += {"<hr>[answer]<br>
							  <a href='?src=\ref[src];get_log=\ref[TR]'>Show exosuit log</a> | <a style='color: #f00;' href='?src=\ref[src];shock=\ref[TR]'>(EMP pulse)</a><br>"}
		if(screen==1)
			dat += "<h3>Log contents</h3>"
			dat += "<a href='?src=\ref[src];return=1'>Return</a><hr>"
			dat += "[stored_data]"

		dat += "<A href='?src=\ref[src];refresh=1'>(Refresh)</A><BR>"
		dat += "</body></html>"

		user << browse(dat, "window=computer;size=400x500")
		onclose(user, "computer")
		return

	Topic(href, href_list)
		if(..())
			return
		if(href_list["shock"])
			var/obj/item/mecha_tracking/MT = locate(href_list["shock"])
			MT.shock()
		if(href_list["get_log"])
			var/obj/item/mecha_tracking/MT = locate(href_list["get_log"])
			stored_data = MT.get_mecha_log()
			screen = 1
		if(href_list["return"])
			screen = 0
		src.updateUsrDialog()
		return



/obj/item/mecha_tracking
	name = "Exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'device.dmi'
	icon_state = "motion2"
	origin_tech = "programming=2;magnets=2"
	var/construction_time = 50
	var/list/construction_cost = list("metal"=500)

	proc/get_mecha_info()
		if(!in_mecha())
			return 0
		var/obj/mecha/M = src.loc
		var/cell_charge = M.get_charge()
		var/answer = {"<b>Name:</b> [M.name]<br>
							<b>Integrity:</b> [M.health/initial(M.health)*100]%<br>
							<b>Cell charge:</b> [isnull(cell_charge)?"Not found":"[M.cell.percent()]%"]<br>
							<b>Airtank:</b> [M.return_pressure()]kPa<br>
							<b>Pilot:</b> [M.occupant||"None"]<br>
							<b>Location:</b> [get_area(M)||"Unknown"]<br>
							<b>Active equipment:</b> [M.selected||"None"]"}
		if(istype(M, /obj/mecha/working/ripley))
			var/obj/mecha/working/ripley/RM = M
			answer += "<b>Used cargo space:</b> [RM.cargo.len/RM.cargo_capacity*100]%<br>"

		return answer

	emp_act()
		del src
		return

	ex_act()
		del src
		return

	proc/in_mecha()
		if(istype(src.loc, /obj/mecha))
			return 1
		return 0

	proc/shock()
		if(src.in_mecha())
			var/obj/mecha/M = src.loc
			M.emp_act(3)
		del(src)

	proc/get_mecha_log()
		if(!src.in_mecha())
			return 0
		var/obj/mecha/M = src.loc
		return M.get_log_html()


/obj/item/weapon/storage/mechatrackingbox

	New()
		new /obj/item/mecha_tracking(src)
		new /obj/item/mecha_tracking(src)
		new /obj/item/mecha_tracking(src)
		new /obj/item/mecha_tracking(src)
		new /obj/item/mecha_tracking(src)
		new /obj/item/mecha_tracking(src)
		new /obj/item/mecha_tracking(src)
		..()
		return
