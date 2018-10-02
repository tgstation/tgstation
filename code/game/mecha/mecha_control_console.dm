/obj/machinery/computer/mecha
	name = "exosuit control console"
	desc = "Used to remotely locate or lockdown exosuits."
	icon_screen = "mecha"
	icon_keyboard = "tech_key"
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/computer/mecha_control
	var/list/located = list()
	var/screen = 0
	var/stored_data

/obj/machinery/computer/mecha/ui_interact(mob/user)
	. = ..()
	var/dat = "<html><head><title>[src.name]</title><style>h3 {margin: 0px; padding: 0px;}</style></head><body>"
	if(screen == 0)
		dat += "<h3>Tracking beacons data</h3>"
		var/list/trackerlist = list()
		for(var/obj/mecha/MC in GLOB.mechas_list)
			trackerlist += MC.trackers
		for(var/obj/item/mecha_parts/mecha_tracking/TR in trackerlist)
			var/answer = TR.get_mecha_info()
			if(answer)
				dat += {"<hr>[answer]<br/>
						  <a href='?src=[REF(src)];send_message=[REF(TR)]'>Send message</a><br/>

	if(screen==1)
		dat += {"<h3>Log contents</h3>"
		<a href='?src=[REF(src)];return=1'>Return</a><hr>"
		[stored_data]"}

	dat += "<A href='?src=[REF(src)];refresh=1'>(Refresh)</A><BR>"
	dat += "</body></html>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")

/obj/machinery/computer/mecha/Topic(href, href_list)
	if(..())
		return
	var/datum/topic_input/afilter = new /datum/topic_input(href,href_list)
	if(href_list["send_message"])
		var/obj/item/mecha_parts/mecha_tracking/MT = afilter.getObj("send_message")
		var/message = stripped_input(usr,"Input message","Transmit message")
		var/obj/mecha/M = MT.in_mecha()
		if(trim(message) && M)
			M.occupant_message(message)
		return
	if(href_list["shock"])
		var/obj/item/mecha_parts/mecha_tracking/MT = afilter.getObj("shock")
		MT.shock()
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
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		qdel(src)

/obj/item/mecha_parts/mecha_tracking/Destroy()
	if(ismecha(loc))
		var/obj/mecha/M = loc
		if(src in M.trackers)
			M.trackers -= src
	return ..()

/obj/item/mecha_parts/mecha_tracking/proc/in_mecha()
	if(ismecha(loc))
		return loc
	return 0

/obj/item/mecha_parts/mecha_tracking/proc/shock()
	var/obj/mecha/M = in_mecha()
	if(M)
		M.emp_act(EMP_LIGHT)
	qdel(src)

/obj/item/mecha_parts/mecha_tracking/ai_control
	name = "exosuit AI control beacon"
	desc = "A device used to transmit exosuit data. Also allows active AI units to take control of said exosuit."
	ai_beacon = TRUE


/obj/item/storage/box/mechabeacons
	name = "exosuit tracking beacons"

/obj/item/storage/box/mechabeacons/PopulateContents()
	..()
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
