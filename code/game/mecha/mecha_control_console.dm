/obj/machinery/computer/mecha
	name = "Exosuit Control"
	icon = 'icons/obj/computer.dmi'
	icon_state = "mecha"
	req_access = list(access_robotics)
	circuit = "/obj/item/weapon/circuitboard/mecha_control"
	var/list/located = list()
	var/screen = 0
	var/stored_data

	l_color = "#CD00CD"

	attack_ai(var/mob/user as mob)
		src.add_hiddenprint(user)
		return src.attack_hand(user)

	attack_paw(var/mob/user as mob)
		return src.attack_hand(user)

	attack_hand(var/mob/user as mob)
		if(..())
			return
		user.set_machine(src)
		var/dat = "<html><head><title>[src.name]</title><style>h3 {margin: 0px; padding: 0px;}</style></head><body>"
		if(screen == 0)
			dat += "<h3>Tracking beacons data</h3>"
			for(var/obj/item/mecha_parts/mecha_tracking/TR in world)
				var/answer = TR.get_mecha_info()
				if(answer)
					dat += {"<hr>[answer]<br/>
							  <a href='?src=\ref[src];send_message=\ref[TR]'>Send message</a><br/>
							  <a href='?src=\ref[src];get_log=\ref[TR]'>Show exosuit log</a> | <a style='color: #f00;' href='?src=\ref[src];shock=\ref[TR]'>(Detonate Beacon)</a><br>"}

		if(screen==1)

			// AUTOFIXED BY fix_string_idiocy.py
			// C:\Users\Rob\Documents\Projects\vgstation13\code\game\mecha\mecha_control_console.dm:33: dat += "<h3>Log contents</h3>"
			dat += {"<h3>Log contents</h3>
				<a href='?src=\ref[src];return=1'>Return</a><hr>
				[stored_data]"}
			// END AUTOFIX


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\mecha\mecha_control_console.dm:37: dat += "<A href='?src=\ref[src];refresh=1'>(Refresh)</A><BR>"
		dat += {"<A href='?src=\ref[src];refresh=1'>(Refresh)</A><BR>
			</body></html>"}
		// END AUTOFIX
		user << browse(dat, "window=computer;size=400x500")
		onclose(user, "computer")
		return

	Topic(href, href_list)
		if(..())
			return
		var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
		if(href_list["send_message"])
			var/obj/item/mecha_parts/mecha_tracking/MT = filter.getObj("send_message")
			var/message = strip_html_simple(input(usr,"Input message","Transmit message") as text)
			var/obj/mecha/M = MT.in_mecha()
			if(trim(message) && M)
				M.occupant_message(message)
			return
		if(href_list["shock"])
			switch(alert("Are you sure? This cannot be undone.","Transmit Beacon Self-Destruct Code","Yes","No"))
				if ("Yes")
					var/obj/item/mecha_parts/mecha_tracking/MT = filter.getObj("shock")
					MT.shock()
				if ("No")
					usr << "You have second thoughts."
		if(href_list["get_log"])
			var/obj/item/mecha_parts/mecha_tracking/MT = filter.getObj("get_log")
			stored_data = MT.get_mecha_log()
			screen = 1
		if(href_list["return"])
			screen = 0
		src.updateUsrDialog()
		return



/obj/item/mecha_parts/mecha_tracking
	name = "Exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"
	origin_tech = "programming=2;magnets=2"
	materials = list("metal"=500)

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
			return src.loc
		return 0

	proc/shock()
		var/obj/mecha/M = in_mecha()
		if(M)
			M.log_message("Exosuit tracking beacon self-destruct activated.",1)
			M.occupant << "<font color='red'><b>Exosuit tracking beacon short-circuits!</b></font>"
			M.occupant << sound('sound/machines/warning-buzzer.ogg',wait=0)
			if (M.get_charge())
				if (M.cell.charge < 5000 && M)
					M.use_power(M.cell.charge/4)
					M.take_damage(25,"energy")
				if (M.cell.charge > 5000 && M)
					M.take_damage((round(M.cell.charge/5000)*50),"energy")
					M.use_power(round(M.cell.charge/5000)*(rand(4000,5000)))
		M.check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT),1)
		del(src)

	proc/get_mecha_log()
		if(!src.in_mecha())
			return 0
		var/obj/mecha/M = src.loc
		return M.get_log_html()


/obj/item/weapon/storage/box/mechabeacons
	name = "Exosuit Tracking Beacons"
	New()
		..()
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
		new /obj/item/mecha_parts/mecha_tracking(src)
