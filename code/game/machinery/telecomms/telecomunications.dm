//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/*
	Hello, friends, this is Doohl from sexylands. You may be wondering what this
	monstrous code file is. Sit down, boys and girls, while I tell you the tale.


	The machines defined in this file were designed to be compatible with any radio
	signals, provided they use subspace transmission. Currently they are only used for
	headsets, but they can eventually be outfitted for real COMPUTER networks. This
	is just a skeleton, ladies and gentlemen.

	Look at radio.dm for the prequel to this code.
*/

var/global/list/obj/machinery/telecomms/telecomms_list = list()

/obj/machinery/telecomms
	var/list/links = list() // list of machines this machine is linked to
	var/traffic = 0 // value increases as traffic increases
	var/netspeed = 5 // how much traffic to lose per tick (50 gigabytes/second * netspeed)
	var/list/autolinkers = list() // list of text/number values to link with
	var/id = "NULL" // identification string
	var/network = "NULL" // the network of the machinery

	var/list/freq_listening = list() // list of frequencies to tune into: if none, will listen to all

	var/machinetype = 0 // just a hacky way of preventing alike machines from pairing
	var/toggled = 1 	// Is it toggled on
	var/on = 1
	var/integrity = 100 // basically HP, loses integrity by heat
	var/heatgen = 20 // how much heat to transfer to the environment
	var/delay = 10 // how many process() ticks to delay per heat
	var/heating_power = 40000
	var/long_range_link = 0
	var/circuitboard = null // string pointing to a circuitboard type
	var/hide = 0				// Is it a hidden machine?


/obj/machinery/telecomms/proc/relay_information(datum/signal/signal, filter, copysig, amount)
	// relay signal to all linked machinery that are of type [filter]. If signal has been sent [amount] times, stop sending

	if(!on)
		return

	var/send_count = 0

	signal.data["slow"] += rand(0, round((100-integrity))) // apply some lag based on integrity

	// Apply some lag based on traffic rates
	var/netlag = round(traffic / 50)
	if(netlag > signal.data["slow"])
		signal.data["slow"] = netlag

// Loop through all linked machines and send the signal or copy.
	for(var/obj/machinery/telecomms/machine in links)
		if(filter && !istype( machine, text2path(filter) ))
			continue
		if(!machine.on)
			continue
		if(amount && send_count >= amount)
			break
		if(machine.loc.z != src.loc.z)
			if(long_range_link == 0 && machine.long_range_link == 0)
				continue
		//Is this a test signal?
		if(signal.data["type"] == 4)
			send_count++
			if(machine.is_freq_listening(signal))
				machine.traffic++
			machine.receive_information(signal, src)
			continue
		// If we're sending a copy, be sure to create the copy for EACH machine and paste the data
		var/datum/signal/copy = new
		if(copysig)

			copy.transmission_method = 2
			copy.frequency = signal.frequency
			// Copy the main data contents! Workaround for some nasty bug where the actual array memory is copied and not its contents.
			copy.data = list(

			"mob" = signal.data["mob"],
			"mobtype" = signal.data["mobtype"],
			"realname" = signal.data["realname"],
			"name" = signal.data["name"],
			"job" = signal.data["job"],
			"key" = signal.data["key"],
			"vmessage" = signal.data["vmessage"],
			"vname" = signal.data["vname"],
			"vmask" = signal.data["vmask"],
			"compression" = signal.data["compression"],
			"message" = signal.data["message"],
			"connection" = signal.data["connection"],
			"radio" = signal.data["radio"],
			"slow" = signal.data["slow"],
			"traffic" = signal.data["traffic"],
			"type" = signal.data["type"],
			"server" = signal.data["server"],
			"reject" = signal.data["reject"]
			)

			// Keep the "original" signal constant
			if(!signal.data["original"])
				copy.data["original"] = signal
			else
				copy.data["original"] = signal.data["original"]

		else
			del(copy)


		send_count++
		if(machine.is_freq_listening(signal))
			machine.traffic++

		if(copysig && copy)
			machine.receive_information(copy, src)
		else
			machine.receive_information(signal, src)


	if(send_count > 0 && is_freq_listening(signal))
		traffic++

	return send_count

/obj/machinery/telecomms/proc/relay_direct_information(datum/signal/signal, obj/machinery/telecomms/machine)
	// send signal directly to a machine
	machine.receive_information(signal, src)

/obj/machinery/telecomms/proc/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	// receive information from linked machinery
	..()

/obj/machinery/telecomms/proc/is_freq_listening(datum/signal/signal)
	// return 1 if found, 0 if not found
	if((signal.frequency in freq_listening) || (!freq_listening.len))
		return 1
	else
		return 0

/obj/machinery/telecomms/New()
	telecomms_list += src
	..()
	if(autolinkers.len)
		spawn(15)
			// Links nearby machines
			if(!long_range_link)
				for(var/obj/machinery/telecomms/T in orange(15, src))
					add_link(T)
			else
				for(var/obj/machinery/telecomms/T in telecomms_list)
					add_link(T)

	if(istype(src, /obj/machinery/telecomms/server))
		var/obj/machinery/telecomms/server/S = src
		S.Compiler = new()
		S.Compiler.Holder = src

/obj/machinery/telecomms/Del()
	telecomms_list -= src
	..()

/obj/machinery/telecomms/proc/add_link(var/obj/machinery/telecomms/T)
	if((src.loc.z && T.loc.z) || (src.long_range_link && T.long_range_link))
		for(var/x in autolinkers)
			if(T.autolinkers.Find(x))
				if(!(T in links) && machinetype != T.machinetype)
					links.Add(T)

/obj/machinery/telecomms/update_icon()
	if(on)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_off"


/obj/machinery/telecomms/process()
	if(toggled)
		if(stat & (BROKEN|NOPOWER) || integrity <= 0) // if powered, on. if not powered, off. if too damaged, off
			on = 0
		else
			on = 1
	else
		on = 0

	// Check heat and generate some
	checkheat()

	// Update the icon
	update_icon()

	if(traffic > 0)
		traffic -= netspeed

/obj/machinery/telecomms/proc/checkheat()
	// Checks heat from the environment and applies any integrity damage
	var/datum/gas_mixture/environment = loc.return_air()
	switch(environment.temperature)
		if(T0C to (T20C + 20))
			integrity = between(0, integrity, 100)
		if((T20C + 20) to (T0C + 70))
			integrity = max(0, integrity - 1)
	if(delay)
		delay--
	else
		// If the machine is on, ready to produce heat, and has positive traffic, genn some heat
		if(on && traffic > 0)
			produce_heat(heatgen)
			delay = initial(delay)

/obj/machinery/telecomms/proc/produce_heat(heat_amt)
	if(heatgen == 0)
		return

	if(!(stat & (NOPOWER|BROKEN))) //Blatently stolen from space heater.
		var/turf/simulated/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature < (heat_amt+T0C))

				var/transfer_moles = 0.25 * env.total_moles()

				var/datum/gas_mixture/removed = env.remove(transfer_moles)

				if(removed)

					var/heat_capacity = removed.heat_capacity()
					if(heat_capacity == 0 || heat_capacity == null)
						heat_capacity = 1
					removed.temperature = min((removed.temperature*heat_capacity + heating_power)/heat_capacity, 1000)

				env.merge(removed)
/*
	The receiver idles and receives messages from subspace-compatible radio equipment;
	primarily headsets. They then just relay this information to all linked devices,
	which can would probably be network buses.

	Link to Processor Units in case receiver can't send to bus units.
*/

/obj/machinery/telecomms/receiver
	name = "Subspace Receiver"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "broadcast receiver"
	desc = "This machine has a dish-like shape and green lights. It is designed to detect and process subspace radio activity."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 30
	machinetype = 1
	heatgen = 0
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/receiver"

/obj/machinery/telecomms/receiver/receive_signal(datum/signal/signal)

	if(!on) // has to be on to receive messages
		return

	if(signal.transmission_method == 2)

		if(is_freq_listening(signal)) // detect subspace signals
			var/can_send = relay_information(signal, "/obj/machinery/telecomms/relay") // ideally relay the copied information to relays
			if(!can_send)
				relay_information(signal, "/obj/machinery/telecomms/bus") // Send it to a bus instead, if it's linked to one

/*
	The HUB idles until it receives information. It then passes on that information
	depending on where it came from.

	This is the heart of the Telecommunications Network, sending information where it
	is needed. It mainly receives information from long-distance Relays and then sends
	that information to be processed. Afterwards it gets the uncompressed information
	from Servers/Buses and sends that back to the relay, to then be broadcasted.
*/

/obj/machinery/telecomms/hub
	name = "Telecommunication Hub"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "hub"
	desc = "A mighty piece of hardware used to send/receive massive amounts of data."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 80
	machinetype = 7
	heatgen = 40
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/hub"
	long_range_link = 1
	netspeed = 40

/obj/machinery/telecomms/hub/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	if(is_freq_listening(signal))
		if(istype(machine_from, /obj/machinery/telecomms/relay))

			//If the signal is compressed, send it to the bus.
			relay_information(signal, "/obj/machinery/telecomms/bus", 1) // ideally relay the copied information to bus units
		else
			//The signal is ready to be sent!
			var/can_send = relay_information(signal, "/obj/machinery/telecomms/relay", 1)
			if(!can_send)
				relay_information(signal, "/obj/machinery/telecomms/broadcaster", 1) // Send it to a broadcaster instead, if it's linked to one
/*
	The relay idles until it receives information. It then passes on that information
	depending on where it came from.

	The relay is needed in order to send information pass Z levels. It must be linked
	with a HUB, the only other machine that can send/receive pass Z levels.
*/

/obj/machinery/telecomms/relay
	name = "Telecommunication Relay"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "relay"
	desc = "A mighty piece of hardware used to send massive amounts of data far away."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 30
	machinetype = 8
	heatgen = 0
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/relay"
	netspeed = 5
	long_range_link = 1

/obj/machinery/telecomms/relay/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

	if(is_freq_listening(signal))
		if(istype(machine_from, /obj/machinery/telecomms/receiver))

			//If the signal is compressed, send it to the bus.
			var/can_send = relay_information(signal, "/obj/machinery/telecomms/hub", 1) // ideally relay the copied information to bus units
			if(!can_send)
				relay_information(signal, "/obj/machinery/telecomms/bus", 1) // Send it to a bus instead, if it's linked to one
		else
			//The signal is ready to be sent!
			relay_information(signal, "/obj/machinery/telecomms/broadcaster", 1)

/*
	The bus mainframe idles and waits for hubs to relay them signals. They act
	as junctions for the network.

	They transfer uncompressed subspace packets to processor units, and then take
	the processed packet to a server for logging.

	Link to a subspace hub if it can't send to a server.
*/

/obj/machinery/telecomms/bus
	name = "Bus Mainframe"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "bus"
	desc = "A mighty piece of hardware used to send massive amounts of data quickly."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 50
	machinetype = 2
	heatgen = 20
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/bus"
	netspeed = 40

/obj/machinery/telecomms/bus/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

	if(is_freq_listening(signal))
		if(signal.data["compression"]) // if signal is still compressed from subspace transmission
			// send to one linked processor unit
			var/send_to_processor = relay_information(signal, "/obj/machinery/telecomms/processor", 1)

			if(!send_to_processor) // failed to send to a processor, relay information anyway
				signal.data["slow"] += rand(1, 5) // slow the signal down only slightly
				relay_information(signal, "/obj/machinery/telecomms/server", 1)


		else // the signal has been decompressed by a processor unit
			 // send to all linked server units
			var/sendserver = relay_information(signal, "/obj/machinery/telecomms/server", 1)

			// Can't send to a single server, send to a hub instead!
			if(!sendserver)
				signal.data["slow"] += rand(0, 1) // slow the signal down only slightly
				relay_information(signal, "/obj/machinery/telecomms/hub")



/*
	The processor is a very simple machine that decompresses subspace signals and
	transfers them back to the original bus. It is essential in producing audible
	data.

	Link to servers if bus is not present
*/

/obj/machinery/telecomms/processor
	name = "Processor Unit"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "processor"
	desc = "This machine is used to process large quantities of information."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 30
	machinetype = 3
	heatgen = 100
	delay = 5
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/processor"

	receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

		if(is_freq_listening(signal))
			signal.data["compression"] = 0 // uncompress subspace signal
			if(istype(machine_from, /obj/machinery/telecomms/bus))
				relay_direct_information(signal, machine_from) // send the signal back to the machine
			else // no bus detected - send the signal to servers instead
				signal.data["slow"] += rand(5, 10) // slow the signal down
				relay_information(signal, "/obj/machinery/telecomms/server", 1)


/*
	The server logs all traffic and signal data. Once it records the signal, it sends
	it to the subspace broadcaster.

	Store a maximum of 100 logs and then deletes them.
*/


/obj/machinery/telecomms/server
	name = "Telecommunication Server"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "comm_server"
	desc = "A machine used to store data and network statistics."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 15
	machinetype = 4
	heatgen = 50
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/server"
	var/list/log_entries = list()
	var/list/stored_names = list()
	var/list/TrafficActions = list()
	var/logs = 0 // number of logs
	var/totaltraffic = 0 // gigabytes (if > 1024, divide by 1024 -> terrabytes)

	var/list/memory = list()	// stored memory
	var/rawcode = ""	// the code to compile (raw text)
	var/datum/TCS_Compiler/Compiler	// the compiler that compiles and runs the code
	var/autoruncode = 0		// 1 if the code is set to run every time a signal is picked up

	var/encryption = "null" // encryption key: ie "password"
	var/salt = "null"		// encryption salt: ie "123comsat"
							// would add up to md5("password123comsat")
	var/language = "human"

/obj/machinery/telecomms/server/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

	if(signal.data["message"])

		if(is_freq_listening(signal))

			if(traffic > 0)
				totaltraffic += traffic // add current traffic to total traffic

			//Is this a test signal? Bypass logging
			if(signal.data["type"] != 4)

				// If signal has a message and appropriate frequency

				update_logs()

				var/datum/comm_log_entry/log = new
				var/mob/M = signal.data["mob"]

				// Copy the signal.data entries we want
				log.parameters["mobtype"] = signal.data["mobtype"]
				log.parameters["job"] = signal.data["job"]
				log.parameters["key"] = signal.data["key"]
				log.parameters["vmessage"] = signal.data["message"]
				log.parameters["vname"] = signal.data["vname"]
				log.parameters["message"] = signal.data["message"]
				log.parameters["name"] = signal.data["name"]
				log.parameters["realname"] = signal.data["realname"]

				if(!istype(M, /mob/new_player) && M)
					log.parameters["uspeech"] = M.universal_speak
				else
					log.parameters["uspeech"] = 0

				// If the signal is still compressed, make the log entry gibberish
				if(signal.data["compression"] > 0)
					log.parameters["message"] = Gibberish(signal.data["message"], signal.data["compression"] + 50)
					log.parameters["job"] = Gibberish(signal.data["job"], signal.data["compression"] + 50)
					log.parameters["name"] = Gibberish(signal.data["name"], signal.data["compression"] + 50)
					log.parameters["realname"] = Gibberish(signal.data["realname"], signal.data["compression"] + 50)
					log.parameters["vname"] = Gibberish(signal.data["vname"], signal.data["compression"] + 50)
					log.input_type = "Corrupt File"

				// Log and store everything that needs to be logged
				log_entries.Add(log)
				if(!(signal.data["name"] in stored_names))
					stored_names.Add(signal.data["name"])
				logs++
				signal.data["server"] = src

				// Give the log a name
				var/identifier = num2text( rand(-1000,1000) + world.time )
				log.name = "data packet ([md5(identifier)])"

				if(Compiler && autoruncode)
					Compiler.Run(signal)	// execute the code

			relay_information(signal, "/obj/machinery/telecomms/hub", 1)


/obj/machinery/telecomms/server/proc/setcode(var/t)
	if(t)
		if(istext(t))
			rawcode = t

/obj/machinery/telecomms/server/proc/compile()
	if(Compiler)
		return Compiler.Compile(rawcode)

/obj/machinery/telecomms/server/proc/update_logs()
	// start deleting the very first log entry
	if(logs >= 400)
		for(var/i = 1, i <= logs, i++) // locate the first garbage collectable log entry and remove it
			var/datum/comm_log_entry/L = log_entries[i]
			if(L.garbage_collector)
				log_entries.Remove(L)
				logs--
				break

/obj/machinery/telecomms/server/proc/add_entry(var/content, var/input)
	var/datum/comm_log_entry/log = new
	var/identifier = num2text( rand(-1000,1000) + world.time )
	log.name = "[input] ([md5(identifier)])"
	log.input_type = input
	log.parameters["message"] = content
	log_entries.Add(log)
	update_logs()




// Simple log entry datum

/datum/comm_log_entry
	var/parameters = list() // carbon-copy to signal.data[]
	var/name = "data packet (#)"
	var/garbage_collector = 1 // if set to 0, will not be garbage collected
	var/input_type = "Speech File"




// ### Preset machines (Located at centcom!) (Or the Comms Satellite) ###

//Relay

/obj/machinery/telecomms/relay/preset
	network = "tcommsat"

/obj/machinery/telecomms/relay/preset/station
	id = "Station Relay"
	autolinkers = list("s_relay", "s_receiverA", "s_receiverB", "s_broadcasterA", "s_broadcasterB")

/obj/machinery/telecomms/relay/preset/telecomms
	id = "Telecomms Relay"
	autolinkers = list("relay", "receiverA", "receiverB", "broadcasterA", "broadcasterB")

/obj/machinery/telecomms/relay/preset/mining
	id = "Mining Relay"
	autolinkers = list("m_relay", "m_receiverA", "m_receiverB", "m_broadcasterA", "m_broadcasterB")

/obj/machinery/telecomms/relay/preset/ruskie
	id = "Ruskie Relay"
	hide = 1
	toggled = 0
	autolinkers = list("r_relay", "r_receiverA", "r_receiverB", "r_broadcasterA", "r_broadcasterB")

//HUB

/obj/machinery/telecomms/hub/preset
	id = "Hub"
	network = "tcommsat"
	autolinkers = list("hub", "relay", "s_relay", "m_relay", "r_relay", "science", "medical",
	"cargo", "mining", "common", "command", "engineering", "security")

//Receivers

/obj/machinery/telecomms/receiver/preset_left
	id = "Receiver A"
	network = "tcommsat"
	autolinkers = list("receiverA") // link to relay
	freq_listening = list(1351, 1355, 1347, 1349) // science, medical, cargo, mining

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

/obj/machinery/telecomms/receiver/preset_left/station // Unused, note to self to delete later
	id = "Station Receiver A"
	autolinkers = list("s_receiverA")

/obj/machinery/telecomms/receiver/preset_right/station
	id = "Station Receiver B"
	autolinkers = list("s_receiverB")
	freq_listening = list(1351, 1355, 1347, 1349, 1353, 1357, 1359) // science, medical, cargo, mining, command, engineering, security

/obj/machinery/telecomms/receiver/preset_left/mining
	id = "Mining Receiver A"
	autolinkers = list("m_receiverA")

/obj/machinery/telecomms/receiver/preset_right/mining
	id = "Mining Receiver B"
	autolinkers = list("m_receiverB")

/obj/machinery/telecomms/receiver/preset_left/ruskie // Unused, not to self to delete later.
	id = "Ruskie Receiver A"
	autolinkers = list("r_receiverA")
	toggled = 0
	hide = 1

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

/obj/machinery/telecomms/broadcaster/preset_left
	id = "Broadcaster A"
	network = "tcommsat"
	autolinkers = list("broadcasterA")

/obj/machinery/telecomms/broadcaster/preset_right
	id = "Broadcaster B"
	network = "tcommsat"
	autolinkers = list("broadcasterB")

/obj/machinery/telecomms/broadcaster/preset_left/station // Unused, not to self to delete later
	id = "Station Broadcaster A"
	autolinkers = list("s_broadcasterA")


/obj/machinery/telecomms/broadcaster/preset_right/station
	id = "Station Broadcaster B"
	autolinkers = list("s_broadcasterB")

/obj/machinery/telecomms/broadcaster/preset_left/mining
	id = "Mining Broadcaster A"
	autolinkers = list("m_broadcasterA")

/obj/machinery/telecomms/broadcaster/preset_right/mining
	id = "Mining Broadcaster B"
	autolinkers = list("m_broadcasterB")

/obj/machinery/telecomms/broadcaster/preset_left/ruskie
	id = "Ruskie Broadcaster A"
	autolinkers = list("r_broadcasterA")
	toggled = 0
	hide = 1

/obj/machinery/telecomms/broadcaster/preset_right/ruskie
	id = "Ruskie Broadcaster B"
	autolinkers = list("r_broadcasterB")
	toggled = 0
	hide = 1








