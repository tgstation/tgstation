PROCESSING_SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 1
	stat_tag = "NET"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS

	var/datum/ntnet/station/station_network

	var/list/interfaces_by_hardware_id = list()
	var/list/networks = list()
	// Used with map tags to look up hardware address
	var/list/network_tag_to_hardware_id = list()

/datum/controller/subsystem/processing/networks/Initialize()
	station_network = new
	station_network.register_map_supremecy()
	// lets regester some basic networks
	create_network_from_string(NETWORK_ATMOS)
	create_network_from_string(NETWORK_ATMOS_AIRALARMS)
	create_network_from_string(NETWORK_ATMOS_SCUBBERS)
	create_network_from_string(NETWORK_ATMOS_ALARMS)
	create_network_from_string(NETWORK_ATMOS_CONTROL)
	create_network_from_string(NETWORK_TOOLS)
	create_network_from_string(NETWORK_TOOLS_REMOTES)
	create_network_from_string(NETWORK_AIRLOCKS)
	. = ..()

/datum/controller/subsystem/processing/networks/proc/create_network_tree_string(datum/ntnet/net)
	var/list/queue = list()
	while(net)
		queue += net.network_id
		net = net.parent
	return queue.Join(".")

/datum/controller/subsystem/processing/networks/proc/create_network_from_string(network_name, datum/ntnet/root = null)
	return create_network(splittext_char(network_name,"."), root)

/datum/controller/subsystem/processing/networks/proc/create_network(list/tree, datum/ntnet/root = null)
	var/datum/ntnet/net = root || station_network
	for(var/i in tree.len)
		var/network_id  = tree[i]
		if(!net.children[network_id])
			net.children[network_id] = new/datum/ntnet(network_id)
		net = net.children[network_id]
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


