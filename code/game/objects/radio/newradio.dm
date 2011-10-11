/obj/item/device/Nradio
	icon = 'radio.dmi'
	name = "station bounced radio"
	suffix = "\[3\]"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"

	flags = 450//FFFF what does this even mean likely conduct+onbelt+someothershit
	throw_speed = 2
	throw_range = 9
	w_class = 2
	g_amt = 25
	m_amt = 75

	var
		//General things
		frequency = 1459	//Default freq
		broadcasting = 0	//Mike
		listening = 1		//Speaker
		secured = 0			//Can you see our wires
		freerange = 0		// 0 - Sanitize frequencies, 1 - Full range

		datum/radio_frequency/radio_connection = null
		list/datum/radio_frequency/secure_radio_connections = new

		//Internal things
		obj/item/weapon/syndicate_uplink/uplink = null 	//If we have an uplink one of our freqs will activate it
		wires = WIRE_RECEIVE | WIRE_TRANSMIT			//Active wires

		list/channels = list() //see communications.dm for full list. First channes is a "default" for :h
//			"Example" = FREQ_LISTENING|FREQ_BROADCASTING

		last_transmission						//What is this
		obj/item/device/radio/patch_link = null	//What is this

	var/const
		WIRE_TRANSMIT = 1 //sends a signal, like to set off a bomb or electrocute someone, or talk
		WIRE_RECEIVE = 2 //we can hear things
		TRANSMISSION_DELAY = 5 // only 2/second/radio  antispam protection
		FREQ_LISTENING = 1


	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, frequency)
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)

