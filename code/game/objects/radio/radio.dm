/obj/item/device/radio/New()
	..()
	if(radio_controller)
		initialize()

/obj/item/device/radio/initialize()
	if(src.freerange)
		if(src.frequency < 1200 || src.frequency > 1600)
			src.frequency = sanitize_frequency(src.frequency)
	else if (src.frequency < 1441 || src.frequency > 1489)
		world.log << "[src] ([src.type]) has a frequency of [src.frequency], sanitizing."
		src.frequency = sanitize_frequency(src.frequency)

	set_frequency(frequency)

	for (var/ch_name in channels)
		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)

/obj/item/device/radio
	var
		datum/radio_frequency/radio_connection
		list/datum/radio_frequency/secure_radio_connections = new
	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)

/obj/item/device/radio/attack_self(mob/user as mob)
	user.machine = src
	interact(user)

/obj/item/device/radio/proc/interact(mob/user as mob)
	var/dat = {"
<html><head><title>[src]</title></head><body><TT>
Microphone: [src.broadcasting ? "<A href='byond://?src=\ref[src];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];talk=1'>Disengaged</A>"]<BR>
Speaker: [src.listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A>
[format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>"}

	for (var/ch_name in channels)
		dat+=text_sec_channel(ch_name, channels[ch_name])
	dat+={"[text_wires()]</TT></body></html>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/device/radio/proc/text_wires()
	if (!src.b_stat)
		return ""
	return {"
<hr>
Green Wire: <A href='byond://?src=\ref[src];wires=4'>[(src.wires & 4) ? "Cut" : "Mend"] Wire</A><BR>
Red Wire:   <A href='byond://?src=\ref[src];wires=2'>[(src.wires & 2) ? "Cut" : "Mend"] Wire</A><BR>
Blue Wire:  <A href='byond://?src=\ref[src];wires=1'>[(src.wires & 1) ? "Cut" : "Mend"] Wire</A><BR>"}


/obj/item/device/radio/proc/text_sec_channel(var/chan_name, var/chan_stat)
	//var/broad = (chan_stat&FREQ_BROADCASTING)!=0
	var/list = !!(chan_stat&FREQ_LISTENING)!=0
/*
Microphone:"<A href='byond://?src=\ref[src];ch_name=[chan_name];talk=[!broad]'> [broad ? "Engaged" : "Disengaged"]</A>"
*/
	return {"
<B>[chan_name]</B><br>
Speaker: <A href='byond://?src=\ref[src];ch_name=[chan_name];listen=[!list]'>[list ? "Engaged" : "Disengaged"]</A><BR>"}

/obj/item/device/radio/Topic(href, href_list)
	//..()
	if (usr.stat)
		return
	if (\
			!(\
				istype(usr, /mob/living/silicon) || \
				(\
					usr.contents.Find(src) || \
						( in_range(src, usr) && istype(src.loc, /turf) )\
				)\
			)\
		)
		usr << browse(null, "window=radio")
		return
	usr.machine = src
	if (href_list["track"])
		var/mob/target = locate(href_list["track"])
		var/mob/living/silicon/ai/A = locate(href_list["track2"])
		A.ai_actual_track(target)
		return
	else if (href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if (!src.freerange || (src.frequency < 1200 || src.frequency > 1600))
			new_frequency = sanitize_frequency(new_frequency)
		set_frequency(new_frequency)

		if (src.traitor_frequency && src.frequency == src.traitor_frequency)
			usr.machine = null
			usr << browse(null, "window=radio")
			// now transform the regular radio, into a (disguised)syndicate uplink!
			var/obj/item/weapon/syndicate_uplink/T = src.traitorradio
			var/obj/item/device/radio/R = src
			R.loc = T
			T.loc = usr
			R.layer = 0
			if (usr.client)
				usr.client.screen -= R
			if (usr.r_hand == R)
				usr.u_equip(R)
				usr.r_hand = T
			else
				usr.u_equip(R)
				usr.l_hand = T
			R.loc = T
			T.layer = 20
			T.attack_self(usr)
			return
	else if (href_list["talk"])
		src.broadcasting = text2num(href_list["talk"])
	else if (href_list["listen"])
		var/chan_name = href_list["ch_name"]
		if (!chan_name)
			src.listening = text2num(href_list["listen"])
		else
			if (channels[chan_name] & FREQ_LISTENING)
				channels[chan_name] &= ~FREQ_LISTENING
			else
				channels[chan_name] |= FREQ_LISTENING
	else if (href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
			return
		if (src.wires & t1)
			src.wires &= ~t1
		else
			src.wires |= t1
	if (!( src.master ))
		if (istype(src.loc, /mob))
			interact(src.loc)
		else
			src.updateDialog()
	else
		if (istype(src.master.loc, /mob))
			interact(src.master.loc)
		else
			src.updateDialog()
	src.add_fingerprint(usr)

/obj/item/device/radio/talk_into(mob/M as mob, message, channel)
	var/datum/radio_frequency/connection = null // Code shared by Mport2004 for Security Headsets -- TLE
	if(channel && src.channels && src.channels.len > 0)
		if (channel == "department")
			//world << "DEBUG: channel=\"[channel]\" switching to \"[src.channels[1]]\""
			channel = src.channels[1]
		connection = secure_radio_connections[channel]
	else
		connection = src.radio_connection
		channel = null
	if (!istype(connection))
		return
	var/display_freq = connection.frequency

	//world << "DEBUG: used channel=\"[channel]\" frequency= \"[display_freq]\" connection.devices.len = [connection.devices.len]"

	var/eqjobname

	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		eqjobname = H.get_assignment()
	else if (istype(M, /mob/living/carbon))
		eqjobname = "No id" //only humans can wear ID
	else if (istype(M,/mob/living/silicon/ai))
		eqjobname = "AI"
	else if (istype(M,/mob/living/silicon/robot))
		eqjobname = "Android"
	else
		eqjobname = "Unknown"

	if (!(src.wires & WIRE_TRANSMIT))
		return

	var/list/receive = list()

	//for (var/obj/item/device/radio/R in radio_connection.devices)
	for (var/obj/item/device/radio/R in connection.devices["[RADIO_CHAT]"]) // Modified for security headset code -- TLE
		//if(R.accept_rad(src, message))
		receive |= R.send_hear(display_freq)

	//world << "DEBUG: receive.len=[receive.len]"
	var/list/heard_masked = list() // masked name or no real name
	var/list/heard_normal = list() // normal message
	var/list/heard_voice = list() // voice message
	var/list/heard_garbled = list() // garbled message

	for (var/mob/R in receive)
		if (R.say_understands(M))
			if (!istype(M, /mob/living/carbon/human) || istype(M.wear_mask, /obj/item/clothing/mask/gas/voice))
				heard_masked += R
			else
				heard_normal += R
		else
			if (M.voice_message)
				heard_voice += R
			else
				heard_garbled += R

	if (length(heard_masked) || length(heard_normal) || length(heard_voice) || length(heard_garbled))
		var/part_a = "<span class='radio'><span class='name'>"
		//var/part_b = "</span><b> \icon[src]\[[format_frequency(src.frequency)]\]</b> <span class='message'>"
		var/freq_text = (display_freq!=SYND_FREQ) ? format_frequency(display_freq) : "#unkn"
		var/part_b = "</span><b> \icon[src]\[[freq_text]\]</b> <span class='message'>" // Tweaked for security headsets -- TLE
		var/part_c = "</span></span>"

		if (display_freq==SYND_FREQ)
			part_a = "<span class='syndradio'><span class='name'>"
		else if (display_freq==COMM_FREQ)
			part_a = "<span class='comradio'><span class='name'>"
		else if (display_freq in DEPT_FREQS)
			part_a = "<span class='deptradio'><span class='name'>"

		var/quotedmsg = M.say_quote(message)

		//This following recording is intended for research and feedback in the use of department radio channels. It was added on 30.3.2011 by errorage.

		var/part_blackbox_b = "</span><b> \[[freq_text]\]</b> <span class='message'>" // Tweaked for security headsets -- TLE
		var/blackbox_msg = "[part_a][M.name][part_blackbox_b][quotedmsg][part_c]"
		//var/blackbox_admin_msg = "[part_a][M.name] (Real name: [M.real_name])[part_blackbox_b][quotedmsg][part_c]"
		for (var/obj/machinery/blackbox_recorder/BR in world)
			//BR.messages_admin += blackbox_admin_msg
			switch(display_freq)
				if(1459)
					BR.msg_common += blackbox_msg
				if(1351)
					BR.msg_science += blackbox_msg
				if(1353)
					BR.msg_command += blackbox_msg
				if(1355)
					BR.msg_medical += blackbox_msg
				if(1357)
					BR.msg_engineering += blackbox_msg
				if(1359)
					BR.msg_security += blackbox_msg
				if(1441)
					BR.msg_deathsquad += blackbox_msg
				if(1213)
					BR.msg_syndicate += blackbox_msg
				if(1349)
					BR.msg_mining += blackbox_msg
				if(1347)
					BR.msg_cargo += blackbox_msg
				else
					BR.messages += blackbox_msg

		//End of research and feedback code.

		if (length(heard_masked))
			var/N = M.name
			var/J = eqjobname
			if (istype(M.wear_mask, /obj/item/clothing/mask/gas/voice)&&M.wear_mask:vchange)
			//To properly have the ninja show up on radio. Could also be useful for similar items.
			//Would not be necessary but the mob could be wearing a mask that is not a voice changer.
				N = M.wear_mask:voice
				J = "Unknown"
			var/rendered = "[part_a][N][part_b][quotedmsg][part_c]"
			for (var/mob/R in heard_masked)
				if(istype(R, /mob/living/silicon/ai))
					R.show_message("[part_a]<a href='byond://?src=\ref[src];track2=\ref[R];track=\ref[M]'>[N] ([J]) </a>[part_b][quotedmsg][part_c]", 2)
				else
					R.show_message(rendered, 2)

		if (length(heard_normal))
			var/rendered = "[part_a][M.real_name][part_b][quotedmsg][part_c]"

			for (var/mob/R in heard_normal)
				if(istype(R, /mob/living/silicon/ai))
					R.show_message("[part_a]<a href='byond://?src=\ref[src];track2=\ref[R];track=\ref[M]'>[M.real_name] ([eqjobname]) </a>[part_b][quotedmsg][part_c]", 2)
				else
					R.show_message(rendered, 2)

		if (length(heard_voice))
			var/rendered = "[part_a][M.voice_name][part_b][M.voice_message][part_c]"

			for (var/mob/R in heard_voice)
				if(istype(R, /mob/living/silicon/ai))
					R.show_message("[part_a]<a href='byond://?src=\ref[src];track2=\ref[R];track=\ref[M]'>[M.voice_name] ([eqjobname]) </a>[part_b][M.voice_message][part_c]", 2)
				else
					R.show_message(rendered, 2)

		if (length(heard_garbled))
			quotedmsg = M.say_quote(stars(message))
			var/rendered = "[part_a][M.voice_name][part_b][quotedmsg][part_c]"

			for (var/mob/R in heard_voice)
				if(istype(R, /mob/living/silicon/ai))
					R.show_message("[part_a]<a href='byond://?src=\ref[src];track2=\ref[R];track=\ref[M]'>[M.voice_name]</a>[part_b][quotedmsg][part_c]", 2)
				else
					R.show_message(rendered, 2)

/obj/item/device/radio/hear_talk(mob/M as mob, msg)
	if (src.broadcasting)
		talk_into(M, msg)
/*
/obj/item/device/radio/proc/accept_rad(obj/item/device/radio/R as obj, message)

	if ((R.frequency == src.frequency && message))
		return 1
	else if

	else
		return null
	return
*/
/obj/item/device/radio/proc/send_hear(freq)
	if(last_transmission && world.time < (last_transmission + TRANSMISSION_DELAY))
		return
	last_transmission = world.time
	if (!(src.wires & WIRE_RECEIVE))
		return
	if (!freq) //recieved on main frequency
		if (!src.listening)
			return
	else
		var/accept = (freq==frequency && src.listening)
		if (!accept)
			for (var/ch_name in channels)
				var/datum/radio_frequency/RF = secure_radio_connections[ch_name]
				if (RF.frequency==freq && (channels[ch_name]&FREQ_LISTENING))
					accept = 1
					break
		if (!accept)
			return

	var/turf/T = get_turf(src)
	var/list/hear = hearers(1, T)
	var/list/V
	//find mobs in lockers, cryo and intellycards
	for (var/mob/M in world)
		if (isturf(M.loc))
			continue //if M can hear us it is already was found by hearers()
		if (!M.client)
			continue //skip monkeys and leavers
		if (!V) //lasy initialisation
			V = view(1, T)
		if (get_turf(M) in V) //this slow, but I don't think we'd have a lot of wardrobewhores every round --rastaf0
			hear+=M
	return hear

/obj/item/device/radio/examine()
	set src in view()

	..()
	if ((in_range(src, usr) || src.loc == usr))
		if (src.b_stat)
			usr.show_message("\blue \the [src] can be attached and modified!")
		else
			usr.show_message("\blue \the [src] can not be modified or attached!")
	return

/obj/item/device/radio/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	user.machine = src
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.b_stat = !( src.b_stat )
	if (src.b_stat)
		user.show_message("\blue The radio can now be attached and modified!")
	else
		user.show_message("\blue The radio can no longer be modified or attached!")
	src.updateDialog()
		//Foreach goto(83)
	src.add_fingerprint(user)
	return

/obj/item/device/radio/emp_act(severity)
	broadcasting = 0
	listening = 0
	for (var/ch_name in channels)
		channels[ch_name] = 0
	..()
