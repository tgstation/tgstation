#define MAX_SHUTTLE_NAME_LEN

/obj/machinery/computer/shuttle_control
	name = "shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = null
	circuit = "/obj/item/weapon/circuitboard/shuttle_control"

	machine_flags = EMAGGABLE | SCREWTOGGLE

	light_color = LIGHT_COLOR_BLUE

	var/datum/shuttle/shuttle

	var/obj/structure/docking_port/selected_port

	var/allow_selecting_all = 0 //if 1, allow selecting ALL ports, not only those of linked shuttle
								//only abusable by admins

	var/allow_silicons = 1		//If 0, AIs and cyborgs can't use this computer
								//used for admin-only shuttles so that borgs cant hijack 'em

/obj/machinery/computer/shuttle_control/New()
	if(shuttle)
		name = "[shuttle.name] console"

	.=..()

/obj/machinery/computer/shuttle_control/proc/announce(var/message)
	return say(message)

/obj/machinery/computer/shuttle_control/proc/get_doc_href(var/obj/structure/docking_port/D, var/bonus_parameters=null)
	if(!D) return "ERROR"
	var/name = capitalize(D.areaname)
	var/span_s = "<a href='?src=\ref[src];select=\ref[D][bonus_parameters]'>"
	var/span_e = "</a>"
	if(D == selected_port)
		span_s += "<font color='blue'>"
		span_e += "</font>"
	else
		span_s += "<font color='green'>"
		span_e += "</font>"

	if(D.docked_with) //If used by somebody
		span_s = "<i>"
		span_e = "</i>"

	if(shuttle && !shuttle.linked_port)
		span_s = ""
		span_e = ""

	return "[span_s][name][span_e]"

/obj/machinery/computer/shuttle_control/attack_hand(mob/user as mob)
	if(..(user))
		return

	user.set_machine(src)
	src.add_fingerprint(usr)
	var/shuttle_name = "Unknown shuttle"
	var/dat

	if(shuttle)
		shuttle_name = shuttle.name
		if(shuttle.lockdown)
			dat += "<h2><font color='red'>THIS SHUTTLE IS LOCKED DOWN</font></h2><br>"
			if(istext(shuttle.lockdown))
				dat += shuttle.lockdown
			else
				dat += "Additional information has not been provided."
		else if(!shuttle.linked_area)
			dat = "<h2><font color='red'>UNABLE TO FIND [uppertext(shuttle.name)]</font></h2>"
		else if(!shuttle.linked_port)
			dat += {"<h2><font color='red'>This shuttle has no docking port specified.</font></h2><br>
				<a href='?src=\ref[src];link_to_port=1'>Scan for docking ports</a>"}
		else if(shuttle.moving)
			dat += "<center><h3>Currently moving [shuttle.destination_port.areaname ? "to [shuttle.destination_port.areaname]" : ""]</h3></center>"
		else
			if(shuttle.current_port)
				dat += "Location: <b>[shuttle.current_port.areaname]</b><br>"
			else
				dat += "Location: <font color='red'><b>unknown</b></font><br>"
			dat += "Ready to move[max(shuttle.last_moved + shuttle.cooldown - world.time, 0) ? " in [max(round((shuttle.last_moved + shuttle.cooldown - world.time) * 0.1), 0)] seconds" : ": now"]<br>"

				//Write a list of all possible areas
			var/text
			if(allow_selecting_all)
				for(var/obj/structure/docking_port/destination/D in all_docking_ports)
					if(D.docked_with)
						continue
					else
						text = get_doc_href(D)

					dat += " | [text] | "
			else
				for(var/obj/structure/docking_port/destination/D in shuttle.docking_ports)
					if(D.docked_with)
						continue
					else
						text = get_doc_href(D)

					dat += " | [text] | "

			dat += " |<BR>"
			dat += "<center>[shuttle_name]:<br> <b><A href='?src=\ref[src];move=[1]'>Send[selected_port ? " to [selected_port.areaname]" : ""]</A></b></center><BR>"
	else //No shuttle
		dat = "<h1>NO SHUTTLE LINKED</h1><br>"
		dat += "<a href='?src=\ref[src];link_to_shuttle=1'>Link to a shuttle</a>"

	if(isAdminGhost(user))
		dat += "<br><hr><br>"
		dat += "<b><font color='red'>SPECIAL OPTIONS</font></h1></b>"
		dat += "<i>These are only available to administrators. Abuse may result in fun.</i><br><br>"
		dat += "<a href='?src=\ref[src];admin_link_to_shuttle=1'>Link to a shuttle</a><br><i>This allows you to link this computer to any existing shuttle, even if it's normally impossible to do so.</i><br>"
		if(shuttle)
			dat += {"<a href='?src=\ref[src];admin_unlink_shuttle=1'>Unlink current shuttle</a><br><i>Unlink this computer from [shuttle.name]</i><br>
			<a href='?src=\ref[src];admin_toggle_lockdown=1'>[shuttle.lockdown ? "Lift lockdown" : "Lock down"]</a><br>
			<a href='?src=\ref[src];admin_toggle_select_all=1'>[allow_selecting_all ? "Select only from ports linked to [shuttle.name]" : "Select from ALL ports"]</a><br>
			<a href='?src=\ref[src];admin_toggle_silicon_use=1'>[allow_silicons ? "Forbid silicons from using this computer" : "Allow silicons to use this computer"]</a><br>
			<a href='?src=\ref[src];admin_reset=1'>Reset shuttle</a><br><i>Revert the shuttle's areas to initial state</i><br>"}

	user << browse("[dat]", "window=shuttle_control;size=575x450")
	onclose(user, "shuttle_control")

/obj/machinery/computer/shuttle_control/Topic(href, href_list)
	if(..())
		return
	if(issilicon(usr) && !allow_silicons)
		to_chat(usr, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(!shuttle) return
		if(!allowed(usr))
			to_chat(usr, "<font color='red'>Access denied.</font>")
			return

		if(!selected_port && shuttle.docking_ports.len >= 2)
			selected_port = pick(shuttle.docking_ports - shuttle.current_port)

		if(!allow_selecting_all && !(selected_port in shuttle.docking_ports))
			return

		if(selected_port.docked_with) //If used by another shuttle, don't try to move this shuttle
			return

		//Send a message to the shuttle to move
		shuttle.travel_to(selected_port, src)

		selected_port = null
		src.updateUsrDialog()
	if(href_list["link_to_port"])
		if(!shuttle) return
		if(!shuttle.linked_area) return
		if(!allowed(usr))
			to_chat(usr, "<font color='red'>Access denied.</font>")
			return

		var/list/ports = list()

		for(var/obj/structure/docking_port/shuttle/S in shuttle.linked_area)
			var/name = capitalize(S.areaname)
			ports += name
			ports[name] = S

		var/choice = input("Select a docking port to link this shuttle to","Shuttle maintenance") in ports
		if(!Adjacent(usr) && !isAdminGhost(usr) && !isAI(usr)) return
		var/obj/structure/docking_port/shuttle/S = ports[choice]

		if(S)
			S.link_to_shuttle(shuttle)
			to_chat(usr, "Successfully linked [capitalize(shuttle.name)] to the port.")
			return src.updateUsrDialog()
		to_chat(usr, "No docking ports found.")

	if(href_list["select"])
		if(!allowed(usr))
			to_chat(usr, "<font color='red'>Access denied.</font>")
			return
		var/obj/structure/docking_port/A = locate(href_list["select"]) in all_docking_ports
		if(!A)
			return

		selected_port = A
		src.updateUsrDialog()
	if(href_list["link_to_shuttle"])
		if(!allowed(usr))
			to_chat(usr, "<font color='red'>Access denied.</font>")
			return
		var/list/L = list()
		for(var/datum/shuttle/S in shuttles)
			var/name = S.name
			switch(S.can_link_to_computer)
				if(LINK_PASSWORD_ONLY)
					name = "[name] (requires password)"
				if(LINK_FORBIDDEN)
					continue

			L += name
			L[name] = S

		var/choice = input(usr,"Select a shuttle to link this computer to", "Shuttle control console") in L as text|null
		if(!Adjacent(usr) && !isAdminGhost(usr) && !isAI(usr)) return
		if(L[choice] && istype(L[choice],/datum/shuttle))
			var/datum/shuttle/S = L[choice]

			if(S.can_link_to_computer == LINK_PASSWORD_ONLY)
				var/password_attempt = input(usr,"Please input [capitalize(S.name)]'s interface password:", "Shuttle control console", 00000) as num

				if(!Adjacent(usr) && !isAdminGhost(usr) && !isAI(usr)) return
				if(S.password == password_attempt)
					shuttle = L[choice]
				else
					return
			else if(S.can_link_to_computer == LINK_FORBIDDEN)
				return
			else
				link_to(L[choice])
			to_chat(usr, "Successfully linked [src] to [capitalize(S.name)]!")
			src.updateUsrDialog()


	if(href_list["admin_link_to_shuttle"])
		if(!isAdminGhost(usr))
			to_chat(usr, "You must be an admin for this")
			return

		var/list/L = list()
		for(var/datum/shuttle/S in shuttles)
			var/name = S.name
			switch(S.can_link_to_computer)
				if(LINK_PASSWORD_ONLY)
					name = "[name] (password)"
				if(LINK_FORBIDDEN)
					name = "[name] (private)"

			L += name
			L[name] = S

		var/choice = input(usr,"Select a shuttle to link this computer to", "Admin abuse") in L as text|null
		if(L[choice] && istype(L[choice],/datum/shuttle))
			shuttle = L[choice]

	if(href_list["admin_unlink_shuttle"])
		if(!isAdminGhost(usr))
			to_chat(usr, "You must be an admin for this")
			return

		shuttle = null

	if(href_list["admin_toggle_lockdown"])
		if(!isAdminGhost(usr))
			to_chat(usr, "You must be an admin for this")
			return

		if(!shuttle.lockdown)
			var/choice = input(usr,"Would you like to specify a reason?", "Admin abuse") in list("Yes","No","Cancel")

			if(choice == "Cancel")
				return

			shuttle.lockdown = 1
			if(choice == "Yes")
				shuttle.lockdown = input(usr,"Please write a reason for locking the [capitalize(shuttle.name)] down.", "Admin abuse")
		else
			shuttle.lockdown = 0

		src.updateUsrDialog()
	if(href_list["admin_toggle_select_all"])
		if(!isAdminGhost(usr))
			to_chat(usr, "You must be an admin for this")
			return

		if(allow_selecting_all)
			allow_selecting_all = 0
			to_chat(usr, "Now selecting from shuttle's docking ports.")
		else
			allow_selecting_all = 1
			to_chat(usr, "Now selecting from all existing docking ports.")

		src.updateUsrDialog()
	if(href_list["admin_reset"])
		if(!isAdminGhost(usr))
			to_chat(usr, "You must be an admin for this")
			return

		shuttle.initialize()
		to_chat(usr, "Shuttle's list of travel destinations has been reset")
	if(href_list["admin_toggle_silicon_use"])
		if(!isAdminGhost(usr))
			to_chat(usr, "You must be an admin for this")
			return

		if(allow_silicons)
			allow_silicons = 0
			to_chat(usr, "Silicons can no longer use [src].")
		else
			allow_silicons = 1
			to_chat(usr, "Silicons may now use [src] again.")

		src.updateUsrDialog()

/obj/machinery/computer/shuttle_control/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")

/obj/machinery/computer/shuttle_control/proc/link_to(var/datum/shuttle/S, var/add_to_list = 1)
	if(shuttle)
		if(src in shuttle.control_consoles)
			shuttle.control_consoles -= src

	shuttle = S
	if(add_to_list)
		shuttle.control_consoles |= src
	src.req_access = shuttle.req_access
	src.updateUsrDialog()

/obj/machinery/computer/shuttle_control/emag(mob/user as mob)
	..()
	src.req_access = list()
	to_chat(usr, "You disable the console's access requirement.")

#undef MAX_SHUTTLE_NAME_LEN