<<<<<<< HEAD
/obj/machinery/computer/atmos_alert
	name = "atmospheric alert console"
	desc = "Used to monitor the station's air alarms."
	circuit = /obj/item/weapon/circuitboard/computer/atmos_alert
	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = 1437
	var/datum/radio_frequency/radio_connection

/obj/machinery/computer/atmos_alert/initialize()
	..()
	set_frequency(receive_frequency)

/obj/machinery/computer/atmos_alert/Destroy()
	if(SSradio)
		SSradio.remove_object(src, receive_frequency)
	return ..()

/obj/machinery/computer/atmos_alert/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
									datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "atmos_alert", name, 350, 300, master_ui, state)
		ui.open()

/obj/machinery/computer/atmos_alert/ui_data(mob/user)
	var/list/data = list()

	data["priority"] = list()
	for(var/zone in priority_alarms)
		data["priority"] += zone
	data["minor"] = list()
	for(var/zone in minor_alarms)
		data["minor"] += zone

	return data

/obj/machinery/computer/atmos_alert/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("clear")
			var/zone = params["zone"]
			if(zone in priority_alarms)
				usr << "Priority alarm for [zone] cleared."
				priority_alarms -= zone
				. = TRUE
			if(zone in minor_alarms)
				usr << "Minor alarm for [zone] cleared."
				minor_alarms -= zone
				. = TRUE
	update_icon()

/obj/machinery/computer/atmos_alert/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, receive_frequency)
	receive_frequency = new_frequency
	radio_connection = SSradio.add_object(src, receive_frequency, RADIO_ATMOSIA)

/obj/machinery/computer/atmos_alert/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	var/zone = signal.data["zone"]
	var/severity = signal.data["alert"]

	if(!zone || !severity) return

	minor_alarms -= zone
	priority_alarms -= zone
	if(severity == "severe")
		priority_alarms += zone
	else if (severity == "minor")
		minor_alarms += zone
	update_icon()
	return

/obj/machinery/computer/atmos_alert/update_icon()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	if(priority_alarms.len)
		add_overlay("alert:2")
	else if(minor_alarms.len)
		add_overlay("alert:1")
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31


/obj/machinery/computer/atmos_alert
	name = "Atmospheric Alert Computer"
	desc = "Used to access the station's atmospheric sensors."
	circuit = "/obj/item/weapon/circuitboard/atmos_alert"
	icon_state = "alert:0"
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = 1437
	var/datum/radio_frequency/radio_connection

	light_color = LIGHT_COLOR_CYAN


/obj/machinery/computer/atmos_alert/initialize()
	..()
	set_frequency(receive_frequency)

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
	user << browse(return_text(),"window=computer")
	user.set_machine(src)
	onclose(user, "computer")

/obj/machinery/computer/atmos_alert/process()
	if(..())
		src.updateDialog()

/obj/machinery/computer/atmos_alert/update_icon()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	if(priority_alarms.len)
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
			priority_text += "<FONT color='red'><B>[zone]</B></FONT>  <A href='?src=\ref[src];priority_clear=[ckey(zone)]'>X</A><BR>"
	else
		priority_text = "No priority alerts detected.<BR>"

	if(minor_alarms.len)
		for(var/zone in minor_alarms)
			minor_text += "<B>[zone]</B>  <A href='?src=\ref[src];minor_clear=[ckey(zone)]'>X</A><BR>"
	else
		minor_text = "No minor alerts detected.<BR>"

	var/output = {"<B>[name]</B><HR>
<B>Priority Alerts:</B><BR>
[priority_text]
<BR>
<HR>
<B>Minor Alerts:</B><BR>
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
				priority_alarms -= zone

	if(href_list["minor_clear"])
		var/removing_zone = href_list["minor_clear"]
		for(var/zone in minor_alarms)
			if(ckey(zone) == removing_zone)
				minor_alarms -= zone
	update_icon()
	return

/obj/machinery/computer/atmos_alert/Destroy()
	radio_controller.remove_object(src, receive_frequency)
	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
