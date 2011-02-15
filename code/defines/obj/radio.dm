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
	var/const
		WIRE_SIGNAL = 1 //sends a signal, like to set off a bomb or electrocute someone
		WIRE_RECEIVE = 2
		WIRE_TRANSMIT = 4
		TRANSMISSION_DELAY = 5 // only 2/second/radio
		FREQ_LISTENING = 1
		//FREQ_BROADCASTING = 2

/obj/item/device/radio/beacon
	name = "Tracking Beacon"
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "electronic"

/obj/item/device/radio/courtroom_beacon
	name = "Tracking Beacon"
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "electronic"

/obj/item/device/radio/electropack
	name = "Electropack"
	icon_state = "electropack0"
	var/code = 2
	var/on = 0
	var/e_pads = 0.0
	frequency = 1449
	w_class = 5.0
	flags = 323
	item_state = "electropack"

/obj/item/device/radio/signaler
	name = "Remote Signaling Device"
	icon_state = "signaller"
	item_state = "signaler"
	var/code = 30
	w_class = 1
	frequency = 1457
	var/delay = 0
	var/airlock_wire = null

/obj/item/device/radio/intercom
	name = "Station Intercom (Radio)"
	icon_state = "intercom"
	anchored = 1
	var/number = 0
	var/anyai = 1
	var/mob/living/silicon/ai/ai = list()

/obj/item/device/radio/headset
	name = "Radio Headset"
	icon_state = "headset"
	item_state = "headset"
	var
		protective_temperature = 0
		translate_binary = 0
		translate_hive = 0

/obj/item/device/radio/headset/traitor
	translate_binary = 1
	channels = list("Syndicate" = 1)

/obj/item/device/radio/headset/headset_sec // -- TLE
	name = "Security Radio Headset"
	icon_state = "sec_headset"
	item_state = "headset"
	channels = list("Security" = 1)

/obj/item/device/radio/headset/headset_eng // -- TLE
	name = "Engineering Radio Headset"
	icon_state = "eng_headset"
	item_state = "headset"
	channels = list("Engineering" = 1)

/obj/item/device/radio/headset/headset_med // -- TLE
	name = "Medical Radio Headset"
	icon_state = "med_headset"
	item_state = "headset"
	channels = list("Medical" = 1)

/obj/item/device/radio/headset/headset_com // -- TLE
	name = "Command Radio Headset"
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Command" = 1)

/obj/item/device/radio/headset/headset_sci // -- Bar
	name = "Science Radio Headset"
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Science" = 1)

/obj/item/device/radio/headset/heads/captain // -- Bar
	name = "Captain's Headset"
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Command" = 1, "Science" = 0, "Medical" = 0, "Security" = 1, "Engineering" = 0, "Mining" = 0, "Cargo" = 0)

/obj/item/device/radio/headset/heads/rd // -- Bar
	name = "Research Director's Headset"
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Science" = 1, "Command" = 1, "Medical" = 1)

/obj/item/device/radio/headset/heads/hos // -- Bar
	name = "Head of Security's Headset"
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Security" = 1, "Command" = 1)

/obj/item/device/radio/headset/heads/ce // -- Bar
	name = "Chief Engineer's Headset"
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Engineering" = 1, "Command" = 1, "Mining" = 1)

/obj/item/device/radio/headset/heads/cmo // -- Bar
	name = "Chief Medical Officer's Headset"
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Medical" = 1, "Command" = 1)
	
/obj/item/device/radio/headset/heads/hop // -- rastaf0
	name = "Head of Personnel's Headset"
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Command" = 1, "Security" = 1, "Cargo" = 0)

/obj/item/device/radio/headset/headset_mine // -- rastaf0
	name = "Mining Radio Headset"
	icon_state = "mine_headset"
	item_state = "headset"
	channels = list("Mining" = 1)

/obj/item/device/radio/headset/headset_cargo // -- rastaf0
	name = "Cargo Radio Headset"
	icon_state = "cargo_headset"
	item_state = "headset"
	channels = list("Cargo" = 1)

/obj/item/device/radio/headset/heads/qm // -- rastaf0 //he is not a real head but he gives orders sometimes
	name = "Quartermaster's Headset"
	icon_state = "cargo_headset"
	item_state = "headset"
	channels = list("Cargo" = 1, "Mining" = 1) //no command frequency yet
