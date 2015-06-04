//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31


/obj/machinery/computer/atmos_alert
	name = "atmospheric alert console"
	desc = "Used to access the station's atmospheric sensors."
	circuit = /obj/item/weapon/circuitboard/atmos_alert
	icon_state = "alert:0"
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = 1437
	var/datum/radio_frequency/radio_connection


/obj/machinery/computer/atmos_alert/initialize()
	..()
	set_frequency(receive_frequency)

/obj/machinery/computer/atmos_alert/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, receive_frequency)
	..()

/obj/machinery/computer/atmos_alert/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/zone = signal.data["zone"]
	var/severity = signal.data["alert"]

	if(!zone || !severity) return

	minor_alarms -= zone
	priority_alarms -= zone
	if(severity=="severe")
		priority_alarms += zone
	else if (severity=="minor")
		minor_alarms += zone
	update_icon()
	return


/obj/machinery/computer/atmos_alert/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, receive_frequency)
	receive_frequency = new_frequency
	radio_connection = radio_controller.add_object(src, receive_frequency, RADIO_ATMOSIA)


/obj/machinery/computer/atmos_alert/attack_hand(mob/user)
	if(..(user))
		return
	interact(user) //UpdateDialog() is calling /interact each tick, not attack_hand()

/obj/machinery/computer/atmos_alert/interact(mob/user)
	var/datum/browser/popup = new(user, "computer", name)
	popup.set_content(return_text())
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/atmos_alert/process()
	if(..())
		src.updateDialog()

/obj/machinery/computer/atmos_alert/update_icon()
	SetLuminosity(brightness_on)
	if(stat & BROKEN)
		icon_state = "alert:b"
		return
	else if (stat & NOPOWER)
		icon_state = "alert:O"
		SetLuminosity(0)
		return
	else if(priority_alarms.len)
		icon_state = "alert:2"

	else if(minor_alarms.len)
		icon_state = "alert:1"

	else
		icon_state = "alert:0"
	return


/obj/machinery/computer/atmos_alert/proc/return_text()
	var/priority_text
	var/minor_text

	if(priority_alarms.len)
		for(var/zone in priority_alarms)
			priority_text += "<FONT color='red'><B>[format_text(zone)]</B></FONT>  <A href='?src=\ref[src];priority_clear=[ckey(zone)]'>X</A><BR>"
	else
		priority_text = "No priority alerts detected.<BR>"

	if(minor_alarms.len)
		for(var/zone in minor_alarms)
			minor_text += "<B>[format_text(zone)]</B>  <A href='?src=\ref[src];minor_clear=[ckey(zone)]'>X</A><BR>"
	else
		minor_text = "No minor alerts detected.<BR>"

	var/output = {"<h2>Priority Alerts:</h2>
[priority_text]
<BR>
<HR>
<h2>Minor Alerts:</h2>
[minor_text]
<BR>"}

	return output


/obj/machinery/computer/atmos_alert/Topic(href, href_list)
	if(..())
		return

	if(href_list["priority_clear"])
		var/removing_zone = href_list["priority_clear"]
		for(var/zone in priority_alarms)
			if(ckey(zone) == removing_zone)
				usr << "\green Priority Alert for [format_text(zone)] cleared."
				priority_alarms -= zone

	if(href_list["minor_clear"])
		var/removing_zone = href_list["minor_clear"]
		for(var/zone in minor_alarms)
			if(ckey(zone) == removing_zone)
				usr << "\green Minor Alert for [format_text(zone)] cleared."
				minor_alarms -= zone
	update_icon()
	return
