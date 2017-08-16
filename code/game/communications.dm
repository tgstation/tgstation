/*
  HOW IT WORKS

  The SSradio is a global object maintaining all radio transmissions, think about it as about "ether".
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
    Avoid of sending signals directly from this proc, use spawn(0). Do not use sleep() here please.
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
/*	the radio controller is a confusing piece of shit and didnt work
	so i made radios not use the radio controller.
*/
GLOBAL_LIST_EMPTY(all_radios)
/proc/add_radio(obj/item/radio, freq)
	if(!freq || !radio)
		return
	if(!GLOB.all_radios["[freq]"])
		GLOB.all_radios["[freq]"] = list(radio)
		return freq

	GLOB.all_radios["[freq]"] |= radio
	return freq

/proc/remove_radio(obj/item/radio, freq)
	if(!freq || !radio)
		return
	if(!GLOB.all_radios["[freq]"])
		return

	GLOB.all_radios["[freq]"] -= radio

/proc/remove_radio_all(obj/item/radio)
	for(var/freq in GLOB.all_radios)
		GLOB.all_radios["[freq]"] -= radio

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
1337 - death squad
1443 - Confession Intercom
1349 - Miners
1347 - Cargo techs
1447 - AI Private

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

GLOBAL_LIST_INIT(radiochannels, list(
	"Common" = 1459,
	"Science" = 1351,
	"Command" = 1353,
	"Medical" = 1355,
	"Engineering" = 1357,
	"Security" = 1359,
	"CentCom" = 1337,
	"Syndicate" = 1213,
	"Supply" = 1347,
	"Service" = 1349,
	"AI Private" = 1447,
	"Red Team" = 1215,
	"Blue Team" = 1217
))

GLOBAL_LIST_INIT(reverseradiochannels, list(
	"1459" = "Common",
	"1351" = "Science",
	"1353" = "Command",
	"1355" = "Medical",
	"1357" = "Engineering",
	"1359" = "Security",
	"1337" = "CentCom",
	"1213" = "Syndicate",
	"1347" = "Supply",
	"1349" = "Service",
	"1447" = "AI Private",
	"1215" = "Red Team",
	"1217" = "Blue Team"
))

//depenging helpers
GLOBAL_VAR_CONST(SYND_FREQ, 1213) //nuke op frequency, coloured dark brown in chat window
GLOBAL_VAR_CONST(SUPP_FREQ, 1347) //supply, coloured light brown in chat window
GLOBAL_VAR_CONST(SERV_FREQ, 1349) //service, coloured green in chat window
GLOBAL_VAR_CONST(SCI_FREQ, 1351) //science, coloured plum in chat window
GLOBAL_VAR_CONST(COMM_FREQ, 1353) //command, colored gold in chat window
GLOBAL_VAR_CONST(MED_FREQ, 1355) //medical, coloured blue in chat window
GLOBAL_VAR_CONST(ENG_FREQ, 1357) //engineering, coloured orange in chat window
GLOBAL_VAR_CONST(SEC_FREQ, 1359) //security, coloured red in chat window
GLOBAL_VAR_CONST(CENTCOM_FREQ, 1337) //centcom frequency, coloured grey in chat window
GLOBAL_VAR_CONST(AIPRIV_FREQ, 1447) //AI private, colored magenta in chat window
GLOBAL_VAR_CONST(REDTEAM_FREQ, 1215) // red team (CTF) frequency, coloured red
GLOBAL_VAR_CONST(BLUETEAM_FREQ, 1217) // blue team (CTF) frequency, coloured blue

#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1

/* filters */
GLOBAL_VAR_INIT(RADIO_TO_AIRALARM, "1")
GLOBAL_VAR_INIT(RADIO_FROM_AIRALARM, "2")
GLOBAL_VAR_INIT(RADIO_CHAT, "3") //deprecated
GLOBAL_VAR_INIT(RADIO_ATMOSIA, "4")
GLOBAL_VAR_INIT(RADIO_NAVBEACONS, "5")
GLOBAL_VAR_INIT(RADIO_AIRLOCK, "6")
GLOBAL_VAR_INIT(RADIO_MAGNETS, "9")

/datum/radio_frequency

	var/frequency as num
	var/list/list/obj/devices = list()

//If range > 0, only post to devices on the same z_level and within range
//Use range = -1, to restrain to the same z_level without limiting range
/datum/radio_frequency/proc/post_signal(obj/source as obj|null, datum/signal/signal, filter = null as text|null, range = null as num|null)

	//Apply filter to the signal. If none supply, broadcast to every devices
	//_default channel is always checked
	var/list/filter_list

	if(filter)
		filter_list = list(filter,"_default")
	else
		filter_list = devices

	//If checking range, find the source turf
	var/turf/start_point
	if(range)
		start_point = get_turf(source)
		if(!start_point)
			return 0

	//Send the data
	for(var/current_filter in filter_list)
		for(var/obj/device in devices[current_filter])
			if(device == source)
				continue
			if(range)
				var/turf/end_point = get_turf(device)
				if(!end_point)
					continue
				if(start_point.z != end_point.z || (range > 0 && get_dist(start_point, end_point) > range))
					continue
			device.receive_signal(signal, TRANSMISSION_RADIO, frequency)

/datum/radio_frequency/proc/add_listener(obj/device, filter as text|null)
	if (!filter)
		filter = "_default"

	var/list/devices_line = devices[filter]
	if(!devices_line)
		devices_line = list()
		devices[filter] = devices_line
	devices_line += device


/datum/radio_frequency/proc/remove_listener(obj/device)
	for(var/devices_filter in devices)
		var/list/devices_line = devices[devices_filter]
		if(!devices_line)
			devices -= devices_filter
		devices_line -= device
		if(!devices_line.len)
			devices -= devices_filter





/client/proc/print_pointers()
	set name = "Debug Signals"
	set category = "Debug"

	if(!holder)
		return

	var/datum/signal/S
	to_chat(src, "There are [S.pointers.len] pointers:")
	for(var/p in S.pointers)
		to_chat(src, p)
		S = locate(p)
		if(istype(S))
			to_chat(src, S.debug_print())

/obj/proc/receive_signal(datum/signal/signal, receive_method, receive_param)
	return

/datum/signal
	var/obj/source

	var/transmission_method = 0
	//0 = wire
	//1 = radio transmission
	//2 = subspace transmission

	var/data = list()
	var/encryption

	var/frequency = 0
	var/static/list/pointers = list()

/datum/signal/New()
	..()
	pointers += "\ref[src]"

/datum/signal/Destroy()
	pointers -= "\ref[src]"
	return ..()

/datum/signal/proc/copy_from(datum/signal/model)
	source = model.source
	transmission_method = model.transmission_method
	data = model.data
	encryption = model.encryption
	frequency = model.frequency

/datum/signal/proc/debug_print()
	if (source)
		. = "signal = {source = '[source]' ([source:x],[source:y],[source:z])\n"
	else
		. = "signal = {source = '[source]' ()\n"
	for (var/i in data)
		. += "data\[\"[i]\"\] = \"[data[i]]\"\n"
		if(islist(data[i]))
			var/list/L = data[i]
			for(var/t in L)
				. += "data\[\"[i]\"\] list has: [t]"

/datum/signal/proc/sanitize_data()
	for(var/d in data)
		var/val = data[d]
		if(istext(val))
			data[d] = html_encode(val)
