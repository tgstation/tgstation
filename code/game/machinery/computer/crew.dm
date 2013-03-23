/obj/machinery/computer/crew
	name = "Crew Monitoring Console"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"
	var/list/tracked = list(  )


/obj/machinery/computer/crew/New()
	tracked = list()
	..()


/obj/machinery/computer/crew/attack_ai(mob/user)
	attack_hand(user)
	interact(user)


/obj/machinery/computer/crew/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)


/obj/machinery/computer/crew/update_icon()

	if(stat & BROKEN)
		icon_state = "broken"
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
	src.scan()
	var/t = ""
	t += "<BR><A href='?src=\ref[src];update=1'>Refresh</A> "
	t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	t += "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='30%'><h3>Vitals</h3></td><td width='30%'><h3>Position</h3></td></tr>"
	var/list/logs = list()
	for(var/obj/item/clothing/under/C in src.tracked)
		var/log = ""
		var/turf/pos = get_turf(C)
		if((C) && (C.has_sensor) && (pos) && (pos.z == src.z) && C.sensor_mode)
			if(istype(C.loc, /mob/living/carbon/human))

				var/mob/living/carbon/human/H = C.loc
				var/obj/item/ID = null

				if(H.wear_id)
					ID = H.wear_id.GetID()

				var/dam1 = round(H.getOxyLoss(),1)
				var/dam2 = round(H.getToxLoss(),1)
				var/dam3 = round(H.getFireLoss(),1)
				var/dam4 = round(H.getBruteLoss(),1)

				var/life_status = "[H.stat > 1 ? "<span class='bad'>Deceased</span>" : "<span class='good'>Living</span>"]"
				var/damage_report = "(<font color='blue'>[dam1]</font>/<font color='green'>[dam2]</font>/<font color='orange'>[dam3]</font>/<font color='red'>[dam4]</font>)"

				if(ID)
					log += "<tr><td width='40%'>[ID.name]</td>"
				else
					log += "<tr><td width='40%'>Unknown</td>"

				switch(C.sensor_mode)
					if(1)
						log += "<td width='30%'>[life_status]</td><td width='30%'>Not Available</td></tr>"
					if(2)
						log += "<td width='30%'>[life_status] [damage_report]</td><td width='30%'>Not Available</td></tr>"
					if(3)
						var/area/player_area = get_area(H)
						log += "<td width='30%'>[life_status] [damage_report]</td><td width='30%'>[format_text(player_area.name)] ([pos.x], [pos.y])</td></tr>"
		logs += log
	logs = sortList(logs)
	for(var/log in logs)
		t += log
	t += "</table>"
	//user << browse(t, "window=crewcomp;size=900x600")
	//onclose(user, "crewcomp")
	var/datum/browser/popup = new(user, "crewcomp", name, 900, 600)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()


/obj/machinery/computer/crew/proc/scan()
	for(var/obj/item/clothing/under/C in world)
		if((C.has_sensor) && (istype(C.loc, /mob/living/carbon/human)))
			var/check = 0
			for(var/O in src.tracked)
				if(O == C)
					check = 1
					break
			if(!check)
				src.tracked.Add(C)
	return 1