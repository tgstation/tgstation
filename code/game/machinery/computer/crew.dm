/obj/machinery/computer/crew
	name = "Crew monitoring computer"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"
	var/track_special_role
	var/list/tracked

/obj/machinery/computer/crew/Destroy()
	if(tracked)
		tracked = null

	..()

/obj/machinery/computer/crew/attack_ai(mob/user)
	src.add_hiddenprint(user)
	attack_hand(user)
	interact(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/crew/update_icon()
	if(stat & BROKEN)
		icon_state = "crewb"
	else
		if(stat & NOPOWER)
			src.icon_state = "c_unpowered"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/crew/Topic(href, href_list)
	if(..()) return
	if (src.z > 6)
		usr << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
		return
	if( href_list["close"] )
		usr << browse(null, "window=crewcomp")
		usr.unset_machine()
		return
	if(href_list["update"])
		src.updateDialog()
		return

/obj/machinery/computer/crew/interact(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!istype(user, /mob/living/silicon) && get_dist(src, user) > 1)
		user.unset_machine()
		user << browse(null, "window=powcomp")
		return
	user.set_machine(src)
	var/t = "<TT><B>Crew Monitoring</B><HR>"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\computer\crew.dm:67: t += "<BR><A href='?src=\ref[src];update=1'>Refresh</A> "
	t += {"<BR><A href='?src=\ref[src];update=1'>Refresh</A>
		<A href='?src=\ref[src];close=1'>Close</A><BR>
		<table><tr><td width='40%'>Name</td><td width='20%'>Vitals</td><td width='40%'>Position</td></tr>"}
	// END AUTOFIX
	var/list/logs = list()
	scan()

	for(var/obj/item/clothing/under/C in tracked)
		var/log = ""
		var/turf/pos = get_turf(C)

		if((C) && (C.has_sensor) && (pos) && (pos.z == src.z) && C.sensor_mode)
			if(istype(C.loc, /mob/living/carbon/human))

				var/mob/living/carbon/human/H = C.loc

				var/dam1 = round(H.getOxyLoss(),1)
				var/dam2 = round(H.getToxLoss(),1)
				var/dam3 = round(H.getFireLoss(),1)
				var/dam4 = round(H.getBruteLoss(),1)

				var/life_status = "[H.stat > 1 ? "<font color=red>Deceased</font>" : "Living"]"
				var/damage_report = "(<font color='blue'>[dam1]</font>/<font color='green'>[dam2]</font>/<font color='orange'>[dam3]</font>/<font color='red'>[dam4]</font>)"

				if(H.wear_id)
					log += "<tr><td width='40%'>[H.wear_id.name]</td>"
				else
					log += "<tr><td width='40%'>Unknown</td>"

				switch(C.sensor_mode)
					if(1)
						log += "<td width='15%'>[life_status]</td><td width='40%'>Not Available</td></tr>"
					if(2)
						log += "<td width='20%'>[life_status] [damage_report]</td><td width='40%'>Not Available</td></tr>"
					if(3)
						var/area/player_area = get_area(H)
						log += "<td width='20%'>[life_status] [damage_report]</td><td width='40%'>[player_area.name] ([pos.x-WORLD_X_OFFSET], [pos.y-WORLD_Y_OFFSET])</td></tr>"
		logs += log
	logs = sortList(logs)
	for(var/log in logs)
		t += log

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\computer\crew.dm:104: t += "</table>"
	t += {"</table>
		</FONT></PRE></TT>"}
	// END AUTOFIX
	user << browse(t, "window=crewcomp;size=900x600")
	onclose(user, "crewcomp")

/obj/machinery/computer/crew/proc/is_scannable(const/obj/item/clothing/under/C, const/mob/living/carbon/human/H)
	if(!istype(H))
		return 0

	if(isnull(track_special_role))
		return C.has_sensor

	return H.mind.special_role == track_special_role

/obj/machinery/computer/crew/proc/scan()
	tracked = new

	for(var/mob/living/carbon/human/H in mob_list)
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform

			if(is_scannable(U, H))
				if(!(U in tracked))
					tracked += U
