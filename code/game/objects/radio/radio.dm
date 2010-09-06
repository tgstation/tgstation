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
	if(src.secure_frequency)
		secure_radio_connection = radio_controller.add_object(src, "[secure_frequency]")

/obj/item/device/radio
	var/datum/radio_frequency/radio_connection
	var/datum/radio_frequency/secure_radio_connection // Shared by Mport2004 for the security headsets -- TLE

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")

/obj/item/device/radio/attack_self(mob/user as mob)
	user.machine = src
	var/t1
	if (src.b_stat)
		t1 = {"
-------<BR>
Green Wire: <A href='byond://?src=\ref[src];wires=4'>[src.wires & 4 ? "Cut" : "Mend"] Wire</A><BR>
Red Wire:   <A href='byond://?src=\ref[src];wires=2'>[src.wires & 2 ? "Cut" : "Mend"] Wire</A><BR>
Blue Wire:  <A href='byond://?src=\ref[src];wires=1'>[src.wires & 1 ? "Cut" : "Mend"] Wire</A><BR>"}
	else
		t1 = "-------"
	var/dat = {"
<TT>
Microphone: [src.broadcasting ? "<A href='byond://?src=\ref[src];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];talk=1'>Disengaged</A>"]<BR>
Speaker: [src.listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
Frequency:
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A>
[format_frequency(src.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
[t1]
</TT>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/device/radio/Topic(href, href_list)
	//..()
	if (usr.stat)
		return
	if ((usr.contents.Find(src) || in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["track"])
			var/mob/target = locate(href_list["track"])
			var/mob/living/silicon/ai/A = locate(href_list["track2"])
			A.ai_actual_track(target)
			return
		if (href_list["freq"])
			var/new_frequency = sanitize_frequency(frequency + text2num(href_list["freq"]))
			set_frequency(new_frequency)

			if (src.traitor_frequency && src.frequency == src.traitor_frequency)
				usr.machine = null
				usr << browse(null, "window=radio")
				onclose(usr, "radio")
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
		else
			if (href_list["talk"])
				src.broadcasting = text2num(href_list["talk"])
			else
				if (href_list["listen"])
					src.listening = text2num(href_list["listen"])
				else
					if (href_list["wires"])
						var/t1 = text2num(href_list["wires"])
						if (!( istype(usr.equipped(), /obj/item/weapon/wirecutters) ))
							return
						if (t1 & 1)
							if (src.wires & 1)
								src.wires &= 65534
							else
								src.wires |= 1
						else
							if (t1 & 2)
								if (src.wires & 2)
									src.wires &= 65533
								else
									src.wires |= 2
							else
								if (t1 & 4)
									if (src.wires & 4)
										src.wires &= 65531
									else
										src.wires |= 4
		if (!( src.master ))
			if (istype(src.loc, /mob))
				attack_self(src.loc)
			else
				src.updateDialog()
		else
			if (istype(src.master.loc, /mob))
				src.attack_self(src.master.loc)
			else
				src.updateDialog()
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=radio")

/obj/item/device/radio/talk_into(mob/M as mob, message, secure)

	var/datum/radio_frequency/connection = null // Code shared by Mport2004 for Security Headsets -- TLE
	var/datum/display_freq = src.frequency
	if(secure && src.secure_radio_connection)
		connection = src.secure_radio_connection
		display_freq = src.secure_frequency
	else
		connection = src.radio_connection
		secure = 0


	var/eqjobname

	if (istype(M, /mob/living/carbon))
		if (M:wear_id)
			eqjobname = M:wear_id:assignment
		else
			eqjobname = "No id"
	else if (istype(M,/mob/living/silicon/ai))
		eqjobname = "AI"
	else if (istype(M,/mob/living/silicon/robot))
		eqjobname = "Android"
	else
		eqjobname = "Unknown"

	if (!(src.wires & 4))
		return

	var/list/receive = list()

	//for (var/obj/item/device/radio/R in radio_connection.devices)
	for (var/obj/item/device/radio/R in connection.devices) // Modified for security headset code -- TLE
		if(R.accept_rad(src, message))
			for (var/i in R.send_hear())
				if (!(i in receive))
					receive += i

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
		var/part_a = "<span class='game radio'><span class='name'>"
		//var/part_b = "</span><b> \icon[src]\[[format_frequency(src.frequency)]\]</b> <span class='message'>"
		var/part_b = "</span><b> \icon[src]\[[format_frequency(display_freq)]\]</b> <span class='message'>" // Tweaked for security headsets -- TLE
		var/part_c = "</span></span>"

		if(findtext(part_b, "135.3") || findtext(part_b, "135.5") || findtext(part_b, "135.7") || findtext(part_b, "135.9"))
			part_a = "<span class='deptradio'><span class='name'>"



		if (length(heard_masked))
			var/rendered = "[part_a][M.name][part_b][M.say_quote(message)][part_c]"

			for (var/mob/R in heard_masked)
				if(istype(R, /mob/living/silicon/ai))
					R.show_message("[part_a]<a href='byond://?src=\ref[src];track2=\ref[R];track=\ref[M]'>[M.name] ([eqjobname]) </a>[part_b][M.say_quote(message)][part_c]", 2)
				else
					R.show_message(rendered, 2)

		if (length(heard_normal))
			var/rendered = "[part_a][M.real_name][part_b][M.say_quote(message)][part_c]"

			for (var/mob/R in heard_normal)
				if(istype(R, /mob/living/silicon/ai))
					R.show_message("[part_a]<a href='byond://?src=\ref[src];track2=\ref[R];track=\ref[M]'>[M.real_name] ([eqjobname]) </a>[part_b][M.say_quote(message)][part_c]", 2)
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
			var/rendered = "[part_a][M.voice_name][part_b][M.say_quote(stars(message))][part_c]"

			for (var/mob/R in heard_voice)
				if(istype(R, /mob/living/silicon/ai))
					R.show_message("[part_a]<a href='byond://?src=\ref[src];track2=\ref[R];track=\ref[M]'>[M.voice_name]</a>[part_b][M.say_quote(stars(message))][part_c]", 2)
				else
					R.show_message(rendered, 2)

/obj/item/device/radio/hear_talk(mob/M as mob, msg)
	if (src.broadcasting)
		talk_into(M, msg)

/obj/item/device/radio/proc/accept_rad(obj/item/device/radio/R as obj, message)

	if ((R.frequency == src.frequency && message))
		return 1
	else
		return null
	return

/obj/item/device/radio/proc/send_hear()
	if(last_transmission && world.time < (last_transmission + TRANSMISSION_DELAY))
		return
	last_transmission = world.time
	if ((src.listening && src.wires & 2))
		var/list/hear = hearers(1, src.loc)

		// modified so that a mob holding the radio is always a hearer of it
		// this fixes radio problems when inside something (e.g. mulebot)

		if(ismob(loc))
			if(! hear.Find(loc) )
				hear += loc
		return hear
	return

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
	user.machine = src
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.b_stat = !( src.b_stat )
	if (src.b_stat)
		user.show_message("\blue The radio can now be attached and modified!")
	else
		user.show_message("\blue The radio can no longer be modified or attached!")
	for(var/mob/M in viewers(1, src))
		if (M.client)
			src.attack_self(M)
		//Foreach goto(83)
	src.add_fingerprint(user)
	return
