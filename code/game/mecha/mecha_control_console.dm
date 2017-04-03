/obj/machinery/computer/mecha
	name = "exosuit control console"
	desc = "Used to remotely locate or lockdown exosuits."
	icon_screen = "mecha"
	icon_keyboard = "tech_key"
	req_access = list(access_robotics)
	circuit = /obj/item/weapon/circuitboard/computer/mecha_control
	var/list/located = list()
	var/screen = 0
	var/stored_data

/obj/machinery/computer/mecha/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat = "<html><head><title>[src.name]</title><style>h3 {margin: 0px; padding: 0px;}</style></head><body>"
	if(screen == 0)
		dat += "<h3>Tracking beacons data</h3>"
		var/list/trackerlist = list()
		for(var/obj/mecha/MC in mechas_list)
			trackerlist += MC.trackers
		for(var/obj/item/mecha_parts/mecha_tracking/TR in trackerlist)
			var/answer = TR.get_mecha_info()
			if(answer)
				dat += {"<hr>[answer]<br/>
						  <a href='?src=\ref[src];send_message=\ref[TR]'>Send message</a><br/>
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

/obj/machinery/computer/mecha/Topic(href, href_list)
	if(..())
		return
	var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
	if(href_list["send_message"])
		var/obj/item/mecha_parts/mecha_tracking/MT = filter.getObj("send_message")
		var/message = stripped_input(usr,"Input message","Transmit message")
		var/obj/mecha/M = MT.in_mecha()
		if(trim(message) && M)
			M.occupant_message(message)
		return
	if(href_list["shock"])
		var/obj/item/mecha_parts/mecha_tracking/MT = filter.getObj("shock")
		MT.shock()
	if(href_list["get_log"])
		var/obj/item/mecha_parts/mecha_tracking/MT = filter.getObj("get_log")
		stored_data = MT.get_mecha_log()
		screen = 1
	if(href_list["return"])
		screen = 0
	updateUsrDialog()
	return

/obj/item/mecha_parts/mecha_tracking
	name = "exosuit tracking beacon"
	desc = "Device used to transmit exosuit data."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion2"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "programming=2;magnets=2"
	var/ai_beacon = FALSE //If this beacon allows for AI control. Exists to avoid using istype() on checking.

/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_info()
	if(!in_mecha())
		return 0
	var/obj/mecha/M = src.loc
	var/cell_charge = M.get_charge()
	var/answer = {"<b>Name:</b> [M.name]
<b>Integrity:</b> [M.obj_integrity/M.max_integrity*100]%
<b>Cell charge:</b> [isnull(cell_charge)?"Not found":"[M.cell.percent()]%"]
<b>Airtank:</b> [M.return_pressure()]kPa
<b>Pilot:</b> [M.occupant||"None"]
<b>Location:</b> [get_area(M)||"Unknown"]
<b>Active equipment:</b> [M.selected||"None"] "}
	if(istype(M, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/RM = M
		answer += "<b>Used cargo space:</b> [RM.cargo.len/RM.cargo_capacity*100]%<br>"

	return answer

/obj/item/mecha_parts/mecha_tracking/emp_act()
	qdel(src)

/obj/item/mecha_parts/mecha_tracking/Destroy()
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		if(src in M.trackers)
			M.trackers -= src
	return ..()

/obj/item/mecha_parts/mecha_tracking/proc/in_mecha()
	if(istype(src.loc, /obj/mecha))
		return src.loc
	return 0

/obj/item/mecha_parts/mecha_tracking/proc/shock()
	var/obj/mecha/M = in_mecha()
	if(M)
		M.emp_act(2)
	qdel(src)

/obj/item/mecha_parts/mecha_tracking/proc/get_mecha_log()
	if(!istype(loc, /obj/mecha))
		return 0
	var/obj/mecha/M = src.loc
	return M.get_log_html()


/obj/item/mecha_parts/mecha_tracking/ai_control
	name = "exosuit AI control beacon"
	desc = "A device used to transmit exosuit data. Also allows active AI units to take control of said exosuit."
	origin_tech = "programming=3;magnets=2;engineering=2"
	ai_beacon = TRUE


/obj/item/weapon/storage/box/mechabeacons
	name = "exosuit tracking beacons"

/obj/item/weapon/storage/box/mechabeacons/New()
	..()
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
