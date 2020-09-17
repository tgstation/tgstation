PROCESSING_SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 1
	stat_tag = "NET"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS

	// This is a tree network.  These are the trunks
	var/datum/ntnet/station/station_network

	var/list/interfaces_by_hardware_id = list()

/datum/controller/subsystem/processing/networks/Initialize()
	station_network = new

	station_network.register_map_supremecy()
	. = ..()

/datum/controller/subsystem/processing/networks/proc/register_network(network_id, network_parent=null)
	var/datum/ntnet/net = station_network.networks[network_id]
	if(net)
		return net 		// if the net exists, just return
	// net dosn't exist, lets create it
	if(!network_parent)
		net = station_network.create_or_find_domain(network_id)	// default to the roote network
	else if(istext(network_parent))
		net = station_network.networks[network_parent]
		if(!net)	// the parrent dosn't exist, this is an error as it shoul assume you wanted to make the parrent of the main station network
			net = station_network.create_or_find_domain(network_parent)
			log_network("Network created for [network_parent] does not exist, creating [network_parent] off station network")
		net = net.create_or_find_domain(network_id)
		log_network("Network '[network_id]'")
	else
		log_runtime("No network created and not sure why?")
	return net



/// I think we should do this more like a routable ip address
/datum/controller/subsystem/processing/networks/proc/get_next_HID()
	// lets get rid of recursion
	var/static/list/collision_check = list()
	do
		var/string = md5("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]")
		if(!string)
			log_runtime("Could not generagea m5 hash from address, problem with md5?")
			return		//errored
		. = "[copytext_char(string, 1, 9)]"		//16 ^ 8 possibilities I think.
	while(collision_check[.])
	collision_check[.] = TRUE


/datum/controller/subsystem/processing/networks/proc/register_interface(datum/component/ntnet_interface/interface, network_id, network_root=null)
		interface.hardware_id = "[get_next_HID()]"
		interfaces_by_hardware_id[interface.hardware_id] = interface
		var/datum/ntnet/net = register_network(network_id, network_root)	// default to station
		net.interface_connect(interface)

/datum/controller/subsystem/processing/networks/proc/unregister_interface(datum/component/ntnet_interface/interface)
		interface.network.interface_disconnect(interface)
		interfaces_by_hardware_id.Remove(interface.hardware_id)



