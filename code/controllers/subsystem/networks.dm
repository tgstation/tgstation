#define DEBUG_NETWORKS


SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 5
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS

	var/list/relays = list()
	var/datum/ntnet/station/station_network
	var/list/network_initialize_queue = list()

	var/list/interfaces_by_hardware_id = list()

	// Fire information
	var/list/networks = list()
	var/datum/netdata/first = null // start of the queue.  Pulled off in fire.
	var/datum/netdata/last = null	// end of the queue.  pushed on by transmit
	var/packet_count = 0
	// packet stats
	var/count_broadcasts_packets = 0 // count of broadcast packets sent
	var/count_failed_packets = 0 	// count of message fails
	var/count_good_packets = 0
	// Logs moved here
	// Amount of logs the system tries to keep in memory. Keep below 999 to prevent byond from acting weirdly.
	// High values make displaying logs much laggier.
	var/static/setting_maxlogcount = 100
	var/list/logs = list()


/datum/controller/subsystem/networks/stat_entry(msg)
	msg = "NET: QUEUE([packet_count]) FAILS([count_failed_packets]) BROADCAST([count_broadcasts_packets])"
	return ..()

/datum/controller/subsystem/networks/Initialize()
	station_network = new
	station_network.register_map_supremecy() // sigh
	return ..()

/datum/controller/subsystem/networks/proc/_process_packet(receiver_id, datum/netdata/data)
	var/datum/ntnet/target_network = networks[data.network_id]
	if(target_network)
		var/datum/component/ntnet_interface/target_interface = target_network.root_devices[receiver_id]
		if(!QDELETED(target_interface))
			target_interface.parent.ntnet_receive(data)
			count_good_packets++
		else
			count_failed_packets++
			add_log("Bad target device '[receiver_id]'", target_network, data.sender_id)
	else
		count_failed_packets++
		add_log("Bad target network '[data.network_id]'", null, data.sender_id)

#define POP_PACKET(CURRENT) first = CURRENT.next; packet_count--; if(!first) { last = null; packet_count = 0; }; qdel(CURRENT);

/datum/controller/subsystem/networks/fire(resumed = 0)
	var/datum/netdata/current
	while(first)
		current = first
		if(islist(current.receiver_id)) // are we a broadcast list, not logged
			var/list/receivers = current.receiver_id
			var/receiver_id = receivers[receivers.len--] // pop it
			_process_packet(receiver_id, current)
			if(receivers.len == 0) // pop it if done
				count_broadcasts_packets++
				POP_PACKET(current)
		else
			_process_packet(current.receiver_id, current) // single target
			POP_PACKET(current)
		if (MC_TICK_CHECK)
			return
#undef POP_PACKET

/datum/controller/subsystem/networks/proc/transmit(datum/netdata/data)
	data.next = null // sanity check
	var/datum/ntnet/target_network = networks[data.network_id]
	if(!target_network)
		add_log("Bad network '[data.network_id]'",null, data.sender_id)
		qdel(data)
	else
		// check if we are a broadcast and fix the packet
		if(data.receiver_id == null)
			data.receiver_id = target_network.collect_interfaces()
			// broadcasts are usually one way so no error checking if its in the network
			// Packets are just dropped if not found
		else if(!target_network.root_devices[data.receiver_id])
			add_log("Receiver '[data.receiver_id]' not in network", target_network, data.sender_id)
			qdel(data)
		else // finally add to queue
			if(!last)
				first = last = data
			else
				last.next = data
				last = data
			packet_count++
			return TRUE

/datum/controller/subsystem/networks/proc/check_relay_operation(zlevel=0)	//can be expanded later but right now it's true/false.
	for(var/i in relays)
		var/obj/machinery/ntnet_relay/n = i
		if(zlevel && n.z != zlevel)
			continue
		if(n.is_operational)
			return TRUE
	return FALSE

/datum/controller/subsystem/networks/proc/log_data_transfer( datum/netdata/data)
	logs += "[station_time_timestamp()] - [data.generate_netlog()]"
	if(logs.len > setting_maxlogcount)
		logs = logs.Copy(logs.len - setting_maxlogcount, 0)

// Simplified logging: Adds a log. log_string is mandatory parameter
/datum/controller/subsystem/networks/proc/add_log(log_string, datum/ntnet/network = null , hardware_id = null)
	set waitfor = FALSE // so process keeps running
	var/list/log_text = list()
	log_text += "\[[station_time_timestamp()]\]"
	if(network)
		log_text += "{network.network_id}"

	if(hardware_id)
		var/datum/component/ntnet_interface/conn = interfaces_by_hardware_id[hardware_id]
		if(conn)
			log_text += " ([hardware_id])[conn.parent]"
		else
			log_text += " ([hardware_id])*BAD ID*"
	else
		log_text += "*SYSTEM*"
	log_text += " - "
	log_text += log_string
	logs.Add(log_text.Join())

	// We have too many logs, remove the oldest entries until we get into the limit
	if(logs.len > setting_maxlogcount)
		logs = logs.Copy(logs.len-setting_maxlogcount,0)


// Removes all logs
/datum/controller/subsystem/networks/proc/purge_logs()
	logs = list()
	add_log("-!- LOGS DELETED BY SYSTEM OPERATOR -!-")

// Updates maximal amount of stored logs. Use this instead of setting the number, it performs required checks.
/datum/controller/subsystem/networks/proc/update_max_log_count(lognumber)
	if(!lognumber)
		return FALSE
	// Trim the value if necessary
	lognumber = max(MIN_NTNET_LOGS, min(lognumber, MAX_NTNET_LOGS))
	setting_maxlogcount = lognumber
	add_log("Configuration Updated. Now keeping [setting_maxlogcount] logs in system memory.")

// verifies the network name has the right letters in it.  Might need to expand unwanted punctuations

/datum/controller/subsystem/networks/proc/verify_network_name(name)
	return istext(name) && length(name) > 0 && findtext(name, @"[^\.][A-Z0-9_\.]+[^\.]") == 0

// Fixes a network name by replacing the spaces and making eveything uppercase
/datum/controller/subsystem/networks/proc/_simple_network_name_fix(net_name)
	return replacetext(uppertext(net_name),"\[ -\]", "_")

/// Ok, so instead of goign though all the maps and making sure all the tags
/// are set up properly, we can use THIS to set a root id to an area so when the
/// atom loads it joins the right local network.  neat!
/datum/controller/subsystem/networks/proc/lookup_root_id(area/A, datum/map_template/M=null)
	/// Alright boys, lets cycle though a few special cases
	if(M)
		if(M.station_id && M.station_id != NETWORK_LIMBO)
			return M.station_id // override due to template
		if(istype(M, /datum/map_template/shuttle))
			var/datum/map_template/shuttle/T = M	// we are a shuttle so use shuttle id
			return _simple_network_name_fix(T.shuttle_id)
		else if(istype(M,/datum/map_template/ruin))
			var/datum/map_template/ruin/R = M	// ruins have an id var?  why so many var names
			return _simple_network_name_fix(R.id)
	// ok so template overrides over
	if(A)
		if(SSmapping.level_trait(A.z, ZTRAIT_STATION))
			return STATION_NETWORK_ROOT
		else if(SSmapping.level_trait(A.z, ZTRAIT_CENTCOM))
			return CENTCOM_NETWORK_ROOT

	to_chat(world, "Limbo? Area '[A.name]' is going to limbo?")
	return NETWORK_LIMBO // shouldn't get here often...hopefully



// create a network name from a list containing the network tree
/datum/controller/subsystem/networks/proc/network_list_to_string(list/tree)
	ASSERT(tree && tree.len > 0) // this should be obvious but JUST in case.
	for(var/part in tree)
		if(!istext(part))
			log_runtime("Cannot create network with [part]")
			return null // not a valid tree
		if(!verify_network_name(part) && findtext(name,".")==0) // and no stray dots
			log_runtime("Cannot create network with [part]")
			return null 	// name part wrong
	return tree.Join(".")

// create a network tree from a network string
/datum/controller/subsystem/networks/proc/network_string_to_list(name)
#ifdef DEBUG_NETWORKS
	if(!verify_network_name(name))
		log_runtime("network_string_to_list: [name] IS INVALID")
#endif
	return splittext(name,".") // should we do a splittext_char?  I doubt we really need unicode in network names

// finds OR creates a network from a simple string like "SS13.ATMOS.AIRALRM", runtimes if error
/datum/controller/subsystem/networks/proc/create_network_simple(network_id)
	var/datum/ntnet/network = networks[network_id]
	if(network)
		return network // don't worry about it	if(network_id in networks)

#ifdef DEBUG_NETWORKS
	if(!verify_network_name(network_id))
		to_chat(world, "create_network_simple: [network_id] IS INVALID")
		return null
#endif
	var/list/network_tree = network_string_to_list(network_id)
	ASSERT(network_tree.len > 0)
	var/network_name_part = ""
	var/datum/ntnet/parent = null
	var/start = FALSE
	for(var/i in 1 to network_tree.len)
		if(start)
			network_name_part += "."
		if(!network_tree[i])
			continue
		start = TRUE
		network_name_part += network_tree[i]

		network = networks[network_name_part]
		if(!network)
			network = new(network_name_part, parent)
		parent = network
	to_chat(world, "create_network_simple:  created final [network.network_id]")
	return network // and we are done!


// This will create OR find a network.  This is a heavy function as it can handle something like create_network("BASENETWORK", "ATMOS.AIRALARM", "AREA3")
// or even network tree lists (at a latter date).  you should use create_network_simple to check for networks that are already on
// a network_id but if your building from a raw user string use this
/datum/controller/subsystem/networks/proc/create_network(...)
	var/list/network_tree = list()
	for(var/part in args)
#ifdef DEBUG_NETWORKS
		if(!part || !istext(part))
			log_runtime("create_network: We only take text")
			return null
#endif
		network_tree += network_string_to_list(part)
#ifdef DEBUG_NETWORKS
	var/network_id = network_tree.Join(".")
	to_chat(world, "Trying to create [network_id]")
	var/datum/ntnet/net = create_network_simple(network_id)
	if(!net)
		log_runtime("create_network: Network create Failed for [network_id]")
	if(net.network_id != network_id)
		log_runtime("create_network: huh? [network_id]")
	return net
#else
	return create_network_simple(network_tree.Join("."))
#endif


/// I think we should do this more like a routable ip address
/datum/controller/subsystem/networks/proc/get_next_HID()
	do
		var/string = md5("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]")
		if(!string)
			log_runtime("Could not generagea m5 hash from address, problem with md5?")
			return		//errored
		. = "[copytext_char(string, 1, 9)]"		//16 ^ 8 possibilities I think.
	while(interfaces_by_hardware_id[.])

