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


#define NA "<span style=\"color:#7f8c8d\">Not Available</span>"
proc/crewmonitor(mob/user,var/atom/source)
	var/jobs[0]
	jobs["Captain"] = 00
	jobs["Head of Personnel"] = 50
	jobs["Head of Security"] = 10
	jobs["Warden"] = 11
	jobs["Security Officer"] = 12
	jobs["Detective"] = 13
	jobs["Chief Medical Officer"] = 20
	jobs["Chemist"] = 21
	jobs["Geneticist"] = 22
	jobs["Virologist"] = 23
	jobs["Medical Doctor"] = 24
	jobs["Research Director"] = 30
	jobs["Scientist"] = 31
	jobs["Roboticist"] = 32
	jobs["Chief Engineer"] = 40
	jobs["Station Engineer"] = 41
	jobs["Atmospheric Technician"] = 42
	jobs["Quartermaster"] = 51
	jobs["Shaft Miner"] = 52
	jobs["Cargo Technician"] = 53
	jobs["Bartender"] = 61
	jobs["Chef"] = 62
	jobs["Botanist"] = 63
	jobs["Librarian"] = 64
	jobs["Chaplain"] = 65
	jobs["Clown"] = 66
	jobs["Mime"] = 67
	jobs["Janitor"] = 68
	jobs["Assistant"] = 99	//Unknowns/custom jobs should appear after civilians, and before assistants

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
					var/name_style = null
					var/subject_job = NA
					var/ijob = 80
					var/subject_binary_lifesigns = NA
					if(sensor_data.len >= 1)
						var/list/level1_data = sensor_data[1]
						subject_name = level1_data[1]
						if(!subject_name)
							subject_name = "<i>Unknown</i>"
						subject_job = level1_data[2]
						if(subject_job)
							ijob = jobs[subject_job]
							if(ijob % 10 == 0)
								name_style += "font-weight: bold; "	//head roles always end in 0
							if(ijob >= 10 && ijob < 20)
								name_style += "color: #E74C3C; "	//security
							if(ijob >= 20 && ijob < 30)
								name_style += "color: #3498DB; "	//medical
							if(ijob >= 30 && ijob < 40)
								name_style += "color: #9B59B6; "	//science
							if(ijob >= 40 && ijob < 50)
								name_style += "color: #F1C40F; "	//engineering
							if(ijob >= 50 && ijob < 60)
								name_style += "color: #F39C12; "	//cargo

						subject_binary_lifesigns = "[level1_data[3] > 1 ? "<span class='bad'>Deceased</span>" : "<span class='good'>Living</span>"]"

					var/subject_vital_lifesigns = ""
					if(sensor_data.len >= 2)
						var/list/level2_data = sensor_data[2]
						subject_vital_lifesigns = " (<font color='#3498db'>[level2_data[1]]</font>/<font color='#2ecc71'>[level2_data[2]]</font>/<font color='#e67e22'>[level2_data[3]]</font>/<font color='#e74c3c'>[level2_data[4]]</font>)"

					var/subject_position = NA
					if(sensor_data.len >= 3)
						var/list/level3_data = sensor_data[3]
						subject_position = "[level3_data[1]] ([level3_data[2]], [level3_data[3]])"

					log = "<tr><span style=\"display: none\">[ijob]]</span><td width='40%'><span style=\"[name_style]\">[subject_name]</span>[subject_job ? " ([subject_job])" : ""]</td><td width='30%'>[subject_binary_lifesigns][subject_vital_lifesigns]</td><td width='30%'>[subject_position]</td></tr>"
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