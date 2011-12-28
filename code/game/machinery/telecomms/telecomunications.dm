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
		list/autolinkers = list() // list of text/number values to link with
		id = "NULL" // identification string
		network = "NULL" // the network of the machinery

		list/freq_listening = list() // list of frequencies to tune into: if none, will listen to all

		machinetype = 0 // just a hacky way of preventing alike machines from pairing


	proc/relay_information(datum/signal/signal, filter, amount)
		// relay signal to all linked machinery that are of type [filter]. If signal has been sent [amount] times, stop sending

		var/send_count = 0

		for(var/obj/machinery/telecomms/machine in links)
			if(filter && !istype( machine, text2path(filter) ))
				continue
			if(amount && send_count >= amount)
				break

			send_count++

			spawn()
				machine.receive_information(signal, src)

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



/*
	The receiver idles and receives messages from subspace-compatible radio equipment;
	primarily headsets. They then just relay this information to all linked devices,
	which can would probably be network buses.
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

	receive_signal(datum/signal/signal)

		if(signal.transmission_method == 2)

			if(is_freq_listening(signal)) // detect subspace signals

				var/datum/signal/copy = new
				copy.copy_from(signal) // copy information to new signal
				copy.data["original"] = signal

				relay_information(copy) // ideally relay the information to bus units



/*
	The bus mainframe idles and waits for receivers to relay them signals. They act
	as the main network hub, transferring data packets from and to other machines.

	They transfer uncompressed subspace packets to processor units, and then take
	the processed packet to a server for logging.
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

	receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

		if(is_freq_listening(signal))
			if(signal.data["compression"]) // if signal is still compressed from subspace transmission
				// send to one linked processor unit

				var/send_to_processor = relay_information(signal, "/obj/machinery/telecomms/processor", 1)

				if(!send_to_processor) // failed to send to a processor, relay information anyway
					relay_information(signal, "/obj/machinery/telecomms/server")


			else // the signal has been decompressed by a processor unit
				 // send to all linked server units
				relay_information(signal, "/obj/machinery/telecomms/server")



/*
	The processor is a very simple machine that decompresses subspace signals and
	transfers them back to the original bus. It is essential in producing audible
	data.
*/

/obj/machinery/telecomms/processor
	name = "Processor Unit"
	icon = 'stationobjs.dmi'
	icon_state = "processor_on"
	desc = "This machine is used to process large quantities of information."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 30
	machinetype = 3

	receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

		if(is_freq_listening(signal))
			signal.data["compression"] = 0 // uncompress subspace signal
			relay_direct_information(signal, machine_from) // send the signal back to the machine



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
	var
		list/log_entries = list()

	receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)

		if(signal.data["message"] && !signal.data["compression"])

			if(is_freq_listening(signal))

				// if signal contains discernable data

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
				log.parameters["uspeech"] = M.universal_speak

				log_entries.Add(log)

				var/identifier = num2text( rand(-1000,1000) + world.time )
				log.name = "data packet ([md5(identifier)])"

				relay_information(signal, "/obj/machinery/telecomms/broadcaster") // send to all broadcasters

	proc/update_logs()
		// deletes all logs when there are 100
		if(log_entries.len >= 100)
			var/list/restore = list()
			for(var/datum/comm_log_entry/log in log_entries)
				if(log.garbage_collector) // if garbage collector is set to 1, delete
					del(log)
				else
					restore.Add(log)

			log_entries.len = 0
			log_entries.Add(restore)

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
		id = "science server"
		freq_listening = list(1351)
		autolinkers = list("science", "broadcasterA")

	medical
		id = "medical server"
		freq_listening = list(1355)
		autolinkers = list("medical", "broadcasterA")

	cargo
		id = "cargo server"
		freq_listening = list(1347)
		autolinkers = list("cargo", "broadcasterA")

	mining
		id = "mining server"
		freq_listening = list(1349)
		autolinkers = list("mining", "broadcasterA")

	common
		id = "common server"
		freq_listening = list(1459)
		autolinkers = list("common", "broadcasterB")

	command
		id = "command server"
		freq_listening = list(1353)
		autolinkers = list("command", "broadcasterB")

	engineering
		id = "engineering server"
		freq_listening = list(1357)
		autolinkers = list("engineering", "broadcasterB")

	security
		id = "security server"
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









