/*
  HOW IT WORKS

  The radio_controller is a global object maintaining all radio transmissions, think about it as about "ether".
  Note that walkie-talkie, intercoms and headsets handle transmission using nonstandard way.
  procs:

    add_object(obj/device as obj, var/new_frequency as num, var/filter as text|null = null)
      Adds listening object.
      parameters:
        device - device receiving signals, must have proc receive_signal (see description below).
          one device may listen several frequencies, but not same frequency twice.
        new_frequency - see possibly frequencies below;
        filter - thing for optimization. Optional, but recommended.
                 All filters should be consolidated in this file, see defines later.
                 Device without listening filter will receive all signals (on specified frequency).
                 Device with filter will receive any signals sent without filter.
                 Device with filter will not receive any signals sent with different filter.
      returns:
       Reference to frequency object.

    remove_object (obj/device, old_frequency)
      Obliviously, after calling this proc, device will not receive any signals on old_frequency.
      Other frequencies will left unaffected.

   return_frequency(var/frequency as num)
      returns:
       Reference to frequency object. Use it if you need to send and do not need to listen.

  radio_frequency is a global object maintaining list of devices that listening specific frequency.
  procs:

    post_signal(obj/source as obj|null, datum/signal/signal, var/filter as text|null = null, var/range as num|null = null)
      Sends signal to all devices that wants such signal.
      parameters:
        source - object, emitted signal. Usually, devices will not receive their own signals.
        signal - see description below.
        filter - described above.
        range - radius of regular byond's square circle on that z-level. null means everywhere, on all z-levels.

  obj/proc/receive_signal(datum/signal/signal, var/receive_method as num, var/receive_param)
    Handler from received signals. By default does nothing. Define your own for your object.
    Avoid of sending signals directly from this proc, use spawn(-1). Do not use sleep() here please.
      parameters:
        signal - see description below. Extract all needed data from the signal before doing sleep(), spawn() or return!
        receive_method - may be TRANSMISSION_WIRE or TRANSMISSION_RADIO.
          TRANSMISSION_WIRE is currently unused.
        receive_param - for TRANSMISSION_RADIO here comes frequency.

  datum/signal
    vars:
    source
      an object that emitted signal. Used for debug and bearing.
    data
      list with transmitting data. Usual use pattern:
        data["msg"] = "hello world"
    encryption
      Some number symbolizing "encryption key".
      Note that game actually do not use any cryptography here.
      If receiving object don't know right key, it must ignore encrypted signal in its receive_signal.

*/

/*
Frequency range: 1200 to 1600
Radiochat range: 1441 to 1489 (most devices refuse to be tune to other frequency, even during mapmaking)

Radio:
1459 - standard radio chat
1351 - Science
1353 - Command
1355 - Medical
1357 - Engineering
1359 - Security
1441 - death squad
1443 - Confession Intercom
1349 - Miners
1347 - Cargo techs

Devices:
1451 - tracking implant
1457 - RSD default

On the map:
1311 for prison shuttle console (in fact, it is not used)
1435 for status displays
1437 for atmospherics/fire alerts
1439 for engine components
1439 for air pumps, air scrubbers, atmo control
1441 for atmospherics - supply tanks
1443 for atmospherics - distribution loop/mixed air tank
1445 for bot nav beacons
1447 for mulebot, secbot and ed209 control
1449 for airlock controls, electropack, magnets
1451 for toxin lab access
1453 for engineering access
1455 for AI access
*/

/proc/radioalert(var/message,var/from)
	var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)
	a.autosay(message,from)

var/list/radiochannels = list(
	"Common" = 1459,
	"Science" = 1351,
	"Command" = 1353,
	"Medical" = 1355,
	"Engineering" = 1357,
	"Security" = 1359,
	"Response Team" = 1439,
	"Syndicate" = 1213,
	"Mining" = 1349,
	"Cargo" = 1347,
)
//depenging helpers
var/list/DEPT_FREQS = list(1351,1355,1357,1359,1213,1439,1349,1347)
var/const/COMM_FREQ = 1353 //command, colored gold in chat window
var/const/SYND_FREQ = 1213
var/NUKE_FREQ = 1200 //Randomised on nuke rounds.

var/global/datum/controller/radio/radio_controller

datum/controller/radio
	var/list/datum/radio_frequency/frequencies = list()

	proc/add_object(obj/device as obj, var/new_frequency as num, var/filter = null as text|null)
		var/f_text = num2text(new_frequency)
		var/datum/radio_frequency/frequency = frequencies[f_text]

		if(!frequency)
			frequency = new
			frequency.frequency = new_frequency
			frequencies[f_text] = frequency

		frequency.add_listener(device, filter)
		return frequency

	proc/remove_object(obj/device, old_frequency)
		var/f_text = num2text(old_frequency)
		var/datum/radio_frequency/frequency = frequencies[f_text]

		if(frequency)
			frequency.remove_listener(device)

			if(frequency.devices.len == 0)
				del(frequency)
				frequencies -= f_text

		return 1

	proc/return_frequency(var/new_frequency as num)
		var/f_text = num2text(new_frequency)
		var/datum/radio_frequency/frequency = frequencies[f_text]

		if(!frequency)
			frequency = new
			frequency.frequency = new_frequency
			frequencies[f_text] = frequency

		return frequency

datum/radio_frequency
	var/frequency as num
	var/list/list/obj/devices = list()

	proc
		post_signal(obj/source as obj|null, datum/signal/signal, var/filter = null as text|null, var/range = null as num|null)
			//log_admin("DEBUG \[[world.timeofday]\]: post_signal {source=\"[source]\", [signal.debug_print()], filter=[filter]}")
//			var/N_f=0
//			var/N_nf=0
//			var/Nt=0
			var/turf/start_point
			if(range)
				start_point = get_turf(source)
				if(!start_point)
					del(signal)
					return 0
			if (filter) //here goes some copypasta. It is for optimisation. -rastaf0
				for(var/obj/device in devices[filter])
					if(device == source)
						continue
					if(range)
						var/turf/end_point = get_turf(device)
						if(!end_point)
							continue
						//if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)
						if(start_point.z!=end_point.z || get_dist(start_point, end_point) > range)
							continue
					device.receive_signal(signal, TRANSMISSION_RADIO, frequency)
				for(var/obj/device in devices["_default"])
					if(device == source)
						continue
					if(range)
						var/turf/end_point = get_turf(device)
						if(!end_point)
							continue
						//if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)
						if(start_point.z!=end_point.z || get_dist(start_point, end_point) > range)
							continue
					device.receive_signal(signal, TRANSMISSION_RADIO, frequency)
//					N_f++
			else
				for (var/next_filter in devices)
//					var/list/obj/DDD = devices[next_filter]
//					Nt+=DDD.len
					for(var/obj/device in devices[next_filter])
						if(device == source)
							continue
						if(range)
							var/turf/end_point = get_turf(device)
							if(!end_point)
								continue
							//if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)
							if(start_point.z!=end_point.z || get_dist(start_point, end_point) > range)
								continue
						device.receive_signal(signal, TRANSMISSION_RADIO, frequency)
//						N_nf++

//			log_admin("DEBUG: post_signal(source=[source] ([source.x], [source.y], [source.z]),filter=[filter]) frequency=[frequency], N_f=[N_f], N_nf=[N_nf]")


			del(signal)

		add_listener(obj/device as obj, var/filter as text|null)
			if (!filter)
				filter = "_default"
			//log_admin("add_listener(device=[device],filter=[filter]) frequency=[frequency]")
			var/list/obj/devices_line = devices[filter]
			if (!devices_line)
				devices_line = new
				devices[filter] = devices_line
			devices_line+=device
//			var/list/obj/devices_line___ = devices[filter_str]
//			var/l = devices_line___.len
			//log_admin("DEBUG: devices_line.len=[devices_line.len]")
			//log_admin("DEBUG: devices(filter_str).len=[l]")

		remove_listener(obj/device)
			for (var/devices_filter in devices)
				var/list/devices_line = devices[devices_filter]
				devices_line-=device
				devices_line.Remove(null)
				if (!devices_line.len)
					devices -= devices_filter
					del(devices_line)


obj/proc
	receive_signal(datum/signal/signal, receive_method, receive_param)
		return null

datum/signal
	var/obj/source

	var/transmission_method = 0
	//0 = wire
	//1 = radio transmission
	//2 = subspace transmission

	var/data = list()
	var/encryption

	var/frequency = 0

	proc/copy_from(datum/signal/model)
		source = model.source
		transmission_method = model.transmission_method
		data = model.data
		encryption = model.encryption
		frequency = model.frequency

	proc/debug_print()
		if (source)
			. = "signal = {source = '[source]' ([source:x],[source:y],[source:z])\n"
		else
			. = "signal = {source = '[source]' ()\n"
		for (var/i in data)
			. += "data\[\"[i]\"\] = \"[data[i]]\"\n"
