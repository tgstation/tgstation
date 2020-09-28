#define DEBUG_NETWORKS

PROCESSING_SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 1
	stat_tag = "NET"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS

	var/datum/ntnet/station/station_network
	var/list/network_initialize_queue = list()

	var/list/interfaces_by_hardware_id = list()
	var/list/networks = list()
	// Used with map tags to look up hardware address

/datum/controller/subsystem/processing/stat_entry(msg)
	msg = "[stat_tag]:[length(processing)]"
	return ..()


/datum/controller/subsystem/processing/networks/Initialize()
	station_network = new

	return ..()

/datum/controller/subsystem/processing/networks/fire(resumed = 0)
	// so life sucks.  Can't be in Initialize because Initialize is run async and we must start
	// when everything is built and working.
	if(SSmapping.initialized)
		station_network.register_map_supremecy()
		if(network_initialize_queue.len)
			for(var/datum/component/ntnet_interface/conn in network_initialize_queue)
				if(conn.network) // we really should runtime if there is no network
					SEND_SIGNAL(conn.parent, COMSIG_COMPONENT_NTNET_JOIN_NETWORK, conn.network)
			network_initialize_queue.Cut()
		flags |= SS_NO_FIRE // never have to run again yea!
	else
		to_chat(world, "Holly fuck those maps take a while to load")


// verifies the network name has the right letters in it.  Might need to expand unwanted punctuations

/datum/controller/subsystem/processing/networks/proc/verify_network_name(name)
	return istext(name) && length(name) > 0 && name[1] != "." && name[length(name)] != "."&& findtext(name,"\[ \n-;:\]*") == 0


// create a network name from a list containing the network tree
/datum/controller/subsystem/processing/networks/proc/network_list_to_string(list/tree)
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
/datum/controller/subsystem/processing/networks/proc/network_string_to_list(name)
#ifdef DEBUG_NETWORKS
	if(!verify_network_name(name))
		log_runtime("network_string_to_list: [name] IS INVALID")
#endif
	return splittext(name,".") // should we do a splittext_char?  I doubt we really need unicode in network names

// finds OR creates a network from a simple string like "SS13.ATMOS.AIRALRM", runtimes if error
/datum/controller/subsystem/processing/networks/proc/create_network_simple(network_id)
	var/datum/ntnet/network = networks[network_id]
	if(network)
		return network // don't worry about it	if(network_id in networks)

#ifdef DEBUG_NETWORKS
	if(!verify_network_name(network_id))
		log_runtime("create_network_simple: [network_id] IS INVALID")
		return null
#endif
	var/list/network_tree = network_string_to_list(network_id)
	ASSERT(network_tree.len > 0)
	var/network_name_part = ""
	var/datum/ntnet/parent = null

	for(var/i in 1 to network_tree.len)
		if(i!=1)
			network_name_part += "."
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
/datum/controller/subsystem/processing/networks/proc/create_network(...)
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
/datum/controller/subsystem/processing/networks/proc/get_next_HID()
	do
		var/string = md5("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]")
		if(!string)
			log_runtime("Could not generagea m5 hash from address, problem with md5?")
			return		//errored
		. = "[copytext_char(string, 1, 9)]"		//16 ^ 8 possibilities I think.
	while(interfaces_by_hardware_id[.])
	interfaces_by_hardware_id[.] = TRUE


