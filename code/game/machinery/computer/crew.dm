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


#define NA "Not Available"
proc/crewmonitor(mob/user,var/atom/source)
	var/t = "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='30%'><h3>Vitals</h3></td><td width='30%'><h3>Position</h3></td></tr>"
	var/list/logs = list()
	var/list/tracked = crewscan()
	var/turf/srcturf = get_turf(source)
	for(var/mob/living/carbon/human/H in tracked)
		var/turf/pos = get_turf(H)
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform
			if(pos && pos.z == srcturf.z && U.sensor_mode)
				var/list/sensor_data = U.query_sensors()
				if(sensor_data && sensor_data.len)
					var/log = ""

					var/subject_name = NA
					var/subject_binary_lifesigns = NA
					if(sensor_data.len >= 1)
						var/list/level1_data = sensor_data[1]
						subject_name = level1_data[1]
						subject_binary_lifesigns = "[level1_data[2] > 1 ? "<span class='bad'>Deceased</span>" : "<span class='good'>Living</span>"]"

					var/subject_vital_lifesigns = ""
					if(sensor_data.len >= 2)
						var/list/level2_data = sensor_data[2]
						subject_vital_lifesigns = " (<font color='blue'>[level2_data[1]]</font>/<font color='green'>[level2_data[2]]</font>/<font color='orange'>[level2_data[3]]</font>/<font color='red'>[level2_data[4]]</font>)"

					var/subject_position = NA
					if(sensor_data.len >= 3)
						var/list/level3_data = sensor_data[3]
						subject_position = "[level3_data[1]] ([level3_data[2]], [level3_data[3]])"

					log = "<tr><td width='40%'>[subject_name]</td><td width='30%'>[subject_binary_lifesigns][subject_vital_lifesigns]</td><td width='30%'>[subject_position]</td></tr>"
					logs += log

	logs = sortList(logs)
	for(var/log in logs)
		t += log
	t += "</table>"
	var/datum/browser/popup = new(user, "crewcomp", "Crew Monitoring", 900, 600)
	popup.set_content(t)
	popup.open()
#undef NA


proc/crewscan()
	var/list/tracked = list()
	for(var/mob/living/carbon/human/H in mob_list)
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform
			if(U.has_sensor && U.sensor_mode)
				tracked.Add(H)
	return tracked