/*
	Hello, friends, this is Doohl from sexylands. You may be wondering what this
	monstrous code file is. Sit down, boys and girls, while I tell you the tale.


	The machines defined in this file were designed to be compatible with any radio
	signals, provided they use subspace transmission. Currently they are only used for
	headsets, but they can eventually be outfitted for real COMPUTER networks. This
	is just a skeleton, ladies and gentlemen.

	Look at radio.dm for the prequel to this code.
*/

/obj/machinery/telecomms
	var
		list/links = list() // list of machines this machine is linked to
		traffic = 0 // value increases as traffic increases
		netspeed = 5 // how much traffic to lose per tick (50 gigabytes/second * netspeed)
		list/autolinkers = list() // list of text/number values to link with
		id = "NULL" // identification string
		network = "NULL" // the network of the machinery

		list/freq_listening = list() // list of frequencies to tune into: if none, will listen to all

		machinetype = 0 // just a hacky way of preventing alike machines from pairing
		on = 1
		integrity = 100 // basically HP, loses integrity by heat
		heatgen = 20 // how much heat to transfer to the environment
		delay = 10 // how many process() ticks to delay per heat
		heating_power = 40000

		circuitboard = null // string pointing to a circuitboard type



	proc/relay_information(datum/signal/signal, filter, copysig, amount)
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

	proc/relay_direct_information(datum/signal/signal, obj/machinery/telecomms/machine)
		// send signal directly to a machine
		machine.receive_information(signal, src)

	proc/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
		// receive information from linked machinery
		..()

	proc/is_freq_listening(datum/signal/signal)
		// return 1 if found, 0 if not found
		if((signal.frequency in freq_listening) || (!freq_listening.len))
			return 1
		else
			return 0

	New()
		..()
		if(autolinkers.len)
			spawn(10)
				// Links nearby machines
				for(var/obj/machinery/telecomms/T in orange(15, src))
					for(var/x in autolinkers)
						if(T.autolinkers.Find(x))
							if(!(T in links) && machinetype != T.machinetype)
								links.Add(T)

		if(istype(src, /obj/machinery/telecomms/server))
			var/obj/machinery/telecomms/server/S = src
			S.Compiler = new()
			S.Compiler.Holder = src


	update_icon()
		if(on)
			icon_state = initial(icon_state)
		else
			icon_state = "[initial(icon_state)]_off"


	process()
		if(stat & (BROKEN|NOPOWER) || integrity <= 0) // if powered, on. if not powered, off. if too damaged, off
			on = 0
		else
			on = 1

		// Check heat and generate some
		checkheat()

		// Update the icon
		update_icon()

		if(traffic > 0)
			traffic -= netspeed
		/* Machine checks */
		if(on)
			if(machinetype == 2) // bus mainframes
				switch(traffic)
					if(-100 to 49)
						icon_state = initial(icon_state)
					if(50 to 200)
						icon_state = "bus2"
					else
						icon_state = "bus3"

		// Check heat and generate some

	proc/checkheat()
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

	proc/produce_heat(heat_amt)
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
	icon = 'stationobjs.dmi'
	icon_state = "broadcast receiver"
	desc = "This machine has a dish-like shape and green lights. It is designed to detect and process subspace radio activity."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 30
	machinetype = 1
	heatgen = 10
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/receiver"

	receive_signal(datum/signal/signal)

		if(!on) // has to be on to receive messages
			return

		if(signal.transmission_method == 2)

			if(is_freq_listening(signal)) // detect subspace signals


				var/sendbus = relay_information(signal, "/obj/machinery/telecomms/bus", 1) // ideally relay the copied information to bus units

				/* We can't send the signal to a bus, so we send it to a processor */
				if(!sendbus)
					signal.data["slow"] += rand(5, 10) // slow the signal down
					relay_information(signal, "/obj/machinery/telecomms/processor", 1) // send copy to processors


/*
	The bus mainframe idles and waits for receivers to relay them signals. They act
	as the main network hub, transferring data packets from and to other machines.

	They transfer uncompressed subspace packets to processor units, and then take
	the processed packet to a server for logging.

	Link to a subspace broadcaster if it can't send to a server.
*/

/obj/machinery/telecomms/bus
	name = "Bus Mainframe"
	icon = 'stationobjs.dmi'
	icon_state = "bus1"
	desc = "A mighty piece of hardware used to send massive amounts of data quickly."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 50
	machinetype = 2
	heatgen = 20
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/bus"
	netspeed = 40

	receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

		if(is_freq_listening(signal))
			if(signal.data["compression"]) // if signal is still compressed from subspace transmission
				// send to one linked processor unit

				var/send_to_processor = relay_information(signal, "/obj/machinery/telecomms/processor")

				if(!send_to_processor) // failed to send to a processor, relay information anyway
					signal.data["slow"] += rand(1, 5) // slow the signal down only slightly
					relay_information(signal, "/obj/machinery/telecomms/server", 1)


			else // the signal has been decompressed by a processor unit
				 // send to all linked server units
				var/sendserver = relay_information(signal, "/obj/machinery/telecomms/server", 1)

				// Can't send to a single server, send to a broadcaster instead! But it needs a processor to do this
				if(!sendserver)
					signal.data["slow"] += rand(0, 1) // slow the signal down only slightly
					relay_information(signal, "/obj/machinery/telecomms/broadcaster")



/*
	The processor is a very simple machine that decompresses subspace signals and
	transfers them back to the original bus. It is essential in producing audible
	data.

	Link to servers if bus is not present
*/

/obj/machinery/telecomms/processor
	name = "Processor Unit"
	icon = 'stationobjs.dmi'
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
	icon = 'stationobjs.dmi'
	icon_state = "comm_server"
	desc = "A machine used to store data and network statistics."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 15
	machinetype = 4
	heatgen = 50
	circuitboard = "/obj/item/weapon/circuitboard/telecomms/server"
	var
		list/log_entries = list()
		list/stored_names = list()
		list/TrafficActions = list()
		logs = 0 // number of logs
		totaltraffic = 0 // gigabytes (if > 1024, divide by 1024 -> terrabytes)

		list/memory = list()	// stored memory
		rawcode = ""	// the code to compile (raw text)
		datum/TCS_Compiler/Compiler	// the compiler that compiles and runs the code
		autoruncode = 0		// 1 if the code is set to run every time a signal is picked up

		encryption = "null" // encryption key: ie "password"
		salt = "null"		// encryption salt: ie "123comsat"
							// would add up to md5("password123comsat")
		language = "human"

	receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

		if(signal.data["message"])

			if(is_freq_listening(signal))

				if(traffic > 0)
					totaltraffic += traffic // add current traffic to total traffic

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

				relay_information(signal, "/obj/machinery/telecomms/broadcaster")


	proc/setcode(var/t)
		if(t)
			if(istext(t))
				rawcode = t

	proc/compile()
		if(Compiler)
			return Compiler.Compile(rawcode)

	proc/update_logs()
		// start deleting the very first log entry
		if(logs >= 400)
			for(var/i = 1, i <= logs, i++) // locate the first garbage collectable log entry and remove it
				var/datum/comm_log_entry/L = log_entries[i]
				if(L.garbage_collector)
					log_entries.Remove(L)
					logs--
					break

	proc/add_entry(var/content, var/input)
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


/obj/machinery/telecomms/receiver/preset_left
	id = "Receiver A"
	network = "tcommsat"
	autolinkers = list("bus1", "bus2") // link to bus units 1 and 2
	freq_listening = list(1351, 1355, 1347, 1349) // science, medical, cargo, mining

/obj/machinery/telecomms/receiver/preset_right
	id = "Receiver B"
	network = "tcommsat"
	autolinkers = list("bus3", "bus4") // Bus units 3 and 4
	freq_listening = list(1459, 1353, 1357, 1359) // common, command, engineering, security



/obj/machinery/telecomms/bus/preset_one
	id = "Bus 1"
	network = "tcommsat"
	autolinkers = list("bus1", "processor1", "science", "medical")

/obj/machinery/telecomms/bus/preset_two
	id = "Bus 2"
	network = "tcommsat"
	autolinkers = list("bus2", "processor2", "cargo", "mining")

/obj/machinery/telecomms/bus/preset_three
	id = "Bus 3"
	network = "tcommsat"
	autolinkers = list("bus3", "processor3", "security", "command")

/obj/machinery/telecomms/bus/preset_four
	id = "Bus 4"
	network = "tcommsat"
	autolinkers = list("bus4", "processor4", "engineering", "common")



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
	network = "Communications Satellite"
	autolinkers = list("processor3")

/obj/machinery/telecomms/processor/preset_four
	id = "Processor 4"
	network = "tcommsat"
	autolinkers = list("processor4")



/obj/machinery/telecomms/server/presets

	network = "tcommsat"

	science
		id = "Science Server"
		freq_listening = list(1351)
		autolinkers = list("science", "broadcasterA")

	medical
		id = "Medical Server"
		freq_listening = list(1355)
		autolinkers = list("medical", "broadcasterA")

	cargo
		id = "Cargo Server"
		freq_listening = list(1347)
		autolinkers = list("cargo", "broadcasterA")

	mining
		id = "Mining Server"
		freq_listening = list(1349)
		autolinkers = list("mining", "broadcasterA")

	common
		id = "Common Server"
		freq_listening = list(1459)
		autolinkers = list("common", "broadcasterB")

	command
		id = "Command Server"
		freq_listening = list(1353)
		autolinkers = list("command", "broadcasterB")

	engineering
		id = "Engineering Server"
		freq_listening = list(1357)
		autolinkers = list("engineering", "broadcasterB")

	security
		id = "Security Server"
		freq_listening = list(1359)
		autolinkers = list("security", "broadcasterB")




/obj/machinery/telecomms/broadcaster/preset_left
	id = "Broadcaster A"
	network = "tcommsat"
	autolinkers = list("broadcasterA")

/obj/machinery/telecomms/broadcaster/preset_right
	id = "Broadcaster B"
	network = "tcommsat"
	autolinkers = list("broadcasterB")









