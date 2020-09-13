

/datum/radio_frequency
	var/frequency as text
	// This includes a list of filters on the radio
	var/list/list/obj/devices = list()
	// list of all devices on this frequency, can be directly accessed by hardware id

/datum/radio_frequency/New(freq)
	frequency = freq

// returns a list of all objects in an area relitive to source
/datum/radio_frequency/proc/search(datum/component/radio_interface/source, filter = null, range = RADIO_RANGE_INFINITY)
	var/obj/source_obj = source.parent
	var/obj/dest_obj

	//Apply filter to the signal. If none supply, broadcast to every devices
	//_default channel is always checked
	var/list/filter_list = filter ? list(filter,"_default") : devices

	. = list()
		//Send the data
	switch(range)
		if(RADIO_RANGE_INFINITY)
			for(var/current_filter in filter_list)
				for(var/datum/component/radio_interface/dest in devices[current_filter])
					if(dest == source)
						continue
					dest_obj = dest.parent
					if(source_obj.z != dest_obj.z)
						continue
					. += dest
		if(RADIO_RANGE_AREA)
			for(var/current_filter in filter_list)
				for(var/datum/component/radio_interface/dest in devices[current_filter])
					if(dest == source)
						continue
					dest_obj = dest.parent
					// Hack of get_area, we just skip the test for "is an area"
					if(get_step(source_obj, 0).loc != get_step(dest_obj, 0).loc)
						continue
					. += dest
		else
			ASSERT(range >= 0)
			for(var/current_filter in filter_list)
				for(var/datum/component/radio_interface/dest in devices[current_filter])
					if(dest == source)
						continue
					dest_obj = dest.parent
					// Why the hell does this thing work?!?
					if(source_obj.z != dest_obj.z && !(max(abs(source_obj.x-dest_obj.x), abs(source_obj.y-dest_obj.y)) >= range))
						continue
					. += dest


// we brodcast a signal from the interface on this frequency
/datum/radio_frequency/proc/broadcast_signal(datum/component/radio_interface/source, datum/signal/signal, filter = null, range = RADIO_RANGE_INFINITY)
	set waitfor = FALSE		// I hope I don't regret this one
	var/datum/component/radio_interface/dest
	// Ensure the signal's data is fully filled
	signal.source = source.parent
	signal.frequency = frequency
	var/list/targets = search(source,filter,range)
	for(var/i in 1 to targets.len)
		dest = targets[i]
		SEND_SIGNAL(dest.parent, COMSIG_RADIO_RECEIVE_DATA, signal)

// sending a signal to a singal target by station id, useed mainly for devices that cache the stations
/datum/radio_frequency/proc/transmit_signal(datum/component/radio_interface/source, target_station_id, datum/signal/signal)
	ASSERT(target_station_id != null)
	var/datum/component/radio_interface/dest = devices[target_station_id]
	if(dest)
		signal.source = source.parent
		signal.frequency = frequency
		SEND_SIGNAL(dest.parent, COMSIG_RADIO_RECEIVE_DATA, signal)

/datum/radio_frequency/proc/add_listener(datum/component/radio_interface/I, filter as text|null)
	if (!filter)
		filter = "_default"

	var/list/devices_line = devices[filter]
	if(!devices_line)
		devices[filter] = devices_line = list()
	devices_line[I.station_id] = I
	devices[I.station_id] = I

/datum/radio_frequency/proc/remove_listener(datum/component/radio_interface/I)
	for(var/devices_filter in devices)
		var/list/devices_line = devices[devices_filter]
		if(devices_line)
			devices_line.Remove(I.station_id)
	devices.Remove(I.station_id)


/datum/component/radio_interface
	var/static/list/all_interfaces = list()
	var/datum/radio_frequency/frequency = null

	var/frequency_text = null
	var/station_id = null
	var/filter = null
	var/map_tag = null

/datum/component/radio_interface/proc/create_station_id(len=5)
	var/list/new_id = list()
	do
		new_id.Cut()
		// machine id's should be fun random chars hinting at a larger world
		for(var/i = 1 to len)
			switch(rand(1,3))
				if(1)
					new_id += ascii2text(rand(65, 90)) // A - Z
				if(2)
					new_id += ascii2text(rand(97,122)) // a - z
				if(3)
					new_id += ascii2text(rand(48, 57)) // 0 - 9
		station_id = new_id.Join()
	while(all_interfaces[station_id])
	all_interfaces[station_id] = src

/datum/component/radio_interface/proc/disconnect()
	if(frequency)
		frequency.remove_listener(src)
		frequency_text = null
		frequency = null
// Creates a new interface.  map_tag is used to find a device that have a special map
// tag
/datum/component/radio_interface/Initialize(freq, filter=null, map_tag=null)
	create_station_id()
	if(map_tag)
		if(all_interfaces[map_tag]) // checck if it exists
			var/obj/O = parent
			O.investigate_log("There is a map problem with a device with the [map_tag] tag, more than one device has this tag",INVESTIGATE_RADIO)
		else
			all_interfaces[map_tag] = src
			src.map_tag = map_tag
	RegisterSignal(parent, COMSIG_RADIO_NEW_FREQUENCY, .proc/set_frequency)
	if(freq)
		set_frequency(freq, filter)


/datum/component/radio_interface/proc/set_frequency(new_frequency, filter = null as text|null)
	var/f_text = istext(new_frequency) ? new_frequency : num2text(new_frequency)
	if(f_text != frequency_text || src.filter != filter)
		if(frequency)
			disconnect()
		frequency = SSradio.return_frequency(f_text)
		frequency.add_listener(src, filter)
		src.filter = filter
		frequency_text = f_text

/datum/component/radio_interface/proc/broadcast(datum/signal/signal, filter = null as text|null, range = null as num|null)
	if(frequency)
		frequency.broadcast_signal(src,signal,filter,range)

/datum/component/radio_interface/proc/transmit(datum/signal/signal, target_id, range = null as num|null)
	if(!target_id)
		var/obj/O = parent
		O.investigate_log("Target ID for sending is null", INVESTIGATE_RADIO)
	if(frequency)
		frequency.transmit_signal(src,signal,filter,range)



/datum/component/radio_interface/Destroy()
	disconnect()
	all_interfaces.Remove(station_id)
	if(map_tag)
		all_interfaces.Remove(map_tag)
	UnregisterSignal(parent, COMSIG_RADIO_NEW_FREQUENCY)

	return ..()
