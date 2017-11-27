GLOBAL_LIST_INIT(message_servers, list())

/datum/data_pda_msg
	var/recipient = "Unspecified" //name of the person
	var/sender = "Unspecified" //name of the sender
	var/message = "Blank" //transferred message
	var/icon/photo //Attached photo

/datum/data_pda_msg/New(var/param_rec = "",var/param_sender = "",var/param_message = "",var/param_photo=null)

	if(param_rec)
		recipient = param_rec
	if(param_sender)
		sender = param_sender
	if(param_message)
		message = param_message
	if(param_photo)
		photo = param_photo

/datum/data_pda_msg/proc/get_photo_ref()
	if(photo)
		return "<a href='byond://?src=\ref[src];photo=1'>(Photo)</a>"
	return ""

/datum/data_pda_msg/Topic(href,href_list)
	..()
	if(href_list["photo"])
		var/mob/M = usr
		M << browse_rsc(photo, "pda_photo.png")
		M << browse("<html><head><title>PDA Photo</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='pda_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "</body></html>", "window=book;size=192x192")
		onclose(M, "PDA Photo")

/datum/data_rc_msg
	var/rec_dpt = "Unspecified" //name of the person
	var/send_dpt = "Unspecified" //name of the sender
	var/message = "Blank" //transferred message
	var/stamp = "Unstamped"
	var/id_auth = "Unauthenticated"
	var/priority = "Normal"

/datum/data_rc_msg/New(var/param_rec = "",var/param_sender = "",var/param_message = "",var/param_stamp = "",var/param_id_auth = "",var/param_priority)
	if(param_rec)
		rec_dpt = param_rec
	if(param_sender)
		send_dpt = param_sender
	if(param_message)
		message = param_message
	if(param_stamp)
		stamp = param_stamp
	if(param_id_auth)
		id_auth = param_id_auth
	if(param_priority)
		switch(param_priority)
			if(1)
				priority = "Normal"
			if(2)
				priority = "High"
			if(3)
				priority = "Extreme"
			else
				priority = "Undetermined"

/obj/machinery/message_server
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	name = "Messaging Server"
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100

	var/list/datum/data_pda_msg/pda_msgs = list()
	var/list/datum/data_rc_msg/rc_msgs = list()
	var/active = 1
	var/decryptkey = "password"

/obj/machinery/message_server/Initialize()
	GLOB.message_servers += src
	decryptkey = GenerateKey()
	send_pda_message("System Administrator", "system", "This is an automated message. The messaging system is functioning correctly.")
	. = ..()

/obj/machinery/message_server/Destroy()
	GLOB.message_servers -= src
	return ..()

/obj/machinery/message_server/proc/GenerateKey()
	//Feel free to move to Helpers.
	var/newKey
	newKey += pick("the", "if", "of", "as", "in", "a", "you", "from", "to", "an", "too", "little", "snow", "dead", "drunk", "rosebud", "duck", "al", "le")
	newKey += pick("diamond", "beer", "mushroom", "assistant", "clown", "captain", "twinkie", "security", "nuke", "small", "big", "escape", "yellow", "gloves", "monkey", "engine", "nuclear", "ai")
	newKey += pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	return newKey

/obj/machinery/message_server/process()
	//if(decryptkey == "password")
	//	decryptkey = generateKey()
	if(active && (stat & (BROKEN|NOPOWER)))
		active = 0
		return
	update_icon()
	return

/obj/machinery/message_server/proc/send_pda_message(recipient = "",sender = "",message = "",photo=null)
	. = new/datum/data_pda_msg(recipient,sender,message,photo)
	pda_msgs += .

/obj/machinery/message_server/proc/send_rc_message(recipient = "",sender = "",message = "",stamp = "", id_auth = "", priority = 1)
	rc_msgs += new/datum/data_rc_msg(recipient,sender,message,stamp,id_auth)

/obj/machinery/message_server/attack_hand(mob/user)
	to_chat(user, "You toggle PDA message passing from [active ? "On" : "Off"] to [active ? "Off" : "On"]")
	active = !active
	update_icon()

	return

/obj/machinery/message_server/update_icon()
	if((stat & (BROKEN|NOPOWER)))
		icon_state = "server-nopower"
	else if (!active)
		icon_state = "server-off"
	else
		icon_state = "server-on"

	return

/obj/machinery/blackbox_recorder
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	name = "Blackbox Recorder"
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	armor = list(melee = 25, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70)
