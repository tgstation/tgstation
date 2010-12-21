/obj/item/device/radio
	name = "station bounced radio"
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"
	var/last_transmission
	var/frequency = 1459
	var/secure_frequency
	var/traitor_frequency = 0.0
	var/obj/item/device/radio/patch_link = null
	var/obj/item/weapon/syndicate_uplink/traitorradio = null
	var/wires = WIRE_SIGNAL | WIRE_RECEIVE | WIRE_TRANSMIT
	var/b_stat = 0.0
	var/broadcasting = null
	var/listening = 1.0
	var/freerange = 0 // 0 - Sanitize frequencies, 1 - Full range
	flags = 450.0
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	var/const
		WIRE_SIGNAL = 1 //sends a signal, like to set off a bomb or electrocute someone
		WIRE_RECEIVE = 2
		WIRE_TRANSMIT = 4
		TRANSMISSION_DELAY = 5 // only 2/second/radio

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
	var/code = 2.0
	var/on = 0.0
	var/e_pads = 0.0
	frequency = 1449
	w_class = 5.0
	flags = 323.0
	item_state = "electropack"

/obj/item/device/radio/headset
	name = "Radio Headset"
	icon_state = "headset"
	item_state = "headset"
	var/protective_temperature = 0

/obj/item/device/radio/headset/traitor
// No variables, as everything else it does is handled in human's life.dm

/obj/item/device/radio/headset/headset_sec // -- TLE
	name = "Security Radio Headset"
	icon_state = "sec_headset"
	item_state = "headset"
	secure_frequency = 1359

/obj/item/device/radio/headset/headset_eng // -- TLE
	name = "Engineering Radio Headset"
	icon_state = "eng_headset"
	item_state = "headset"
	secure_frequency = 1357

/obj/item/device/radio/headset/headset_med // -- TLE
	name = "Medical Radio Headset"
	icon_state = "med_headset"
	item_state = "headset"
	secure_frequency = 1355

/obj/item/device/radio/headset/headset_com // -- TLE
	name = "Command Radio Headset"
	icon_state = "com_headset"
	item_state = "headset"
	secure_frequency = 1353

/obj/item/device/radio/intercom
	name = "Station Intercom (Radio)"
	icon_state = "intercom"
	anchored = 1.0
	var/number = 0
	var/anyai = 1
	var/mob/living/silicon/ai/ai = list()

/obj/item/device/radio/signaler
	name = "Remote Signaling Device"
	icon_state = "signaller"
	item_state = "signaler"
	var/code = 30.0
	w_class = 1.0
	frequency = 1457
	var/delay = 0
	var/airlock_wire = null
