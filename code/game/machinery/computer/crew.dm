/obj/machinery/computer/crew
	name = "crew monitoring console"
	desc = "Used to monitor active health sensors built into most of the crew's uniforms."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	use_power = 1
	idle_power_usage = 250
	active_power_usage = 500
	circuit = "/obj/item/weapon/circuitboard/crew"

/obj/machinery/computer/crew/attack_ai(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	crewmonitor.show(user)

/obj/machinery/computer/crew/attack_hand(mob/user)
	if(..())
		return
	if(stat & (BROKEN|NOPOWER))
		return
	crewmonitor.show(user)

/obj/machinery/computer/crew/Topic(href, href_list)
	if(..()) return
	if (src.z > 6)
		usr << "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!"
		return
	if( href_list["close"] )
		usr << browse(null, "window=crewcomp")
		usr.unset_machine()
		return
	if(href_list["update"])
		src.updateDialog()
		return

var/datum/singleton/crewmonitor/crewmonitor = new

/datum/singleton/crewmonitor/var/list/jobs
/datum/singleton/crewmonitor/var/list/interfaces

/datum/singleton/crewmonitor/New()
	. = ..()

	var/list/jobs = new/list()
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
	jobs["Cook"] = 62
	jobs["Botanist"] = 63
	jobs["Librarian"] = 64
	jobs["Chaplain"] = 65
	jobs["Clown"] = 66
	jobs["Mime"] = 67
	jobs["Janitor"] = 68
	jobs["Lawyer"] = 69
	jobs["Admiral"] = 200
	jobs["Centcom Commander"] = 210
	jobs["Custodian"] = 211
	jobs["Medical Officer"] = 212
	jobs["Research Officer"] = 213
	jobs["Emergency Response Team Commander"] = 220
	jobs["Security Response Officer"] = 221
	jobs["Engineer Response Officer"] = 222
	jobs["Medical Response Officer"] = 223
	jobs["Assistant"] = 999 //Unknowns/custom jobs should appear after civilians, and before assistants

	src.jobs = jobs
	src.interfaces = list()

/datum/singleton/crewmonitor/Destroy()
	if (src.interfaces)
		for (var/datum/html_interface/hi in interfaces)
			qdel(hi)
		src.interfaces = null

	return ..()

/datum/singleton/crewmonitor/proc/show(mob/mob, z)
	if (!z) z = mob.z

	if (z > 0 && src.interfaces)
		if (!src.interfaces["[mob.z]"])
			src.interfaces["[mob.z]"] = new/datum/html_interface/nanotrasen(src, "Crew Monitoring", 900, 600)

			src.update()

		var/datum/html_interface/hi = src.interfaces["[z]"]
		hi.show(mob)

/datum/singleton/crewmonitor/proc/update(z)
	if (src.interfaces["[z]"])
		var/datum/html_interface/hi = src.interfaces["[z]"]

		if (hi.isUsed())
			var/t = "<table width='100%'><tr><td width='40%'><h3>Name</h3></td><td width='30%'><h3>Vitals</h3></td><td width='30%'><h3>Position</h3></td></tr>"
			var/list/logs = list()
			var/obj/item/clothing/under/U
			var/obj/item/weapon/card/id/I
			var/log
			var/turf/pos
			var/style
			var/ijob
			var/damage_report

			for(var/mob/living/carbon/human/H in mob_list)
				// Check if their z-level is correct and if they are wearing a uniform.
				// Accept H.z==0 as well in case the mob is inside an object.
				if ((H.z == 0 || H.z == z) && istype(H.w_uniform, /obj/item/clothing/under))
					U = H.w_uniform

					// Are the suit sensors on?
					if (U.has_sensor && U.sensor_mode)
						pos = H.z == 0 || U.sensor_mode == 3 ? get_turf(H) : null

						// Special case: If the mob is inside an object confirm the z-level on turf level.
						if (H.z == 0 && (!pos || pos.z != z)) continue

						log = ""
						I = H.wear_id ? H.wear_id.GetID() : null

						var/life_status = (H.stat > 1 ? "<span class=\"bad\">Deceased</span>" : "<span class=\"good\">Living</span>")

						if (I)
							style = null
							ijob = jobs[I.assignment]

							if (ijob % 10 == 0)            style += "font-weight: bold; " // head roles always end in 0
							if (ijob >= 10 && ijob < 20)   style += "color: #E74C3C; "    // security
							if (ijob >= 20 && ijob < 30)   style += "color: #3498DB; "    // medical
							if (ijob >= 30 && ijob < 40)   style += "color: #9B59B6; "    // science
							if (ijob >= 40 && ijob < 50)   style += "color: #F1C40F; "    // engineering
							if (ijob >= 50 && ijob < 60)   style += "color: #F39C12; "    // cargo
							if (ijob >= 200 && ijob < 230) style += "color: #00C100; "    // Centcom

							// ijob does not get displayed, nor does it take up space, it's just used for the positioning of an entry
							log += "<span style=\"display: none\">[ijob]</span><tr><td width='40%'><span style=\"[style]\">[I.registered_name]</span> ([I.assignment])</td>"
						else
							log += "<span style=\"display: none\">80</span><tr><td width='40%'><i>Unknown</i></td>"

						damage_report = ""

						if (U.sensor_mode > 1)
							var/dam1 = round(H.getOxyLoss(),1)
							var/dam2 = round(H.getToxLoss(),1)
							var/dam3 = round(H.getFireLoss(),1)
							var/dam4 = round(H.getBruteLoss(),1)
							damage_report = "(<font color=\"#3498db\">[dam1]</font>/<font color=\"#2ecc71\">[dam2]</font>/<font color=\"#e67e22\">[dam3]</font>/<font color=\"#e74c3c\">[dam4]</font>)"

						switch (U.sensor_mode)
							if (1)
								log += "<td width=\"30%\">[life_status]</td><td width=\"30%\"><span style=\"color:#7f8c8d\">Not Available</span></td></tr>"

							if (2)
								log += "<td width=\"30%\">[life_status] [damage_report]</td><td width=\"30%\"><span style=\"color:#7f8c8d\">Not Available</span></td></tr>"

							if (3)
								if (!pos) pos = get_turf(H)

								var/area/player_area = get_area(H)
								log += "<td width=\"30%\">[life_status] [damage_report]</td><td width=\"30%\">[format_text(player_area.name)] ([pos.x], [pos.y])</td></tr>"

						logs.Add(log)

			// TODO: Client-side sorting?
			logs = sortList(logs)

			for(log in logs)
				t += log

			t += "</table>"

			hi.updateContent("content", t)

/datum/singleton/crewmonitor/proc/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	var/z = ""

	for (z in src.interfaces)
		if (src.interfaces[z] == hi) break

	return (hclient.client.mob && hclient.client.mob.stat == 0 && hclient.client.mob.z == text2num(z) && ( isAI(hclient.client.mob) || (locate(/obj/machinery/computer/crew, range(1, hclient.client.mob))) || (locate(/obj/item/device/sensor_device, hclient.client.mob.contents)) ) )

/*
/proc/crewscan()
	var/list/tracked = list()
	for(var/mob/living/carbon/human/H in mob_list)
		if(istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform
			if(U.has_sensor && U.sensor_mode)
				tracked.Add(H)
	return tracked
*/

/mob/living/carbon/human/Move()
	if (src.w_uniform)
		var/old_z = src.z

		. = ..()

		if (old_z != src.z) procqueue.queue(crewmonitor, "update", old_z)
		procqueue.queue(crewmonitor, "update", src.z)
	else
		return ..()