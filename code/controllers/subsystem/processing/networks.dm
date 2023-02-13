SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 5
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS

	/// all interfaces by their hardware address.
	/// Do NOT use to verify a reciver_id is valid, use the network.root_devices for that
	var/list/interfaces_by_hardware_id = list()

	/// List of networks using their fully qualified network name.  Used for quick lookups
	/// of networks for sending packets
	var/list/networks = list()
	/// List of the root networks starting at their root names.  Used to find and/or build
	/// network tress
	var/list/root_networks = list()

	// Why not list?  Because its a Copy() every time we add a packet, and thats stupid.
	var/datum/netdata/first = null // start of the queue.  Pulled off in fire.
	var/datum/netdata/last = null // end of the queue.  pushed on by transmit
	var/packet_count = 0
	// packet stats
	var/count_broadcasts_packets = 0 // count of broadcast packets sent
	var/count_failed_packets = 0 // count of message fails
	// Logs moved here
	// Amount of logs the system tries to keep in memory. Keep below 999 to prevent byond from acting weirdly.
	// High values make displaying logs much laggier.
	var/setting_maxlogcount = 100
	var/list/logs = list()

	/// Random name search to make sure we have unique names.
	/// DO NOT REMOVE NAMES HERE UNLESS YOU KNOW WHAT YOUR DOING
	var/list/used_names = list()


/// You shouldn't need to do this.  But mapping is async and there is no guarantee that Initialize
/// will run before these networks are dynamically created.  So its here.
/datum/controller/subsystem/networks/PreInit()
	/// Limbo network needs to be made at boot up for all error devices
	new/datum/ntnet(LIMBO_NETWORK_ROOT)
	new/datum/ntnet(STATION_NETWORK_ROOT)
	new/datum/ntnet(SYNDICATE_NETWORK_ROOT)
	/// As well as the station network incase something funny goes during startup
	new/datum/ntnet(CENTCOM_NETWORK_ROOT)


/datum/controller/subsystem/networks/stat_entry(msg)
	msg = "NET: QUEUE([packet_count]) FAILS([count_failed_packets]) BROADCAST([count_broadcasts_packets])"
	return ..()

/datum/controller/subsystem/networks/Initialize()
	assign_areas_root_ids(get_sorted_areas()) // setup area names before Initialize
	initialized = TRUE
	// Now when the objects Initialize they will join the right network
	return SS_INIT_SUCCESS

/*
 * Process incoming queued packet and return NAK/ACK signals
 *
 * This should only be called when you want the target object to process the NAK/ACK signal, usually
 * during fire.  At this point data.receiver_id has already been converted if it was a broadcast but
 * is undefined in this function.
 * Arguments:
 * * receiver_id - text hardware id for the target device
 * * data - packet to be sent
 */

/datum/controller/subsystem/networks/proc/_process_packet(receiver_id, datum/netdata/data)
	/// Used only for sending NAK/ACK and error reply's
	var/datum/component/ntnet_interface/sending_interface = interfaces_by_hardware_id[data.sender_id]

	/// Check if the network_id is valid and if not send an error and return
	var/datum/ntnet/target_network = networks[data.network_id]
	if(!target_network)
		count_failed_packets++
		add_log("Bad target network '[data.network_id]'", null, data.sender_id)
		if(!QDELETED(sending_interface))
			SEND_SIGNAL(sending_interface.parent, COMSIG_COMPONENT_NTNET_NAK, data , NETWORK_ERROR_BAD_NETWORK)
		return

	/// Check if the receiver_id is in the network.  If not send an error and return
	var/datum/component/ntnet_interface/target_interface = target_network.root_devices[receiver_id]
	if(QDELETED(target_interface))
		count_failed_packets++
		add_log("Bad target device '[receiver_id]'", target_network, data.sender_id)
		if(!QDELETED(sending_interface))
			SEND_SIGNAL(sending_interface.parent, COMSIG_COMPONENT_NTNET_NAK, data,  NETWORK_ERROR_BAD_RECEIVER_ID)
		return

	// Check if we care about permissions.  If we do check if we are allowed the message to be processed
	if(data.passkey) // got to check permissions
		var/obj/O = target_interface.parent
		if(O)
			if(!O.check_access_ntnet(data.passkey))
				count_failed_packets++
				add_log("Access denied to ([receiver_id]) from ([data.network_id])", target_network, data.sender_id)
				if(!QDELETED(sending_interface))
					SEND_SIGNAL(sending_interface.parent, COMSIG_COMPONENT_NTNET_NAK, data, NETWORK_ERROR_UNAUTHORIZED)
				return
		else
			add_log("A access key message was sent to a non-device", target_network, data.sender_id)
			if(!QDELETED(sending_interface))
				SEND_SIGNAL(sending_interface.parent, COMSIG_COMPONENT_NTNET_NAK, data, NETWORK_ERROR_UNAUTHORIZED)


	SEND_SIGNAL(target_interface.parent, COMSIG_COMPONENT_NTNET_RECEIVE, data)
	// All is good, send the packet then send an ACK to the sender
	if(!QDELETED(sending_interface))
		SEND_SIGNAL(sending_interface.parent, COMSIG_COMPONENT_NTNET_ACK, data)

/// Helper define to make sure we pop the packet and qdel it
#define POP_PACKET(CURRENT) first = CURRENT.next;  packet_count--; if(!first) { last = null; packet_count = 0; }; qdel(CURRENT);

/datum/controller/subsystem/networks/fire(resumed = 0)
	var/datum/netdata/current
	var/datum/component/ntnet_interface/target_interface
	while(first)
		current = first
		/// Check if we are a list.  If so process the list
		if(islist(current.receiver_id)) // are we a broadcast list
			var/list/receivers = current.receiver_id
			var/receiver_id = receivers[receivers.len] // pop it
			receivers.len--
			_process_packet(receiver_id, current)
			if(receivers.len == 0) // pop it if done
				count_broadcasts_packets++
				POP_PACKET(current)
		else // else set up a broadcast or send a single targete
			// check if we are sending to a network or to a single target
			target_interface = interfaces_by_hardware_id[current.receiver_id]
			if(target_interface) // a single sender id
				_process_packet(current.receiver_id, current) // single target
				POP_PACKET(current)
			else // ok so lets find the network to send it too
				var/datum/ntnet/net = networks[current.network_id] // get the sending network
				net = net?.networks[current.receiver_id] // find the target network to broadcast
				if(net) // we found it
					current.receiver_id = net.collect_interfaces() // make a list of all the sending targets
				else
					// We got an error, the network is bad so send a NAK
					target_interface = interfaces_by_hardware_id[current.sender_id]
					if(!QDELETED(target_interface))
						SEND_SIGNAL(target_interface.parent, COMSIG_COMPONENT_NTNET_NAK, current , NETWORK_ERROR_BAD_NETWORK)
					POP_PACKET(current) // and get rid of it
		if (MC_TICK_CHECK)
			return

#undef POP_PACKET

/*
 * Main function to queue a packet.  As long as we have valid receiver_id and network_id we will take it
 *
 * Main queuing function for any message sent.  if the data.receiver_id is null, then it will be broadcasted
 * error checking is only done during the process this just throws it on the queue.
 * Arguments:
 * * data - packet to be sent
 */
/datum/controller/subsystem/networks/proc/transmit(datum/netdata/data)
	data.next = null // sanity check

	if(!last)
		first = last = data
	else
		last.next = data
		last = data
	packet_count++
	// We do error checking when the packet is sent
	return NETWORK_ERROR_OK

/**
 * Records a message into the station logging system for the network
 *
 * This CAN be read in station by personal so do not use it for game debugging
 * during fire.  At this point data.receiver_id has already been converted if it was a broadcast but
 * is undefined in this function.  It is also dumped to normal logs but remember players can read/intercept
 * these messages
 * Arguments:
 * * log_string - message to log
 * * network - optional, It can be a ntnet or just the text equivalent
 * * hardware_id = optional, text, will look it up and return with the parent.name as well
 */
/datum/controller/subsystem/networks/proc/add_log(log_string, network = null)
	set waitfor = FALSE // so process keeps running
	var/list/log_text = list()
	log_text += "\[[station_time_timestamp()]\]"
	if(network)
		var/datum/ntnet/net = network
		if(!istype(net))
			net = networks[network]
		if(net) // bad network?
			log_text += "{[net.network_id]}"
		else // bad network?
			log_text += "{[network] *BAD*}"

	log_text += "*SYSTEM* - "
	log_text += log_string
	log_string = log_text.Join()

	logs.Add(log_string)
	//log_telecomms("NetLog: [log_string]") // causes runtime on startup humm

	// We have too many logs, remove the oldest entries until we get into the limit
	if(logs.len > setting_maxlogcount)
		logs = logs.Copy(logs.len-setting_maxlogcount,0)

/**
 * Removes all station logs for the current game
 */
/datum/controller/subsystem/networks/proc/purge_logs()
	logs = list()
	add_log("-!- LOGS DELETED BY SYSTEM OPERATOR -!-")

/datum/controller/subsystem/networks/proc/log_data_transfer( datum/netdata/data)
	logs += "[station_time_timestamp()] - [data.generate_netlog()]"
	if(logs.len > setting_maxlogcount)
		logs = logs.Copy(logs.len - setting_maxlogcount, 0)

/**
 * Updates the maximum amount of logs and purges those that go beyond that number
 *
 * Shouldn't been needed to be run by players but maybe admins need it?
 * Arguments:
 * * lognumber - new setting_maxlogcount count
 */
/datum/controller/subsystem/networks/proc/update_max_log_count(lognumber)
	if(!lognumber)
		return FALSE
	// Trim the value if necessary
	lognumber = max(MIN_NTNET_LOGS, min(lognumber, MAX_NTNET_LOGS))
	setting_maxlogcount = lognumber
	add_log("Configuration Updated. Now keeping [setting_maxlogcount] logs in system memory.")



/**
 * Gives an area a root and a network_area_id
 *
 * When a device is added to the network on map load, it needs to know where it is.
 * So that it is added to that ruins/base's network instead of the general station network
 * This way people on the station cannot just hack Charlie's doors and visa versa.  All area's
 * "should" have this information and if not one is created from existing map tags or
 * ruin template id's.  This SHOULD run before the Initialize of a atom, or the root will not
 * be put in the object.area
 *
 * An example on what the area.network_root_id does/
 * Before Init: obj.network_id = "ATMOS.SCRUBBER"  area.network_root_id="SS13_STATION" area.network_area_id = "BRIDGE"
 * After Init: obj.network_id = "SS13_STATION.ATMOS.SCRUBBER" also obj.network_id = "SS13_STATION.AREA.BRIDGE"
 *
 * Arguments:
 * * area - Area to modify the root id.
 * * template - optional, map_template of that area
 */
/datum/controller/subsystem/networks/proc/lookup_area_root_id(area/A, datum/map_template/M=null)
	/// Check if the area is valid and if it doesn't have a network root id.
	if(!istype(A) || A.network_root_id != null)
		return

	/// If we are a ruin or a shuttle, we get our own network
	if(M)
		/// if we have a template, try to get the network id from the template
		if(M.station_id && M.station_id != LIMBO_NETWORK_ROOT) // check if the template specifies it
			A.network_root_id = simple_network_name_fix(M.station_id)
		else if(istype(M, /datum/map_template/shuttle))  // if not, then check if its a shuttle type
			var/datum/map_template/shuttle/T = M // we are a shuttle so use shuttle id
			A.network_root_id = simple_network_name_fix(T.shuttle_id)
		else if(istype(M,/datum/map_template/ruin)) // if not again, check if its a ruin type
			var/datum/map_template/ruin/R = M
			A.network_root_id = simple_network_name_fix(R.id)

	if(!A.network_root_id) // not assigned?  Then lets use some defaults
		// Anything in Centcom is completely isolated
		// Special case for holodecks.
		if(istype(A,/area/station/holodeck))
			A.network_root_id = "HOLODECK" // isolated from the station network
		else if(SSmapping.level_trait(A.z, ZTRAIT_CENTCOM))
			A.network_root_id = CENTCOM_NETWORK_ROOT
		// Otherwise the default is the station
		else
			A.network_root_id = STATION_NETWORK_ROOT

/datum/controller/subsystem/networks/proc/assign_area_network_id(area/A, datum/map_template/M=null)
	if(!istype(A))
		return
	if(!A.network_root_id)
		lookup_area_root_id(A, M)
		// finally  set the network area id, bit copy paste from area Initialize
		// This is done in case we have more than one area type, each area instance has its own network name
	if(!A.network_area_id)
		A.network_area_id = A.network_root_id + ".AREA." + simple_network_name_fix(A.name) // Make the string
		if(!(A.area_flags & UNIQUE_AREA)) // if we aren't a unique area, make sure our name is different
			A.network_area_id = SSnetworks.assign_random_name(5, A.network_area_id + "_") // tack on some garbage incase there are two area types

/datum/controller/subsystem/networks/proc/assign_areas_root_ids(list/areas, datum/map_template/map_template)
	for(var/area/area as anything in areas)
		assign_area_network_id(area, map_template)

/**
 * Converts a list of string's into a full network_id
 *
 * Converts a list of individual branches into a proper network id.  Validates
 * individual parts to make sure they are clean.
 *
 * ex. list("A","B","C") -> A.B.C
 *
 * Arguments:
 * * tree - List of strings
 */
/datum/controller/subsystem/networks/proc/network_list_to_string(list/tree)
#ifdef DEBUG_NETWORKS
	ASSERT(tree && tree.len > 0) // this should be obvious but JUST in case.
	for(var/part in tree)
		if(!verify_network_name(part) || findtext(name,".") != 0) // and no stray dots
			stack_trace("network_list_to_string: Cannot create network with ([part]) of ([tree.Join(".")])")
			break
#endif
	return tree.Join(".")

/**
 * Converts string into a list of network branches
 *
 * Converts a a proper network id into a list of the individual branches
 *
 * ex.  A.B.C -> list("A","B","C")
 *
 * Arguments:
 * * tree - List of strings
 */
/datum/controller/subsystem/networks/proc/network_string_to_list(name)
#ifdef DEBUG_NETWORKS
	if(!verify_network_name(name))
		stack_trace("network_string_to_list: [name] IS INVALID")
#endif
	return splittext(name,".") // should we do a splittext_char?  I doubt we really need unicode in network names


/**
 * Hard creates a network. Helper function for create_network_simple and create_network
 *
 * Hard creates a using a list of branches and returns.  No error checking as it should
 * of been done before this call
 *
 * Arguments:
 * * network_tree - list,text List of branches of network
 */
/datum/controller/subsystem/networks/proc/_hard_create_network(list/network_tree)
	var/network_name_part = network_tree[1]
	var/network_id = network_name_part
	var/datum/ntnet/parent = root_networks[network_name_part]
	var/datum/ntnet/network
	if(!parent) // we have no network root?  Must be mapload of a ruin or such
		parent = new(network_name_part)

	// go up the branches, creating nodes
	for(var/i in 2 to network_tree.len)
		network_name_part = network_tree[i]
		network = parent.children[network_name_part]
		network_id += "." + network_name_part
		if(!network)
			network = new(network_id, network_name_part, parent)

		parent = network
	return network


/**
 * Creates or finds a network anywhere in the world using a fully qualified name
 *
 * This is the simple case finding of a network in the world.  It must take a full
 * qualified network name and it will either return an existing network or build
 * a new one from scratch.  We must be able to create names on the fly as there is
 * no way for the map loader to tell us ahead of time what networks to create or
 * use for any maps or templates.  So this thing will throw silent mapping errors
 * and log them, but will always return a network for something.
 *
 * Arguments:
 * * network_id - text, Fully qualified network name
 */
/datum/controller/subsystem/networks/proc/create_network_simple(network_id)

	var/datum/ntnet/network = networks[network_id]
	if(network != null)
		return network // don't worry about it

	/// Checks to make sure the network is valid.  We log BOTH to mapping and telecoms
	/// so if your checking for network errors you can find it in mapping to (because its their fault!)
	if(!verify_network_name(network_id))
		log_mapping("create_network_simple: [network_id] IS INVALID, replacing with LIMBO")
		log_telecomms("create_network_simple: [network_id] IS INVALID, replacing with LIMBO")
		return networks[LIMBO_NETWORK_ROOT]

	var/list/network_tree = network_string_to_list(network_id)
	if(!network_tree || network_tree.len == 0)
		log_mapping("create_network_simple: [network_id] IS INVALID, replacing with LIMBO")
		log_telecomms("create_network_simple: [network_id] IS INVALID, replacing with LIMBO")
		return networks[LIMBO_NETWORK_ROOT]

	network = _hard_create_network(network_tree)
#ifdef DEBUG_NETWORKS
	if(!network)
		CRASH("NETWORK CANNOT BE NULL")
#endif
	log_telecomms("create_network_simple:  created final [network.network_id]")
	return network // and we are done!


/**
 * Creates or finds a network anywhere in the world using bits of text
 *
 * This works the same as create_network_simple however it allows the addition
 * of qualified network names.  So you can call it with a root_id and a sub
 * network.  However this function WILL return null if it cannot be created
 * so it should be used with error checking is involved.
 *
 * ex. create_network("ROOT_NETWORK", "ATMOS.SCRUBBERS") -> ROOT_NETWORK.ATMOS.SCRUBBERS
 *
 * Arguments:
 * * tree - List of string
 */
/datum/controller/subsystem/networks/proc/create_network(...)
	var/list/network_tree = list()

	for(var/i in 1 to args.len)
		var/part = args[i]
#ifdef DEBUG_NETWORKS
		if(!part || !istext(part))
			/// stack trace here because this is a bad error
			stack_trace("create_network: We only take text on [part] index [i]")
			return null
#endif
		network_tree += network_string_to_list(part)

	var/datum/ntnet/network = _hard_create_network(network_tree)
	log_telecomms("create_network:  created final [network.network_id]")
	return network

/**
 * Generate a hardware id for devices.
 *
 * Creates a 32 bit hardware id for network devices.  This is random so masking
 * the number won't make routing "easier" (Think Ethernet)  It does check if
 * an existing device has the number but will NOT assign it as thats
 * up to the collar
 *
 * Returns (string) The generated name
 */
/datum/controller/subsystem/networks/proc/get_next_HID()
	do
		var/string = md5("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]")
		if(!string)
			log_runtime("Could not generagea m5 hash from address, problem with md5?")
			return //errored
		. = "[copytext_char(string, 1, 9)]" //16 ^ 8 possibilities I think.
	while(interfaces_by_hardware_id[.])

/**
 * Generate a name devices
 *
 * Creates a randomly generated tag or name for devices or anything really
 * it keeps track of a special list that makes sure no name is used more than
 * once
 *
 * args:
 * * len (int)(Optional) Default=5 The length of the name
 * * prefix (string)(Optional) static text in front of the random name
 * * postfix (string)(Optional) static text in back of the random name
 * Returns (string) The generated name
 */
/datum/controller/subsystem/networks/proc/assign_random_name(len=5, prefix="", postfix="")
	var/static/valid_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	var/list/new_name = list()
	var/text
	// machine id's should be fun random chars hinting at a larger world
	do
		new_name.Cut()
		new_name += prefix
		for(var/i = 1 to len)
			new_name += valid_chars[rand(1,length(valid_chars))]
		new_name += postfix
		text = new_name.Join()
	while(used_names[text])
	used_names[text] = TRUE
	return text
