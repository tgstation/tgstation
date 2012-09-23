// ### Preset machines  ###

//Relay

/obj/machinery/telecomms/relay/preset
	network = "tcommsat"

/obj/machinery/telecomms/relay/preset/station
	id = "Station Relay"
	autolinkers = list("s_relay", "s_receiverA", "s_broadcasterA", "s_receiverB", "s_broadcasterB")

/obj/machinery/telecomms/relay/preset/telecomms
	id = "Telecomms Relay"
	autolinkers = list("relay", "receiverA", "receiverB", "broadcasterA", "broadcasterB")

/obj/machinery/telecomms/relay/preset/mining
	id = "Mining Relay"
	autolinkers = list("m_relay", "m_receiverB", "m_broadcasterB")

/obj/machinery/telecomms/relay/preset/ruskie
	id = "Ruskie Relay"
	hide = 1
	toggled = 0
	autolinkers = list("r_relay", "r_receiverB", "r_broadcasterB")

//HUB

/obj/machinery/telecomms/hub/preset
	id = "Hub"
	network = "tcommsat"
	autolinkers = list("hub", "relay", "s_relay", "m_relay", "r_relay", "science", "medical",
	"cargo", "mining", "common", "command", "engineering", "security")

//Receivers

//--PRESET LEFT--//

/obj/machinery/telecomms/receiver/preset_left
	id = "Receiver A"
	network = "tcommsat"
	autolinkers = list("receiverA") // link to relay
	freq_listening = list(1351, 1355, 1347, 1349) // science, medical, cargo, mining

/obj/machinery/telecomms/receiver/preset_left/station
	id = "Station Receiver A"
	autolinkers = list("s_receiverA") // link to relay
	listening_level = 1

//--PRESET RIGHT--//

/obj/machinery/telecomms/receiver/preset_right
	id = "Receiver B"
	network = "tcommsat"
	autolinkers = list("receiverB") // link to relay
	freq_listening = list(1353, 1357, 1359) //command, engineering, security

	//Common and other radio frequencies for people to freely use
	New()
		for(var/i = 1441, i < 1489, i += 2)
			freq_listening |= i
		..()

/obj/machinery/telecomms/receiver/preset_right/station
	id = "Station Receiver B"
	autolinkers = list("s_receiverB")
	listening_level = 1 // Listen to the station remotely

/obj/machinery/telecomms/receiver/preset_right/mining
	id = "Mining Receiver B"
	autolinkers = list("m_receiverB")
	freq_listening = list(1351, 1355, 1347, 1349, 1353, 1357, 1359)

/obj/machinery/telecomms/receiver/preset_right/ruskie
	id = "Ruskie Receiver B"
	autolinkers = list("r_receiverB")
	freq_listening = list(1351, 1355, 1347, 1349, 1353, 1357, 1359) // science, medical, cargo, mining, command, engineering, security
	toggled = 0
	hide = 1


//Buses

/obj/machinery/telecomms/bus/preset_one
	id = "Bus 1"
	network = "tcommsat"
	autolinkers = list("processor1", "science", "medical")

/obj/machinery/telecomms/bus/preset_two
	id = "Bus 2"
	network = "tcommsat"
	autolinkers = list("processor2", "cargo", "mining")

/obj/machinery/telecomms/bus/preset_three
	id = "Bus 3"
	network = "tcommsat"
	autolinkers = list("processor3", "security", "command")

/obj/machinery/telecomms/bus/preset_four
	id = "Bus 4"
	network = "tcommsat"
	autolinkers = list("processor4", "engineering", "common")


//Processors

/obj/machinery/telecomms/processor/preset_one
	id = "Processor 1"
	network = "tcommsat"
	autolinkers = list("processor1") // processors are sort of isolated; they don't need backward links

/obj/machinery/telecomms/processor/preset_two
	id = "Processor 2"
	network = "tcommsat"
	autolinkers = list("processor2")

/obj/machinery/telecomms/processor/preset_three
	id = "Processor 3"
	network = "tcommsat"
	autolinkers = list("processor3")

/obj/machinery/telecomms/processor/preset_four
	id = "Processor 4"
	network = "tcommsat"
	autolinkers = list("processor4")

//Servers

/obj/machinery/telecomms/server/presets

	network = "tcommsat"

/obj/machinery/telecomms/server/presets/science
	id = "Science Server"
	freq_listening = list(1351)
	autolinkers = list("science")

/obj/machinery/telecomms/server/presets/medical
	id = "Medical Server"
	freq_listening = list(1355)
	autolinkers = list("medical")

/obj/machinery/telecomms/server/presets/cargo
	id = "Cargo Server"
	freq_listening = list(1347)
	autolinkers = list("cargo")

/obj/machinery/telecomms/server/presets/mining
	id = "Mining Server"
	freq_listening = list(1349)
	autolinkers = list("mining")

/obj/machinery/telecomms/server/presets/common
	id = "Common Server"
	freq_listening = list()
	autolinkers = list("common")

	//Common and other radio frequencies for people to freely use
	// 1441 to 1489
/obj/machinery/telecomms/server/presets/common/New()
	for(var/i = 1441, i < 1489, i += 2)
		freq_listening |= i
	..()

/obj/machinery/telecomms/server/presets/command
	id = "Command Server"
	freq_listening = list(1353)
	autolinkers = list("command")

/obj/machinery/telecomms/server/presets/engineering
	id = "Engineering Server"
	freq_listening = list(1357)
	autolinkers = list("engineering")

/obj/machinery/telecomms/server/presets/security
	id = "Security Server"
	freq_listening = list(1359)
	autolinkers = list("security")


//Broadcasters

//--PRESET LEFT--//

/obj/machinery/telecomms/broadcaster/preset_left
	id = "Broadcaster A"
	network = "tcommsat"
	autolinkers = list("broadcasterA")

/obj/machinery/telecomms/broadcaster/preset_left/station
	id = "Station Broadcaster A"
	autolinkers = list("s_broadcasterA")
	listening_level = 1 // Station

//--PRESET RIGHT--//

/obj/machinery/telecomms/broadcaster/preset_right
	id = "Broadcaster B"
	network = "tcommsat"
	autolinkers = list("broadcasterB")


/obj/machinery/telecomms/broadcaster/preset_right/station
	id = "Station Broadcaster B"
	autolinkers = list("s_broadcasterB")
	listening_level = 1 // Station

/obj/machinery/telecomms/broadcaster/preset_right/mining
	id = "Mining Broadcaster B"
	autolinkers = list("m_broadcasterB")

/obj/machinery/telecomms/broadcaster/preset_right/ruskie
	id = "Ruskie Broadcaster B"
	autolinkers = list("r_broadcasterB")
	toggled = 0
	hide = 1
