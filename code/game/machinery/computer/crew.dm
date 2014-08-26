/obj/machinery/computer/crew
	name = "crew monitoring console"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_state = "crew"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"

/obj/machinery/computer/crew/attack_ai(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	crewmonitor(user,src)

/obj/machinery/computer/crew/attack_hand(mob/user)
	if(..())
		return
	if(stat & (BROKEN|NOPOWER))
		return
	crewmonitor(user,src)

/obj/machinery/computer/crew/Topic(href, href_list)
	if(..()) return
	if (src.z > 6)
		usr << "<span class='userdanger'>Unable to establish a connection</span>: \black You're too far away from the station!"
		return
	if( href_list["close"] )
		usr << browse(null, "window=crewcomp")
		usr.unset_machine()
		return
	if(href_list["update"])
		src.updateDialog()
		return


proc/crewmonitor(mob/user,var/atom/source)
	var/t = "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='30%'><h3>Vitals</h3></td><td width='30%'><h3>Position</h3></td></tr>"
	var/list/logs = list()
	var/list/tracked = crewscan()
	var/turf/srcturf = get_turf(source)
	for(var/mob/living/carbon/human/H in tracked)
		var/log = ""
		var/turf/pos = get_turf(H)
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform
			if(pos && pos.z == srcturf.z && U.sensor_mode)
				var/obj/item/ID = null
				if(H.wear_id)
					ID = H.wear_id.GetID()


				var/life_status = "[H.stat > 1 ? "<span class='bad'>Deceased</span>" : "<span class='good'>Living</span>"]"

				if(ID)
					log += "<tr><td width='40%'>[ID.name]</td>"
				else
					log += "<tr><td width='40%'>Unknown</td>"

				var/damage_report
				if(U.sensor_mode > 1)
					var/dam1 = round(H.getOxyLoss(),1)
					var/dam2 = round(H.getToxLoss(),1)
					var/dam3 = round(H.getFireLoss(),1)
					var/dam4 = round(H.getBruteLoss(),1)
					damage_report = "(<font color='blue'>[dam1]</font>/<font color='green'>[dam2]</font>/<font color='orange'>[dam3]</font>/<font color='red'>[dam4]</font>)"

				switch(U.sensor_mode)
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
	var/datum/browser/popup = new(user, "crewcomp", "Crew Monitoring", 900, 600)
	popup.set_content(t)
	popup.open()


proc/crewscan()
	var/list/tracked = list()
	for(var/mob/living/carbon/human/H in mob_list)
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform
			if(U.has_sensor && U.sensor_mode)
				tracked.Add(H)
	return tracked