///////////////////////////////
//////////Borg Radios//////////
///////////////////////////////
//Giving borgs their own radio to have some more room to work with -Sieve

/obj/item/device/radio/borg
	var/obj/item/device/encryptionkey/keyslot = null//Borg radios can handle a single encryption key
	subspace_transmission = 1

/obj/item/device/radio/borg/proc/insert_key(obj/item/device/encryptionkey/key)
	keyslot = key
	recalculateChannels()

/obj/item/device/radio/borg/attackby(obj/item/weapon/W as obj, mob/user as mob)
//	..()
	user.set_machine(src)
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

	if (istype(W, /obj/item/device/encryptionkey))
		if (!isnull(keyslot))
			user << "<SPAN CLASS='notice'>The radio can't hold another key!</SPAN>"
		else
			user.drop_item(src)
			insert_key(W)

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

		secure_radio_connections[ch_name] = add_radio(src, radiochannels[ch_name])

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

/obj/item/device/radio/off
	listening = 0
