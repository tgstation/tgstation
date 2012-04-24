/obj/item/device/radio/headset
	name = "radio headset"
	desc = "An updated, modular intercom that fits over the head. Takes encryption keys"
	icon_state = "headset"
	item_state = "headset"
	g_amt = 0
	m_amt = 75
	subspace_transmission = 1
	protective_temperature = 0
	canhear_range = 1 // can't hear headsets from very far away
	var
		translate_binary = 0
		translate_hive = 0
		obj/item/device/encryptionkey/keyslot1 = null
		obj/item/device/encryptionkey/keyslot2 = null

/obj/item/device/radio/headset/New()
	..()
	keyslot1 = new /obj/item/device/encryptionkey/
	recalculateChannels()

/obj/item/device/radio/headset/traitor
	origin_tech = "syndicate=3"
	canhear_range = 0
/obj/item/device/radio/headset/traitor/New()
	..()
	del(keyslot1)
	keyslot1 = new /obj/item/device/encryptionkey/traitor
	recalculateChannels()

/obj/item/device/radio/headset/binary
	origin_tech = "syndicate=3"
	canhear_range = 0
/obj/item/device/radio/headset/binary/New()
	..()
	del(keyslot1)
	keyslot1 = new /obj/item/device/encryptionkey/binary
	recalculateChannels()

/obj/item/device/radio/headset/headset_sec
	name = "security radio headset"
	desc = "This is used by your elite security force. To access the security channel, use :s."
	icon_state = "sec_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/headset_sec

/obj/item/device/radio/headset/headset_eng
	name = "engineering radio headset"
	desc = "When the engineers wish to chat like girls. To access the engineering channel, use :e. "
	icon_state = "eng_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/headset_eng

/obj/item/device/radio/headset/headset_rob
	name = "robotics radio headset"
	desc = "Made specifically for the roboticists who cannot decide between departments. To access the engineering channel, use :e. For research, use :n."
	icon_state = "rob_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/headset_rob

/obj/item/device/radio/headset/headset_med
	name = "medical radio headset"
	desc = "A headset for the trained staff of the medbay. To access the medical channel, use :m."
	icon_state = "med_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/headset_med

/obj/item/device/radio/headset/headset_sci
	name = "science radio headset"
	desc = "A sciency headset. Like usual. To access the science channel, use :n."
	icon_state = "com_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/headset_sci

/obj/item/device/radio/headset/headset_medsci
	name = "medical research radio headset"
	desc = "A headset that is a result of the mating between medical and science. To access the medical channel, use :m. For science, use :n."
	icon_state = "med_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/headset_medsci

/obj/item/device/radio/headset/headset_com
	name = "command radio headset"
	desc = "A headset with a commanding channel. To access the command channel, use :c."
	icon_state = "com_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/headset_com

/obj/item/device/radio/headset/heads/captain
	name = "captain's headset"
	desc = "The headset of the boss. Channels are as follows: :c - command, :s - security, :e - engineering, :d - mining, :q - cargo, :m - medical, :n - science."
	icon_state = "com_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/heads/captain

/obj/item/device/radio/headset/heads/rd
	name = "Research Director's headset"
	desc = "Headset of the researching God. To access the science channel, use :n. For command, use :c."
	icon_state = "com_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/heads/rd

/obj/item/device/radio/headset/heads/hos
	name = "head of security's headset"
	desc = "The headset of the man who protects your worthless lifes. To access the security channel, use :s. For command, use :c."
	icon_state = "com_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/heads/hos

/obj/item/device/radio/headset/heads/ce
	name = "chief engineer's headset"
	desc = "The headset of the guy who is in charge of morons. To access the engineering channel, use :e. For command, use :c."
	icon_state = "com_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/heads/ce

/obj/item/device/radio/headset/heads/cmo
	name = "chief medical officer's headset"
	desc = "The headset of the highly trained medical chief. To access the medical channel, use :m. For command, use :c."
	icon_state = "com_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/heads/cmo

/obj/item/device/radio/headset/heads/hop
	name = "head of personnel's headset"
	desc = "The headset of the guy who will one day be captain. Channels are as follows: :c - command, :s - security, :q - cargo, :d - mining."
	icon_state = "com_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/heads/hop

/obj/item/device/radio/headset/headset_mine
	name = "mining radio headset"
	desc = "Headset used by miners. How useless. To access the mining channel, use :d."
	icon_state = "mine_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/headset_mine

/obj/item/device/radio/headset/heads/qm
	name = "quartermaster's headset"
	desc = "The headset of the man who control your toiletpaper supply. To access the cargo channel, use :q. For mining, use :d."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/heads/qm

/obj/item/device/radio/headset/headset_cargo
	name = "cargo radio headset"
	desc = "Headset used by the QM's slaves. To access the cargo channel, use :q."
	icon_state = "cargo_headset"
	item_state = "headset"
	keyslot2 = new /obj/item/device/encryptionkey/headset_cargo

/obj/item/device/radio/headset/nuclear
	freerange = 1
	listening = 0
	keyslot2 = new /obj/item/device/encryptionkey/nuclear

/obj/item/device/radio/headset/ert
	name = "CentCom Response Team headset"
	desc = "The headset of the boss's boss. Channels are as follows: :h - Response Team :c - command, :s - security, :e - engineering, :d - mining, :q - cargo, :m - medical, :n - science."
	icon_state = "com_headset"
	item_state = "headset"
	freerange = 1
	keyslot2 = new /obj/item/device/encryptionkey/ert

/obj/item/device/radio/headset/attackby(obj/item/weapon/W as obj, mob/user as mob)
//	..()
	user.machine = src
	if (!( istype(W, /obj/item/weapon/screwdriver) || (istype(W, /obj/item/device/encryptionkey/ ))))
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(keyslot1 || keyslot2)


			for(var/ch_name in channels)
				radio_controller.remove_object(src, radiochannels[ch_name])
				secure_radio_connections[ch_name] = null


			if(keyslot1)
				user.put_in_hands(keyslot1)
				keyslot1 = null

			if(keyslot2)
				user.put_in_hands(keyslot2)
				keyslot2 = null

			recalculateChannels()
			user << "You pop out the encryption keys in the headset!"

		else
			user << "This headset doesn't have any encryption keys!  How useless..."

	if(istype(W, /obj/item/device/encryptionkey/))
		if(keyslot1 && keyslot2)
			user << "The headset can't hold another key!"
			return

		if(!keyslot1)
			user.drop_item()
			W.loc = src
			keyslot1 = W

		else
			user.drop_item()
			W.loc = src
			keyslot2 = W


		recalculateChannels()

	return


/obj/item/device/radio/headset/proc/recalculateChannels()
	src.channels = list()
	src.translate_binary = 0
	src.translate_hive = 0

	if(keyslot1)
		for(var/ch_name in keyslot1.channels)
			if(ch_name in src.channels)
				continue
			src.channels += ch_name
			src.channels[ch_name] = keyslot1.channels[ch_name]

		if(keyslot1.translate_binary)
			src.translate_binary = 1

		if(keyslot1.translate_hive)
			src.translate_hive = 1

	if(keyslot2)
		for(var/ch_name in keyslot2.channels)
			if(ch_name in src.channels)
				continue
			src.channels += ch_name
			src.channels[ch_name] = keyslot2.channels[ch_name]

		if(keyslot2.translate_binary)
			src.translate_binary = 1

		if(keyslot2.translate_hive)
			src.translate_hive = 1


	for (var/ch_name in channels)
		if(!radio_controller)
			sleep(30) // Waiting for the radio_controller to be created.
		if(!radio_controller)
			src.name = "broken radio headset"
			return

		secure_radio_connections[ch_name] = radio_controller.add_object(src, radiochannels[ch_name],  RADIO_CHAT)

	return