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
	desc = "A beacon used by a teleporter."
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "electronic"
	origin_tech = "bluespace=1"

/obj/item/device/radio/courtroom_beacon
	name = "Tracking Beacon"
	desc = "A more useless beacon in the courtroom."
	icon_state = "beacon"
	item_state = "signaler"
	var/code = "electronic"

/obj/item/device/radio/intercom
	name = "Station Intercom (Radio)"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = 1
	var/number = 0
	var/anyai = 1
	var/mob/living/silicon/ai/ai = list()

/obj/item/device/radio/headset
	name = "Radio Headset"
	desc = "An intercom that fits over the head."
	icon_state = "headset"
	item_state = "headset"
	var
		protective_temperature = 0
		translate_binary = 0
		translate_hive = 0

/obj/item/device/radio/headset/traitor
	translate_binary = 1
	channels = list("Syndicate" = 1)
	origin_tech = "syndicate=3"

/obj/item/device/radio/headset/headset_sec // -- TLE
	name = "Security Radio Headset"
	desc = "This is used by your elite security force."
	icon_state = "sec_headset"
	item_state = "headset"
	channels = list("Security" = 1)

/obj/item/device/radio/headset/headset_eng // -- TLE
	name = "Engineering Radio Headset"
	desc = "When the engineers wishes to chat like girls."
	icon_state = "eng_headset"
	item_state = "headset"
	channels = list("Engineering" = 1)

/obj/item/device/radio/headset/headset_rob // -- DH
	name = "Robotics Radio Headset"
	desc = "Made specifically for the roboticists who cannot decide between departments."
	icon_state = "rob_headset"
	item_state = "headset"
	channels = list("Engineering" = 1, "Science" = 1)

/obj/item/device/radio/headset/headset_med // -- TLE
	name = "Medical Radio Headset"
	desc = "A headset for the trained staff of the medbay."
	icon_state = "med_headset"
	item_state = "headset"
	channels = list("Medical" = 1)

/obj/item/device/radio/headset/headset_sci // -- Bar
	name = "Science Radio Headset"
	desc = "A sciency headset. Like usual."
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Science" = 1)

/obj/item/device/radio/headset/headset_medsci // -- Micro
	name = "Medical Research Radio Headset"
	desc = "A headset that is a result of the mating between medical and science."
	icon_state = "med_headset"
	item_state = "headset"
	channels = list("Medical" = 1, "Science" = 1)

/obj/item/device/radio/headset/headset_com // -- TLE
	name = "Command Radio Headset"
	desc = "A headset with a commanding channel"
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Command" = 1)

/obj/item/device/radio/headset/heads/captain // -- Bar
	name = "Captain's Headset"
	desc = "The headset of the boss."
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Command" = 1, "Science" = 0, "Medical" = 0, "Security" = 1, "Engineering" = 0, "Mining" = 0, "Cargo" = 0)

/obj/item/device/radio/headset/heads/rd // -- Bar
	name = "Research Director's Headset"
	desc = "Headset of the researching God."
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Science" = 1, "Command" = 1)

/obj/item/device/radio/headset/heads/hos // -- Bar
	name = "Head of Security's Headset"
	desc = "The headset of the man who protects your worthless lifes."
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Security" = 1, "Command" = 1)

/obj/item/device/radio/headset/heads/ce // -- Bar
	name = "Chief Engineer's Headset"
	desc = "The headset of the guy who is in charge of morons."
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Engineering" = 1, "Command" = 1)

/obj/item/device/radio/headset/heads/cmo // -- Bar
	name = "Chief Medical Officer's Headset"
	desc = "The headset of the highly trained medical chief."
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Medical" = 1, "Command" = 1)

/obj/item/device/radio/headset/heads/hop // -- rastaf0
	name = "Head of Personnel's Headset"
	desc = "The headset of the guy who will one day be captain."
	icon_state = "com_headset"
	item_state = "headset"
	channels = list("Command" = 1, "Security" = 0, "Cargo" = 1, "Mining" = 0)

/obj/item/device/radio/headset/headset_mine // -- rastaf0
	name = "Mining Radio Headset"
	desc = "Headset used by miners. How useless."
	icon_state = "mine_headset"
	item_state = "headset"
	channels = list("Mining" = 1)

/obj/item/device/radio/headset/headset_cargo // -- rastaf0
	name = "Cargo Radio Headset"
	desc = "Headset used by the QM's slaves."
	icon_state = "cargo_headset"
	item_state = "headset"
	channels = list("Cargo" = 1)

/obj/item/device/radio/headset/heads/qm // -- rastaf0
	name = "Quartermaster's Headset"
	desc = "The headset of the man who control your toiletpaper supply."
	icon_state = "cargo_headset"
	item_state = "headset"
	channels = list("Cargo" = 1, "Mining" = 1)
