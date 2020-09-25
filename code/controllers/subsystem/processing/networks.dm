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
	var/list/network_tag_to_hardware_id = list()

/datum/controller/subsystem/processing/networks/Initialize()
	station_network = new
	station_network.register_map_supremecy()
	for(var/atom/V in init_interface_queue)
		V.AddComponent(/datum/component/ntnet_interface, V.network_id, V.network_tag)
		V.NetworkInitialize()
	init_interface_queue = null // kill the refrences
	return ..()

/datum/controller/subsystem/processing/networks/proc/fire(resumed = 0)
	// so life sucks.  Can't be in Initialize because Initialize is run async and we must start
	// when everything is built and working.
	if(SSmapping.initialized)
		if(network_initialize_queue.len)
			for(var/datum/component/ntnet_interface/conn in network_initialize_queue)
				if(conn.network) // we really should runtime if there is no network
					SEND_SIGNAL(conn.parent, COMSIG_COMPONENT_NTNET_JOIN_NETWORK, conn.network)
			network_initialize_queue.Cut()
		flags |= SS_NO_FIRE // never have to run again yea!
	else
		to_chat(world, "Holly fuck those maps take a while to load")



/datum/controller/subsystem/processing/networks/proc/create_network_tree_string(datum/ntnet/net)
	var/list/queue = list()
	while(net)
		queue += net.network_id
		net = net.parent
	var/network_tree = ""
	while(queue.len)
		network_tree += queue[queue.len--]
		if(queue.len)
			network_tree += "."
	return network_tree

/datum/controller/subsystem/processing/networks/proc/create_network_from_string(network_name, datum/ntnet/root = null)
	to_chat(world, "Creating netowok [network_name]")
	return create_network(splittext_char(network_name,"."), root)

/datum/controller/subsystem/processing/networks/proc/create_network(list/tree, datum/ntnet/root = null)
	var/datum/ntnet/net = root ? root : station_network
	for(var/i in tree.len)
		var/network_id = tree[i]
		net = net.find_child(network_id, TRUE)

	to_chat(world, "Finished Creating netowok [net.network_tree]")
	return net


/datum/controller/subsystem/processing/networks/proc/find_network(network_id)
	if(istext(network_id))
		return networks[network_id] // if we get text and the network exists, skip the search
	var/list/net_tree = istext(network_id) ? splittext_char(network_id,".") : network_id
	if(!length(net_tree))
		return null
	var/datum/ntnet/net = station_network
	for(var/i in 1 to net_tree.len)
		var/net_name = net_tree[i]
		if(!net.children[net_name])
			return null // network dosn't exist
		net = net.children[net_name]
	return net // and here it is


// collect all interfaces as well as children.  It looks wonky to stop recursion
/datum/controller/subsystem/processing/networks/proc/collect_interfaces(network_id)
	. = list()
	var/list/datum/ntnet/queue = list(find_network(network_id))
	while(queue.len)
		var/datum/ntnet/net = queue[queue.len--]
		if(length(net.children))
			for(var/net_id in net.children)
				queue += networks[net_id]
		. += net.linked_devices


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


