var/GLOBAL_RADIO_TYPE = 1 // radio type to use
	// 0 = old radios
	// 1 = new radios (subspace technology)


/obj/item/device/radio
	icon = 'icons/obj/radio.dmi'
	name = "station bounced radio"
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"
	var/on = 1 // 0 for off
	var/last_transmission
	var/frequency = 1459 //common chat
	var/traitor_frequency = 0 //tune to frequency to unlock traitor supplies
	var/canhear_range = 3 // the range which mobs can hear this radio from
	var/obj/item/device/radio/patch_link = null
	var/wires = WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT
	var/b_stat = 0
	var/broadcasting = 0
	var/listening = 1
	var/freerange = 0 // 0 - Sanitize frequencies, 1 - Full range
	var/list/channels = list() //see communications.dm for full list. First channes is a "default" for :h
	var/subspace_transmission = 0
	var/syndie = 0//Holder to see if it's a syndicate encrpyed radio
	var/maxf = 1499
//			"Example" = FREQ_LISTENING|FREQ_BROADCASTING
	flags = FPRINT | CONDUCT | TABLEPASS
	slot_flags = SLOT_BELT
	throw_speed = 2
	throw_range = 9
	w_class = 2
	g_amt = 25
	m_amt = 75
	var/const/WIRE_SIGNAL = 1 //sends a signal, like to set off a bomb or electrocute someone
	var/const/WIRE_RECEIVE = 2
	var/const/WIRE_TRANSMIT = 4
	var/const/TRANSMISSION_DELAY = 5 // only 2/second/radio
	var/const/FREQ_LISTENING = 1
		//FREQ_BROADCASTING = 2

/obj/item/device/radio
	var/datum/radio_frequency/radio_connection
	var/list/datum/radio_frequency/secure_radio_connections = new

	proc/set_frequency(new_frequency)
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
			frequency = sanitize_frequency(frequency, maxf)
	// The max freq is higher than a regular headset to decrease the chance of people listening in, if you use the higher channels.
	else if (frequency < 1441 || frequency > maxf)
		//world.log << "[src] ([type]) has a frequency of [frequency], sanitizing."
		frequency = sanitize_frequency(frequency, maxf)

	set_frequency(frequency)

	for (var/ch_name in channels)
		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)


/obj/item/device/radio/attack_self(mob/user as mob)
	user.machine = src
	interact(user)

/obj/item/device/radio/proc/interact(mob/user as mob)
	if(!on)
		return

	if(active_uplink_check(user))
		return

	var/dat = "<html><head><title>[src]</title></head><body><TT>"

	if(!istype(src, /obj/item/device/radio/headset)) //Headsets dont get a mic button
		dat += "Microphone: [broadcasting ? "<A href='byond://?src=\ref[src];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];talk=1'>Disengaged</A>"]<BR>"

	dat += {"
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
	if (usr.stat || !on)
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

	else if (href_list["faketrack"])
		var/mob/target = locate(href_list["track"])
		var/mob/living/silicon/ai/A = locate(href_list["track2"])
		if(A && target)

			A:cameraFollow = target
			A << text("Now tracking [] on camera.", target.name)
			if (usr.machine == null)
				usr.machine = usr

			while (usr:cameraFollow == target)
				usr << "Target is not on or near any active cameras on the station. We'll check again in 5 seconds (unless you use the cancel-camera verb)."
				sleep(40)
				continue

		return

	else if (href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		if (!freerange || (frequency < 1200 || frequency > 1600))
			new_frequency = sanitize_frequency(new_frequency, maxf)
		set_frequency(new_frequency)
		if(hidden_uplink)
			if(hidden_uplink.check_trigger(usr, frequency, traitor_frequency))
				usr << browse(null, "window=radio")
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
		if (!( istype(usr.get_active_hand(), /obj/item/weapon/wirecutters) ))
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

/obj/item/device/radio/proc/autosay(var/message, var/from, var/channel) //BS12 EDIT	var/datum/radio_frequency/connection = null	if(channel && channels && channels.len > 0)		if (channel == "department")			//world << "DEBUG: channel=\"[channel]\" switching to \"[channels[1]]\""			channel = channels[1]		connection = secure_radio_connections[channel]	else		connection = radio_connection		channel = null	if (!istype(connection))		return	if (!connection)		return	Broadcast_Message(connection, new /mob/living/silicon/ai(src),						0, "*garbled automated announcement*", src,						message, from, "Automated Announcement", from, "synthesized voice",						4, 0, 1)	return/obj/item/device/radio/talk_into(mob/living/M as mob, message, channel)
	if(!on) return // the device has to be on
	//  Fix for permacell radios, but kinda eh about actually fixing them.
	if(!M || !message) return

	//  Uncommenting this. To the above comment:
	// 	The permacell radios aren't suppose to be able to transmit, this isn't a bug and this "fix" is just making radio wires useless. -Giacom
	if(!(src.wires & WIRE_TRANSMIT)) // The device has to have all its wires and shit intact
		return


	if(GLOBAL_RADIO_TYPE == 1) // NEW RADIO SYSTEMS: By Doohl

		/* Quick introduction:
			This new radio system uses a very robust FTL signaling technology unoriginally
			dubbed "subspace" which is somewhat similar to 'blue-space' but can't
			actually transmit large mass. Headsets are the only radio devices capable
			of sending subspace transmissions to the Communications Satellite.

			A headset sends a signal to a subspace listener/reciever elsewhere in space,
			the signal gets processed and logged, and an audible transmission gets sent
			to each individual headset.
		*/

	   //#### Grab the connection datum ####//
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
		if (!connection)
			return

		var/turf/position = get_turf(src)

		//#### Tagging the signal with all appropriate identity values ####//

		// ||-- The mob's name identity --||
		var/displayname = M.name	// grab the display name (name you get when you hover over someone's icon)
		var/real_name = M.real_name // mob's real name
		var/mobkey = "none" // player key associated with mob
		var/voicemask = 0 // the speaker is wearing a voice mask
		if(M.client)
			mobkey = M.key // assign the mob's key


		var/jobname // the mob's "job"

		// --- Human: use their actual job ---
		if (ishuman(M))
			jobname = M:get_assignment()

		// --- Carbon Nonhuman ---
		else if (iscarbon(M)) // Nonhuman carbon mob
			jobname = "No id"

		// --- AI ---
		else if (isAI(M))
			jobname = "AI"

		// --- Cyborg ---
		else if (isrobot(M))
			jobname = "Cyborg"

		// --- Personal AI (pAI) ---
		else if (istype(M, /mob/living/silicon/pai))
			jobname = "Personal AI"

		// --- Unidentifiable mob ---
		else
			jobname = "Unknown"


		// --- Modifications to the mob's identity ---

		// The mob is disguising their identity:
		if (ishuman(M) && M.GetVoice() != real_name)
			displayname = M.GetVoice()
			jobname = "Unknown"
			voicemask = 1



	  /* ###### Radio headsets can only broadcast through subspace ###### */

		if(subspace_transmission)
			// First, we want to generate a new radio signal
			var/datum/signal/signal = new
			signal.transmission_method = 2 // 2 would be a subspace transmission.
										   // transmission_method could probably be enumerated through #define. Would be neater.

			// --- Finally, tag the actual signal with the appropriate values ---
			signal.data = list(
			  // Identity-associated tags:
				"mob" = M, // store a reference to the mob
				"mobtype" = M.type, 	// the mob's type
				"realname" = real_name, // the mob's real name
				"name" = displayname,	// the mob's display name
				"job" = jobname,		// the mob's job
				"key" = mobkey,			// the mob's key
				"vmessage" = M.voice_message, // the message to display if the voice wasn't understood
				"vname" = M.voice_name, // the name to display if the voice wasn't understood
				"vmask" = voicemask,	// 1 if the mob is using a voice gas mask

				// We store things that would otherwise be kept in the actual mob
				// so that they can be logged even AFTER the mob is deleted or something

			  // Other tags:
				"compression" = rand(45,50), // compressed radio signal
				"message" = message, // the actual sent message
				"connection" = connection, // the radio connection to use
				"radio" = src, // stores the radio used for transmission
				"slow" = 0, // how much to sleep() before broadcasting - simulates net lag
				"traffic" = 0, // dictates the total traffic sum that the signal went through
				"type" = 0, // determines what type of radio input it is: normal broadcast
				"server" = null, // the last server to log this signal
				"reject" = 0,	// if nonzero, the signal will not be accepted by any broadcasting machinery
				"level" = position.z // The source's z level
			)
			signal.frequency = connection.frequency // Quick frequency set

		  //#### Sending the signal to all subspace receivers ####//

			for(var/obj/machinery/telecomms/receiver/R in telecomms_list)
				R.receive_signal(signal)

			// Allinone can act as receivers.
			for(var/obj/machinery/telecomms/allinone/R in telecomms_list)
				R.receive_signal(signal)

			// Receiving code can be located in Telecommunications.dm
			return


	  /* ###### Intercoms and station-bounced radios ###### */

		var/filter_type = 2

		/* --- Intercoms can only broadcast to other intercoms, but bounced radios can broadcast to bounced radios and intercoms --- */
		if(istype(src, /obj/item/device/radio/intercom))
			filter_type = 1


		var/datum/signal/signal = new
		signal.transmission_method = 2


		/* --- Try to send a normal subspace broadcast first */

		signal.data = list(

			"mob" = M, // store a reference to the mob
			"mobtype" = M.type, 	// the mob's type
			"realname" = real_name, // the mob's real name
			"name" = displayname,	// the mob's display name
			"job" = jobname,		// the mob's job
			"key" = mobkey,			// the mob's key
			"vmessage" = M.voice_message, // the message to display if the voice wasn't understood
			"vname" = M.voice_name, // the name to display if the voice wasn't understood
			"vmask" = voicemask,	// 1 if the mob is using a voice gas mas

			"compression" = 0, // uncompressed radio signal
			"message" = message, // the actual sent message
			"connection" = connection, // the radio connection to use
			"radio" = src, // stores the radio used for transmission
			"slow" = 0,
			"traffic" = 0,
			"type" = 0,
			"server" = null,
			"reject" = 0,
			"level" = position.z
		)
		signal.frequency = connection.frequency // Quick frequency set

		for(var/obj/machinery/telecomms/receiver/R in telecomms_list)
			R.receive_signal(signal)


		sleep(rand(10,25)) // wait a little...

		if(signal.data["done"])
			// we're done here.
			return

	  	// Oh my god; the comms are down or something because the signal hasn't been broadcasted yet.
	  	// Send a mundane broadcast with limited targets:

		//THIS IS TEMPORARY.
		if(!connection)	return	//~Carn

		Broadcast_Message(connection, M, voicemask, M.voice_message,
						  src, message, displayname, jobname, real_name, M.voice_name,
		                  filter_type, signal.data["compression"], position.z)



	else // OLD RADIO SYSTEMS: By Goons?

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
			receive |= R.send_hear(display_freq, 0)

		//world << "DEBUG: receive.len=[receive.len]"
		var/list/heard_masked = list() // masked name or no real name
		var/list/heard_normal = list() // normal message
		var/list/heard_voice = list() // voice message
		var/list/heard_garbled = list() // garbled message

		for (var/mob/R in receive)
			if (R.client && R.client.STFU_radio) //Adminning with 80 people on can be fun when you're trying to talk and all you can hear is radios.
				continue
			if (R.say_understands(M))
				if (ishuman(M) && M.GetVoice() != M.real_name)
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
			if(istype(blackbox))
				//BR.messages_admin += blackbox_admin_msg
				switch(display_freq)
					if(1459)
						blackbox.msg_common += blackbox_msg
					if(1351)
						blackbox.msg_science += blackbox_msg
					if(1353)
						blackbox.msg_command += blackbox_msg
					if(1355)
						blackbox.msg_medical += blackbox_msg
					if(1357)
						blackbox.msg_engineering += blackbox_msg
					if(1359)
						blackbox.msg_security += blackbox_msg
					if(1441)
						blackbox.msg_deathsquad += blackbox_msg
					if(1213)
						blackbox.msg_syndicate += blackbox_msg
					if(1349)
						blackbox.msg_mining += blackbox_msg
					if(1347)
						blackbox.msg_cargo += blackbox_msg
					else
						blackbox.messages += blackbox_msg

			//End of research and feedback code.

			if (length(heard_masked))
				var/N = M.name
				var/J = eqjobname
				if(ishuman(M) && M.GetVoice() != M.real_name)
					N = M.GetVoice()
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


/obj/item/device/radio/proc/receive_range(freq, level)
	// check if this radio can receive on the given frequency, and if so,
	// what the range is in which mobs will hear the radio
	// returns: -1 if can't receive, range otherwise

	if (!(wires & WIRE_RECEIVE))
		return -1
	if(!listening)
		return -1
	if(level != 0)
		var/turf/position = get_turf(src)
		if(isnull(position) || position.z != level)
			return -1
	if(freq == SYND_FREQ)
		if(!(src.syndie))//Checks to see if it's allowed on that frequency, based on the encryption keys
			return -1
	if (!on)
		return -1
	if (!freq) //recieved on main frequency
		if (!listening)
			return -1
	else
		var/accept = (freq==frequency && listening)
		if (!accept)
			for (var/ch_name in channels)
				var/datum/radio_frequency/RF = secure_radio_connections[ch_name]
				if (RF.frequency==freq && (channels[ch_name]&FREQ_LISTENING))
					accept = 1
					break
		if (!accept)
			return -1

	return canhear_range

/obj/item/device/radio/proc/send_hear(freq, level)

	var/range = receive_range(freq, level)
	if(range > -1)
		return get_mobs_in_view(canhear_range, src)


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
	if(!istype(src, /obj/item/device/radio/beacon))
		if (b_stat)
			user.show_message("\blue The radio can now be attached and modified!")
		else
			user.show_message("\blue The radio can no longer be modified or attached!")
		updateDialog()
			//Foreach goto(83)
		add_fingerprint(user)
		return
	else return

/obj/item/device/radio/emp_act(severity)
	broadcasting = 0
	listening = 0
	for (var/ch_name in channels)
		channels[ch_name] = 0
	..()

///////////////////////////////
//////////Borg Radios//////////
///////////////////////////////
//Giving borgs their own radio to have some more room to work with -Sieve

/obj/item/device/radio/borg
	var/obj/item/device/encryptionkey/keyslot = null//Borg radios can handle a single encryption key

/obj/item/device/radio/borg/attackby(obj/item/weapon/W as obj, mob/user as mob)
//	..()
	user.machine = src
	if (!( istype(W, /obj/item/weapon/screwdriver) || (istype(W, /obj/item/device/encryptionkey/ ))))
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(keyslot)


			for(var/ch_name in channels)
				radio_controller.remove_object(src, radiochannels[ch_name])
				secure_radio_connections[ch_name] = null


			if(keyslot)
				var/turf/T = get_turf(user)
				if(T)
					keyslot.loc = T
					keyslot = null

			recalculateChannels()
			user << "You pop out the encryption key in the radio!"

		else
			user << "This radio doesn't have any encryption keys!"

	if(istype(W, /obj/item/device/encryptionkey/))
		if(keyslot)
			user << "The radio can't hold another key!"
			return

		if(!keyslot)
			user.drop_item()
			W.loc = src
			keyslot = W

		recalculateChannels()

	return

/obj/item/device/radio/borg/proc/recalculateChannels()
	src.channels = list()
	src.syndie = 0

	if(keyslot)
		for(var/ch_name in keyslot.channels)
			if(ch_name in src.channels)
				continue
			src.channels += ch_name
			src.channels[ch_name] = keyslot.channels[ch_name]

		if(keyslot.syndie)
			src.syndie = 1


	for (var/ch_name in channels)
		if(!radio_controller)
			sleep(30) // Waiting for the radio_controller to be created.
		if(!radio_controller)
			src.name = "broken radio"
			return

		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)

	return

/obj/item/device/radio/borg/Topic(href, href_list)
	if(usr.stat || !on)
		return
	if (href_list["mode"])
		subspace_transmission = !subspace_transmission
		if(!subspace_transmission)//Simple as fuck, clears the channel list to prevent talking/listening over them if subspace transmission is disabled
			channels = list()
		else
			recalculateChannels()
		usr << "Subspace Transmission is [(subspace_transmission) ? "enabled" : "disabled"]"
	..()

/obj/item/device/radio/borg/interact(mob/user as mob)
	if(!on)
		return

	var/dat = "<html><head><title>[src]</title></head><body><TT>"
	dat += {"
				Speaker: [listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
				Frequency:
				<A href='byond://?src=\ref[src];freq=-10'>-</A>
				<A href='byond://?src=\ref[src];freq=-2'>-</A>
				[format_frequency(frequency)]
				<A href='byond://?src=\ref[src];freq=2'>+</A>
				<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
				<A href='byond://?src=\ref[src];mode=1'>Toggle Broadcast Mode</A><BR>
				"}

	if(subspace_transmission)//Don't even bother if subspace isn't turned on
		for (var/ch_name in channels)
			dat+=text_sec_channel(ch_name, channels[ch_name])
	dat+={"[text_wires()]</TT></body></html>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return


/obj/item/device/radio/proc/config(op)
	if(radio_controller)
		for (var/ch_name in channels)
			radio_controller.remove_object(src, radiochannels[ch_name])
	secure_radio_connections = new
	channels = op
	if(radio_controller)
		for (var/ch_name in op)
			secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)
	return