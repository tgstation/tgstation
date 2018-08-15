/*
	The equivalent of the server, for PDA and request console messages.
	Without it, PDA and request console messages cannot be transmitted.
	PDAs require the rest of the telecomms setup, but request consoles only
	require the message server.
*/

// A decorational representation of SSblackbox, usually placed alongside the message server.
/obj/machinery/blackbox_recorder
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	name = "Blackbox Recorder"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 70)


// The message server itself.
/obj/machinery/telecomms/message_server
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	name = "Messaging Server"
	desc = "A machine that attempts to gather the secret knowledge of the universe."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100

	id = "Messaging Server"
	network = "tcommsat"
	autolinkers = list("common")

	var/list/datum/data_pda_msg/pda_msgs = list()
	var/list/datum/data_rc_msg/rc_msgs = list()
	var/decryptkey

/obj/machinery/telecomms/message_server/Initialize()
	. = ..()
	if (!decryptkey)
		decryptkey = GenerateKey()
	pda_msgs += new /datum/data_pda_msg("System Administrator", "system", "This is an automated message. The messaging system is functioning correctly.")

/obj/machinery/telecomms/message_server/Destroy()
	for(var/obj/machinery/computer/message_monitor/monitor in GLOB.telecomms_list)
		if(monitor.linkedServer && monitor.linkedServer == src)
			monitor.linkedServer = null
	. = ..()

/obj/machinery/telecomms/message_server/proc/GenerateKey()
	var/newKey
	newKey += pick("the", "if", "of", "as", "in", "a", "you", "from", "to", "an", "too", "little", "snow", "dead", "drunk", "rosebud", "duck", "al", "le")
	newKey += pick("diamond", "beer", "mushroom", "assistant", "clown", "captain", "twinkie", "security", "nuke", "small", "big", "escape", "yellow", "gloves", "monkey", "engine", "nuclear", "ai")
	newKey += pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	return newKey

/obj/machinery/telecomms/message_server/process()
	if(toggled && (stat & (BROKEN|NOPOWER)))
		toggled = FALSE
	update_icon()

/obj/machinery/telecomms/message_server/receive_information(datum/signal/subspace/pda/signal, obj/machinery/telecomms/machine_from)
	// can't log non-PDA signals
	if(!istype(signal) || !signal.data["message"] || !toggled)
		return

	// log the signal
	var/datum/data_pda_msg/M = new(signal.format_target(), "[signal.data["name"]] ([signal.data["job"]])", signal.data["message"], signal.data["photo"])
	pda_msgs += M
	signal.logged = M

	// pass it along to either the hub or the broadcaster
	if(!relay_information(signal, /obj/machinery/telecomms/hub))
		relay_information(signal, /obj/machinery/telecomms/broadcaster)

/obj/machinery/telecomms/message_server/update_icon()
	if((stat & (BROKEN|NOPOWER)))
		icon_state = "server-nopower"
	else if (!toggled)
		icon_state = "server-off"
	else
		icon_state = "server-on"


// PDA signal datum
/datum/signal/subspace/pda
	frequency = FREQ_COMMON
	server_type = /obj/machinery/telecomms/message_server
	var/datum/data_pda_msg/logged

/datum/signal/subspace/pda/New(source, data)
	src.source = source
	src.data = data
	var/turf/T = get_turf(source)
	levels = list(T.z)

/datum/signal/subspace/pda/copy()
	var/datum/signal/subspace/pda/copy = new(source, data.Copy())
	copy.original = src
	copy.levels = levels
	return copy

/datum/signal/subspace/pda/proc/format_target()
	if (length(data["targets"]) > 1)
		return "Everyone"
	return data["targets"][1]

/datum/signal/subspace/pda/proc/format_message()
	if (logged && data["photo"])
		return "\"[data["message"]]\" (<a href='byond://?src=[REF(logged)];photo=1'>Photo</a>)"
	return "\"[data["message"]]\""

/datum/signal/subspace/pda/broadcast()
	if (!logged)  // Can only go through if a message server logs it
		return
	for (var/obj/item/pda/P in GLOB.PDAs)
		if ("[P.owner] ([P.ownjob])" in data["targets"])
			P.receive_message(src)


// Log datums stored by the message server.
/datum/data_pda_msg
	var/sender = "Unspecified"
	var/recipient = "Unspecified"
	var/message = "Blank"  // transferred message
	var/datum/picture/picture  // attached photo

/datum/data_pda_msg/New(param_rec, param_sender, param_message, param_photo)
	if(param_rec)
		recipient = param_rec
	if(param_sender)
		sender = param_sender
	if(param_message)
		message = param_message
	if(param_photo)
		picture = param_photo

/datum/data_pda_msg/Topic(href,href_list)
	..()
	if(href_list["photo"])
		var/mob/M = usr
		M << browse_rsc(picture.picture_image, "pda_photo.png")
		M << browse("<html><head><title>PDA Photo</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='pda_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "</body></html>", "window=pdaphoto;size=[picture.psize_x]x[picture.psize_y];can-close=true")
		onclose(M, "pdaphoto")

/datum/data_rc_msg
	var/rec_dpt = "Unspecified"  // receiving department
	var/send_dpt = "Unspecified"  // sending department
	var/message = "Blank"
	var/stamp = "Unstamped"
	var/id_auth = "Unauthenticated"
	var/priority = "Normal"

/datum/data_rc_msg/New(param_rec, param_sender, param_message, param_stamp, param_id_auth, param_priority)
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

