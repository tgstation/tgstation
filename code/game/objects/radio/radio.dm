/obj/item/device/radio
	icon = 'radio.dmi'
	name = "station bounced radio"
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"
	var
		last_transmission
		frequency = 1459 //common chat
		traitor_frequency = 0 //tune to frequency to unlock traitor supplies
		obj/item/device/radio/patch_link = null
		obj/item/weapon/syndicate_uplink/traitorradio = null
		wires = WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT
		b_stat = 0
		broadcasting = 0
		listening = 1
		freerange = 0 // 0 - Sanitize frequencies, 1 - Full range
		list/channels = list() //see communications.dm for full list. First channes is a "default" for :h
//			"Example" = FREQ_LISTENING|FREQ_BROADCASTING
	flags = 450
	throw_speed = 2
	throw_range = 9
	w_class = 2
	g_amt = 25
	m_amt = 75
	var/const
		WIRE_SIGNAL = 1 //sends a signal, like to set off a bomb or electrocute someone
		WIRE_RECEIVE = 2
		WIRE_TRANSMIT = 4
		TRANSMISSION_DELAY = 0 // only 2/second/radio
		FREQ_LISTENING = 1
		//FREQ_BROADCASTING = 2


/obj/item/device/radio
	var
		datum/radio_frequency/radio_connection
		list/datum/radio_frequency/secure_radio_connections = new
	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)



/obj/item/device/radio/New()
	..()
	if(radio_controller)
		initialize()

/obj/item/device/radio/initialize()
	if(freerange)
		if(frequency < 1200 || frequency > 1600)
			frequency = sanitize_frequency(frequency)
	else if (frequency < 1441 || frequency > 1489)
		world.log << "[src] ([type]) has a frequency of [frequency], sanitizing."
		frequency = sanitize_frequency(frequency)

	set_frequency(frequency)

	for (var/ch_name in channels)
		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)


/obj/item/device/radio/attack_self(mob/user as mob)
	user.machine = src
	interact(user)

/obj/item/device/radio/proc/interact(mob/user as mob)
	var/dat = {"
				<html><head><title>[src]</title></head><body><TT>
				Microphone: [broadcasting ? "<A href='byond://?src=\ref[src];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];talk=1'>Disengaged</A>"]<BR>
				Speaker: [listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
				Frequency:
				<A href='byond://?src=\ref[src];freq=-10'>-</A>
				<A href='byond://?src=\ref[src];freq=-2'>-</A>
				[format_frequency(frequency)]
				<A href='byond://?src=\ref[src];freq=2'>+</A>
				<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
				"}

	for (var/ch_name in channels)
		dat+=text_sec_channel(ch_name, channels[ch_name])
	dat+={"[text_wires()]</TT></body></html>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/device/radio/proc/text_wires()
	if (!b_stat)
		return ""
	return {"
			<hr>
			Green Wire: <A href='byond://?src=\ref[src];wires=4'>[(wires & 4) ? "Cut" : "Mend"] Wire</A><BR>
			Red Wire:   <A href='byond://?src=\ref[src];wires=2'>[(wires & 2) ? "Cut" : "Mend"] Wire</A><BR>
			Blue Wire:  <A href='byond://?src=\ref[src];wires=1'>[(wires & 1) ? "Cut" : "Mend"] Wire</A><BR>
			"}


/obj/item/device/radio/proc/text_sec_channel(var/chan_name, var/chan_stat)
	var/list = !!(chan_stat&FREQ_LISTENING)!=0
	return {"
			<B>[chan_name]</B><br>
			Speaker: <A href='byond://?src=\ref[src];ch_name=[chan_name];listen=[!list]'>[list ? "Engaged" : "Disengaged"]</A><BR>
			"}

/obj/item/device/radio/Topic(href, href_list)
	//..()
	if (usr.stat)
		return
	if (!(issilicon(usr) || (usr.contents.Find(src) || ( in_range(src, usr) && istype(loc, /turf) ))))
		usr << browse(null, "window=radio")
		return
	usr.machine = src
	if (href_list["track"])
		var/mob/target = locate(href_list["track"])
		var/mob/living/silicon/ai/A = locate(href_list["track2"])
		if(A && target)
			A.ai_actual_track(target)
		return
	else if (href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if (!freerange || (frequency < 1200 || frequency > 1600))
			new_frequency = sanitize_frequency(new_frequency)
		set_frequency(new_frequency)

		if (traitor_frequency && frequency == traitor_frequency)
			usr.machine = null
			usr << browse(null, "window=radio")
			// now transform the regular radio, into a (disguised)syndicate uplink!
			var/obj/item/weapon/syndicate_uplink/T = traitorradio
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
		broadcasting = text2num(href_list["talk"])
	else if (href_list["listen"])
		var/chan_name = href_list["ch_name"]
		if (!chan_name)
			listening = text2num(href_list["listen"])
		else
			if (channels[chan_name] & FREQ_LISTENING)
				channels[chan_name] &= ~FREQ_LISTENING
			else
				channels[chan_name] |= FREQ_LISTENING
	else if (href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
			return
		if (wires & t1)
			wires &= ~t1
		else
			wires |= t1
	if (!( master ))
		if (istype(loc, /mob))
			interact(loc)
		else
			updateDialog()
	else
		if (istype(master.loc, /mob))
			interact(master.loc)
		else
			updateDialog()
	add_fingerprint(usr)

/obj/item/device/radio/talk_into(mob/M as mob, message, channel)
	var/datum/radio_frequency/connection = null
	if(channel && channels && channels.len > 0)
		if (channel == "department")
			//world << "DEBUG: channel=\"[channel]\" switching to \"[channels[1]]\""
			channel = channels[1]
		connection = secure_radio_connections[channel]
	else
		connection = radio_connection
		channel = null
	if (!istype(connection))
		return
	var/display_freq = connection.frequency

	//world << "DEBUG: used channel=\"[channel]\" frequency= \"[display_freq]\" connection.devices.len = [connection.devices.len]"

	var/eqjobname

	if (ishuman(M))
		eqjobname = M:get_assignment()
	else if (iscarbon(M))
		eqjobname = "No id" //only humans can wear ID
	else if (isAI(M))
		eqjobname = "AI"
	else if (isrobot(M))
		eqjobname = "Cyborg"//Androids don't really describe these too well, in my opinion.
	else if (istype(M, /mob/living/silicon/pai))
		eqjobname = "Personal AI"
	else
		eqjobname = "Unknown"

	if (!(wires & WIRE_TRANSMIT))
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
		if (R.client && R.client.STFU_radio) //Adminning with 80 people on can be fun when you're trying to talk and all you can hear is radios.
			continue
		if (R.say_understands(M))
			if (!ishuman(M) || istype(M.wear_mask, /obj/item/clothing/mask/gas/voice))
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
		//var/part_b = "</span><b> \icon[src]\[[format_frequency(frequency)]\]</b> <span class='message'>"
		var/freq_text
		switch(display_freq)
			if(SYND_FREQ)
				freq_text = "#unkn"
			if(COMM_FREQ)
				freq_text = "Command"
			if(1351)
				freq_text = "Science"
			if(1355)
				freq_text = "Medical"
			if(1357)
				freq_text = "Engineering"
			if(1359)
				freq_text = "Security"
			if(1349)
				freq_text = "Mining"
			if(1347)
				freq_text = "Cargo"
		//There's probably a way to use the list var of channels in code\game\communications.dm to make the dept channels non-hardcoded, but I wasn't in an experimentive mood. --NEO

		if(!freq_text)
			freq_text = format_frequency(display_freq)

		var/part_b = "</span><b> \icon[src]\[[freq_text]\]</b> <span class='message'>" // Tweaked for security headsets -- TLE
		var/part_c = "</span></span>"

		if (display_freq==SYND_FREQ)
			part_a = "<span class='syndradio'><span class='name'>"
		else if (display_freq==COMM_FREQ)
			part_a = "<span class='comradio'><span class='name'>"
		else if (display_freq in DEPT_FREQS)
			part_a = "<span class='deptradio'><span class='name'>"

		var/quotedmsg = M.say_quote(message)

		//This following recording is intended for research and feedback in the use of department radio channels.

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
	if (broadcasting)
		talk_into(M, msg)
/*
/obj/item/device/radio/proc/accept_rad(obj/item/device/radio/R as obj, message)

	if ((R.frequency == frequency && message))
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
	if (!(wires & WIRE_RECEIVE))
		return
	if (!freq) //recieved on main frequency
		if (!listening)
			return
	else
		var/accept = (freq==frequency && listening)
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
	//find mobs in lockers, cryo and intellicards, brains, MMIs, and so on.
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
	if ((in_range(src, usr) || loc == usr))
		if (b_stat)
			usr.show_message("\blue \the [src] can be attached and modified!")
		else
			usr.show_message("\blue \the [src] can not be modified or attached!")
	return

/obj/item/device/radio/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	user.machine = src
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	b_stat = !( b_stat )
	if (b_stat)
		user.show_message("\blue The radio can now be attached and modified!")
	else
		user.show_message("\blue The radio can no longer be modified or attached!")
	updateDialog()
		//Foreach goto(83)
	add_fingerprint(user)
	return

/obj/item/device/radio/emp_act(severity)
	broadcasting = 0
	listening = 0
	for (var/ch_name in channels)
		channels[ch_name] = 0
	..()
